unit IupOrm.LiveBindings.PrototypeBindSource;

interface

uses
  Data.Bind.ObjectScope, IupOrm.LiveBindings.Interfaces, System.Classes,
  IupOrm.LiveBindings.Notification, IupOrm.MVVM.Interfaces, System.Rtti;

type


  TioPrototypeBindSource = class;

  TioMasterBindSource = TioPrototypeBindSource;

  TioNeedViewModelEvent = procedure(Sender: TioPrototypeBindSource; var AViewModel: IioViewModel) of object;

  TioPrototypeBindSource = class (TPrototypeBindSource, IioNotifiableBindSource)
  strict private
    FioTypeName: String;
    FioTypeAlias: String;
    FioMasterBindSource: TioMasterBindSource;
    FioMasterPropertyName: String;
    FioWhere: TStrings;
    FioAutoRefreshOnNotification: TioAutoRefreshType;
    FioViewModelInterface, FioViewModelAlias: String;
    FioViewModel: IioViewModel;
    FonNotify: TioBSANotificationEvent;
    FOnNeedViewModel: TioNeedViewModelEvent;
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
    function GetIsDetail: Boolean;
    procedure DoNeedViewModel;
    procedure DoCreateAdapter(var ADataObject: TBindSourceAdapter); override;
    procedure Loaded; override;
    procedure DoNotify(ANotification:IioBSANotification);
//    procedure ioSetBindSourceAdapter(AAdapter: TBindSourceAdapter);
    property IsDetail:Boolean read GetIsDetail;
  public
    procedure Append; overload;
    procedure Append(AObject:TObject); overload;
    procedure Persist(ReloadData:Boolean=False);
    procedure BindVMActions(const AView:TComponent);
    procedure BindVMAction(const AType:TRttiType; const AView:TComponent; const AComponentName, AActionName: String);
    function Current: TObject;
    property ioViewModel:IioViewModel read FioViewModel write FioViewModel;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification);
    procedure Refresh(ReloadData:Boolean); overload;

    property ioOnNotify:TioBSANotificationEvent read FonNotify write FonNotify;
    property ioOnNeedViewModel:TioNeedViewModelEvent read FOnNeedViewModel write FOnNeedViewModel;

    property ioTypeName:String read FioTypeName write FioTypeName;
    property ioTypeAlias:String read FioTypeAlias write FioTypeAlias;
    property ioWhere:TStrings read FIoWhere write FIoWhere;
    property ioMasterBindSource:TioMasterBindSource read FIoMasterBindSource write FIoMasterBindSource;
    property ioMasterPropertyName:String read FIoMasterPropertyName write FIoMasterPropertyName;
    property ioAutoRefreshOnNotification:TioAutoRefreshType read FioAutoRefreshOnNotification write FioAutoRefreshOnNotification;
    property ioViewModelInterface:String read FioViewModelInterface write FioViewModelInterface;
    property ioViewModelAlias:String read FioViewModelAlias write FioViewModelAlias;
  end;

implementation

uses
  System.SysUtils, IupOrm.Exceptions, IupOrm.RttiContext.Factory,
  IupOrm.Attributes, IupOrm.DependencyInjection, IupOrm,
  IupOrm.Context.Container, IupOrm.LiveBindings.Factory;

{ TioPrototypeBindSource }

procedure TioPrototypeBindSource.Append;
begin
  if CheckAdapter then
    GetInternalAdapter.Append;
end;

procedure TioPrototypeBindSource.Append(AObject: TObject);
var
  AnActiveBSA: IioActiveBindSourceAdapter;
begin
  if CheckAdapter and Supports(Self.GetInternalAdapter, IioActiveBindSourceAdapter, AnActiveBSA) then
  begin
    AnActiveBSA.Append(AObject);
    AnActiveBSA.Refresh(False);
  end
  else raise EIupOrmException.Create(Self.ClassName + ': Internal adapter is not an ActiveBindSourceAdapter!');
end;

procedure TioPrototypeBindSource.BindVMAction(const AType: TRttiType; const AView:TComponent; const AComponentName,
  AActionName: String);
var
  AObj: TObject;
  AProp: TRttiProperty;
  AAction: TBasicAction;
  AValue: TValue;
begin
  // Get RttiProperty
  AProp := AType.GetProperty('Action');
  if not Assigned(AProp) then EIupOrmException.Create(Self.ClassName + ': RttiProperty not found!');
  // Get the object
  AObj := AView.FindComponent(AComponentName);
  if not Assigned(AObj) then EIupOrmException.Create(Self.ClassName + ': View component not found!');
  // Get action
  AAction := Self.ioViewModel.GetActionByName(AActionName);
  if not Assigned(AAction) then EIupOrmException.Create(Self.ClassName + ': Action not found!');
  // Set the action property of the object
  AValue := TValue.From<TBasicAction>(AAction);
  AProp.SetValue(AObj, AValue);
end;

procedure TioPrototypeBindSource.BindVMActions(const AView: TComponent);
var
  Typ: TRttiType;
  Fld: TRttiField;
  Attr: TCustomAttribute;
