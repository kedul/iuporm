unit IupOrm.LiveBindings.ActiveListBindSourceAdapter;

interface

uses
  Data.Bind.ObjectScope, IupOrm.Where, System.Classes,
  System.Generics.Collections, IupOrm.Where.SqlItems.Interfaces,
  IupOrm.CommonTypes, IupOrm.Context.Properties.Interfaces,
  IupOrm.LiveBindings.Interfaces;

type

  TioActiveListBindSourceAdapter = class(TListBindSourceAdapter, IioContainedBindSourceAdapter)
  strict private
    FWhereStr: String;
    FClassRef: TioClassRef;
    FLocalOwnsObject: Boolean;
    FAutoLoadData: Boolean;
    FMasterProperty: IioContextProperty;
    FDetailAdaptersContainer: IioDetailBindSourceAdaptersContainer;
  strict protected
    function _Release: Integer; stdcall;
    procedure DoBeforeOpen; override;
    procedure DoBeforeRefresh; override;
    procedure DoBeforeDelete; override;
    procedure DoAfterPost; override;
    procedure DoAfterScroll; override;
    procedure SetDataObject(AObj: TList<TObject>);
  public
    constructor Create(AClassRef:TioClassRef; AWhereStr:String; AOwner: TComponent; AList: TList<TObject>; AutoLoadData: Boolean; AOwnsObject: Boolean = True); overload;
    procedure SetMasterProperty(AMasterProperty: IioContextProperty);
    procedure ExtractDetailObject(AMasterObj: TObject);
    function GetDetailBindSourceAdapter(AMasterPropertyName:String): TBindSourceAdapter;
  end;

implementation

uses
  IupOrm, System.Rtti, IupOrm.LiveBindings.Factory;

{ TioActiveListBindSourceAdapter<T> }

constructor TioActiveListBindSourceAdapter.Create(AClassRef: TioClassRef;
  AWhereStr: String; AOwner: TComponent; AList: TList<TObject>; AutoLoadData,
  AOwnsObject: Boolean);
begin
  FAutoLoadData := AutoLoadData;
  inherited Create(AOwner, AList, AClassRef, AOwnsObject);
  FLocalOwnsObject := AOwnsObject;
  FWhereStr := AWhereStr;
  FClassRef := AClassRef;
  FDetailAdaptersContainer := TioLiveBindingsFactory.DetailAdaptersContainer;
end;

procedure TioActiveListBindSourceAdapter.DoAfterPost;
begin
  inherited;
  TIupOrm.Persist(Self.Current);
end;

procedure TioActiveListBindSourceAdapter.DoAfterScroll;
begin
  inherited;
  Self.FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

procedure TioActiveListBindSourceAdapter.DoBeforeDelete;
begin
  inherited;
  TIupOrm.Delete(Self.Current);
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
  Self.First;  // Bug
  Self.Active := False;
  Self.List.Clear;
  Self.Active := True;
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

function TioActiveListBindSourceAdapter.GetDetailBindSourceAdapter(
  AMasterPropertyName: String): TBindSourceAdapter;
begin
  // Return the requested DetailBindSourceAdapter and set the current master object
  Result := FDetailAdaptersContainer.GetBindSourceAdapter(Self.FClassRef.ClassName, AMasterPropertyName);
  FDetailAdaptersContainer.SetMasterObject(Self.Current);
end;

procedure TioActiveListBindSourceAdapter.SetDataObject(AObj: TList<TObject>);
begin
  Self.First;  // Bug
  Self.Active := False;
  Self.SetList(AObj, False);  // NB: AOwns (2° parameters) = False ABSOLUTELY!!!!!!
  Self.Active := True;
end;

procedure TioActiveListBindSourceAdapter.SetMasterProperty(
  AMasterProperty: IioContextProperty);
begin
  FMasterProperty := AMasterProperty;
end;

function TioActiveListBindSourceAdapter._Release: Integer;
begin
  // Nothing
end;

end.
