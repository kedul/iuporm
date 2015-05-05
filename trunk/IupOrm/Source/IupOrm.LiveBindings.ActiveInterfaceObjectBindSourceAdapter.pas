unit IupOrm.LiveBindings.ActiveInterfaceObjectBindSourceAdapter;

interface

uses
  IupOrm.LiveBindings.InterfaceObjectBindSourceAdapter,
  IupOrm.LiveBindings.Interfaces, IupOrm.LiveBindings.Notification,
  IupOrm.CommonTypes, System.Classes, IupOrm.Context.Properties.Interfaces,
  Data.Bind.ObjectScope;

type

  TioActiveInterfaceObjectBindSourceAdapter = class(TInterfaceObjectBindSourceAdapter, IioContainedBindSourceAdapter, IioActiveBindSourceAdapter, IioNaturalBindSourceAdapterSource)
  strict private
    FWhereStr: String;
    FTypeName, FTypeAlias: String;
    FUseObjStatus: Boolean;  // Not use directly, use UseObjStatus function or property even for internal use
    FLocalOwnsObject: Boolean;
    FAutoLoadData: Boolean;
    FReloadDataOnRefresh: Boolean;
    FMasterPropertyName: String;
    FMasterAdaptersContainer: IioDetailBindSourceAdaptersContainer;
    FDetailAdaptersContainer: IioDetailBindSourceAdaptersContainer;
    FBindSource: IioNotifiableBindSource;
    FonNotify: TioBSANotificationEvent;
//    FNaturalBSA_MasterBindSourceAdapter: IioActiveBindSourceAdapter;
    FInsertObj_Enabled: Boolean;
    FInsertObj_NewObj: TObject;
 strict protected
    // =========================================================================
    // Part for the support of the IioNotifiableBindSource interfaces (Added by IupOrm)
    //  because is not implementing IInterface (NB: RefCount DISABLED)
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // =========================================================================
    procedure DoBeforeOpen; override;
    procedure DoBeforeRefresh; override;
    procedure DoBeforeDelete; override;
    procedure DoAfterDelete; override;
    procedure DoAfterPost; override;
    procedure DoAfterScroll; override;
    procedure DoAfterInsert; override;
    procedure SetObjStatus(AObjStatus: TIupOrmObjectStatus);
    function UseObjStatus: Boolean;
    procedure DoNotify(ANotification:IioBSANotification);
  public
    constructor Create(const ATypeName, ATypeAlias, AWhereStr:String; const AOwner: TComponent; const AObject: TObject; const AutoLoadData, AUseObjStatus: Boolean; const AOwnsObject: Boolean = True); overload;
    destructor Destroy; override;
    procedure SetMasterAdapterContainer(AMasterAdapterContainer:IioDetailBindSourceAdaptersContainer);
    procedure SetMasterProperty(AMasterProperty: IioContextProperty);
    procedure SetBindSource(ANotifiableBindSource:IioNotifiableBindSource);
    procedure ExtractDetailObject(AMasterObj: TObject);
    procedure Persist(ReloadData:Boolean=False);
    function GetDetailBindSourceAdapter(AOwner:TComponent; AMasterPropertyName:String): TBindSourceAdapter;
    function GetNaturalObjectBindSourceAdapter(AOwner:TComponent): TBindSourceAdapter;
    procedure Append(AObject:TObject); overload;
    procedure Insert(AObject:TObject); overload;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification); virtual;
    procedure Refresh(ReloadData:Boolean); overload;
//    FNaturalBSA_MasterBindSourceAdapter: IioActiveBindSourceAdapter;  *** NB: Code presente (commented) in the unit body ***
    function GetDataObject: TObject;
    procedure SetDataObject(const AObj: TObject);

    property ioOnNotify:TioBSANotificationEvent read FonNotify write FonNotify;
  end;


implementation

uses
  IupOrm, System.SysUtils, IupOrm.LiveBindings.Factory, IupOrm.Context.Factory,
  System.Rtti, IupOrm.Context.Map.Interfaces;

{ TioActiveInterfaceObjectBindSourceAdapter }

procedure TioActiveInterfaceObjectBindSourceAdapter.Append(AObject: TObject);
begin
  // Set sone InsertObj subsystem variables
  // Then call the standard code
  FInsertObj_NewObj := AObject;
  FInsertObj_Enabled := True;
  Self.Append;
end;

