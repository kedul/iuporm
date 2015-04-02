unit IupOrm.DuckTyped.List;

interface

uses
  IupOrm.DuckTyped.Interfaces,
  System.Rtti;

type

  // DuckTypedList
  TioDuckTypedList = class(TInterfacedObject, IioDuckTypedList)
  strict protected
    FListObject: TObject;
    FCountProperty: TRttiProperty;
    FOwnsObjectsProperty: TRttiProperty;
    FAddMethod: TRttiMethod;
    FClearMethod: TRttiMethod;
    FGetItemMethod: TRttiMethod;
    procedure SetOwnsObjects(AValue:Boolean);
    function GetOwnsObjects: Boolean;
  public
    constructor Create(AListObject: TObject);
    procedure Add(AObject: TObject);
    procedure Clear;
    function Count: Integer;
    function GetItem(Index: Integer): TObject;
    function GetEnumerator: IEnumerator;
    property OwnsObjects:Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

  // DuckTypedListEnumerator
  TioDuckTypedListEnumerator = class(TInterfacedObject, IEnumerator)
  strict protected
    FPosition: Integer;
    FDuckTypedList: IioDuckTypedList;
  public
    constructor Create(ADuckTypedList: IioDuckTypedList);
    procedure Reset;
    function MoveNext: boolean;
    function GetCurrent: TObject;
    property Current: TObject read GetCurrent;
  end;

implementation

uses
  IupOrm.Exceptions, IupOrm.RttiContext.Factory;

{ TioDuckTypedList }

procedure TioDuckTypedList.Add(AObject: TObject);
begin
  FAddMethod.Invoke(FListObject, [AObject]);
end;

procedure TioDuckTypedList.Clear;
begin
  FClearMethod.Invoke(FListObject, []);
end;

function TioDuckTypedList.Count: Integer;
begin
  Result := FCountProperty.GetValue(FListObject).AsInteger;
end;

constructor TioDuckTypedList.Create(AListObject: TObject);
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  inherited Create;
  FListObject := AListObject;
  // Init Rtti
  Ctx := TioRttiContextFactory.RttiContext;
  Typ := Ctx.GetType(AListObject.ClassInfo);
  // OwnsObjects Property (No exception if not exist)
  FOwnsObjectsProperty := nil;
  FOwnsObjectsProperty := Typ.GetProperty('OwnsObjects');
  // Count Property
  FCountProperty := Typ.GetProperty('Count');
  if not Assigned(FCountProperty) then EIupOrmException.Create('DuckTypedList: "Count" property not found in the object');
  // Add method
  FAddMethod := Typ.GetMethod('Add');
  if not Assigned(FAddMethod) then EIupOrmException.Create('DuckTypedList: "Add" method not found in the object');
  // Clear
  FClearMethod := Typ.GetMethod('Clear');
  if not Assigned(FClearMethod) then EIupOrmException.Create('DuckTypedList: "Clear" method not found in the object');
  // GetItem method
{$IF CompilerVersion >= 23}
  FGetItemMethod := Typ.GetIndexedProperty('Items').ReadMethod;
{$IFEND}
  if not Assigned(FGetItemMethod) then FGetItemMethod := Typ.GetMethod('GetItem');
  if not Assigned(FGetItemMethod) then FGetItemMethod := Typ.GetMethod('GetElement');
  if not Assigned(FGetItemMethod) then EIupOrmException.Create(Self.ClassName + ': "Items" property or "GetItem/GetElement" method not found in the object');
end;

function TioDuckTypedList.GetEnumerator: IEnumerator;
begin
  Result := TioDuckTypedListEnumerator.Create(self);
end;

function TioDuckTypedList.GetItem(Index: Integer): TObject;
begin
  Result := FGetItemMethod.Invoke(FListObject, [index]).AsObject;
end;

function TioDuckTypedList.GetOwnsObjects: Boolean;
begin
  Result := False;
  if Assigned(FOwnsObjectsProperty) then
    Result := FOwnsObjectsProperty.GetValue(FListObject).AsBoolean;
end;

procedure TioDuckTypedList.SetOwnsObjects(AValue: Boolean);
begin
  if Assigned(FOwnsObjectsProperty) then
    FOwnsObjectsProperty.SetValue(FListObject, AValue);
end;

{ TioDuckTypedListEnumerator }

constructor TioDuckTypedListEnumerator.Create(ADuckTypedList: IioDuckTypedList);
begin
  inherited Create;
  FDuckTypedList := ADuckTypedList;
  FPosition := -1;
end;

function TioDuckTypedListEnumerator.GetCurrent: TObject;
begin
  if FPosition > -1 then
    Result := FDuckTypedList.GetItem(FPosition)
  else
    raise EIupOrmException.Create(Self.ClassName + ': Call MoveNext first');
end;

function TioDuckTypedListEnumerator.MoveNext: boolean;
begin
  if FPosition < FDuckTypedList.Count - 1 then
  begin
    Inc(FPosition);
    Result := True;
  end else Result := false;
end;

procedure TioDuckTypedListEnumerator.Reset;
begin
  // Nothing but necessary
end;

end.
