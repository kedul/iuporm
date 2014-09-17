unit IupOrm.LiveBindings.ActiveListBindSourceAdapter;

interface

uses
  Data.Bind.ObjectScope, IupOrm.Where, System.Classes,
  System.Generics.Collections, IupOrm.Where.SqlItems.Interfaces,
  IupOrm.CommonTypes, IupOrm.Context.Properties.Interfaces,
  IupOrm.LiveBindings.Interfaces, IupOrm.LiveBindings.Notification;

type

  TioActiveListBindSourceAdapter = class(TListBindSourceAdapter, IioContainedBindSourceAdapter, IioActiveBindSourceAdapter, IioNaturalBindSourceAdapterSource)
  strict private
    FWhereStr: String;
    FClassRef: TioClassRef;
    FUseObjStatus: Boolean;  // Not use directly, use UseObjStatus function or property even for internal use
    FLocalOwnsObject: Boolean;
    FAutoLoadData: Boolean;
    FReloadDataOnRefresh: Boolean;
    FMasterProperty: IioContextProperty;
    FMasterAdaptersContainer: IioDetailBindSourceAdaptersContainer;
    FDetailAdaptersContainer: IioDetailBindSourceAdaptersContainer;
    FBindSource: IioNotifiableBindSource;
    FonNotify: TioBSANotificationEvent;
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
    procedure SetDataObject(AObj: TList<TObject>);
    procedure SetObjStatus(AObjStatus: TIupOrmObjectStatus);
    function UseObjStatus: Boolean;
    procedure DoNotify(ANotification:IioBSANotification);
  public
    constructor Create(AClassRef:TioClassRef; AWhereStr:String; AOwner: TComponent; AList: TList<TObject>; AutoLoadData, AUseObjStatus: Boolean; AOwnsObject: Boolean = True); overload;
    destructor Destroy; override;
    procedure SetMasterAdapterContainer(AMasterAdapterContainer:IioDetailBindSourceAdaptersContainer);
    procedure SetMasterProperty(AMasterProperty: IioContextProperty);
    procedure SetBindSource(ANotifiableBindSource:IioNotifiableBindSource);
    procedure ExtractDetailObject(AMasterObj: TObject);
    procedure Persist(ReloadData:Boolean=False);
    function GetDetailBindSourceAdapter(AOwner:TComponent; AMasterPropertyName:String): TBindSourceAdapter;
    function GetNaturalObjectBindSourceAdapter(AOwner:TComponent): TBindSourceAdapter;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification); virtual;
    procedure Refresh(ReloadData:Boolean); overload;

    property ioOnNotify:TioBSANotificationEvent read FonNotify write FonNotify;
  end;

implementation

uses
  IupOrm, System.Rtti, IupOrm.LiveBindings.Factory, IupOrm.Context.Factory,
  IupOrm.Context.Interfaces, System.SysUtils, IupOrm.LazyLoad.Interfaces,
  FMX.Dialogs, IupOrm.Exceptions;

{ TioActiveListBindSourceAdapter<T> }

constructor TioActiveListBindSourceAdapter.Create(AClassRef: TioClassRef;
  AWhereStr: String; AOwner: TComponent; AList: TList<TObject>; AutoLoadData,
  AUseObjStatus, AOwnsObject: Boolean);
begin
  FAutoLoadData := AutoLoadData;
  FReloadDataOnRefresh := True;
  FUseObjStatus := AUseObjStatus;
  inherited Create(AOwner, AList, AClassRef, AOwnsObject);
  FLocalOwnsObject := AOwnsObject;
  FWhereStr := AWhereStr;
  FClassRef := AClassRef;
  // Set Master & Details adapters reference
  FMasterAdaptersContainer := nil;
  FDetailAdaptersContainer := TioLiveBindingsFactory.DetailAdaptersContainer(Self);
end;

destructor TioActiveListBindSourceAdapter.Destroy;
begin
  // Detach itself from MasterAdapterContainer (if it's contained)
  if Assigned(FMasterAdaptersContainer) then
    FMasterAdaptersContainer.RemoveBindSourceAdapter(Self);
  // Free the DetailAdaptersContainer
  FDetailAdaptersContainer.Free;
  inherited;
end;

procedure TioActiveListBindSourceAdapter.DoAfterDelete;
begin
  inherited;
  // Send a notification to other ActiveBindSourceAdapters & BindSource
  Notify(
         Self,
         TioLiveBindingsFactory.Notification(Self, Self.Current, ntAfterDelete)
        );
end;

procedure TioActiveListBindSourceAdapter.DoAfterPost;
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

