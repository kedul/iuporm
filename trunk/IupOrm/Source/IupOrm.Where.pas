unit IupOrm.Where;

interface

uses
  System.Rtti,
  System.Generics.Collections,
  IupOrm.CommonTypes,
  IupOrm.Interfaces,
  IupOrm.SqlItems,
  IupOrm.Context.Properties.Interfaces, IupOrm.Context.Table.Interfaces,
  System.Classes, Data.Bind.ObjectScope, IupOrm.Where.SqlItems.Interfaces;

type

  // Where conditions (standard version)
  TioWhere = class (TioSqlItem)
  strict protected
    FWhereItems: TWhereItems;
    FClassRef: TioClassRef;
    FContextProperties: IioContextProperties;
    FDisableClassFromField: Boolean;
    function IsAnInterface<T>: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function GetWhereItems: TWhereItems;
    function GetSql(AddWhere:Boolean=True): String; reintroduce;
    function GetSqlWithClassFromField(AClassFromField: IioClassFromField): String;
    function GetDisableClassFromField: Boolean;
    function GetClassRef: TioClassRef;
    procedure SetClassRef(AClassRef:TioClassRef);
    procedure SetContextProperties(AContextProperties:IioContextProperties);
    // ------ Destination methods
    function ToObject: TObject;
    function ToList<TDEST:class,constructor>(AOwnsObjects:Boolean=True): TDEST; overload;
    procedure ToList(AList: TObject); overload;
    function ToActiveListBindSourceAdapter(AOwner:TComponent; AOwnsObject:Boolean=True): TBindSourceAdapter; overload;
    procedure Delete;
    // ------ Conditions
    function ByOID(AOID:Integer): TioWhere;
    function Add(ATextCondition:String): TioWhere;
    function DisableClassFromField: TioWhere;
    // ------ Logic relations
    function _And: TioWhere; overload;
    function _Or: TioWhere; overload;
    function _Not: TioWhere; overload;
    function _OpenPar: TioWhere; overload;
    function _ClosePar: TioWhere; overload;
    // ------ Logic relations with TextCondition
    function _And(ATextCondition:String): TioWhere; overload;
    function _Or(ATextCondition:String): TioWhere; overload;
    function _Not(ATextCondition:String): TioWhere; overload;
    function _OpenPar(ATextCondition:String): TioWhere; overload;
    function _ClosePar(ATextCondition:String): TioWhere; overload;
    // ------ Compare operators
    function _Equal: TioWhere;
    function _Greater: TioWhere;
    function _Lower: TioWhere;
    function _GreaterOrEqual: TioWhere;
    function _LowerOrEqual: TioWhere;
    function _NotEqual: TioWhere;
    function _Like: TioWhere;
    function _IsNull: TioWhere;
    function _IsNotNull: TioWhere;
    // ------ Compare operators with TValue
    function _EqualTo(AValue:TValue): TioWhere;
    function _GreaterThan(AValue:TValue): TioWhere;
    function _LowerThan(AValue:TValue): TioWhere;
    function _GreaterOrEqualThan(AValue:TValue): TioWhere;
    function _LowerOrEqualThan(AValue:TValue): TioWhere;
    function _NotEqualTo(AValue:TValue): TioWhere;
    function _LikeTo(AValue:TValue): TioWhere;
    // ------
    function _Where: TioWhere; overload;
    function _Where(AWhereCond:TioWhere): TioWhere; overload;
    function _Where(ATextCondition:String): TioWhere; overload;
    function _Property(APropertyName:String): TioWhere;
    function _PropertyOID: TioWhere;
    function _Value(AValue:TValue): TioWhere;
  end;

  // Where conditions (generic version)
  TioWhere<T:class,constructor> = class (TioWhere)
  public
    // ------ Destination methods
    function ToObject: T; overload;
    function ToList(AOwnsObject:Boolean=True): TObjectList<T>; overload;
    function ToListBindSourceAdapter(AOwner:TComponent; AOwnsObject:Boolean=True): TBindSourceAdapter;
    // ------ Conditions
    function ByOID(AOID:Integer): TioWhere<T>;
    function Add(ATextCondition:String): TioWhere<T>;
    function DisableClassFromField: TioWhere<T>;
    // ------ Logic relations
    function _And: TioWhere<T>; overload;
    function _Or: TioWhere<T>; overload;
    function _Not: TioWhere<T>; overload;
    function _OpenPar: TioWhere<T>; overload;
    function _ClosePar: TioWhere<T>; overload;
    // ------ Logic relations with TextCondition
    function _And(ATextCondition:String): TioWhere<T>; overload;
    function _Or(ATextCondition:String): TioWhere<T>; overload;
    function _Not(ATextCondition:String): TioWhere<T>; overload;
    function _OpenPar(ATextCondition:String): TioWhere<T>; overload;
    function _ClosePar(ATextCondition:String): TioWhere<T>; overload;
    // ------ Compare operators
    function _Equal: TioWhere<T>;
    function _Greater: TioWhere<T>;
    function _Lower: TioWhere<T>;
    function _GreaterOrEqual: TioWhere<T>;
    function _LowerOrEqual: TioWhere<T>;
    function _NotEqual: TioWhere<T>;
    function _Like: TioWhere<T>;
    function _IsNull: TioWhere<T>;
    function _IsNotNull: TioWhere<T>;
    // ------ Compare operators with TValue
    function _EqualTo(AValue:TValue): TioWhere<T>;
    function _GreaterThan(AValue:TValue): TioWhere<T>;
    function _LowerThan(AValue:TValue): TioWhere<T>;
    function _GreaterOrEqualThan(AValue:TValue): TioWhere<T>;
    function _LowerOrEqualThan(AValue:TValue): TioWhere<T>;
    function _NotEqualTo(AValue:TValue): TioWhere<T>;
    function _LikeTo(AValue:TValue): TioWhere<T>;
    // ------
    function _Where: TioWhere<T>; overload;
    function _Where(AWhereCond:TioWhere): TioWhere<T>; overload;
    function _Where(ATextCondition:String): TioWhere<T>; overload;
    function _Property(APropertyName:String): TioWhere<T>;
    function _PropertyOID: TioWhere<T>;
    function _Value(AValue:TValue): TioWhere<T>;
  end;


