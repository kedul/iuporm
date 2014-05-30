unit IupOrm.LiveBindings.DetailAdaptersContainer;

interface

uses
  IupOrm.LiveBindings.Interfaces, IupOrm.CommonTypes, Data.Bind.ObjectScope;

type

  TioDetailAdaptersContainer = class (TInterfacedObject, IioDetailBindSourceAdaptersContainer)
  strict private
    FDetailAdapters: TioDetailAdapters;
  strict protected
    procedure NewBindSourceAdapter(AMasterClassRef:TioClassRef; AMasterPropertyName:String);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetMasterObject(AMasterObj: TObject);
    function GetBindSourceAdapter(AMasterClassRef:TioClassRef; AMasterPropertyName:String): TBindSourceAdapter;
  end;

implementation

uses
  IupOrm.Context.Interfaces, IupOrm.Context.Factory,
  IupOrm.Context.Properties.Interfaces, IupOrm.Attributes,
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter,
  IupOrm.LiveBindings.ActiveListBindSourceAdapter, System.Generics.Collections,
  IupOrm.Exceptions, IupOrm.LiveBindings.Factory;

{ TioDetailAdaptersContainer }

constructor TioDetailAdaptersContainer.Create;
begin
  inherited;
  FDetailAdapters := TioDetailAdapters.Create;
end;

destructor TioDetailAdaptersContainer.Destroy;
begin
  FDetailAdapters.Free;
  inherited;
end;

function TioDetailAdaptersContainer.GetBindSourceAdapter(
  AMasterClassRef: TioClassRef; AMasterPropertyName: String): TBindSourceAdapter;
begin
  // If the requested adapter not exist create and add it to the container
  if not FDetailAdapters.ContainsKey(AMasterPropertyName)
    then Self.NewBindSourceAdapter(AMasterClassRef, AMasterPropertyName);
  // Return the requested adapter
  Result := FDetailAdapters.Items[AMasterPropertyName] as TBindSourceAdapter;
end;

procedure TioDetailAdaptersContainer.NewBindSourceAdapter(
  AMasterClassRef: TioClassRef; AMasterPropertyName: String);
var
  AMasterContext: IioContext;
  AMasterProperty: IioContextProperty;
  NewAdapter: IioContainedBindSourceAdapter;
begin
  AMasterContext := TioContextFactory.Context(AMasterClassRef);
  AMasterProperty := AMasterContext.GetProperties.GetPropertyByName(AMasterPropertyName);
  case AMasterProperty.GetRelationType of
    ioRTBelongsTo, ioRTHasOne:
      NewAdapter := TioLiveBindingsFactory.ContainedObjectBindSourceAdapter(AMasterProperty);
    ioRTHasMany:
      NewAdapter := TioLiveBindingsFactory.ContainedListBindSourceAdapter(AMasterProperty);
    else raise EIupOrmException.Create(Self.ClassName + ': Relation not found');
  end;
  Self.FDetailAdapters.Add(AMasterPropertyName, NewAdapter);
end;

procedure TioDetailAdaptersContainer.SetMasterObject(AMasterObj: TObject);
var
  ABindSourceAdapter: IioContainedBindSourceAdapter;
begin
  for ABindSourceAdapter in FDetailAdapters.Values do
    ABindSourceAdapter.ExtractDetailObject(AMasterObj);
end;

end.
