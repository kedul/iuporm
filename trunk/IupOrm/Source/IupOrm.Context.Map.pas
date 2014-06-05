unit IupOrm.Context.Map;

interface

uses
  IupOrm.CommonTypes, IupOrm.Context.Table.Interfaces,
  IupOrm.Context.Properties.Interfaces, System.Rtti,
  IupOrm.Context.Map.Interfaces;

type

  TioMap = class(TInterfacedObject, IioMap)
  strict private
    FClassRef: TioClassRef;
    FTable: IioContextTable;
    FProperties: IioContextProperties;
    FRttiContext: TRttiContext;
    FRttiType: TRttiInstanceType;
  strict protected
  public
    constructor Create(AClassRef:TioClassRef; ARttiContext:TRttiContext; ARttiType:TRttiInstanceType; ATable:IioContextTable; AProperties:IioContextProperties); overload;
    function GetClassRef: TioClassRef;
    function GetTable: IioContextTable;
    function GetProperties: IioContextProperties;
    function ClassFromField: IioClassFromField;
    function RttiContext: TRttiContext;
    function RttiType: TRttiInstanceType;
    // Blob field present
    function BlobFieldExists: Boolean;
  end;

implementation

{ TioMap }

function TioMap.BlobFieldExists: Boolean;
begin

end;

function TioMap.ClassFromField: IioClassFromField;
begin
  Result := FTable.GetClassFromField;
end;

constructor TioMap.Create(AClassRef: TioClassRef; ARttiContext: TRttiContext;
  ARttiType: TRttiInstanceType; ATable: IioContextTable;
  AProperties: IioContextProperties);
begin
  inherited Create;
  FClassRef := AClassRef;
  FRttiContext := ARttiContext;
  FRttiType := ARttiType;
  FTable := ATable;
  FProperties := AProperties;
end;

function TioMap.GetClassRef: TioClassRef;
begin
  Result := FClassRef;
end;

function TioMap.GetProperties: IioContextProperties;
begin
  Result := FProperties;
end;

function TioMap.GetTable: IioContextTable;
begin
  Result := FTable;
end;

function TioMap.RttiContext: TRttiContext;
begin
  Result := FRttiContext;
end;

function TioMap.RttiType: TRttiInstanceType;
begin
  Result := FRttiType;
end;

end.
