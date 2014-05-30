unit IupOrm.LiveBindings.PrototypeBindSource.DesignTime;

interface

uses
  DesignEditors, DesignIntf, System.Classes;

type

  TioBindSourceMasterPropertyEditor = class(TComponentProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

procedure Register;

implementation

uses
  IupOrm.LiveBindings.PrototypeBindSource, Data.Bind.ObjectScope,
  System.Rtti, IupOrm.RttiContext.Factory, IupOrm.Exceptions,
  IupOrm.Context.Properties.Interfaces, IupOrm.Context.Factory,
  IupOrm.Context.Interfaces, IupOrm.Attributes;

  procedure Register;
  begin
    RegisterComponents('IupOrm', [TioPrototypeBindSource]);
    RegisterPropertyEditor(TypeInfo(String), TioPrototypeBindSource, 'ioMasterPropertyName', TioBindSourceMasterPropertyEditor);
  end;

{ TioBindSourceMasterPropertyEditor }

function TioBindSourceMasterPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paValueList,paSortList] - [paMultiSelect];
end;

procedure TioBindSourceMasterPropertyEditor.GetValues(Proc: TGetStrProc);
var
  AMasterBindSource: TioPrototypeBindSource;
  ADetailBindSource: TioPrototypeBindSource;
  Ctx: TRttiContext;
  Typ: TRttiType;
  AContext: IioContext;
  AProperty: IioContextProperty;
begin
  // Get the current BindSource component for which we want to set the property (detail)
  ADetailBindSource := Self.GetComponent(0) as TioPrototypeBindSource;
  // Get the Master BindSource (from the detail)
  AMasterBindSource := ADetailBindSource.ioMasterBindSource as TioPrototypeBindSource;
  // If the DetailBindSource.ioMasterBindSource property is defined...
  if Assigned(AMasterBindSource) then
  begin
    Ctx := TioRttiContextFactory.RttiContext;
    Typ := Ctx.FindType(AMasterBindSource.ioClassName);
    if not Assigned(Typ) then raise EIupOrmException.Create(Self.ClassName + ': RttiType not found.');
    if not Typ.IsInstance then raise EIupOrmException.Create(Self.ClassName + ': RttiType is not a RttiInstanceType.');
    AContext := TioContextFactory.Context(Typ.AsInstance.MetaclassType);
    for AProperty in AContext.GetProperties do
    begin
      if AProperty.GetRelationType = ioRTNone then Continue;
      Proc(AProperty.GetName);
    end;
  end else inherited GetValues(Proc);
end;

end.
