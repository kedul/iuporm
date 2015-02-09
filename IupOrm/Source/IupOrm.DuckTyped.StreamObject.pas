unit IupOrm.DuckTyped.StreamObject;

interface

uses
  IupOrm.DuckTyped.Interfaces, System.Classes, System.Rtti,
  IupOrm.DMVC.ObjectsMappersAdapter;

type

  // DuckTypedStreamObject
  //  NB: IWrappedObject interface is for DMVC ObjectsMappers adapter
  TioDuckTypedStreamObject = class(TInterfacedObject, IioDuckTypedStreamObject, IWrappedObject)
  strict protected
    FObj: TObject;
    FLoadFromStreamMethod: TRttiMethod;
    FSaveToStreamMethod: TRttiMethod;
    FIsEmptyMethod: TRttiMethod;
    FCountProperty: TRttiProperty;
  public
    constructor Create(AObj: TObject);
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    function IsEmpty: Boolean; virtual;
  end;

implementation

uses
  IupOrm.RttiContext.Factory, IupOrm.Exceptions, IupOrm;

{ TioDuckTypedStreamObject }

constructor TioDuckTypedStreamObject.Create(AObj: TObject);
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  inherited Create;
  FObj := AObj;
  // Init Rtti
  Ctx := TioRttiContextFactory.RttiContext;
  Typ := Ctx.GetType(AObj.ClassInfo);
  // LoadFromStreamMethod method
  FLoadFromStreamMethod := Typ.GetMethod('LoadFromStream');
  if not Assigned(FLoadFromStreamMethod) then EIupOrmException.Create('DuckTypedStreamObject: "LoadFromStream" method not found in the object');
  // SaveFromStreamMethod method
  FSaveToStreamMethod := Typ.GetMethod('SaveToStream');
  if not Assigned(FSaveToStreamMethod) then EIupOrmException.Create('DuckTypedStreamObject: "SaveToStream" method not found in the object');
  // IsEmpty method
  FIsEmptyMethod := Typ.GetMethod('IsEmpty');
  // Count property method
  FCountProperty := Typ.GetProperty('Count');
end;

function TioDuckTypedStreamObject.IsEmpty: Boolean;
begin
  // FIsEmptyMethod method assigned
  if Assigned(FIsEmptyMethod)
    then Result := FIsEmptyMethod.Invoke(FObj, []).AsBoolean
  // FCountProperty method assigned
  else if Assigned(FCountProperty)
    then Result := (FCountProperty.GetValue(FObj).AsInteger = 0)
  // Otherwise return False
  else Result := False;
end;

procedure TioDuckTypedStreamObject.LoadFromStream(Stream: TStream);
begin
  FLoadFromStreamMethod.Invoke(FObj, [Stream]);
end;

procedure TioDuckTypedStreamObject.SaveToStream(Stream: TStream);
begin
  FSaveToStreamMethod.Invoke(FObj, [Stream]);
end;

end.
