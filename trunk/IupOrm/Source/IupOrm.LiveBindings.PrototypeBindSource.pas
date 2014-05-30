unit IupOrm.LiveBindings.PrototypeBindSource;

interface

uses
  Data.Bind.ObjectScope, IupOrm.CommonTypes, IupOrm.LiveBindings.Interfaces;

type

  TioPrototypeBindSource = class (TPrototypeBindSource)
  private
    FioClassName: String;
    FioMasterBindSource: TioBaseBindSource;
    FioMasterPropertyName: String;
  protected
    function GetIupOrm_ClassRef: TioClassRef;
    procedure DoCreateAdapter(var ADataObject: TBindSourceAdapter); override;
  published
    property ioClassName:String read FioClassName write FioClassName;
    property ioMasterBindSource:TioBaseBindSource read FioMasterBindSource write FioMasterBindSource;
    property ioMasterPropertyName:String read FioMasterPropertyName write FioMasterPropertyName;
  end;

implementation

uses
  IupOrm, System.Classes, System.SysUtils, System.Rtti,
  IupOrm.RttiContext.Factory, IupOrm.Exceptions;

{ TioPrototypeBindSource }

procedure TioPrototypeBindSource.DoCreateAdapter(
  var ADataObject: TBindSourceAdapter);
begin
  inherited;
  // If in DesignTime then Exit
  // If AdataObject is already assigned (by onCreateAdapter event handler) then exit
  // If a ClassName is non provided then exit
  if (csDesigning in ComponentState)
  or Assigned(ADataObject)
  or (ioClassName.Trim = '')
    then Exit;
  // If this is a detail BindSource then retrieve the adapter from the master BindSource
  //  else get the adapter directly from IupOrm
  if Assigned(Self.FioMasterBindSource) and (Self.FioMasterPropertyName.Trim <> '')
    then ADataObject := Self.FioMasterBindSource.IupOrm.GetDetailBindSourceAdapter(Self.FioMasterPropertyName)
    else ADataObject := TIupOrm.Load(Self.GetIupOrm_ClassRef).ToActiveListBindSourceAdapter(Self);
end;

function TioPrototypeBindSource.GetIupOrm_ClassRef: TioClassRef;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  Ctx := TioRttiContextFactory.RttiContext;
  Typ := Ctx.FindType(FioClassName);
  if not Assigned(Typ) then raise EIupOrmException.Create(Self.ClassName + ': RttiType not found.');
  if not (Typ is TRttiInstanceType) then raise EIupOrmException.Create(Self.ClassName + ': Not TRttiInstanceType error.');
  Result := TRttiInstanceType(Typ).MetaclassType;
end;

end.
