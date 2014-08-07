unit IupOrm.LiveBindings.ActiveObjectBindSourceAdapter;

interface

uses
  Data.Bind.ObjectScope, IupOrm.CommonTypes, System.Classes, System.Generics.Collections,
  IupOrm.Context.Properties.Interfaces, IupOrm.LiveBindings.Interfaces,
  IupOrm.LiveBindings.Notification;

type

  TioActiveObjectBindSourceAdapter = class(TObjectBindSourceAdapter, IioContainedBindSourceAdapter, IioActiveBindSourceAdapter)
  strict private
    FWhereStr: String;
    FClassRef: TioClassRef;
    FUseObjStatus: Boolean;  // Not use directly, use UseObjStatus function or property even for internal use
    FLocalOwnsObject: Boolean;
    FAutoLoadData: Boolean;
    FMasterProperty: IioContextProperty;
    FMasterAdaptersContainer: IioDetailBindSourceAdaptersContainer;
    FDetailAdaptersContainer: IioDetailBindSourceAdaptersContainer;
    FBindSource: IioNotifiableBindSource;
    FonNotify: TioBSANotificationEvent;
  strict protected
    procedure DoBeforeOpen; override;
    procedure DoBeforeRefresh; override;
    procedure DoBeforeDelete; override;
    procedure DoAfterDelete; override;
    procedure DoAfterPost; override;
    procedure DoAfterScroll; override;
    procedure SetDataObject(AObj: TObject);
    procedure SetObjStatus(AObjStatus: TIupOrmObjectStatus);
    function UseObjStatus: Boolean;
    procedure DoNotify(ANotification:IioBSANotification);
  public
    constructor Create(AClassRef:TioClassRef; AWhereStr:String; AOwner: TComponent; AObject: TObject; AutoLoadData, AUseObjStatus: Boolean; AOwnsObject: Boolean = True); overload;
    procedure SetMasterAdapterContainer(AMasterAdapterContainer:IioDetailBindSourceAdaptersContainer);
    procedure SetMasterProperty(AMasterProperty: IioContextProperty);
    procedure SetBindSource(ABindSource:TObject);
    procedure ExtractDetailObject(AMasterObj: TObject);
    procedure Persist(ReloadData:Boolean=False);
    function GetDetailBindSourceAdapter(AMasterPropertyName:String): TBindSourceAdapter;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification);

    property ioOnNotify:TioBSANotificationEvent read FonNotify write FonNotify;
  end;

implementation

uses
  IupOrm, System.Rtti, IupOrm.Context.Factory, System.SysUtils,
  IupOrm.LiveBindings.Factory;

{ TioActiveListBindSourceAdapter<T> }

constructor TioActiveObjectBindSourceAdapter.Create(AClassRef:TioClassRef; AWhereStr: String;
  AOwner: TComponent; AObject: TObject; AutoLoadData, AUseObjStatus: Boolean; AOwnsObject: Boolean);
begin
  FAutoLoadData := AutoLoadData;
  FUseObjStatus := AUseObjStatus;
  inherited Create(AOwner, AObject, AClassRef, AOwnsObject);
  FLocalOwnsObject := AOwnsObject;
  FWhereStr := AWhereStr;
  FClassRef := AClassRef;
  // Set Master & Details adapters reference
  FMasterAdaptersContainer := nil;
  FDetailAdaptersContainer := TioLiveBindingsFactory.DetailAdaptersContainer(Self);
end;

procedure TioActiveObjectBindSourceAdapter.DoAfterDelete;
begin
  inherited;
  // Send a notification to other ActiveBindSourceAdapters & BindSource
  Notify(
         Self,
         TioLiveBindingsFactory.Notification(Self, Self.Current, ntAfterDelete)
        );
end;

procedure TioActiveObjectBindSourceAdapter.DoAfterPost;
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

procedure TioActiveObjectBindSourceAdapter.DoAfterScroll;
begin
  inherited;
  Self.FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

procedure TioActiveObjectBindSourceAdapter.DoBeforeDelete;
begin
  inherited;
  if Self.UseObjStatus then
  begin
    Self.SetObjStatus(osDeleted);
    Abort;
  end else TIupOrm.Delete(Self.Current);
end;

procedure TioActiveObjectBindSourceAdapter.DoBeforeOpen;
begin
  inherited;
  // Load the object and assign it to the Adapter
  if FAutoLoadData
    then Self.SetDataObject(   TIupOrm.Load(FClassRef)._Where(FWhereStr).ToObject   );
end;

procedure TioActiveObjectBindSourceAdapter.DoBeforeRefresh;
var
  PrevDataObject: TObject;
begin
  inherited;
  // Deactivate the adapter
  Self.Active := False;
  // Get actual DataObject
  PrevDataObject := Self.DataObject;
  // If ActualDataObject is assigned and OwnsObject = True then destroy the object
  if Assigned(PrevDataObject) and Self.FLocalOwnsObject then PrevDataObject.Free;
  // Activate the Adapter (after the adapter fire the onBeforeOpen event that Load
  //  the NewObject
  Self.Active := True;
end;


procedure TioActiveObjectBindSourceAdapter.DoNotify(
  ANotification: IioBSANotification);
begin
  if Assigned(FonNotify)
    then ioOnNotify(ANotification);
end;

procedure TioActiveObjectBindSourceAdapter.ExtractDetailObject(
  AMasterObj: TObject);
var
  ADetailObj: TObject;
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
    then ADetailObj := AValue.AsObject;
  // Set it to the Adapter itself
  Self.SetDataObject(ADetailObj);
end;

function TioActiveObjectBindSourceAdapter.GetDetailBindSourceAdapter(
  AMasterPropertyName: String): TBindSourceAdapter;
begin
  // Return the requested DetailBindSourceAdapter and set the current master object
  Result := FDetailAdaptersContainer.GetBindSourceAdapter(Self.FClassRef.ClassName, AMasterPropertyName);
  FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

procedure TioActiveObjectBindSourceAdapter.Notify(Sender: TObject;
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

procedure TioActiveObjectBindSourceAdapter.Persist(ReloadData:Boolean=False);
begin
  // Persist
  TIupOrm.Persist(Self.DataObject);
  // Reload
  if ReloadData then Self.DoBeforeOpen;
end;

procedure TioActiveObjectBindSourceAdapter.SetBindSource(ABindSource: TObject);
var
  ANotifiableBindSource: IioNotifiableBindSource;
begin
  if Supports(ABindSource, IioNotifiableBindSource, ANotifiableBindSource)
    then FBindSource := ANotifiableBindSource
    else FBindSource := nil;
end;

procedure TioActiveObjectBindSourceAdapter.SetDataObject(AObj: TObject);
begin
  Self.First;  // Bug
  Self.Active := False;
  Self.SetDataObject(AObj);
  Self.Active := True;
end;

procedure TioActiveObjectBindSourceAdapter.SetMasterAdapterContainer(
  AMasterAdapterContainer: IioDetailBindSourceAdaptersContainer);
begin
  FMasterAdaptersContainer := AMasterAdapterContainer;
end;

procedure TioActiveObjectBindSourceAdapter.SetMasterProperty(
  AMasterProperty: IioContextProperty);
begin
  FMasterProperty := AMasterProperty;
end;

procedure TioActiveObjectBindSourceAdapter.SetObjStatus(
  AObjStatus: TIupOrmObjectStatus);
begin
  TioContextFactory.Context(Self.Current.ClassName, nil, Self.Current).ObjectStatus := AObjStatus;
end;

function TioActiveObjectBindSourceAdapter.UseObjStatus: Boolean;
begin
  Result := FUseObjStatus;
end;

end.
