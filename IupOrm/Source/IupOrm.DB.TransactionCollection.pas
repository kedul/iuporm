unit IupOrm.DB.TransactionCollection;

interface

uses
  IupOrm.DB.Interfaces, IupOrm.Containers.Interfaces;

type

  TioTransactionCollection = class(TInterfacedObject, IioTransactionCollection)
  private
    FTransactionList: IioList<String>;
  protected
    function Exists(AConnectionName:String): Boolean;
  public
    constructor Create;
    procedure StartTransaction(AConnectionName:String='');
    procedure CommitAll;
    procedure RollbackAll;
  end;

implementation

uses
  IupOrm.Containers.Factory, IupOrm.DB.Factory;

{ TioTransactionCollection }

procedure TioTransactionCollection.CommitAll;
var
  AConnectionName: String;
begin
  // Commit all the connections
  for AConnectionName in FTransactionList do
    TioDBFactory.Connection(AConnectionName).Commit;
end;

constructor TioTransactionCollection.Create;
begin
  inherited;
  FTransactionList := TioContainersFactory.GetInterfacedList<String>;
end;

function TioTransactionCollection.Exists(AConnectionName: String): Boolean;
begin
  Result := FTransactionList.IndexOf(AConnectionName) <> -1;
end;

procedure TioTransactionCollection.RollbackAll;
var
  AConnectionName: String;
begin
  // Rollback all the connections
  for AConnectionName in FTransactionList do
    TioDBFactory.Connection(AConnectionName).Commit;
end;

procedure TioTransactionCollection.StartTransaction(AConnectionName: String);
begin
  // The connection is already present then exit
  if Self.Exists(AConnectionName) then Exit;
  // Start the transaction and add it to the TransactionList
  TioDBFactory.Connection(AConnectionName).StartTransaction;
  FTransactionList.Add(AConnectionName);
end;

end.