implementation

uses
  IupOrm.DB.Factory, IupOrm.DB.Interfaces,
  IupOrm.Context.Factory, System.SysUtils,
  IupOrm.DuckTyped.Interfaces, IupOrm.DuckTyped.Factory,
  IupOrm.ObjectsForge.Factory, IupOrm.Context.Interfaces,
  IupOrm.RttiContext.Factory, IupOrm,
  IupOrm.LiveBindings.ActiveListBindSourceAdapter, IupOrm.Where.SqlItems;

{ TioWhere }

function TioWhere.Add(ATextCondition: String): TioWhere;
begin
  Result := Self;
  if ATextCondition.Trim = '' then Exit;
  Self.FWhereItems.Add(TioSqlItemsWhereText.Create(ATextCondition));
end;

function TioWhere._And: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.LogicRelation._And);
end;

function TioWhere._And(ATextCondition: String): TioWhere;
begin
  Result := Self;
  Self._And;
  Self.Add(ATextCondition)
end;

function TioWhere._ClosePar: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.LogicRelation._ClosePar);
end;

function TioWhere._ClosePar(ATextCondition: String): TioWhere;
begin
  Result := Self;
  Self._ClosePar;
  Self.Add(ATextCondition)
end;

function TioWhere._Equal: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._Equal);
end;

function TioWhere._EqualTo(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self._Equal;
  Self._Value(AValue);
end;

function TioWhere._Greater: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._Greater);
end;

function TioWhere._GreaterOrEqual: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._GreaterOrEqual);
end;

function TioWhere._GreaterOrEqualThan(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self._GreaterOrEqual;
  Self._Value(AValue);
end;

function TioWhere._GreaterThan(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self._Greater;
  Self._Value(AValue);
end;

function TioWhere._IsNotNull: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._IsNotNull);
end;

function TioWhere._IsNull: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._IsNull);
end;

