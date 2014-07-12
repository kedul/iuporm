unit IupOrm.DB.Connection;

interface

uses
  IupOrm.DB.Interfaces,
  FireDAC.Stan.Def,
  FireDAC.Phys.SQLite,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Intf,
  FireDAC.Phys,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Stan.Async;

type

  TioConnection = class(TInterfacedObject, IioConnection)
  strict private
    FConnection: TioInternalSqlConnection;
    FTransactionCounter: Integer;
    FFDGUIxWaitCursor: TFDGUIxWaitCursor;
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

uses
  IupOrm.DB.Factory;

{ TioConnectionSqLite }

procedure TioConnection.Commit;
begin
  Dec(FTransactionCounter);
  if FTransactionCounter > 0 then Exit;
  FConnection.Commit;
  TioDBFactory.ConnectionContainer.FreeConnection;
end;

constructor TioConnection.Create(AConnection: TioInternalSqlConnection);
begin
  inherited Create;
  FFDGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FFDGUIxWaitCursor.Provider := 'FMX';
  FTransactionCounter := 0;
  FConnection := AConnection;
end;

destructor TioConnection.Destroy;
begin
  FConnection.Free;
  FFDGUIxWaitCursor.Free;
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
  FConnection.Rollback;
  FTransactionCounter := 0;
  TioDBFactory.ConnectionContainer.FreeConnection;
end;

procedure TioConnection.StartTransaction;
begin
  if FTransactionCounter <= 0 then
  begin
    FConnection.StartTransaction;
    FTransactionCounter := 0;
  end;
  inc(FTransactionCounter);
end;

end.