constructor TioActiveInterfaceObjectBindSourceAdapter.Create(const ATypeName, ATypeAlias, AWhereStr: String;
  const AOwner: TComponent; const AObject: TObject; const AutoLoadData, AUseObjStatus, AOwnsObject: Boolean);
begin
  FAutoLoadData := AutoLoadData;
  FReloadDataOnRefresh := True;
  FUseObjStatus := AUseObjStatus;
  inherited Create(AOwner, AObject, ATypeAlias, ATypeName, AOwnsObject);
  FLocalOwnsObject := AOwnsObject;
  FWhereStr := AWhereStr;
  // Set Master & Details adapters reference
  FMasterAdaptersContainer := nil;
  FDetailAdaptersContainer := TioLiveBindingsFactory.DetailAdaptersContainer(Self);
  // Init InsertObj subsystem values
  FInsertObj_Enabled := False;
  FInsertObj_NewObj := nil;
end;

destructor TioActiveInterfaceObjectBindSourceAdapter.Destroy;
begin
  // Detach itself from MasterAdapterContainer (if it's contained)
  if Assigned(FMasterAdaptersContainer) then
    FMasterAdaptersContainer.RemoveBindSourceAdapter(Self);
  // Free the DetailAdaptersContainer
  FDetailAdaptersContainer.Free;
  inherited;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.DoAfterDelete;
begin
  inherited;
  // Send a notification to other ActiveBindSourceAdapters & BindSource
  Notify(
         Self,
         TioLiveBindingsFactory.Notification(Self, Self.Current, ntAfterDelete)
        );
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.DoAfterInsert;
var
  ObjToFree: TObject;
begin
  // If enabled subsitute the new object with the FInsertObj_NewObj (Append(AObject:TObject))
  //  then destroy the "olr" new object
  if FInsertObj_Enabled then
  begin
    try
      ObjToFree := Self.DataObject as TObject;
      ObjToFree.Free;
      Self.SetDataObject(FInsertObj_NewObj);
    finally
      // Reset InsertObj subsystem
      FInsertObj_Enabled := False;
      FInsertObj_NewObj := nil;
    end;
  end;
  // Execute AfterInsert event handler
  inherited;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.DoAfterPost;
begin
  inherited;
  if Self.UseObjStatus
    then Self.SetObjStatus(osDirty)
    else TIupOrm.Persist(Self.Current);
  // Send a notification to other ActiveBindSourceAdapters & BindSource
  Notify(
         Self,
         TioLiveBindingsFactory.Notification(Self, Self.Current, ntAfterPost)
        );
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.DoAfterScroll;
begin
  inherited;
  Self.FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.DoBeforeDelete;
begin
  inherited;
  if Self.UseObjStatus then
  begin
    Self.SetObjStatus(osDeleted);
    Abort;
  end else TIupOrm.Delete(Self.Current);
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.DoBeforeOpen;
begin
  inherited;
  // Load the object and assign it to the Adapter
  if FAutoLoadData
    then Self.SetDataObject(   TIupOrm.Load(FTypeName, FTypeAlias)._Where(FWhereStr).ToObject   );
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.DoBeforeRefresh;
var
  PrevDataObject: TObject;
begin
  inherited;
  if FReloadDataOnRefresh then
  begin
    // Deactivate the adapter
    Self.Active := False;
    // Get actual DataObject
    PrevDataObject := Self.DataObject as TObject;
    // If ActualDataObject is assigned and OwnsObject = True then destroy the object
    if Assigned(PrevDataObject) and Self.FLocalOwnsObject then PrevDataObject.Free;
    // Activate the Adapter (after the adapter fire the onBeforeOpen event that Load
    //  the NewObject
    Self.Active := True;
  end;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.DoNotify(ANotification: IioBSANotification);
begin
  if Assigned(FonNotify)
    then ioOnNotify(Self, ANotification);
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.ExtractDetailObject(AMasterObj: TObject);
var
  ADetailObj: TObject;
  AValue: TValue;
  AMap: IioMap;
  AMasterProperty: IioContextProperty;
begin
  ADetailObj := nil;
  // Check parameter
  if not Assigned(AMasterObj)
    then Exit;
  // Extract master property value
  AMap := TioContextFactory.Map(AMasterObj.ClassType);
  AMasterProperty := AMap.GetProperties.GetPropertyByName(FMasterPropertyName);
  AValue := AMasterProperty.GetValue(AMasterObj);
  // Retrieve the object from the TValue
  if not AValue.IsEmpty then
    if AMasterProperty.IsInterface then
      ADetailObj := TObject(AValue.AsInterface)
    else
      ADetailObj := AValue.AsObject;
  // Set it to the Adapter itself
  Self.SetDataObject(ADetailObj);