function TioWhere._Like: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._Like);
end;

function TioWhere._LikeTo(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self._Like;
  Self._Value(AValue);
end;

function TioWhere._Lower: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._Lower);
end;

function TioWhere._LowerOrEqual: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._LowerOrEqual);
end;

function TioWhere._LowerOrEqualThan(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self._LowerOrEqual;
  Self._Value(AValue);
end;

function TioWhere._LowerThan(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self._Lower;
  Self._Value(AValue);
end;

function TioWhere.ByOID(AOID:Integer): TioWhere;
begin
  Result := Self;
  Self._Where._PropertyOID._EqualTo(AOID);
end;

constructor TioWhere.Create;
begin
  FDisableClassFromField := False;
  FWhereItems := TWhereItems.Create;
end;

procedure TioWhere.Delete;
var
  AContext: IioContext;
  AQuery: IioQuery;
begin
  try
    // Create Context
    AContext := TioContextFactory.Context(Self.FClassRef.ClassName, Self);
    // Create & open query
    AQuery := TioDbFactory.SqlGenerator.GenerateSqlDelete(AContext);
    AQuery.ExecSQL;
  finally
    // Destroy itself at the end to avoid memory leak
    Self.Free;
  end;
end;

destructor TioWhere.Destroy;
begin
  FWhereItems.Free;
  inherited;
end;

function TioWhere.DisableClassFromField: TioWhere;
begin
  Result := Self;
  FDisableClassFromField := True;
end;

function TioWhere.GetClassRef: TioClassRef;
begin
  Result := FClassRef;
end;

function TioWhere.GetDisableClassFromField: Boolean;
begin
  Result := FDisableClassFromField;
end;

function TioWhere.GetSql(AddWhere:Boolean): String;
var
  CurrSqlItem: IioSqlItem;
  CurrSqlItemWhere: IioSqlItemWhere;
begin
  // NB: NO inherited
  Result := '';
  if FWhereItems.Count = 0 then Exit;
  if AddWhere then Result := 'WHERE ';
  for CurrSqlItem in FWhereItems do
  begin
    // Set ContextProperty if TioSqlItemWhere descendant
    if Supports(CurrSqlItem, IioSqlItemWhere, CurrSqlItemWhere)
      then CurrSqlItemWhere.SetContextProperties(FContextProperties);
    // Add current SqlItem
    Result := Result + CurrSqlItem.GetSql;
  end;
end;

function TioWhere.GetSqlWithClassFromField(
  AClassFromField: IioClassFromField): String;
begin
  Result := Self.GetSql;
  if not Assigned(AClassFromField) then Exit;
  if Result = ''
    then Result := 'WHERE '
    else Result := Result + ' AND ';
  Result := Result + AClassFromField.GetSqlFieldName + ' LIKE ' + TioDbFactory.SqlDataConverter.StringToSQL('%<'+AClassFromField.GetClassName+'>%');
end;

function TioWhere.GetWhereItems: TWhereItems;
begin
  Result := FWhereItems;
end;

function TioWhere.IsAnInterface<T>: Boolean;
begin
  // Result is True if T si an interface
  Result := (   TioRttiContextFactory.RttiContext.GetType(TypeInfo(T)) is TRttiInterfaceType   );
end;

procedure TioWhere.SetClassRef(AClassRef: TioClassRef);
begin
  FClassRef := AClassRef;
end;

procedure TioWhere.SetContextProperties(
  AContextProperties: IioContextProperties);
begin
  FContextProperties := AContextProperties;
end;

function TioWhere.ToActiveListBindSourceAdapter(AOwner: TComponent;
  AOwnsObject: Boolean): TBindSourceAdapter;
var
  AContext: IioContext;
begin
  try
    // Create Context
    // (without context the "Self.GetSql(False)" fail)
    AContext := TioContextFactory.Context(Self.FClassRef.ClassName, Self);
    // Create the adapter
    Result := TioActiveListBindSourceAdapter.Create(
                                                      Self.FClassRef
                                                    , Self.GetSql(False)
                                                    , AOwner
                                                    , TObjectList<TObject>.Create    // Create an empty list for adapter creation only
                                                    , True  // AutoLoadData := True
                                                    , AContext.ObjStatusExist  // Use ObjStatus async persist
                                                    , AOwnsObject
                                                   );
  finally
    // Destroy itself at the end to avoid memory leak
    Self.Free;
  end;
end;

procedure TioWhere.ToList(AList: TObject);
var
  ADuckTypedList: IioDuckTypedList;
  AContext: IioContext;
  AQuery: IioQuery;
  AObj: TObject;
begin
  // Init
  AQuery := nil;
  // Create Context
  AContext := TioContextFactory.Context(Self.FClassRef.ClassName, Self);
  // Start the transaction
  TIupOrm.StartTransaction(AContext.GetConnectionDefName);
  try try
    // Wrap the DestList into a DuckTypedList
    ADuckTypedList := TioDuckTypedFactory.DuckTypedList(AList);
    // Create & open query
    AQuery := TioDbFactory.SqlGenerator.GenerateSqlSelectForList(AContext);
    AQuery.Open;
    // Loop
    while not AQuery.Eof do
    begin
      // Create the object as TObject
      AObj := TioObjectMakerFactory.GetObjectMaker(AContext.IsClassFromField).MakeObject(AContext, AQuery);
      // Add current object to the list
      ADuckTypedList.Add(AObj);
      // Next
      AQuery.Next;
    end;
    // Close query
    AQuery.Close;
    TIupOrm.CommitTransaction(AContext.GetConnectionDefName);
  except
    TIupOrm.RollbackTransaction(AContext.GetConnectionDefName);
    raise;
  end;
  finally
    // Destroy itself at the end to avoid memory leak
    Self.Free;
  end;
end;

function TioWhere.ToList<TDEST>(AOwnsObjects:Boolean=True): TDEST;
begin
  // Create the list
  Result := TioObjectMakerFactory.GetObjectMaker(False).CreateListByClassRef(TDEST) as TDEST;
  // Fill the list
  Self.ToList(Result);
end;

function TioWhere.ToObject: TObject;
var
  AContext: IioContext;
  AQuery: IioQuery;
begin
  // Init
  Result := nil;
  // Create Context
  AContext := TioContextFactory.Context(Self.FClassRef.ClassName, Self);
  TIupOrm.StartTransaction(AContext.GetConnectionDefName);
  try try
    // Create & open query
    AQuery := TioDbFactory.SqlGenerator.GenerateSqlSelectForObject(AContext);
    AQuery.Open;
    // Create the object as TObject
    Result := TioObjectMakerFactory.GetObjectMaker(AContext.IsClassFromField).MakeObject(AContext, AQuery);
    // Close query
    AQuery.Close;
    TIupOrm.CommitTransaction(AContext.GetConnectionDefName);
  except
    TIupOrm.RollbackTransaction(AContext.GetConnectionDefName);
    raise;
  end;
  finally
    // Destroy itself at the end to avoid memory leak
    Self.Free;
  end;
end;

function TioWhere._Not(ATextCondition: String): TioWhere;
begin
  Result := Self;
  Self._Not;
  Self.Add(ATextCondition)
end;

function TioWhere._NotEqual: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.CompareOperator._NotEqual);
end;

function TioWhere._NotEqualTo(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self._NotEqual;
  Self._Value(AValue);
end;

function TioWhere._Not: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.LogicRelation._Not);
end;

function TioWhere._OpenPar: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.LogicRelation._OpenPar);
end;