procedure TioActiveListBindSourceAdapter.DoAfterScroll;
begin
  inherited;
  Self.FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

procedure TioActiveListBindSourceAdapter.DoBeforeDelete;
begin
inherited;
  if Self.UseObjStatus then
  begin
    Self.SetObjStatus(osDeleted);
    Abort;
  end else TIupOrm.Delete(Self.Current);
end;

procedure TioActiveListBindSourceAdapter.DoBeforeOpen;
begin
  inherited;
  if FAutoLoadData
    then TIupOrm.Load(FClassRef)._Where(FWhereStr).ToList(Self.List);
end;

procedure TioActiveListBindSourceAdapter.DoBeforeRefresh;
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

procedure TioActiveListBindSourceAdapter.DoNotify(
  ANotification: IioBSANotification);
begin
  if Assigned(FonNotify)
    then FonNotify(Self, ANotification);
end;

procedure TioActiveListBindSourceAdapter.ExtractDetailObject(
  AMasterObj: TObject);
var
  ADetailObj: TList<TObject>;
  AValue: TValue;
begin
  ADetailObj := nil;
  // Check parameter
  if not Assigned(AMasterObj)
    then Exit;
  // Extract master property value
  AValue := FMasterProperty.GetValue(AMasterObj);
  // if not empty extract the detail object
  if not AValue.IsEmpty
    then ADetailObj := TList<TObject>(AValue.AsObject);
  // Set it to the Adapter itself
  Self.SetDataObject(ADetailObj);
end;

function TioActiveListBindSourceAdapter.GetDetailBindSourceAdapter(AOwner:TComponent;
  AMasterPropertyName: String): TBindSourceAdapter;
begin
  // Return the requested DetailBindSourceAdapter and set the current master object
  Result := FDetailAdaptersContainer.GetBindSourceAdapter(AOwner, Self.FClassRef.ClassName, AMasterPropertyName);
  FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

function TioActiveListBindSourceAdapter.GetNaturalObjectBindSourceAdapter(
  AOwner: TComponent): TBindSourceAdapter;
begin
  Result := TioLiveBindingsFactory.NaturalObjectBindSourceAdapter(AOwner, Self);
end;

procedure TioActiveListBindSourceAdapter.Notify(Sender: TObject;
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

procedure TioActiveListBindSourceAdapter.Persist(ReloadData:Boolean=False);
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

function TioActiveListBindSourceAdapter.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  // RefCount disabled
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TioActiveListBindSourceAdapter.Refresh(ReloadData: Boolean);
var
  PrecReloadData: Boolean;
begin
  PrecReloadData := FReloadDataOnRefresh;
  Self.FReloadDataOnRefresh := ReloadData;
  inherited Refresh;
  Self.FReloadDataOnRefresh := PrecReloadData;
end;

procedure TioActiveListBindSourceAdapter.SetBindSource(ANotifiableBindSource:IioNotifiableBindSource);
begin
  FBindSource := ANotifiableBindSource;
end;

procedure TioActiveListBindSourceAdapter.SetDataObject(AObj: TList<TObject>);
var
  ALazyLoadableObj: IioLazyLoadable;
begin
  Self.First;  // Bug
  Self.Active := False;
  // If is a LazyLoadable list then set the internal List
  //  NB: Assegnare direttamente anche i LazyLoadable come se fossero delle liste
  //       normali dava dei problemi (non dava errori ma non usciva nulla)
  if Supports(AObj, IioLazyLoadable, ALazyLoadableObj)
    then AObj := TList<TObject>(ALazyLoadableObj.GetInternalObject);
  Self.SetList(AObj, False);  // NB: AOwns (2° parameters) = False ABSOLUTELY!!!!!!
  Self.Active := True;
end;

procedure TioActiveListBindSourceAdapter.SetMasterAdapterContainer(
  AMasterAdapterContainer: IioDetailBindSourceAdaptersContainer);
begin
  FMasterAdaptersContainer := AMasterAdapterContainer;
end;

procedure TioActiveListBindSourceAdapter.SetMasterProperty(
  AMasterProperty: IioContextProperty);
begin
  FMasterProperty := AMasterProperty;
end;

procedure TioActiveListBindSourceAdapter.SetObjStatus(
  AObjStatus: TIupOrmObjectStatus);
begin
  TioContextFactory.Context(Self.Current.ClassName, nil, Self.Current).ObjectStatus := AObjStatus;
end;

function TioActiveListBindSourceAdapter.UseObjStatus: Boolean;
begin
  Result := FUseObjStatus;
end;

function TioActiveListBindSourceAdapter._AddRef: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

function TioActiveListBindSourceAdapter._Release: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

end.
