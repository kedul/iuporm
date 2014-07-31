unit IupOrm.LiveBindings.ActiveObjectBindSourceAdapter;

interface

uses
  Data.Bind.ObjectScope, IupOrm.CommonTypes, System.Classes, System.Generics.Collections,
  IupOrm.Context.Properties.Interfaces, IupOrm.LiveBindings.Interfaces;

type

  TioActiveObjectBindSourceAdapter = class(TObjectBindSourceAdapter, IioContainedBindSourceAdapter, IioActiveBindSourceAdapter)
  strict private
    FWhereStr: String;
    FClassRef: TioClassRef;
    FUseObjStatus: Boolean;  // Not use directly, use UseObjStatus function or property even for internal use
    FLocalOwnsObject: Boolean;
    FAutoLoadData: Boolean;
    FMasterProperty: IioContextProperty;
    FDetailAdaptersContainer: IioDetailBindSourceAdaptersContainer;
  strict protected
    procedure DoBeforeOpen; override;
    procedure DoBeforeRefresh; override;
    procedure DoBeforeDelete; override;
    procedure DoAfterPost; override;
    procedure DoAfterScroll; override;
    procedure SetDataObject(AObj: TObject);
    procedure SetObjStatus(AObjStatus: TIupOrmObjectStatus);
    function UseObjStatus: Boolean;
  public
    constructor Create(AClassRef:TioClassRef; AWhereStr:String; AOwner: TComponent; AObject: TObject; AutoLoadData, AUseObjStatus: Boolean; AOwnsObject: Boolean = True); overload;
    procedure SetMasterProperty(AMasterProperty: IioContextProperty);
    procedure ExtractDetailObject(AMasterObj: TObject);
    procedure Persist(ReloadData:Boolean=False);
    function GetDetailBindSourceAdapter(AMasterPropertyName:String): TBindSourceAdapter;
  end;

implementation

uses
  IupOrm, System.Rtti, IupOrm.Context.Factory, System.SysUtils;

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
end;

procedure TioActiveObjectBindSourceAdapter.DoAfterPost;
begin
  inherited;
  if Self.UseObjStatus
    then Self.SetObjStatus(osDirty)
    else TIupOrm.Persist(Self.Current);
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

procedure TioActiveObjectBindSourceAdapter.Persist(ReloadData:Boolean=False);
begin
  // Persist
  TIupOrm.Persist(Self.DataObject);
  // Reload
  if ReloadData then Self.DoBeforeOpen;
end;

procedure TioActiveObjectBindSourceAdapter.SetDataObject(AObj: TObject);
begin
  Self.First;  // Bug
  Self.Active := False;
  Self.SetDataObject(AObj);
  Self.Active := True;
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