function TioWhere._Or: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.LogicRelation._Or);
end;

function TioWhere._OpenPar(ATextCondition: String): TioWhere;
begin
  Result := Self;
  Self._OpenPar;
  Self.Add(ATextCondition)
end;

function TioWhere._Or(ATextCondition: String): TioWhere;
begin
  Result := Self;
  Self._Or;
  Self.Add(ATextCondition)
end;

function TioWhere._Property(APropertyName: String): TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.WhereItemProperty(APropertyName));
end;

function TioWhere._PropertyOID: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.WhereItemPropertyOID);
end;

function TioWhere._Value(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.WhereItemTValue(AValue));
end;

function TioWhere._Where(AWhereCond:TioWhere): TioWhere;
var
  AItem: IioSqlItem;
begin
  Self.FWhereItems.Clear;
  for AItem in AWhereCond.GetWhereItems do Self.FWhereItems.Add(AItem);
  Result := Self;
end;

function TioWhere._Where(ATextCondition: String): TioWhere;
begin
  Result := Self;
  if ATextCondition <> ''
    then Self.Add(ATextCondition);
end;

function TioWhere._Where: TioWhere;
begin
  Result := Self;
  // Nothing
end;

{ TioWhere<T> }

function TioWhere<T>.Add(ATextCondition: String): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self).Add(ATextCondition);
end;

