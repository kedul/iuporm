unit IupOrm.LiveBindings.InterfaceObjectBindSourceAdapter;

interface

uses
  Data.Bind.ObjectScope, System.Rtti, System.Classes;

type

  /// <summary>Adapter to provide an arbitrary object to TAdapterBindSource</summary>
  TInterfaceObjectBindSourceAdapter<T:IInterface> = class(TBaseObjectBindSourceAdapter)
  private
    FTypeName, FTypeAlias: String;
    FBaseObjectRttiType: TRttiType;
    FDataObject: T;
    FOwnsObject: Boolean;
    FOnBeforeSetDataObject: TSetObjectEvent;
    FOnAfterSetDataObject: TAdapterNotifyEvent;
  protected
    function GetObjectType: TRttiType; override;
    function GetCanActivate: Boolean; override;
    function GetCurrent: TObject; override;
    function GetCount: Integer; override;
    function DeleteAt(AIndex: Integer): Boolean;  override;
    function AppendAt: Integer; override;
    function InsertAt(AIndex: Integer): Integer; override;
    function SupportsNestedFields: Boolean; override;
    function GetCanModify: Boolean; override;
    function GetCanApplyUpdates: Boolean; override;
    function GetCanCancelUpdates: Boolean; override;
    procedure AddFields; virtual;
    procedure InternalApplyUpdates; override;
    procedure InternalCancelUpdates; override;
    procedure DoOnBeforeSetDataObject(ADataObject: T); virtual;
    procedure DoOnAfterSetDataObject; virtual;
    property BaseObjectRttiType:TRttiType read FBaseObjectRttiType;
  public
    constructor Create(const AOwner: TComponent; const AObject: T; const ATypeAlias:String=''; const ATypeName:String=''; const AOwnsObject: Boolean = True); reintroduce; overload; virtual;
    destructor Destroy; override;
    procedure SetDataObject(ADataObject: T; AOwnsObject: Boolean = True);
    property DataObject: T read FDataObject;
    property OnBeforeSetDataObject: TSetObjectEvent read FOnBeforeSetDataObject write FOnBeforeSetDataObject;
    property OnAfterSetDataObject: TAdapterNotifyEvent read FOnAfterSetDataObject write FOnAfterSetDataObject;
  end;

  TInterfaceObjectBindSourceAdapter = class(TInterfaceObjectBindSourceAdapter<IInterface>)
  public
    constructor Create(const AOwner: TComponent; const AObject: TObject; const ATypeAlias:String=''; const ATypeName:String='';
      const AOwnsObject: Boolean = True); reintroduce; overload; virtual;
  end;

implementation


uses SysUtils, IupOrm.Rtti.Utilities, IupOrm, IupOrm.Exceptions;

{ TInterfaceObjectBindSourceAdapter<T> }

procedure TInterfaceObjectBindSourceAdapter<T>.AddFields;
var
  LType: TRttiType;
  LIntf: IGetMemberObject;
begin
  LType := GetObjectType;
  LIntf := TBindSourceAdapterGetMemberObject.Create(Self);
  AddFieldsToList(LType, Self, Self.Fields, LIntf);
  AddPropertiesToList(LType, Self, Self.Fields, LIntf);
end;

function TInterfaceObjectBindSourceAdapter<T>.AppendAt: Integer;
begin
  Assert(False);
end;

constructor TInterfaceObjectBindSourceAdapter<T>.Create(const AOwner: TComponent; const AObject: T; const ATypeAlias:String; const ATypeName:String; const AOwnsObject: Boolean);
begin
  inherited Create(AOwner);
  // Set the BaseObjectType
  FTypeName := ATypeName;
  if FTypeName.IsEmpty then
    FTypeName := TioRttiUtilities.GenericToString<T>;
  FTypeAlias := ATypeAlias;
  FBaseObjectRttiType := TIupOrm.DependencyInjection.Locate(FTypeName).Alias(FTypeAlias).GetItem.RttiType;
  // Set the data object
  SetDataObject(AObject, AOwnsObject);
