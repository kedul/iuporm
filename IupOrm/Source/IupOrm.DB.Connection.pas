unit IupOrm.DB.Connection;

interface

uses
  Data.DbxSqlite, IupOrm.DB.Interfaces, Data.DBXCommon;

type

  TioConnection = class(TInterfacedObject, IioConnection)
  strict private
    FConnection: TioInternalSqlConnection;
    FCurrentTransaction: TDBXTransaction;
    FTransactionCounter: Integer;
  public
    constructor Create(AConnection:TioInternalSqlConnection);
    destructor Destroy; override;
    function GetConnection: TioInternalSqlConnection;
    function InTransaction: Boolean;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
  end;


implementation

{ TioConnectionSqLite }

procedure TioConnection.Commit;
begin
  Dec(FTransactionCounter);
  if FTransactionCounter = 0
    then FConnection.CommitFreeAndNil(FCurrentTransaction);
end;

constructor TioConnection.Create(AConnection: TioInternalSqlConnection);
begin
  inherited Create;
  FTransactionCounter := 0;
  FConnection := AConnection;
  FCurrentTransaction := nil;
end;

destructor TioConnection.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function TioConnection.GetConnection: TioInternalSqlConnection;
begin
  Result := FConnection;
end;

function TioConnection.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

procedure TioConnection.Rollback;
begin
  Dec(FTransactionCounter);
  if FTransactionCounter = 0
    then FConnection.RollbackFreeAndNil(FCurrentTransaction);
end;

procedure TioConnection.StartTransaction;
begin
  if FTransactionCounter <= 0 then
  begin
    FCurrentTransaction := FConnection.BeginTransaction;
    FTransactionCounter := 0;
  end;
  inc(FTransactionCounter);
end;

end.
