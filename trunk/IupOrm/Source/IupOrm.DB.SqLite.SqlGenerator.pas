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
    class function GenerateSqlSelectForObject(AContext:IioContext): IioQuery; override;
    class function GenerateSqlSelectForList(AContext:IioContext): IioQuery; override;
    class function GenerateSqlInsert(AContext:IioContext): IioQuery; override;
    class function GenerateSqlUpdate(AContext:IioContext): IioQuery; override;
    class function GenerateSqlDelete(AContext:IioContext): IioQuery; override;
    class function GenerateSqlJoinSectionItem(AJoinItem: IioJoinItem): String; override;
  end;

implementation

uses
  System.Classes, IupOrm.DB.Factory, IupOrm.Context.Properties.Interfaces,
  IupOrm.Attributes, IupOrm.Exceptions, System.IOUtils
  ;

{ TioSqlGeneratorSqLite }

class function TioSqlGeneratorSqLite.GenerateSqlDelete(
  AContext: IioContext): IioQuery;
var
  SQL: TStrings;
begin
  Result := nil;
  SQL := TStringList.Create;
  try
    // Compone l'SQL
    SQL.Add('DELETE FROM ' + AContext.GetTable.GetSql);
    SQL.Add(AContext.Where.GetSql);
    // Crea l'oggetto ioQuery
    Result := TioDbFactory.Query(SQL);
  finally
    // Alla fine devo distruggere la StringLIst sulla quale ho costruito la query
    // per non avere un memory leak
    SQL.Free;
  end;
end;

class function TioSqlGeneratorSqLite.GenerateSqlInsert(
  AContext: IioContext): IioQuery;
var
  SQL: TStrings;
  Prop: IioContextProperty;
  Comma: Char;
begin
  Result := nil;
  SQL := TStringList.Create;
  try
    // Compone l'SQL
    SQL.Add('INSERT INTO ' + AContext.GetTable.GetSql);
    SQL.Add('(');
    SQL.Add(AContext.GetProperties.GetSql);
    if AContext.IsClassFromField
      then SQL.Add(',' + AContext.ClassFromField.GetSqlFieldName);
    SQL.Add(') VALUES (');
    // Cicla per comporre i valori
    Comma := ' ';
    for Prop in AContext.GetProperties do
    begin
      // If current property is the ID property then skip its value (always NULL)
      if Prop = AContext.GetProperties.GetIdProperty then begin
        SQL.Add(Comma + 'NULL');
        Comma := ',';
        Continue;
      end;
      // Relation type
      case Prop.GetRelationType of



        // #####BLOB
        // If RelationType = ioRTNone save the current property value normally
        ioRTNone: begin
          if Prop.IsBlob
            then SQL.Add(Comma + ':' + Prop.GetSqlParamName)
            else SQL.Add(Comma + Prop.GetSqlValue(AContext.DataObject));
          Comma := ',';
        end;



        //  NB: First save the related child object (for ID if it's a new child object)
        ioRTBelongsTo: begin
          SQL.Add(Comma + Prop.GetRelationChildObjectID(AContext.DataObject));
          Comma := ',';
        end;
        // else if RelationType = ioRTHasMany then load objects and assign it to the property  (list)
        ioRTHasMany: {Nothing};
      end;
    end;
    if AContext.IsClassFromField
      then SQL.Add(',' + AContext.ClassFromField.GetSqlValue);
    SQL.Add(')');
    // Crea l'oggetto ioQuery
    Result := TioDbFactory.QueryInsert(SQL);



    // #####BLOB
    // If some blob fields exist then load data on the relative parameters
    if AContext.BlobFieldExists then Self.LoadSqlParamsFromContext(Result, AContext);



  finally
    // Alla fine devo distruggere la StringList sulla quale ho costruito la query
    // per non avere un memory leak
    SQL.Free;
  end;
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

class function TioSqlGeneratorSqLite.GenerateSqlSelectForList(
  AContext: IioContext): IioQuery;
var
  SQL: TStrings;