end;

function TInterfaceObjectBindSourceAdapter<T>.DeleteAt(AIndex: Integer): Boolean;
begin
  Assert(False);
end;

destructor TInterfaceObjectBindSourceAdapter<T>.Destroy;
begin
  if FOwnsObject then
    FreeAndNil(FDataObject);
  inherited;
end;

procedure TInterfaceObjectBindSourceAdapter<T>.DoOnAfterSetDataObject;
begin
  if Assigned(FOnAfterSetDataObject) then
    FOnAfterSetDataObject(Self);
end;

procedure TInterfaceObjectBindSourceAdapter<T>.DoOnBeforeSetDataObject(ADataObject: T);
begin
  if Assigned(FOnBeforeSetDataObject) then
    FOnBeforeSetDataObject(Self, ADataObject as TObject);
end;

function TInterfaceObjectBindSourceAdapter<T>.GetCanActivate: Boolean;
begin
  Result := FDataObject <> nil;
end;

function TInterfaceObjectBindSourceAdapter<T>.GetCanApplyUpdates: Boolean;
begin
  Result := optAllowApplyUpdates in Options;
  if Result then
    Result := Assigned(OnApplyUpdates)
end;

function TInterfaceObjectBindSourceAdapter<T>.GetCanCancelUpdates: Boolean;
begin
  Result := optAllowCancelUpdates in Options;
  if Result then
    Result := Assigned(OnCancelUpdates);
end;

function TInterfaceObjectBindSourceAdapter<T>.GetCanModify: Boolean;
begin
  Result := optAllowModify in Options;
end;

function TInterfaceObjectBindSourceAdapter<T>.GetCount: Integer;
begin
  if Assigned(FDataObject) then
    Result := 1
  else
    Result := 0;
end;

function TInterfaceObjectBindSourceAdapter<T>.GetCurrent: TObject;
begin
  Result := nil;
  if Assigned(FDataObject) then
    Result := FDataObject as TObject;
end;

function TInterfaceObjectBindSourceAdapter<T>.GetObjectType: TRttiType;
begin
  Result := FBaseObjectRttiType;
end;

function TInterfaceObjectBindSourceAdapter<T>.InsertAt(AIndex: Integer): Integer;
begin
  Assert(False);
end;

procedure TInterfaceObjectBindSourceAdapter<T>.InternalApplyUpdates;
begin
  if Assigned(OnApplyUpdates) then
    OnApplyUpdates(Self);
end;

procedure TInterfaceObjectBindSourceAdapter<T>.InternalCancelUpdates;
begin
  if Assigned(OnCancelUpdates) then
    OnCancelUpdates(Self);
end;

procedure TInterfaceObjectBindSourceAdapter<T>.SetDataObject(ADataObject: T; AOwnsObject: Boolean);
begin
  DoOnBeforeSetDataObject(ADataObject);
  Active := False;
  if FDataObject <> nil then
  begin
    ClearFields;
    if FOwnsObject then
      FreeAndNil(FDataObject);
  end;
  FOwnsObject := AOwnsObject;
  FDataObject := ADataObject;
  if FDataObject <> nil then
  begin
    AddFields;
  end;
  DoOnAfterSetDataObject;
end;

function TInterfaceObjectBindSourceAdapter<T>.SupportsNestedFields: Boolean;
begin
  Result := True;
end;

{ TObjectBindSourceAdapter }

constructor TInterfaceObjectBindSourceAdapter.Create(const AOwner: TComponent; const AObject: TObject; const ATypeAlias, ATypeName: String;
  const AOwnsObject: Boolean);
var
  AObjectInternal: IInterface;
begin
  if not Supports(AObject, IInterface, AObjectInternal) then
    raise EIupOrmException.Create(Self.ClassName + ': AObject does not supports IInterface.');
  inherited Create(AOwner, AObjectInternal, ATypeAlias, ATypeName, AOwnsObject);
end;

end.
