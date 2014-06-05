unit IupOrm.LiveBindings.PrototypeBindSource;

interface

uses
  Data.Bind.ObjectScope, IupOrm.CommonTypes, IupOrm.LiveBindings.Interfaces,
  System.Classes;

type

  TioPrototypeBindSource = class (TPrototypeBindSource)
  strict private
    FioClassName: String;
    FioMasterBindSource: TioBaseBindSource;
    FioMasterPropertyName: String;
    FioWhere: TStrings;
  private
    procedure SetIoWhere(const Value: TStrings); protected
  strict protected
      procedure DoCreateAdapter(var ADataObject: TBindSourceAdapter); override;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ioClassName:String read FioClassName write FioClassName;
    property ioWhere:TStrings read FioWhere write SetIoWhere;
    property ioMasterBindSource:TioBaseBindSource read FioMasterBindSource write FioMasterBindSource;
    property ioMasterPropertyName:String read FioMasterPropertyName write FioMasterPropertyName;
  end;

implementation

uses
  IupOrm, System.SysUtils, System.Rtti,
  IupOrm.RttiContext.Factory, IupOrm.Exceptions, IupOrm.Context.Container;

{ TioPrototypeBindSource }

constructor TioPrototypeBindSource.Create(AOwner: TComponent);
begin
  inherited;
  FioWhere := TStringList.Create;
end;

destructor TioPrototypeBindSource.Destroy;
begin
  FioWhere.Free;
  inherited;
end;

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
    else ADataObject := TIupOrm.Load(   TioMapContainer.GetClassRef(FioClassName)   )
           ._Where(Self.ioWhere.Text)
           .ToActiveListBindSourceAdapter(Self);
end;

procedure TioPrototypeBindSource.SetIoWhere(const Value: TStrings);
begin
  FioWhere.Assign(Value);
end;

end.
