unit IupOrm.LiveBindings.ActiveInterfaceListBindSourceAdapter;

interface

uses
  Data.Bind.ObjectScope, IupOrm.Where, System.Classes,
  System.Generics.Collections, IupOrm.Where.SqlItems.Interfaces,
  IupOrm.CommonTypes, IupOrm.Context.Properties.Interfaces,
  IupOrm.LiveBindings.Interfaces, IupOrm.LiveBindings.Notification,
  IupOrm.LiveBindings.InterfaceListBindSourceAdapter;

type

  TioActiveInterfaceListBindSourceAdapter = class(TInterfaceListBindSourceAdapter, IioContainedBindSourceAdapter, IioActiveBindSourceAdapter, IioNaturalBindSourceAdapterSource)
  private
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
    FInsertObj_Enabled: Boolean;
    FInsertObj_NewObj: TObject;
  protected
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
    constructor Create(const ATypeName, ATypeAlias, AWhereStr:String; const AOwner: TComponent; const AList:TObject; const AutoLoadData, AUseObjStatus: Boolean; const AOwnsObject: Boolean = True); overload;
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
    function GetDataObject: TObject;
    procedure SetDataObject(const AObj: TObject);

    property ioOnNotify:TioBSANotificationEvent read FonNotify write FonNotify;
  end;

implementation

uses
  IupOrm, System.Rtti, IupOrm.LiveBindings.Factory, IupOrm.Context.Factory,
  IupOrm.Context.Interfaces, System.SysUtils, IupOrm.LazyLoad.Interfaces,
  IupOrm.Exceptions, IupOrm.Rtti.Utilities, IupOrm.Context.Map.Interfaces;

{ TioActiveListBindSourceAdapter<T> }

procedure TioActiveInterfaceListBindSourceAdapter.Append(AObject: TObject);
begin
  // Set sone InsertObj subsystem variables
  // Then call the standard code
  FInsertObj_NewObj := AObject;
  FInsertObj_Enabled := True;
  Self.Append;
end;

constructor TioActiveInterfaceListBindSourceAdapter.Create(const ATypeName, ATypeAlias, AWhereStr: String; const AOwner: TComponent;
  const AList: TObject; const AutoLoadData, AUseObjStatus, AOwnsObject: Boolean);
begin
  FAutoLoadData := AutoLoadData;
  FReloadDataOnRefresh := True;
  FUseObjStatus := AUseObjStatus;
  inherited Create(AOwner, AList, ATypeAlias, ATypeName, AOwnsObject);
  FLocalOwnsObject := AOwnsObject;
  FWhereStr := AWhereStr;
  FTypeName := ATypeName;
  FTypeAlias := ATypeAlias;
  // Set Master & Details adapters reference
  FMasterAdaptersContainer := nil;
  FDetailAdaptersContainer := TioLiveBindingsFactory.DetailAdaptersContainer(Self);
  // Init InsertObj subsystem values
  FInsertObj_Enabled := False;
  FInsertObj_NewObj := nil;
end;

destructor TioActiveInterfaceListBindSourceAdapter.Destroy;
begin
  // Detach itself from MasterAdapterContainer (if it's contained)
  if Assigned(FMasterAdaptersContainer) then
    FMasterAdaptersContainer.RemoveBindSourceAdapter(Self);
  // Free the DetailAdaptersContainer
  FDetailAdaptersContainer.Free;
  inherited;
end;

procedure TioActiveInterfaceListBindSourceAdapter.DoAfterDelete;
begin
  inherited;
  // Send a notification to other ActiveBindSourceAdapters & BindSource
  Notify(
         Self,
         TioLiveBindingsFactory.Notification(Self, Self.Current, ntAfterDelete)
        );
end;

procedure TioActiveInterfaceListBindSourceAdapter.DoAfterInsert;
var
  ObjToFree: TObject;
  AInterface: IInterface;
begin
  // If enabled subsitute the new object with the FInsertObj_NewObj (Append(AObject:TObject))
  //  then destroy the "olr" new object
  if FInsertObj_Enabled then
  begin
    try
      if Supports(FInsertObj_NewObj, IInterface, AInterface) then
      begin
        ObjToFree := Self.List[Self.ItemIndex] as TObject;
        ObjToFree.Free;
        Self.List[Self.ItemIndex] := AInterface;
      end
      else
        raise EIupOrmException.Create(Self.ClassName + ': "FInsertObj_NewObj" does not implement IInterface.');
    finally
      // Reset InsertObj subsystem
      FInsertObj_Enabled := False;
      FInsertObj_NewObj := nil;
    end;
  end;
  // Execute AfterInsert event handler
  inherited;
end;

procedure TioActiveInterfaceListBindSourceAdapter.DoAfterPost;
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

procedure TioActiveInterfaceListBindSourceAdapter.DoAfterScroll;
begin
  inherited;
  Self.FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

procedure TioActiveInterfaceListBindSourceAdapter.DoBeforeDelete;
begin
inherited;
  if Self.UseObjStatus then
  begin
    Self.SetObjStatus(osDeleted);
    Abort;
  end else TIupOrm.Delete(Self.Current);
end;

procedure TioActiveInterfaceListBindSourceAdapter.DoBeforeOpen;
begin
  inherited;
  if FAutoLoadData
    then TIupOrm.Load(FTypeName, FTypeAlias)._Where(FWhereStr).ToList(Self.List);
end;

