unit IupOrm.DB.SqLite.SqlGenerator;

interface

uses
  IupOrm.Context.Interfaces,
  IupOrm.DB.Interfaces, IupOrm.Context.Table.Interfaces;

type

  // Classe che si occupa di generare il codice SQL delle varie query
  TioSqlGeneratorSqLite = class(TioSqlGenerator)
  strict protected
    class procedure LoadSqlParamsFromContext(AQuery:IioQuery; AContext:IioContext);
  public
    class procedure GenerateSqlSelect(AQuery:IioQuery; AContext:IioContext); override;
    class procedure GenerateSqlInsert(AQuery:IioQuery; AContext:IioContext); override;
    class procedure GenerateSqlLastInsertRowID(AQuery:IioQuery); override;
    class procedure GenerateSqlUpdate(AQuery:IioQuery; AContext:IioContext); override;
    class procedure GenerateSqlDelete(AQuery:IioQuery; AContext:IioContext); override;
    class procedure GenerateSqlForExists(AQuery:IioQuery; AContext:IioContext); override;
    class function GenerateSqlJoinSectionItem(AJoinItem: IioJoinItem): String; override;
  end;

implementation

uses
  System.Classes, IupOrm.DB.Factory, IupOrm.Context.Properties.Interfaces,
  IupOrm.Attributes, IupOrm.Exceptions, System.IOUtils, IupOrm.CommonTypes
  ;

{ TioSqlGeneratorSqLite }

class procedure TioSqlGeneratorSqLite.GenerateSqlDelete(AQuery:IioQuery; AContext:IioContext);
begin
  // Build the query text
  // -----------------------------------------------------------------
  AQuery.SQL.Add('DELETE FROM ' + AContext.GetTable.GetSql);
  // If a Where exist then the query is an external query else
  //  is an internal query.
  if AContext.WhereExist then
    AQuery.SQL.Add(AContext.Where.GetSql(AContext.GetProperties))
  else
    AQuery.SQL.Add('WHERE ' + AContext.GetProperties.GetIdProperty.GetSqlFieldName + '=:' + AContext.GetProperties.GetIdProperty.GetSqlParamName);
  // -----------------------------------------------------------------
end;

class procedure TioSqlGeneratorSqLite.GenerateSqlForExists(AQuery:IioQuery; AContext: IioContext);
begin
  // Build the query text
  // -----------------------------------------------------------------
  AQuery.SQL.Add('SELECT EXISTS(SELECT * FROM '
    + AContext.GetTable.GetSql
    + ' WHERE '
    + AContext.GetProperties.GetIdProperty.GetSqlQualifiedFieldName + '=:' + AContext.GetProperties.GetIdProperty.GetSqlParamName
    + ')'
  );
  // -----------------------------------------------------------------
end;

class procedure TioSqlGeneratorSqLite.GenerateSqlInsert(AQuery:IioQuery; AContext: IioContext);
var
  Comma: Char;
  Prop: IioContextProperty;
begin
  // Build the query text
  // -----------------------------------------------------------------
  AQuery.SQL.Add('INSERT INTO ' + AContext.GetTable.GetSql);
  AQuery.SQL.Add('(');
  AQuery.SQL.Add(AContext.GetProperties.GetSql(ioInsert));
  // Add the ClassFromField if enabled
  if AContext.IsClassFromField
    then AQuery.SQL.Add(',' + AContext.ClassFromField.GetSqlFieldName);
  // -----------------------------------------------------------------
  AQuery.SQL.Add(') VALUES (');
  // -----------------------------------------------------------------
  // Iterate for all properties
  Comma := ' ';
  for Prop in AContext.GetProperties do
  begin
    // If the current property is ReadOnly then skip it
    // If the current property RelationType is HasMany then skip it
    if (not Prop.IsSqlRequestCompliant(ioInsert))
    or (Prop.GetRelationType = ioRTHasMany)
    then Continue;
    // Add the field param
    AQuery.SQL.Add(Comma + ':' + Prop.GetSqlParamName);
    Comma := ',';
  end;
  // Add the ClassFromField if enabled
  if AContext.IsClassFromField
  then AQuery.SQL.Add(',:' + AContext.ClassFromField.GetSqlParamName);
  AQuery.SQL.Add(')');
  // -----------------------------------------------------------------
