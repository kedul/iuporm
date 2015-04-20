unit IupOrm.DB.QueryEngine;

interface

uses
  IupOrm.Context.Interfaces, IupOrm.DB.Interfaces, IupOrm.Where;

type

  TioQueryEngineRef = class of TioQueryEngine;

  // INterfaccia per le classi che devono generare i vari tipi di query
  //  Select/Update/Insert/Delete
  TioQueryEngine = class
  protected
    class function ComposeQueryIdentity(AContext:IioContext; APreIdentity:String; AIdentity:String=''): String;
    class procedure FillQueryWhereParams(AContext:IioContext; AQuery:IioQuery);
//    class procedure PersistRelationChildObject(AMasterContext: IioContext;
//      AMasterProperty: IioContextProperty);
  public
    class function GetQuerySelectForObject(AContext:IioContext): IioQuery;
    class function GetQuerySelectForList(AContext:IioContext): IioQuery;
    class function GetQueryInsert(AContext:IioContext): IioQuery;
    class function GetQueryLastInsertRowID(AContext:IioContext): IioQuery;
    class function GetQueryUpdate(AContext:IioContext): IioQuery;
    class function GetQueryDelete(AContext:IioContext): IioQuery;
    class function GetQueryForExists(AContext:IioContext): IioQuery;
  end;

implementation

uses
  IupOrm.DB.Factory, IupOrm.Context.Properties.Interfaces, IupOrm.CommonTypes,
  IupOrm.Attributes, Data.DB, IupOrm.Interfaces, SysUtils,
  IupOrm.Where.SqlItems.Interfaces;

{ TioQueryEngine }

class function TioQueryEngine.ComposeQueryIdentity(AContext: IioContext; APreIdentity:String; AIdentity:String=''): String;
begin
  Result := AContext.GetClassRef.QualifiedClassName + ':' + APreIdentity + ':' + AIdentity;
end;

class function TioQueryEngine.GetQueryDelete(AContext: IioContext): IioQuery;
var
  AQuery: IioQuery;
begin
  // Get the query object and if does not contain an SQL text (come from QueryContainer)
  //  then call the sql query generator
  AQuery := TioDbFactory.Query(AContext.GetTable.GetConnectionDefName, ComposeQueryIdentity(AContext, 'DEL'));
  Result := AQuery;
  if AQuery.IsSqlEmpty then TioDBFactory.SqlGenerator.GenerateSqlDelete(AQuery, AContext);
  // If a Where exist then the query is an external query else
  //  is an internal query.
  if AContext.WhereExist then
    Self.FillQueryWhereParams(AContext, AQuery)
  else
    AQuery.ParamByProp(AContext.GetProperties.GetIdProperty).Value := AContext.GetProperties.GetIdProperty.GetValue(AContext.DataObject).AsVariant;
end;

class procedure TioQueryEngine.FillQueryWhereParams(AContext:IioContext; AQuery: IioQuery);
var
  ASqlItem: IioSqlItem;
  ASqlItemWhere: IioSqlItemWhere;
begin
  for ASqlItem in AContext.Where.GetWhereItems do
  begin
    if  Supports(ASqlItem, IioSqlItemWhere, ASqlItemWhere)
    and ASqlItemWhere.HasParameter
    then
      AQuery.ParamByName(   ASqlItemWhere.GetSqlParamName(AContext.GetProperties)   ).Value := ASqlItemWhere.GetValue(AContext.GetProperties).AsVariant;
  end;
  if AContext.IsClassFromField then
    AQuery.ParamByName(AContext.ClassFromField.GetSqlParamName).Value := '%'+AContext.ClassFromField.GetClassName+'%';
end;

class function TioQueryEngine.GetQueryForExists(AContext: IioContext): IioQuery;
var
  AQuery: IioQuery;
begin
  // Get the query object and if does not contain an SQL text (come from QueryContainer)
  //  then call the sql query generator
  AQuery := TioDbFactory.Query(AContext.GetTable.GetConnectionDefName, ComposeQueryIdentity(AContext, 'EXIST'));
  Result := AQuery;
  if AQuery.IsSqlEmpty then TioDBFactory.SqlGenerator.GenerateSqlForExists(AQuery, AContext);
  // If a Where exist then the query is an external query else
  //  is an internal query.
  AQuery.ParamByProp(AContext.GetProperties.GetIdProperty).Value := AContext.GetProperties.GetIdProperty.GetValue(AContext.DataObject).AsVariant;
end;

class function TioQueryEngine.GetQueryInsert(AContext:IioContext): IioQuery;
var
  AProp: IioContextProperty;
  AQuery: IioQuery;
