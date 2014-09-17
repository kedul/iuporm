unit IupOrm.LiveBindings.DetailAdaptersContainer;

interface

uses
  IupOrm.LiveBindings.Interfaces, IupOrm.CommonTypes, Data.Bind.ObjectScope,
  System.Classes;

type

  TioDetailAdaptersContainer = class (TInterfacedObject, IioDetailBindSourceAdaptersContainer, IioNotifiableBindSource)
  strict private
    FMasterAdapter: IioContainedBindSourceAdapter;
    FDetailAdapters: TioDetailAdapters;
  public
    constructor Create(AMasterAdapter:IioContainedBindSourceAdapter); overload;
    destructor Destroy; override;
    procedure SetMasterObject(AMasterObj: TObject);
    function GetBindSourceAdapter(AOwner: TComponent; AMasterClassName: String; AMasterPropertyName:String): TBindSourceAdapter;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification);
    procedure RemoveBindSourceAdapter(ABindSourceAdapter: IioContainedBindSourceAdapter);

    // =========================================================================
    // Part for the support of the IioNotifiableBindSource interfaces (Added by IupOrm)
    //  because is not implementing IInterface (NB: RefCount DISABLED)
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // =========================================================================
  end;

implementation

uses
  IupOrm.Context.Interfaces, IupOrm.Context.Factory,
  IupOrm.Context.Properties.Interfaces, IupOrm.Attributes,
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter,
  IupOrm.LiveBindings.ActiveListBindSourceAdapter, System.Generics.Collections,
  IupOrm.Exceptions, IupOrm.LiveBindings.Factory;

{ TioDetailAdaptersContainer }

constructor TioDetailAdaptersContainer.Create(AMasterAdapter:IioContainedBindSourceAdapter);
begin
  inherited Create;
  FMasterAdapter := AMasterAdapter;
  FDetailAdapters := TioDetailAdapters.Create;
end;

destructor TioDetailAdaptersContainer.Destroy;
begin
  FDetailAdapters.Free;
  inherited;
end;

function TioDetailAdaptersContainer.GetBindSourceAdapter(AOwner: TComponent;
  AMasterClassName: String; AMasterPropertyName: String): TBindSourceAdapter;
var
  AMasterContext: IioContext;
  AMasterProperty: IioContextProperty;
  NewAdapter: IioContainedBindSourceAdapter;
begin
  Result := nil;
  // Retrieve MasterContext and MasterProperty
  AMasterContext := TioContextFactory.Context(AMasterClassName);
  AMasterProperty := AMasterContext.GetProperties.GetPropertyByName(AMasterPropertyName);
  // Create the Adapter
  case AMasterProperty.GetRelationType of
    ioRTBelongsTo, ioRTHasOne:
      NewAdapter := TioLiveBindingsFactory.ContainedObjectBindSourceAdapter(AOwner, AMasterProperty);
    ioRTHasMany:
      NewAdapter := TioLiveBindingsFactory.ContainedListBindSourceAdapter(AOwner, AMasterProperty);
    else raise EIupOrmException.Create(Self.ClassName + ': Relation not found');
  end;
  // Set the MasterAdapterConatainer reference (Self)
  NewAdapter.SetMasterAdapterContainer(Self);
  // Add the new adapter to the contained adapters
  Self.FDetailAdapters.Add(NewAdapter);
  // Return the new adapter
  Result := NewAdapter as TBindSourceAdapter;
end;

procedure TioDetailAdaptersContainer.Notify(Sender: TObject;
  ANotification: IioBSANotification);
var
  AAdapter: IioContainedBindSourceAdapter;
begin
  // Replicate notification to MasterBindSourceAdapter
  if Sender <> TObject(FMasterAdapter)
    then FMasterAdapter.Notify(Self, ANotification);
  // Replicate notification to DetailBindSourceAdapters
  for AAdapter in FDetailAdapters do
    if Sender <> TObject(AAdapter) then AAdapter.Notify(Self, ANotification);
end;

function TioDetailAdaptersContainer.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  // RefCount disabled
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TioDetailAdaptersContainer.RemoveBindSourceAdapter(
  ABindSourceAdapter: IioContainedBindSourceAdapter);
begin
  FDetailAdapters.Extract(ABindSourceAdapter);
end;

procedure TioDetailAdaptersContainer.SetMasterObject(AMasterObj: TObject);
var
  ABindSourceAdapter: IioContainedBindSourceAdapter;
begin
  for ABindSourceAdapter in FDetailAdapters do
    ABindSourceAdapter.ExtractDetailObject(AMasterObj);
end;

function TioDetailAdaptersContainer._AddRef: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

function TioDetailAdaptersContainer._Release: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

end.
