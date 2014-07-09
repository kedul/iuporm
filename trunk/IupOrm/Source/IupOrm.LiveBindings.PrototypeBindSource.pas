unit IupOrm.LiveBindings.PrototypeBindSource;

interface

uses
  Data.Bind.ObjectScope, IupOrm.CommonTypes, IupOrm.LiveBindings.Interfaces,
  System.Classes;

type

  TioPrototypeBindSource = class;

  TioMasterBindSource = TioPrototypeBindSource;

  TioPrototypeBindSource = class (TPrototypeBindSource)
  strict private
    FioClassName: String;
    FioMasterBindSource: TioMasterBindSource;
    FioMasterPropertyName: String;
    FioWhere: TStrings;
    // FioLoaded flag for IupOrm DoCreateAdapter internal use only just before
    //  the real Loaded is call. See the Loaded and the DoCreateAdapter methods.
    FioLoaded: Boolean;
  strict protected
    procedure SetIoWhere(const Value: TStrings);
    function GetIoClassName: String;
    function GetIoMasterBindSource: TioMasterBindSource;
    function GetIoMasterPropertyName: String;
    function GetIoWhere: TStrings;
    procedure SetIoClassName(const Value: String);
    procedure SetIoMasterBindSource(const Value: TioMasterBindSource);
    procedure SetIoMasterPropertyName(const Value: String);
    procedure DoCreateAdapter(var ADataObject: TBindSourceAdapter); override;
    procedure Loaded; override;
  public
    procedure Persist(ReloadData:Boolean=False);
    procedure ioSetBindSourceAdapter(AAdapter: TBindSourceAdapter);
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ioClassName:String read GetIoClassName write SetIoClassName;
    property ioWhere:TStrings read GetIoWhere write SetIoWhere;
    property ioMasterBindSource:TioMasterBindSource read GetIoMasterBindSource write SetIoMasterBindSource;
    property ioMasterPropertyName:String read GetIoMasterPropertyName write SetIoMasterPropertyName;
  end;

implementation

uses
  IupOrm, System.SysUtils, System.Rtti,
  IupOrm.RttiContext.Factory, IupOrm.Exceptions, IupOrm.Context.Container;

{ TioPrototypeBindSource }

constructor TioPrototypeBindSource.Create(AOwner: TComponent);
begin
  inherited;
  FioLoaded := False;
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
  // FioLoaded flag for IupOrm DoCreateAdapter internal use only just before
  //  the real Loaded is call. See the Loaded and the DoCreateAdapter methods.
  if (csDesigning in ComponentState)
  or (not FioLoaded)
  or Assigned(ADataObject)
  or (ioClassName.Trim = '')
    then Exit;
  // If this is a detail BindSource then retrieve the adapter from the master BindSource
  //  else get the adapter directly from IupOrm
  if Assigned(Self.ioMasterBindSource) and (Self.ioMasterPropertyName.Trim <> '')
    then ADataObject := Self.FioMasterBindSource.IupOrm.GetDetailBindSourceAdapter(Self.FioMasterPropertyName)
    else ADataObject := TIupOrm.Load(   TioMapContainer.GetClassRef(FioClassName)   )
           ._Where(Self.ioWhere.Text)
           .ToActiveListBindSourceAdapter(Self);
end;

function TioPrototypeBindSource.GetIoClassName: String;
begin
  Result := FioClassName;
end;

function TioPrototypeBindSource.GetIoMasterBindSource: TioMasterBindSource;
begin
  Result := FioMasterBindSource;
end;

function TioPrototypeBindSource.GetIoMasterPropertyName: String;
begin
  Result := FioMasterPropertyName;
end;

function TioPrototypeBindSource.GetIoWhere: TStrings;
begin
  Result := FioWhere;
end;

procedure TioPrototypeBindSource.ioSetBindSourceAdapter(
  AAdapter: TBindSourceAdapter);
begin
  Self.ConnectAdapter(AAdapter);
end;

procedure TioPrototypeBindSource.Loaded;
var
  LAdapter: TBindSourceAdapter;
begin
  // DOCREATEADAPTER CALL MUST BE BEFORE INHERITED !!!!!!
  // ===========================================================================
  // FioLoaded flag for IupOrm DoCreateAdapter internal use only just before
  //  the real Loaded is call. See the Loaded and the DoCreateAdapter methods.
  // ---------------------------------------------------------------------------
  FioLoaded := True;
  Self.DoCreateAdapter(LAdapter);
  if LAdapter <> nil then
    SetRuntimeAdapter(LAdapter);
  // ===========================================================================
  // INHERITED MUST BE AFTER THE DOCREATEADAPTER CALL !!!!!!
  inherited;
end;

procedure TioPrototypeBindSource.Persist(ReloadData: Boolean);
var
 AioActiveBindSourceAdapter: IioActiveBindSourceAdapter;
begin
  // If the InternalAdapter support the IioActiveBindSourceAdapter (is an ActiveBindSourceAdapter)
  //  then call the Adapter Persist method
  if Supports(Self.InternalAdapter, IioActiveBindSourceAdapter, AioActiveBindSourceAdapter)
    then AioActiveBindSourceAdapter.Persist(ReloadData);
end;

procedure TioPrototypeBindSource.SetIoClassName(const Value: String);
begin
  FioClassName := Value;
end;

procedure TioPrototypeBindSource.SetIoMasterBindSource(
  const Value: TioMasterBindSource);
begin
  FioMasterBindSource := Value;
end;

procedure TioPrototypeBindSource.SetIoMasterPropertyName(const Value: String);
begin
  FioMasterPropertyName := Value;
end;

procedure TioPrototypeBindSource.SetIoWhere(const Value: TStrings);
begin
  FioWhere.Assign(Value);
end;

end.