begin
  // Init
  AContext.LastInsertNullID := False;
  // Get the query object and if does not contain an SQL text (come from QueryContainer)
  //  then call the sql query generator
  AQuery := TioDbFactory.Query(AContext.GetTable.GetConnectionDefName, ComposeQueryIdentity(AContext, 'INS'));
  Result := AQuery;
  if AQuery.IsSqlEmpty then TioDBFactory.SqlGenerator.GenerateSqlInsert(AQuery, AContext);
  // Iterate for all properties
  for AProp in AContext.GetProperties do
  begin
    // If the current property is ReadOnly then skip it
    if not AProp.IsSqlRequestCompliant(ioInsert) then Continue;
    // If current property is the ID property and its value is null (0)
    //  then skip its value (always NULL)
    if  AProp.IsID and (AProp.GetValue(AContext.DataObject).AsInteger = IO_INTEGER_NULL_VALUE) then
    begin
      AQuery.SetParamValueToNull(AProp, ftLargeInt);
      AContext.LastInsertNullID := True;
      Continue;
    end;
    // Relation type
    case AProp.GetRelationType of
      // If RelationType = ioRTNone save the current property value normally
      // If RelationType = ioRTEmbedded save the current property value normally (serialization is into the called method
      ioRTNone, ioRTEmbeddedHasMany, ioRTEmbeddedHasOne: AQuery.SetParamValueByContext(AProp, AContext);
      // else if RelationType = ioRTBelongsTo then save the ID
      ioRTBelongsTo: AQuery.ParamByProp(AProp).Value := AProp.GetRelationChildObjectID(AContext.DataObject);
      // else if RelationType = ioRTHasOne
      ioRTHasOne: {Nothing};
      // else if RelationType = ioRTHasMany
      ioRTHasMany: {Nothing};
    end;
  end;
  // Add the ClassFromField value if enabled
  if AContext.IsClassFromField then
    AQuery.ParamByName(AContext.ClassFromField.GetSqlParamName).Value := AContext.ClassFromField.GetValue;
end;

class function TioQueryEngine.GetQueryLastInsertRowID(AContext: IioContext): IioQuery;
begin
  // Get the query object and if does not contain an SQL text (come from QueryContainer)
  //  then call the sql query generator
  Result := TioDbFactory.Query(AContext.GetTable.GetConnectionDefName, ComposeQueryIdentity(AContext, 'LID'));
  if Result.IsSqlEmpty then TioDBFactory.SqlGenerator.GenerateSqlLastInsertRowID(Result);
end;

class function TioQueryEngine.GetQuerySelectForList(AContext: IioContext): IioQuery;
var
  AQuery: IioQuery;
begin
  // Get the query object and if does not contain an SQL text (come from QueryContainer)
  //  then call the sql query generator
  AQuery := TioDbFactory.Query(AContext.GetTable.GetConnectionDefName, ComposeQueryIdentity(AContext, 'SELLST'));
  Result := AQuery;
  if AQuery.IsSqlEmpty then TioDBFactory.SqlGenerator.GenerateSqlSelect(AQuery, AContext);
  // If a Where exist then the query is an external query else
  //  is an internal query.
  if AContext.WhereExist then
    Self.FillQueryWhereParams(AContext, AQuery)
  else
    AQuery.ParamByProp(AContext.GetProperties.GetIdProperty).Value := AContext.GetProperties.GetIdProperty.GetValue(AContext.DataObject).AsVariant;
end;

class function TioQueryEngine.GetQuerySelectForObject(AContext: IioContext): IioQuery;
var
  AQuery: IioQuery;
begin
  // Get the query object and if does not contain an SQL text (come from QueryContainer)
  //  then call the sql query generator
  AQuery := TioDbFactory.Query(AContext.GetTable.GetConnectionDefName, ComposeQueryIdentity(AContext, 'SELOBJ'));
  Result := AQuery;
  if AQuery.IsSqlEmpty then TioDBFactory.SqlGenerator.GenerateSqlSelect(AQuery, AContext);
  // If a Where exist then the query is an external query else
  //  is an internal query.
  if AContext.WhereExist then
    Self.FillQueryWhereParams(AContext, AQuery)
  else
    AQuery.ParamByProp(AContext.GetProperties.GetIdProperty).Value := AContext.GetProperties.GetIdProperty.GetValue(AContext.DataObject).AsVariant;
end;

class function TioQueryEngine.GetQueryUpdate(AContext: IioContext): IioQuery;
var
  AProp: IioContextProperty;
  AQuery: IioQuery;
begin
  // Get the query object and if does not contain an SQL text (come from QueryContainer)
  //  then call the sql query generator
  AQuery := TioDbFactory.Query(AContext.GetTable.GetConnectionDefName, ComposeQueryIdentity(AContext, 'UPD'));
  Result := AQuery;
  if AQuery.IsSqlEmpty then TioDBFactory.SqlGenerator.GenerateSqlUpdate(AQuery, AContext);
  // Iterate for all properties
  for AProp in AContext.GetProperties do
  begin
    // If the current property is ReadOnly then skip it
    if not AProp.IsSqlRequestCompliant(ioUpdate) then Continue;
    // Relation type
    case AProp.GetRelationType of
      // If RelationType = ioRTNone save the current property value normally
      // If RelationType = ioRTEmbedded save the current property value normally (serialization is into the called method
      ioRTNone, ioRTEmbeddedHasMany, ioRTEmbeddedHasOne: AQuery.SetParamValueByContext(AProp, AContext);
      // else if RelationType = ioRTBelongsTo then save the ID
      ioRTBelongsTo: AQuery.ParamByProp(AProp).Value := AProp.GetRelationChildObjectID(AContext.DataObject);
      // else if RelationType = ioRTHasOne
      ioRTHasOne: {Nothing};
      // else if RelationType = ioRTHasMany
      ioRTHasMany: {Nothing};
    end;
  end;
  // Add the ClassFromField value if enabled
  if AContext.IsClassFromField
  then AQuery.ParamByName(AContext.ClassFromField.GetSqlParamName).Value := AContext.ClassFromField.GetValue;
  // Where conditions
  AQuery.ParamByProp(AContext.GetProperties.GetIdProperty).Value := AContext.GetProperties.GetIdProperty.GetValue(AContext.DataObject).AsVariant;
end;

end.