function TioWhere<T>._And: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._And;
end;

function TioWhere<T>._ClosePar: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._ClosePar;
end;

function TioWhere<T>._Not: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Not;
end;

function TioWhere<T>._OpenPar: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._OpenPar;
end;

function TioWhere<T>._Or: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Or;
end;

function TioWhere<T>.ByOID(AOID: Integer): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self).ByOID(AOID);
end;

function TioWhere<T>.DisableClassFromField: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self).DisableClassFromField;
end;

function TioWhere<T>.ToList(AOwnsObject:Boolean=True): TObjectList<T>;
begin
  Result := Self.ToList<TObjectList<T>>;
end;

function TioWhere<T>.ToListBindSourceAdapter(AOwner: TComponent;
  AOwnsObject: Boolean): TBindSourceAdapter;
begin
  Result := TListBindSourceAdapter<T>.Create(
                                              AOwner
                                            , Self.ToList<TObjectList<T>>
                                            , AOwnsObject
                                            );
end;

function TioWhere<T>.ToObject: T;
begin
  Result := TioWhere(Self).ToObject as T;
end;

function TioWhere<T>._And(ATextCondition: String): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._And(ATextCondition);
end;

function TioWhere<T>._ClosePar(ATextCondition: String): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._ClosePar(ATextCondition);
end;

function TioWhere<T>._Equal: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Equal;
end;

function TioWhere<T>._EqualTo(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._EqualTo(AValue);
end;

function TioWhere<T>._Greater: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Greater;
end;

function TioWhere<T>._GreaterOrEqual: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._GreaterOrEqual;
end;

function TioWhere<T>._GreaterOrEqualThan(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._GreaterOrEqualThan(AValue);
end;

function TioWhere<T>._GreaterThan(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._GreaterThan(AValue);
end;

function TioWhere<T>._IsNotNull: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._IsNotNull;
end;

function TioWhere<T>._IsNull: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._IsNull;
end;

function TioWhere<T>._Like: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Like;
end;

function TioWhere<T>._LikeTo(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._LikeTo(AValue);
end;

function TioWhere<T>._Lower: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Lower;
end;

function TioWhere<T>._LowerOrEqual: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._LowerOrEqual;
end;

function TioWhere<T>._LowerOrEqualThan(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._LowerOrEqualThan(AValue);
end;

function TioWhere<T>._LowerThan(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._LowerThan(AValue);
end;

function TioWhere<T>._Not(ATextCondition: String): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Not(ATextCondition);
end;

function TioWhere<T>._NotEqual: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._NotEqual;
end;

function TioWhere<T>._NotEqualTo(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._NotEqualTo(AValue);
end;

function TioWhere<T>._OpenPar(ATextCondition: String): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._OpenPar(ATextCondition);
end;

function TioWhere<T>._Or(ATextCondition: String): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Or(ATextCondition);
end;

function TioWhere<T>._Property(APropertyName: String): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Property(APropertyName);
end;

function TioWhere<T>._PropertyOID: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._PropertyOID;
end;

function TioWhere<T>._Value(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Value(AValue);
end;

function TioWhere<T>._Where(AWhereCond:TioWhere): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Where(AWhereCond);
end;

function TioWhere<T>._Where(ATextCondition: String): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Where(ATextCondition);
end;

function TioWhere<T>._Where: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._Where;
end;

end.