end;

class function TioSqlGeneratorSqLite.GenerateSqlJoinSectionItem(
  AJoinItem: IioJoinItem): String;
begin
  // Join
  case AJoinItem.GetJoinType of
    ioCross:      Result := 'CROSS JOIN ';
    ioInner:      Result := 'INNER JOIN ';
    ioLeftOuter:  Result := 'LEFT OUTER JOIN ';
    ioRightOuter: Result := 'RIGHT OUTER JOIN ';
    ioFullOuter:  Result := 'FULL OUTER JOIN ';
    else raise EIupOrmException.Create(Self.ClassName + ': Join type not valid.');
  end;
  // Joined table name
  Result := Result + '[' + AJoinItem.GetJoinClassRef.ClassName + ']';
  // Conditions
  if AJoinItem.GetJoinType <> ioCross
    then Result := Result + ' ON (' + AJoinItem.GetJoinCondition + ')';
end;

class procedure TioSqlGeneratorSqLite.GenerateSqlLastInsertRowID(AQuery:IioQuery);
begin
  // Build the query text
  AQuery.SQL.Add('SELECT last_insert_rowid()');
end;

class procedure TioSqlGeneratorSqLite.GenerateSqlSelect(AQuery:IioQuery; AContext:IioContext);
begin
  // Build the query text
  // -----------------------------------------------------------------
  AQuery.SQL.Add('SELECT ' + AContext.GetProperties.GetSql(ioSelect));
  if AContext.IsClassFromField
    then AQuery.SQL.Add(',' + AContext.ClassFromField.GetSqlFieldName);
  // From
  AQuery.SQL.Add('FROM ' + AContext.GetTable.GetSql);
  // Join
  AQuery.SQL.Add(AContext.GetJoin.GetSql);
  // If a Where exist then the query is an external query else
  //  is an internal query.
  if AContext.WhereExist then
    AQuery.SQL.Add(AContext.Where.GetSqlWithClassFromField(AContext.GetProperties, AContext.IsClassFromField, AContext.ClassFromField))
  else
    AQuery.SQL.Add('WHERE ' + AContext.GetProperties.GetIdProperty.GetSqlFieldName + '=:' + AContext.GetProperties.GetIdProperty.GetSqlParamName);
  // GroupBy
  AQuery.SQL.Add(AContext.GetGroupBySql);
  // -----------------------------------------------------------------
end;

class procedure TioSqlGeneratorSqLite.GenerateSqlUpdate(AQuery:IioQuery; AContext:IioContext);
var
  Comma: Char;
  Prop: IioContextProperty;
begin
  // Build the query text
  // -----------------------------------------------------------------
  AQuery.SQL.Add('UPDATE ' + AContext.GetTable.GetSql + ' SET');
  // Iterate for all properties
  Comma := ' ';
  for Prop in AContext.GetProperties do
  begin
    // If the current property is ReadOnly then skip it
    // If the current property RelationType is HasMany then skip it
    if (not Prop.IsSqlRequestCompliant(ioInsert))
    or (Prop.GetRelationType = ioRTHasMany)
    then Continue;
    // Add the field param
    AQuery.SQL.Add(Comma + Prop.GetSqlFieldName + '=:' + Prop.GetSqlParamName);
    Comma := ',';
  end;
  // Add the ClassFromField if enabled
  if AContext.IsClassFromField
  then AQuery.SQL.Add(',' + AContext.ClassFromField.GetSqlFieldName + '=:' + AContext.ClassFromField.GetSqlParamName);
  // Where conditions
//  AQuery.SQL.Add(AContext.Where.GetSql);
  AQuery.SQL.Add('WHERE ' + AContext.GetProperties.GetIdProperty.GetSqlFieldName + '=:' + AContext.GetProperties.GetIdProperty.GetSqlParamName);
  // -----------------------------------------------------------------
end;

class procedure TioSqlGeneratorSqLite.LoadSqlParamsFromContext(AQuery: IioQuery;
  AContext: IioContext);
var
  Prop: IioContextProperty;
begin
  // Load query parameters from context
  for Prop in AContext.GetProperties do
    if Prop.IsBlob then
      AQuery.SaveStreamObjectToSqlParam(Prop.GetValue(AContext.DataObject).AsObject, Prop);
end;

end.
