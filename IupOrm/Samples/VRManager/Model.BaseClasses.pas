unit Model.BaseClasses;

interface

uses
  Model.BaseInterfaces, Rtti, IupOrm.Attributes, IupOrm.CommonTypes;

type

  // Classe base
  TBaseClass = class(TInterfacedObject, IBaseInterface)
  strict private
    FID: Integer;
    FDescrizione: String;
    FRttiSession_Context: TRttiContext;
    FRttiSession_Type: TRttiType;
    FObjStatus: TIupOrmObjectStatus;
  strict protected
    FRefCount: Integer;
    function GetID: Integer;
    procedure SetID(Value: Integer);
    function GetDescrizione: String;
    procedure SetDescrizione(Value: String);
    function GetListViewItem_Caption: String; virtual;
    function GetListViewItem_DetailText: String; virtual;
    function GetListViewItem_GroupHeader: String; virtual;
    function GetObjStatus: TIupOrmObjectStatus;
    procedure SetObjStatus(const AValue:TIupOrmObjectStatus);
  public
    constructor Create(AID:Integer; ADescrizione:String); overload;
    property ObjStatus: TIupOrmObjectStatus read GetObjStatus write SetObjStatus;
    [ioSkip]
    property RefCount: Integer read FRefCount;
    [ioOID]
    property ID: Integer read GetID write SetID;
    property Descrizione: String read GetDescrizione write SetDescrizione;
    [ioSkip]
    property ListViewItem_Caption: String read GetListViewItem_Caption;
    [ioSkip]
    property ListViewItem_DetailText: String read GetListViewItem_DetailText;
    [ioSkip]
    property ListViewItem_GroupHeader: String read GetListViewItem_GroupHeader;
    procedure RttiSession_Begin;
    procedure RttiSession_End;
    procedure RttiSession_SetPropertyValue(APropName:String; AValue:TValue);
    function  RttiSession_GetPropertyValue(APropName:String): TValue;
  end;

implementation

uses
  System.SysUtils;

{ TBaseClass }

constructor TBaseClass.Create(AID: Integer; ADescrizione: String);
begin
  inherited Create;
  ID := AID;
  Descrizione := ADescrizione;
end;

function TBaseClass.GetDescrizione: String;
begin
  Result := FDescrizione;
end;

function TBaseClass.GetID: Integer;
begin
  Result := FID;
end;

function TBaseClass.GetListViewItem_Caption: String;
begin
  Result := Self.Descrizione;
end;

function TBaseClass.GetListViewItem_DetailText: String;
begin
  Result := 'Detail';
end;

function TBaseClass.GetListViewItem_GroupHeader: String;
begin
  Result := 'Group header';
end;

function TBaseClass.GetObjStatus: TIupOrmObjectStatus;
begin
  Result := FObjStatus;
end;

procedure TBaseClass.RttiSession_Begin;
begin
  FRttiSession_Context := TRttiContext.Create;
  FRttiSession_Type := FRttiSession_Context.GetType(Self.ClassType);
end;

procedure TBaseClass.RttiSession_End;
begin
  FreeAndNil(FRttiSession_Context);
end;

function TBaseClass.RttiSession_GetPropertyValue(APropName: String): TValue;
var
  RttiProperty: TRttiProperty;
begin
  RttiProperty := FRttiSession_Type.GetProperty(APropName);
  if RttiProperty = nil then Exit;
  Result := RttiProperty.GetValue(Self);
end;

procedure TBaseClass.RttiSession_SetPropertyValue(APropName: String;
  AValue: TValue);
var
  RttiProperty: TRttiProperty;
begin
  RttiProperty := FRttiSession_Type.GetProperty(APropName);
  if RttiProperty = nil then Exit;
  RttiProperty.SetValue(Self, AValue);
end;

procedure TBaseClass.SetDescrizione(Value: String);
begin
  if Value <> FDescrizione then
  begin
    FDescrizione := Value;
  end;
end;

procedure TBaseClass.SetID(Value: Integer);
begin
  if Value <> FID then
  begin
    FID := Value;
  end;
end;

procedure TBaseClass.SetObjStatus(const AValue: TIupOrmObjectStatus);
begin
  FObjStatus := AValue;
end;

end.
