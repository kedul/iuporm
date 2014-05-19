unit IupOrm.DB.Factory;

interface

uses
  IupOrm.Where.SqlItems.Interfaces,
  IupOrm.ObjectsForge.Interfaces,
  IupOrm.DB.Interfaces,
  System.Classes,
  System.Rtti;

type

  TioDbFactory = class
  public
    class function WhereItemProperty(APropertyName:String): IioSqlItemWhere;
    class function WhereItemPropertyOID: IioSqlItemWhere;
    class function WhereItemTValue(AValue:TValue): IioSqlItemWhere;
    class function CompareOperator: TioCompareOperatorRef;
    class function LogicRelation: TioLogicRelationRef;
    class function SqlGenerator: TioSqlGeneratorRef;
    class function SqlDataConverter: TioSqlDataConverterRef;
    class function Connection: IioConnection;
    class function NewConnection: IioConnection;
    class function Query(SQL:TStrings): IioQuery;
    class function QueryInsert(SQL:TStrings): IioQuery;
    class procedure SetDBFolder(AFolderName: String);
  end;

implementation

uses
  IupOrm.DB.SqLite.CompareOperators, Data.SqlExpr, System.IOUtils,
  IupOrm.DB.Connection, IupOrm.DB.SqLite.LogicRelations, IupOrm.DB.Query,
  IupOrm.DB.SqLite.SqlDataConverter, IupOrm.DB.SqLite.SqlGenerator,
  IupOrm.Where.SqlItems;

var
  ioDBFolder: String;
  ioDBConnection: IioConnection;

{ TioDbBuilder }

class function TioDbFactory.CompareOperator: TioCompareOperatorRef;
begin
  Result := TioCompareOperatorSqLite;
end;

class function TioDbFactory.Connection: IioConnection;
begin
  if not Assigned(ioDBConnection) then TioDBFactory.NewConnection;
  Result := ioDBConnection;
end;

class function TioDbFactory.LogicRelation: TioLogicRelationRef;
begin
  Result := TioLogicRelationSqLite;
end;

class function TioDbFactory.NewConnection: IioConnection;
var
  DBFileNameFull: String;
  LConnection: TSqlConnection;
begin
  // Crea la cartella del DB se non c'è
  if not TDirectory.Exists(ioDBFolder)
    then TDirectory.CreateDirectory(ioDBFolder);
  // Compone il nome completo del file database
{$IFDEF IOS}
  DBFileNameFull := TPath.Combine(ioDBFolder, 'db.db');
{$ELSE}
  DBFileNameFull := TPath.Combine(ioDBFolder, 'db.db');
{$ENDIF}
  // Crea la connessione al DB
  LConnection := TSQLConnection.Create(nil);
  LConnection.DriverName := 'SQLite';
  LConnection.LoginPrompt := False;
  LConnection.Params.Values['FailIfMissing'] := 'False';
  LConnection.Params.Values['HostName'] := 'localhost';
  LConnection.Params.Values['Database'] := DBFileNameFull;
  LConnection.Open;
  // Crea la ioCOnnection da ritornare, la assegna alla variabile globale
  //  e richiama se stessa
  ioDBConnection := TioConnection.Create(LConnection);
end;

class function TioDbFactory.Query(SQL: TStrings): IioQuery;
var
  NewQry: TSQLQuery;
begin
  NewQry := TSqlQuery.Create(nil);
  try
    if Assigned(SQL) then NewQry.SQL.AddStrings(SQL);
    Result := TioQuery.Create(Self.Connection, NewQry);
  except
    NewQry.Free;
  end;
end;

class function TioDbFactory.QueryInsert(SQL: TStrings): IioQuery;
var
  NewQry: TSQLQuery;
begin
  NewQry := TSqlQuery.Create(nil);
  try
    NewQry.SQL.AddStrings(SQL);
    Result := TioQueryInsert.Create(Self.Connection, NewQry, 'SELECT last_insert_rowid()');
  except
    NewQry.Free;
  end;
end;

class procedure TioDbFactory.SetDBFolder(AFolderName: String);
begin
  ioDBFolder := TPath.Combine(TPath.GetDocumentsPath, AFolderName);
end;

class function TioDbFactory.SqlDataConverter: TioSqlDataConverterRef;
begin
  Result := TioSqlDataConverterSqLite;
end;

class function TioDbFactory.SqlGenerator: TioSqlGeneratorRef;
begin
  Result := TioSqlGeneratorSqLite;
end;

class function TioDbFactory.WhereItemProperty(APropertyName:String): IioSqlItemWhere;
begin
  Result := TioSqlItemsWhereProperty.Create(APropertyName);
end;

class function TioDbFactory.WhereItemPropertyOID: IioSqlItemWhere;
begin
  Result := TioSqlItemsWherePropertyOID.Create;
end;

class function TioDbFactory.WhereItemTValue(AValue: TValue): IioSqlItemWhere;
begin
  Result := TioSqlItemsWhereTValue.Create(AValue);
end;


end.
