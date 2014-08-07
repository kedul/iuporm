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
  strict protected
    procedure NewBindSourceAdapter(AMasterClassName: String; AMasterPropertyName:String);
  public
    constructor Create(AMasterAdapter:IioContainedBindSourceAdapter); overload;
    destructor Destroy; override;
    procedure SetMasterObject(AMasterObj: TObject);
    function GetBindSourceAdapter(AMasterClassName: String; AMasterPropertyName:String): TBindSourceAdapter;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification);
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

function TioDetailAdaptersContainer.GetBindSourceAdapter(
  AMasterClassName: String; AMasterPropertyName: String): TBindSourceAdapter;
begin
  // If the requested adapter not exist create and add it to the container
  if not FDetailAdapters.ContainsKey(AMasterPropertyName)
    then Self.NewBindSourceAdapter(AMasterClassName, AMasterPropertyName);
  // Return the requested adapter
  Result := FDetailAdapters.Items[AMasterPropertyName] as TBindSourceAdapter;
end;

procedure TioDetailAdaptersContainer.NewBindSourceAdapter(
  AMasterClassName: String; AMasterPropertyName: String);
var
  AMasterContext: IioContext;
  AMasterProperty: IioContextProperty;
  NewAdapter: IioContainedBindSourceAdapter;
begin
  // Retrieve MasterContext and MasterProperty
  AMasterContext := TioContextFactory.Context(AMasterClassName);
  AMasterProperty := AMasterContext.GetProperties.GetPropertyByName(AMasterPropertyName);
  // Create the Adapter
  case AMasterProperty.GetRelationType of
    ioRTBelongsTo, ioRTHasOne:
      NewAdapter := TioLiveBindingsFactory.ContainedObjectBindSourceAdapter(AMasterProperty);
    ioRTHasMany:
      NewAdapter := TioLiveBindingsFactory.ContainedListBindSourceAdapter(AMasterProperty);
    else raise EIupOrmException.Create(Self.ClassName + ': Relation not found');
  end;
  // Set the MasterAdapterConatainer reference (Self)
  NewAdapter.SetMasterAdapterContainer(Self);
  // Add the new adapter to the contained adapters
  Self.FDetailAdapters.Add(AMasterPropertyName, NewAdapter);
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
  for AAdapter in FDetailAdapters.Values do
    if Sender <> TObject(AAdapter) then AAdapter.Notify(Self, ANotification);
end;

procedure TioDetailAdaptersContainer.SetMasterObject(AMasterObj: TObject);
var
  ABindSourceAdapter: IioContainedBindSourceAdapter;
begin
  for ABindSourceAdapter in FDetailAdapters.Values do
    ABindSourceAdapter.ExtractDetailObject(AMasterObj);
end;

end.
