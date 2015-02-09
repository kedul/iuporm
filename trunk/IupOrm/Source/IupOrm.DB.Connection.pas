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
    FQueryContainer: IioQueryContainer;
  public
    constructor Create(AConnection:TioInternalSqlConnection; AQueryContainer:IioQueryContainer);
    destructor Destroy; override;
    function GetConnection: TioInternalSqlConnection;
    function GetConnectionDefName: String;
    function QueryContainer: IioQueryContainer;
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
  TioDBFactory.ConnectionContainer.FreeConnection(Self);
end;

constructor TioConnection.Create(AConnection: TioInternalSqlConnection; AQueryContainer:IioQueryContainer);
begin
  inherited Create;
  FFDGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FFDGUIxWaitCursor.Provider := 'FMX';
  FTransactionCounter := 0;
  FConnection := AConnection;
  FQueryContainer := AQueryContainer;
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

function TioConnection.GetConnectionDefName: String;
begin
  Result := Self.FConnection.ConnectionDefName;
end;

function TioConnection.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

function TioConnection.QueryContainer: IioQueryContainer;
begin
  Result := FQueryContainer;
end;

procedure TioConnection.Rollback;
begin
  FConnection.Rollback;
  FTransactionCounter := 0;
  TioDBFactory.ConnectionContainer.FreeConnection(Self);
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

