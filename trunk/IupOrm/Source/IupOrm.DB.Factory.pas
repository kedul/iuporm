unit IupOrm.DB.Factory;

interface

uses
  IupOrm.Where.SqlItems.Interfaces,
  IupOrm.ObjectsForge.Interfaces,
  IupOrm.DB.Interfaces,
  System.Classes,
  System.Rtti, IupOrm.DB.ConnectionContainer, IupOrm.CommonTypes,
  IupOrm.Context.Interfaces, IupOrm.Context.Properties.Interfaces,
  IupOrm.DB.QueryEngine;

type

  TioDbFactory = class
  public
    class function WhereItemProperty(APropertyName:String): IioSqlItemWhere;
    class function WhereItemPropertyOID: IioSqlItemWhere;
    class function WhereItemTValue(AValue:TValue): IioSqlItemWhere;
    class function WhereItemPropertyEqualsTo(APropertyName:String; AValue:TValue): IioSqlItemWhere;
    class function WhereItemPropertyOIDEqualsTo(AValue:TValue): IioSqlItemWhere;
    class function CompareOperator: TioCompareOperatorRef;
    class function LogicRelation: TioLogicRelationRef;
    class function SqlGenerator: TioSqlGeneratorRef;
    class function SqlDataConverter: TioSqlDataConverterRef;
    class function Connection(AConnectionName:String=''): IioConnection;
    class function NewConnection(AConnectionName:String): IioConnection;
    class function TransactionCollection: IioTransactionCollection;
    class function Query(AConnectionDefName:String; AQueryIdentity:String=''): IioQuery;
    class function ConnectionContainer: TioConnectionContainerRef;
    class function ConnectionManager: TioConnectionManagerRef;
    class function QueryContainer: IioQueryContainer;
    class function QueryEngine: TioQueryEngineRef;
  end;

implementation

uses
  IupOrm.DB.SqLite.CompareOperators, System.IOUtils,
  IupOrm.DB.Connection, IupOrm.DB.SqLite.LogicRelations, IupOrm.DB.Query,
  IupOrm.DB.SqLite.SqlDataConverter, IupOrm.DB.SqLite.SqlGenerator,
  IupOrm.Where.SqlItems, System.SysUtils, IupOrm.DB.QueryContainer,
  IupOrm.DB.TransactionCollection;

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
  DBPath := ExtractFilePath(   Self.ConnectionManager.GetConnectionDefByName(AConnectionName).Params.Values['Database']   );
  if not TDirectory.Exists(DBPath) then TDirectory.CreateDirectory(DBPath);
  // Open the connection
  LConnection.Open;
  // Create the ioConnection and his QueryContainer and return it
  Result := TioConnection.Create(LConnection,   Self.QueryContainer   );
end;

class function TioDbFactory.QueryContainer: IioQueryContainer;
begin
  Result := TioQueryContainer.Create;
end;

class function TioDbFactory.QueryEngine: TioQueryEngineRef;
begin
  Result := TioQueryEngine;
end;

class function TioDbFactory.Query(AConnectionDefName:String; AQueryIdentity:String=''): IioQuery;
var
  AConnection: IioConnection;
begin
  // Get the proper connection
  AConnection := Self.Connection(AConnectionDefName);
  // Else if the query is already present in the QueryContainer of the connection then
  //  get it and return
  if AConnection.QueryContainer.Exist(AQueryIdentity) then
    Exit(   AConnection.QueryContainer.GetQuery(AQueryIdentity)   );
  // Else create a new query and insert it in the QueryContainer of the connection
  //  for future use if AConnectionDefName is valid (used by DBCreator)
  Result := TioQuery.Create(AConnection, TioInternalSqlQuery.Create(nil));
  if not AConnectionDefName.IsEmpty then
    AConnection.QueryContainer.AddQuery(AQueryIdentity, Result);
end;

class function TioDbFactory.SqlDataConverter: TioSqlDataConverterRef;
begin
  Result := TioSqlDataConverterSqLite;
end;

class function TioDbFactory.SqlGenerator: TioSqlGeneratorRef;
begin
  Result := TioSqlGeneratorSqLite;
end;

class function TioDbFactory.TransactionCollection: IioTransactionCollection;
begin
  Result := TioTransactionCollection.Create;
end;

class function TioDbFactory.WhereItemProperty(APropertyName:String): IioSqlItemWhere;
begin
  Result := TioSqlItemsWhereProperty.Create(APropertyName);
end;

class function TioDbFactory.WhereItemPropertyEqualsTo(APropertyName: String; AValue: TValue): IioSqlItemWhere;
begin
  Result := TioSqlItemsWherePropertyEqualsTo.Create(APropertyName, AValue);
end;

class function TioDbFactory.WhereItemPropertyOID: IioSqlItemWhere;
begin
  Result := TioSqlItemsWherePropertyOID.Create;
end;

class function TioDbFactory.WhereItemPropertyOIDEqualsTo(AValue: TValue): IioSqlItemWhere;
begin
  Result := TioSqlItemsWherePropertyOIDEqualsTo.Create(AValue);
end;

class function TioDbFactory.WhereItemTValue(AValue: TValue): IioSqlItemWhere;
begin
  Result := TioSqlItemsWhereTValue.Create(AValue);
end;


end.