begin
  // Retrieve the RttiType of the view
  Typ := TioRttiContextFactory.RttiContext.GetType(AView.ClassType);
  for Fld in Typ.GetFields do
    for Attr in Fld.GetAttributes do
      if Attr is ioAction then
        Self.BindVMAction(Fld.FieldType, AView, Fld.Name, ioAction(Attr).Value);
end;

constructor TioPrototypeBindSource.Create(AOwner: TComponent);
begin
  inherited;
  FioLoaded := False;
  FioAutoRefreshOnNotification := arEnabledNoReload;
  FioWhere := TStringList.Create;
  FioViewModel := nil;
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
  // Init
  AActiveBSA  := nil;
  // If in DesignTime then Exit
  // If a ClassName is not provided then exit
  // FioLoaded flag for IupOrm DoCreateAdapter internal use only just before
  //  the real Loaded is call. See the Loaded and the DoCreateAdapter methods.
  if (csDesigning in ComponentState)
  or (not FioLoaded)
    then Exit;
  // -------------------------------------------------------------------------------------------------------------------------------
  // If a LockedViewModel is present in the DIContainer (an external prepared ViewModel) and the BindSource is not
  //  a detail (is Master) then Get that ViewModel  , assign it to itself (and to the View later during its creating),
  //  and get the BindSourceAdapter from it.
  if TioViewModelShuttle.Exist and not Self.IsDetail then
  begin
    Self.ioViewModel := TioViewModelShuttle.Get;
    ADataObject := Self.ioViewModel.ViewData.BindSourceAdapter;
  end;
  // -------------------------------------------------------------------------------------------------------------------------------
  // If AdataObject is NOT already assigned (by onCreateAdapter event handler) then
  //  retrieve a BindSourceAdapter automagically by iupORM
  if  (not Assigned(ADataObject))
  and (ioTypeName.Trim <> '') then
  begin
    // If this is a detail BindSource then retrieve the adapter from the master BindSource
    //  else get the adapter directly from IupOrm
    if Assigned(Self.ioMasterBindSource)
      then ADataObject := TioLiveBindingsFactory.GetBSAfromMasterBindSource(Self, Self.FioMasterBindSource, Self.ioMasterPropertyName)
      else ADataObject := TioLiveBindingsFactory.GetBSAfromDB(Self, Self.FioTypeName, Self.FioTypeAlias, Self.FioWhere.Text);
  end;
  // -------------------------------------------------------------------------------------------------------------------------------
  // If Self is a Notifiable bind source then register a reference to itself
  //  in the ActiveBindSourceAdapter
  if  Assigned(ADataObject)
  and Supports(ADataObject, IioActiveBindSourceAdapter, AActiveBSA)
  and Supports(Self, IioNotifiableBindSource)
    then AActiveBSA.SetBindSource(Self);
  // If a ViewModel is not already present and the OnNeedViewModel is specified then
  //  use it
  // If a ViewModel interface is specified and the ioViewModel property is not
  //  already assigned then create automatically a proper ViewModel instance
  //  and use it
  if (not Assigned(Self.ioViewModel)) then
    Self.DoNeedViewModel;
  if  (Self.ioViewModelInterface <> '')
  and (not Assigned(Self.ioViewModel))
  then
    Self.ioViewModel := TioDependencyInjection.Locate(Self.ioViewModelInterface)
                                              .Alias(Self.ioViewModelAlias)
                                              .ConstructorParams([TValue.From(AActiveBSA)])
                                              .ConstructorMarker('CreateByBindSourceAdapter')
                                              .Get
                                              .ioAsInterface<IioViewModel>;
  // -------------------------------------------------------------------------------------------------------------------------------
end;

procedure TioPrototypeBindSource.DoNeedViewModel;
begin
  if Assigned(FOnNeedViewModel) then
    FOnNeedViewModel(Self, FioViewModel);
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

function TioPrototypeBindSource.Current: TObject;
begin
  Result := nil;
  if Self.CheckAdapter then Result := Self.InternalAdapter.Current
end;

function TioPrototypeBindSource.GetIsDetail: Boolean;
begin
  Result := Assigned(FioMasterBindSource);
end;

//procedure TioPrototypeBindSource.ioSetBindSourceAdapter(
//  AAdapter: TBindSourceAdapter);
//begin
//  Self.ConnectAdapter(AAdapter);
//end;

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
  if not Assigned(Self.OnCreateAdapter) then
  begin
    Self.DoCreateAdapter(LAdapter);
    if LAdapter <> nil then
      SetRuntimeAdapter(LAdapter);
  end;
  // ===========================================================================
  // INHERITED MUST BE AFTER THE DOCREATEADAPTER CALL !!!!!!
  inherited;
  // ===========================================================================
  // If the ViewModel is assigned (by the DoCreateAdapter method) then it try
  //  to Bind the View (Owner) components to ViewModel's actions
  // ---------------------------------------------------------------------------
  if Assigned(Self.ioViewModel) then
    Self.BindVMActions(Self.Owner);
  // ===========================================================================
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

function TioPrototypeBindSource._AddRef: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

function TioPrototypeBindSource._Release: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

end.
