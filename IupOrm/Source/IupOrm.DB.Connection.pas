unit IupOrm.DB.Connection;

interface

uses
  IupOrm.DB.Interfaces, Data.DBXCommon;

type

  TioConnection = class(TInterfacedObject, IioConnection)
  strict private
    FConnection: TioInternalSqlConnection;
    FCurrentTransaction: TDBXTransaction;
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
  FConnection.CommitFreeAndNil(FCurrentTransaction);
end;

constructor TioConnection.Create(AConnection: TioInternalSqlConnection);
begin
  inherited Create;
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
  FConnection.RollbackFreeAndNil(FCurrentTransaction);
end;

procedure TioConnection.StartTransaction;
begin
  FCurrentTransaction := FConnection.BeginTransaction;
end;

end.
