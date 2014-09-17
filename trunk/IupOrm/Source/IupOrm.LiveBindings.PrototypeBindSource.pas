unit IupOrm.LiveBindings.PrototypeBindSource;

interface

uses
  Data.Bind.ObjectScope, IupOrm.CommonTypes, IupOrm.LiveBindings.Interfaces,
  System.Classes, IupOrm.LiveBindings.Notification;

type

  TioPrototypeBindSource = class;

  TioMasterBindSource = TioPrototypeBindSource;

  TioPrototypeBindSource = class (TPrototypeBindSource, IioNotifiableBindSource)
  strict private
    FioClassName: String;
    FioMasterBindSource: TioMasterBindSource;
    FioMasterPropertyName: String;
    FioWhere: TStrings;
    FonNotify: TioBSANotificationEvent;
    FioAutoRefreshOnNotification: TioAutoRefreshType;
    // FioLoaded flag for IupOrm DoCreateAdapter internal use only just before
    //  the real Loaded is call. See the Loaded and the DoCreateAdapter methods.
    FioLoaded: Boolean;
  strict protected
    // =========================================================================
    // Part for the support of the IioNotifiableBindSource interfaces (Added by IupOrm)
    //  because is not implementing IInterface (NB: RefCount DISABLED)
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // =========================================================================
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
    procedure DoNotify(ANotification:IioBSANotification);
  public
    procedure Append;
    procedure Persist(ReloadData:Boolean=False);
    procedure ioSetBindSourceAdapter(AAdapter: TBindSourceAdapter);
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification);
    procedure Refresh(ReloadData:Boolean); overload;

    property ioOnNotify:TioBSANotificationEvent read FonNotify write FonNotify;

    property ioClassName:String read GetIoClassName write SetIoClassName;
    property ioWhere:TStrings read GetIoWhere write SetIoWhere;
    property ioMasterBindSource:TioMasterBindSource read GetIoMasterBindSource write SetIoMasterBindSource;
    property ioMasterPropertyName:String read GetIoMasterPropertyName write SetIoMasterPropertyName;
    property ioAutoRefreshOnNotification:TioAutoRefreshType read FioAutoRefreshOnNotification write FioAutoRefreshOnNotification;
  end;

implementation

uses
  IupOrm, System.SysUtils, System.Rtti,
  IupOrm.RttiContext.Factory, IupOrm.Exceptions, IupOrm.Context.Container;

{ TioPrototypeBindSource }

procedure TioPrototypeBindSource.Append;
begin
  InternalAdapter.Append;
end;

constructor TioPrototypeBindSource.Create(AOwner: TComponent);
begin
  inherited;
  FioLoaded := False;
  FioAutoRefreshOnNotification := arEnabledNoReload;
  FioWhere := TStringList.Create;
end;

destructor TioPrototypeBindSource.Destroy;
begin
  FioWhere.Free;
  inherited;
end;

procedure TioPrototypeBindSource.DoCreateAdapter(
  var ADataObject: TBindSourceAdapter);
var
  AActiveBSA: IioActiveBindSourceAdapter;
begin
  inherited;
  // If in DesignTime then Exit
  // If a ClassName is non provided then exit
  // FioLoaded flag for IupOrm DoCreateAdapter internal use only just before
  //  the real Loaded is call. See the Loaded and the DoCreateAdapter methods.
  if (csDesigning in ComponentState)
  or (not FioLoaded)
    then Exit;
  // If AdataObject is NOT already assigned (by onCreateAdapter event handler) then
  //  retrieve a BindSourceAdapter automagically by iupORM
  if  (not Assigned(ADataObject))
  and (ioClassName.Trim <> '') then
  begin
    // If this is a detail BindSource then retrieve the adapter from the master BindSource
    //  else get the adapter directly from IupOrm
    if Assigned(Self.ioMasterBindSource) then
    begin
      // If the MasterPropertyName property is empty then get a NaturalActiveBindSourceAdapter
      //  from the MasterBindSource else get a detail ActiveBindSourceAdapter even from the
      //  MasterBindSource.
      if (Self.ioMasterPropertyName.Trim <> '')
        then ADataObject := Self.FioMasterBindSource.IupOrm.GetDetailBindSourceAdapter(Self, Self.FioMasterPropertyName)
        else ADataObject := Self.FioMasterBindSource.IupOrm.GetNaturalObjectBindSourceAdapter(Self);
    end
    //  else get the adapter directly from IupOrm
    else ADataObject := TIupOrm.Load(   TioMapContainer.GetClassRef(FioClassName)   )
           ._Where(Self.ioWhere.Text)
           .ToActiveListBindSourceAdapter(Self);
  end;
  // If Self is a Notifiable bind source then register a reference to itself
  //  in the ActiveBindSourceAdapter
  if  Assigned(ADataObject)
  and Supports(ADataObject, IioActiveBindSourceAdapter, AActiveBSA)
  and Supports(Self, IioNotifiableBindSource) then
    AActiveBSA.SetBindSource(Self);
end;

procedure TioPrototypeBindSource.DoNotify(ANotification:IioBSANotification);
begin
  // If assigned execute the event handler
  if Assigned(FonNotify)
    then ioOnNotify(Self, ANotification);
  // If enabled perform an AutoRefresh operation
  if Self.ioAutoRefreshOnNotification > arDisabled
    then Self.Refresh(Self.ioAutoRefreshOnNotification = arEnabledReload);
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

procedure TioPrototypeBindSource.Notify(Sender: TObject;
  ANotification: IioBSANotification);
begin
  Self.DoNotify(ANotification);
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

function TioPrototypeBindSource.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  // RefCount disabled
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TioPrototypeBindSource.Refresh(ReloadData: Boolean);
var
  AnActiveBSA: IioActiveBindSourceAdapter;
begin
  if not CheckAdapter then Exit;
  if Supports(Self.GetInternalAdapter, IioActiveBindSourceAdapter, AnActiveBSA)
    then AnActiveBSA.Refresh(ReloadData)
    else GetInternalAdapter.Refresh;
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

function TioPrototypeBindSource._AddRef: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

function TioPrototypeBindSource._Release: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

end.