begin
  Result := nil;
  SQL := TStringList.Create;
  try
    // Select
    SQL.Add('SELECT ' + AContext.GetProperties.GetSqlFullQualified);
    if AContext.IsClassFromField
      then SQL.Add(',' + AContext.ClassFromField.GetSqlFieldName);
    // From
    SQL.Add('FROM ' + AContext.GetTable.GetSql);
    // Join
    SQL.Add(AContext.GetJoin.GetSql);
    //Where
    SQL.Add(AContext.Where.GetSqlWithClassFromField(AContext.ClassFromField));
    // GroupBy
    SQL.Add(AContext.GetGroupBySql);
    // Crea l'oggetto ioQuery
    Result := TioDbFactory.Query(SQL);
  finally
    // Alla fine devo distruggere la StringList sulla quale ho costruito la query
    // per non avere un memory leak
//SQL.SaveToFile(TPath.Combine(TPath.GetDocumentsPath, 'sql.sql'));
    SQL.Free;
  end;
end;

class function TioSqlGeneratorSqLite.GenerateSqlSelectForObject(
  AContext: IioContext): IioQuery;
var
  SQL: TStrings;
begin
  Result := nil;
  SQL := TStringList.Create;
  try
    // Select
    SQL.Add('SELECT ' + AContext.GetProperties.GetSqlFullQualified);
    if AContext.IsClassFromField
      then SQL.Add(',' + AContext.ClassFromField.GetSqlFieldName);
    // From
    SQL.Add('FROM ' + AContext.GetTable.GetSql);
    // Join
    SQL.Add(AContext.GetJoin.GetSql);
    // Where
    SQL.Add(AContext.Where.GetSqlWithClassFromField(AContext.ClassFromField));
    // GroupBy
    SQL.Add(AContext.GetGroupBySql);
    // Crea l'oggetto ioQuery
    Result := TioDbFactory.Query(SQL);
  finally
    // Alla fine devo distruggere la StringList sulla quale ho costruito la query
    // per non avere un memory leak
    SQL.Free;
  end;
end;

class function TioSqlGeneratorSqLite.GenerateSqlUpdate(
  AContext: IioContext): IioQuery;
var
  SQL: TStrings;
  Prop: IioContextProperty;
  Comma: Char;
begin
  Result := nil;
  SQL := TStringList.Create;
  try
    // Compone l'SQL
    SQL.Add('UPDATE ' + AContext.GetTable.GetSql + ' SET');
    Comma := ' ';
    for Prop in AContext.GetProperties do
    begin
      // Relation type
      case Prop.GetRelationType of


        // #####BLOB
        // If RelationType = ioRTNone save the current property value normally
        ioRTNone: begin
          if Prop.IsBlob
            then SQL.Add(Comma + Prop.GetSqlFieldName + '=:' +  Prop.GetSqlParamName)
            else SQL.Add(Comma + Prop.GetSqlFieldName + '=' + Prop.GetSqlValue(AContext.DataObject));
          Comma := ',';
        end;



        //  NB: First save the related child object (for ID if it's a new child object)
        ioRTBelongsTo: begin
          SQL.Add(Comma + Prop.GetSqlFieldName + '=' + Prop.GetRelationChildObjectID(AContext.DataObject));
          Comma := ',';
        end;
        // else if RelationType = ioRTHasMany then load objects and assign it to the property  (list)
        ioRTHasMany: {Nothing};
      end;
    end;
    // ClassFromField if enabled
    if AContext.IsClassFromField
      then SQL.Add(',' + AContext.ClassFromField.GetSqlFieldName + '=' + AContext.ClassFromField.GetSqlValue);
    // Where conditions
    SQL.Add(AContext.Where.GetSql);
    // Create ioQuery object
    Result := TioDbFactory.Query(SQL);



    // #####BLOB
    // If some blob fields exist then load data on the relative parameters
    if AContext.BlobFieldExists then Self.LoadSqlParamsFromContext(Result, AContext);



  finally
    // Alla fine devo distruggere la StringList sulla quale ho costruito la query
    // per non avere un memory leak
    SQL.Free;
  end;
end;

class procedure TioSqlGeneratorSqLite.LoadSqlParamsFromContext(AQuery: IioQuery;
  AContext: IioContext);
var
  Prop: IioContextProperty;
begin
  // #####BLOB
  // Load query parameters from context
  for Prop in AContext.GetProperties do
    if Prop.IsBlob then
      AQuery.SaveStreamObjectToSqlParam(Prop.GetValue(AContext.DataObject).AsObject, Prop);
end;

end.