end;

function TioActiveInterfaceObjectBindSourceAdapter.GetDataObject: TObject;
begin
  Result := Self.DataObject as TObject;
end;

function TioActiveInterfaceObjectBindSourceAdapter.GetDetailBindSourceAdapter(AOwner: TComponent;
  AMasterPropertyName: String): TBindSourceAdapter;
begin
  // Return the requested DetailBindSourceAdapter and set the current master object
  Result := FDetailAdaptersContainer.GetBindSourceAdapter(AOwner, BaseObjectRttiType.Name, AMasterPropertyName);
  FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

function TioActiveInterfaceObjectBindSourceAdapter.GetNaturalObjectBindSourceAdapter(AOwner: TComponent): TBindSourceAdapter;
begin
  Result := TioLiveBindingsFactory.NaturalObjectBindSourceAdapter(AOwner, Self);
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.Insert(AObject: TObject);
begin
  // Set sone InsertObj subsystem variables
  // Then call the standard code
  FInsertObj_NewObj := AObject;
  FInsertObj_Enabled := True;
  Self.Insert;
end;

//procedure TioActiveInterfaceObjectBindSourceAdapter.NaturalBSA_SetMasterBindSourceAdapter(
//  AActiveBindSourceAdapter: IioActiveBindSourceAdapter);
//begin
//  Self.FNaturalBSA_MasterBindSourceAdapter := AActiveBindSourceAdapter;
//end;

procedure TioActiveInterfaceObjectBindSourceAdapter.Notify(Sender: TObject; ANotification: IioBSANotification);
begin
  // Fire the event handler
  if Sender <> Self
    then Self.DoNotify(ANotification);
  // Replicate notification to the BindSource
  if Assigned(FBindSource) and (Sender <> TObject(FBindSource))
    then FBindSource.Notify(Self, ANotification);
  // Replicate notification to the DetailAdaptersContainer
  if Sender <> TObject(FDetailAdaptersContainer)
    then FDetailAdaptersContainer.Notify(Self, ANotification);
  // Replicate notification to the MasterAdaptersContainer
  if Assigned(FMasterAdaptersContainer) and (Sender <> TObject(FMasterAdaptersContainer))
    then FMasterAdaptersContainer.Notify(Self, ANotification);
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.Persist(ReloadData: Boolean);
begin
  // Persist
  TIupOrm.Persist(Self.DataObject);
  // Reload
  if ReloadData then Self.DoBeforeOpen;
end;

function TioActiveInterfaceObjectBindSourceAdapter.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  // RefCount disabled
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.Refresh(ReloadData: Boolean);
var
  PrecReloadData: Boolean;
begin
  PrecReloadData := FReloadDataOnRefresh;
  Self.FReloadDataOnRefresh := ReloadData;
  inherited Refresh;
  Self.FReloadDataOnRefresh := PrecReloadData;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.SetBindSource(ANotifiableBindSource: IioNotifiableBindSource);
begin
  FBindSource := ANotifiableBindSource;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.SetDataObject(const AObj: TObject);
begin
  Self.First;  // Bug
  Self.Active := False;
  Self.SetDataObject(AObj);
  Self.Active := True;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.SetMasterAdapterContainer(
  AMasterAdapterContainer: IioDetailBindSourceAdaptersContainer);
begin
  FMasterAdaptersContainer := AMasterAdapterContainer;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.SetMasterProperty(AMasterProperty: IioContextProperty);
begin
  FMasterPropertyName := AMasterProperty.GetName;
end;

procedure TioActiveInterfaceObjectBindSourceAdapter.SetObjStatus(AObjStatus: TIupOrmObjectStatus);
begin
  TioContextFactory.Context(Self.Current.ClassName, nil, Self.Current).ObjectStatus := AObjStatus;
end;

function TioActiveInterfaceObjectBindSourceAdapter.UseObjStatus: Boolean;
begin
  Result := FUseObjStatus;
end;

function TioActiveInterfaceObjectBindSourceAdapter._AddRef: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

function TioActiveInterfaceObjectBindSourceAdapter._Release: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

end.