procedure TioActiveInterfaceListBindSourceAdapter.DoBeforeRefresh;
begin
  inherited;
  // Per fare l reload dei dati dal DB anche FAutoLoadData deve essere True
  //  perchè altrimenti dopo aver riattivato se stesso non farebbe
  // alcun caricamento nel DoBeforeOpen e quindi si otterrebbe una lista
  // completamente vuota
  if FReloadDataOnRefresh and FAutoLoadData then
  begin
    Self.First;  // Bug
    Self.Active := False;
    Self.List.Clear;
    Self.Active := True;
  end;
end;

procedure TioActiveInterfaceListBindSourceAdapter.DoNotify(
  ANotification: IioBSANotification);
begin
  if Assigned(FonNotify)
    then FonNotify(Self, ANotification);
end;

procedure TioActiveInterfaceListBindSourceAdapter.ExtractDetailObject(
  AMasterObj: TObject);
var
  ADetailObj: TObject;
  AValue: TValue;
  ALazyLoadableObj: IioLazyLoadable;
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
  // If is a LazyLoadable list then set the internal List
  //  NB: Assegnare direttamente anche i LazyLoadable come se fossero delle liste
  //       normali dava dei problemi (non dava errori ma non usciva nulla)
  if Supports(ADetailObj, IioLazyLoadable, ALazyLoadableObj)
    then ADetailObj := ALazyLoadableObj.GetInternalObject;
  // Set it to the Adapter itself
  Self.SetDataObject(ADetailObj);
end;

function TioActiveInterfaceListBindSourceAdapter.GetDataObject: TObject;
begin
  Result := Self.List;
end;

function TioActiveInterfaceListBindSourceAdapter.GetDetailBindSourceAdapter(AOwner:TComponent;
  AMasterPropertyName: String): TBindSourceAdapter;
begin
  // Return the requested DetailBindSourceAdapter and set the current master object
  Result := FDetailAdaptersContainer.GetBindSourceAdapter(AOwner, BaseObjectRttiType.Name, AMasterPropertyName);
  FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

function TioActiveInterfaceListBindSourceAdapter.GetNaturalObjectBindSourceAdapter(
  AOwner: TComponent): TBindSourceAdapter;
begin
  Result := TioLiveBindingsFactory.NaturalObjectBindSourceAdapter(AOwner, Self);
end;

procedure TioActiveInterfaceListBindSourceAdapter.Insert(AObject: TObject);
begin
  // Set sone InsertObj subsystem variables
  // Then call the standard code
  FInsertObj_NewObj := AObject;
  FInsertObj_Enabled := True;
  Self.Insert;
end;

procedure TioActiveInterfaceListBindSourceAdapter.Notify(Sender: TObject;
  ANotification: IioBSANotification);
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

procedure TioActiveInterfaceListBindSourceAdapter.Persist(ReloadData:Boolean=False);
begin
  // Persist
  TIupOrm.PersistCollection(Self.List);
  // Reload
  if ReloadData then
  begin
    Self.DoBeforeOpen;
    Self.Refresh;
  end;
end;

function TioActiveInterfaceListBindSourceAdapter.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  // RefCount disabled
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TioActiveInterfaceListBindSourceAdapter.Refresh(ReloadData: Boolean);
var
  PrecReloadData: Boolean;
begin
  PrecReloadData := FReloadDataOnRefresh;
  Self.FReloadDataOnRefresh := ReloadData;
  inherited Refresh;
  Self.FReloadDataOnRefresh := PrecReloadData;
end;

procedure TioActiveInterfaceListBindSourceAdapter.SetBindSource(ANotifiableBindSource:IioNotifiableBindSource);
begin
  FBindSource := ANotifiableBindSource;
end;

procedure TioActiveInterfaceListBindSourceAdapter.SetDataObject(const AObj: TObject);
var
  ALazyLoadableObj: IioLazyLoadable;
begin
  Self.First;  // Bug
  Self.Active := False;
  // If is a LazyLoadable list then set the internal List
  //  NB: Assegnare direttamente anche i LazyLoadable come se fossero delle liste
  //       normali dava dei problemi (non dava errori ma non usciva nulla)
//  if Supports(AObj, IioLazyLoadable, ALazyLoadableObj)
//    then AObj := TList<TObject>(ALazyLoadableObj.GetInternalObject);
//  Self.SetList(AObj as TList<IInterface>, False);  // NB: AOwns (2° parameters) = False ABSOLUTELY!!!!!!
  Self.SetList(TList<IInterface>(AObj), False);  // NB: AOwns (2° parameters) = False ABSOLUTELY!!!!!!
  Self.Active := True;
end;

procedure TioActiveInterfaceListBindSourceAdapter.SetMasterAdapterContainer(
  AMasterAdapterContainer: IioDetailBindSourceAdaptersContainer);
begin
  FMasterAdaptersContainer := AMasterAdapterContainer;
end;

procedure TioActiveInterfaceListBindSourceAdapter.SetMasterProperty(
  AMasterProperty: IioContextProperty);
begin
  FMasterPropertyName := AMasterProperty.GetName;
end;

procedure TioActiveInterfaceListBindSourceAdapter.SetObjStatus(
  AObjStatus: TIupOrmObjectStatus);
begin
  TioContextFactory.Context(Self.Current.ClassName, nil, Self.Current).ObjectStatus := AObjStatus;
end;

function TioActiveInterfaceListBindSourceAdapter.UseObjStatus: Boolean;
begin
  Result := FUseObjStatus;
end;

function TioActiveInterfaceListBindSourceAdapter._AddRef: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

function TioActiveInterfaceListBindSourceAdapter._Release: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

end.
