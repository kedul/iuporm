unit IupOrm.DB.Factory;

interface

uses
  IupOrm.Where.SqlItems.Interfaces,
  IupOrm.ObjectsForge.Interfaces,
  IupOrm.DB.Interfaces,
  System.Classes,
  System.Rtti, IupOrm.DB.ConnectionContainer, IupOrm.CommonTypes;

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
    class function Connection(AConnectionName:String=''): IioConnection;
    class function NewConnection(AConnectionName:String): IioConnection;
    class function Query(AConnectionName:String; SQL:TStrings): IioQuery;
    class function QueryInsert(AConnectionName:String; SQL:TStrings): IioQuery;
    class function ConnectionContainer: TioConnectionContainerRef;
    class function ConnectionManager: TioConnectionManagerRef;
  end;

implementation

uses
  IupOrm.DB.SqLite.CompareOperators, System.IOUtils,
  IupOrm.DB.Connection, IupOrm.DB.SqLite.LogicRelations, IupOrm.DB.Query,
  IupOrm.DB.SqLite.SqlDataConverter, IupOrm.DB.SqLite.SqlGenerator,
  IupOrm.Where.SqlItems, System.SysUtils;

{ TioDbBuilder }

class function TioDbFactory.CompareOperator: TioCompareOperatorRef;
begin
  Result := TioCompareOperatorSqLite;
end;

class function TioDbFactory.Connection(AConnectionName:String): IioConnection;
begin
  // If AConnectionName param is not specified (is empty) then
  //  use the default connection def
  if AConnectionName = '' then AConnectionName := Self.ConnectionManager.GetDefaultConnectionName;
  // If the connection already exists in the COnnectionContainer then return then else
  //  create a new connection, add it to the COnnectionContainer thne return the connection
  //  itself to the caller code
  if not Self.ConnectionContainer.ConnectionExist(AConnectionName)
    then Self.ConnectionContainer.AddConnection(Self.NewConnection(AConnectionName));
  Result := Self.ConnectionContainer.GetConnection(AConnectionName);
end;

class function TioDbFactory.ConnectionContainer: TioConnectionContainerRef;
begin
  Result := TioConnectionContainer;
end;

class function TioDbFactory.ConnectionManager: TioConnectionManagerRef;
begin
  Result := TioConnectionManager;
end;

class function TioDbFactory.LogicRelation: TioLogicRelationRef;
begin
  Result := TioLogicRelationSqLite;
end;

class function TioDbFactory.NewConnection(AConnectionName:String): IioConnection;
var
  DBPath: String;
  LConnection: TioInternalSqlConnection;
begin
  // Create the internal connection
  LConnection := TioInternalSqlConnection.Create(nil);
  // Load and set the connection parameters (from the connection manager)
  LConnection.ConnectionDefName := AConnectionName;
  // Extract the file path anche create the directory if not exists
  DBPath := ExtractFilePath(   Self.ConnectionManager.GetConnectionDefByName(AConnectionName).Database   );
  if not TDirectory.Exists(DBPath) then TDirectory.CreateDirectory(DBPath);
  // Open the connection
  LConnection.Open;
  // Create the ioConnection and retorn
  Result := TioConnection.Create(LConnection);
end;

class function TioDbFactory.Query(AConnectionName:String; SQL: TStrings): IioQuery;
var
  NewQry: TioInternalSqlQuery;
begin
  NewQry := TioInternalSqlQuery.Create(nil);
  try
    if Assigned(SQL) then NewQry.SQL.AddStrings(SQL);
    Result := TioQuery.Create(Self.Connection(AConnectionName), NewQry);
  except
    NewQry.Free;
  end;
end;

class function TioDbFactory.QueryInsert(AConnectionName:String; SQL: TStrings): IioQuery;
var
  NewQry: TioInternalSqlQuery;
begin
  NewQry := TioInternalSqlQuery.Create(nil);
  try
    NewQry.SQL.AddStrings(SQL);
    Result := TioQueryInsert.Create(Self.Connection(AConnectionName), NewQry, 'SELECT last_insert_rowid()');
  except
    NewQry.Free;
  end;
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
