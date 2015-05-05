unit IupOrm.Where;

interface

uses
  System.Rtti,
  System.Generics.Collections,
  IupOrm.CommonTypes,
  IupOrm.Interfaces,
  IupOrm.SqlItems,
  IupOrm.Context.Properties.Interfaces, IupOrm.Context.Table.Interfaces,
  System.Classes, Data.Bind.ObjectScope, IupOrm.Where.SqlItems.Interfaces,
  IupOrm.Resolver.Interfaces, IupOrm.Containers.Interfaces;

type

  // Where conditions (standard version)
  TioWhere = class (TioSqlItem)
  strict
  protected
    FWhereItems: TWhereItems;
    FTypeName, FTypeAlias: String;
    FDisableClassFromField: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function GetWhereItems: TWhereItems;
    function GetSql(AProperties:IioContextProperties; AddWhere:Boolean=True): String; reintroduce;
    function GetSqlWithClassFromField(AProperties:IioContextProperties; AIsClassFromField:Boolean; AClassFromField: IioClassFromField): String;
    function GetDisableClassFromField: Boolean;
    procedure SetType(const ATypeName, ATypeAlias: String);
    // ------ Destination methods
    function ToObject(const AObj:TObject=nil): TObject; virtual;

    procedure ToList(const AList:TObject); overload;
    function ToList(const AListRttiType:TRttiType; const AOwnsObjects:Boolean=True): TObject; overload;
    function ToList(const AInterfacedListTypeName:String; const AAlias:String=''; const AOwnsObjects:Boolean=True): TObject; overload;
    function ToList(const AListClassRef:TioClassRef; const AOwnsObjects:Boolean=True): TObject; overload;
    function ToList<TRESULT>(const AAlias:String=''; const AOwnsObjects:Boolean=True): TRESULT; overload;

    procedure Delete(AResolverMode:TioResolverMode=rmSingle);

    function ToActiveListBindSourceAdapter(const AOwner:TComponent; const AAutoLoadData:Boolean=True; const AOwnsObject:Boolean=True): TBindSourceAdapter; overload;
    function ToActiveObjectBindSourceAdapter(const AOwner:TComponent; const AAutoLoadData:Boolean=True; const AOwnsObject:Boolean=True): TBindSourceAdapter; overload;
    function ToListBindSourceAdapter(AOwner:TComponent; AOwnsObject:Boolean=True): TBindSourceAdapter;
    function ToObjectBindSourceAdapter(AOwner:TComponent; AOwnsObject:Boolean=True): TBindSourceAdapter;
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
    function _PropertyEqualsTo(APropertyName:String; AValue:TValue): TioWhere;
    function _PropertyOIDEqualsTo(AValue:TValue): TioWhere;
    function _Value(AValue:TValue): TioWhere;
  end;

  // Where conditions (generic version)
  TioWhere<T> = class (TioWhere)
  public
    // ------ Destination methods
    function ToObject(const AObj:TObject=nil): T; overload;
    function ToList: TList<T>; overload;
    function ToInterfacedList: IioList<T>; overload;
//    function ToObjectList(const AOwnsObjects:Boolean=True): TObjectList<T>;
//    function ToInterfacedObjectList(const AOwnsObjects:Boolean=True): IioList<T>; overload;
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
    function _PropertyEqualsTo(APropertyName:String; AValue:TValue): TioWhere<T>;
    function _PropertyOIDEqualsTo(AValue:TValue): TioWhere<T>;
    function _Value(AValue:TValue): TioWhere<T>;
  end;


implementation

uses
  IupOrm.DB.Factory,
  IupOrm.Context.Factory, System.SysUtils,
  IupOrm.DuckTyped.Interfaces, IupOrm.DuckTyped.Factory,
  IupOrm.ObjectsForge.Factory,
  IupOrm.RttiContext.Factory, IupOrm,
  IupOrm.LiveBindings.ActiveListBindSourceAdapter, IupOrm.Where.SqlItems,
  IupOrm.DB.Interfaces, System.TypInfo, IupOrm.Resolver.Factory,
  IupOrm.Rtti.Utilities, IupOrm.Context.Interfaces, IupOrm.Containers.Factory,
  IupOrm.LiveBindings.InterfaceListBindSourceAdapter,
  IupOrm.LiveBindings.ActiveInterfaceListBindSourceAdapter,
  IupOrm.LiveBindings.InterfaceObjectBindSourceAdapter,
  IupOrm.LiveBindings.ActiveInterfaceObjectBindSourceAdapter,
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter;

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
  Self._PropertyOIDEqualsTo(AOID);
end;

constructor TioWhere.Create;
begin
  FDisableClassFromField := False;
  FWhereItems := TWhereItems.Create;
end;

procedure TioWhere.Delete(AResolverMode:TioResolverMode);
var
  AResolvedTypeList: IioResolvedTypeList;
  AResolvedTypeName: String;
  AContext: IioContext;
  ATransactionCollection: IioTransactionCollection;
    // Nested
    procedure NestedDelete;
    var
      AQuery: IioQuery;
    begin
      // Create & execute query
      AQuery := TioDbFactory.QueryEngine.GetQueryDelete(AContext);
      AQuery.ExecSQL;
    end;
begin
  try
    // Resolve the type and alias
    AResolvedTypeList := TioResolverFactory.GetResolver(rsByDependencyInjection).Resolve(FTypeName, FTypeAlias, AResolverMode);
    // Get the transaction collection
    ATransactionCollection := TioDBFactory.TransactionCollection;
    try
      // Loop for all classes in the sesolved type list
      for AResolvedTypeName in AResolvedTypeList do
      begin
        // Get the Context for the current ResolverTypeName
        AContext := TioContextFactory.Context(AResolvedTypeName, Self);
        // Start transaction
        ATransactionCollection.StartTransaction(AContext.GetConnectionDefName);
        // Load the current class data into the list
        NestedDelete;
      end;
      // Commit ALL transactions
      ATransactionCollection.CommitAll;
    except
      // Rollback ALL transactions
      ATransactionCollection.RollbackAll;
      raise;
    end;
  finally
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

function TioWhere.GetDisableClassFromField: Boolean;
begin
  Result := FDisableClassFromField;
end;

function TioWhere.GetSql(AProperties:IioContextProperties; AddWhere:Boolean): String;
var
  CurrSqlItem: IioSqlItem;
  CurrSqlItemWhere: IioSqlItemWhere;
begin
  // NB: NO inherited
  Result := '';
  if FWhereItems.Count = 0 then Exit;
  if AddWhere then Result := 'WHERE ';
  // Add current SqlItem
  for CurrSqlItem in FWhereItems do
  begin
    if Supports(CurrSqlItem, IioSqlItemWhere, CurrSqlItemWhere) then
      Result := Result + CurrSqlItemWhere.GetSql(AProperties)
    else
      Result := Result + CurrSqlItem.GetSql;
  end;
end;

function TioWhere.GetSqlWithClassFromField(AProperties:IioContextProperties; AIsClassFromField:Boolean; AClassFromField: IioClassFromField): String;
begin
  Result := Self.GetSql(AProperties);
  if AIsClassFromField then
  begin
    if Result = ''
      then Result := 'WHERE '
      else Result := Result + ' AND ';
//    Result := Result + AClassFromField.GetSqlFieldName + ' LIKE ' + TioDbFactory.SqlDataConverter.StringToSQL('%<'+AClassFromField.GetClassName+'>%');
    Result := Result + AClassFromField.GetSqlFieldName + ' LIKE :' + AClassFromField.GetSqlParamName;
  end;
end;

function TioWhere.GetWhereItems: TWhereItems;
begin
  Result := FWhereItems;
end;


procedure TioWhere.SetType(const ATypeName, ATypeAlias: String);
begin
  FTypeName := ATypeName;
  FTypeAlias := ATypeAlias;
end;

function TioWhere.ToActiveListBindSourceAdapter(const AOwner: TComponent; const AAutoLoadData:Boolean;
  const AOwnsObject: Boolean): TBindSourceAdapter;
var
  AResolvedTypeList: IioResolvedTypeList;
  AContext: IioContext;
begin
  try
    // If the master property type is an interface...
    if TioRttiUtilities.IsAnInterfaceTypeName(FTypeName) then
    begin
      // Resolve the type and alias and get the context
      AResolvedTypeList := TioResolverFactory.GetResolver(rsByDependencyInjection).Resolve(FTypeName, FTypeAlias, rmAll);
      AContext := TioContextFactory.Context(AResolvedTypeList[0], Self);
      // Create the BSA
      Result := TioActiveInterfaceListBindSourceAdapter.Create(
        FTypeName,
        FTypeAlias,
        Self.GetSql(AContext.GetProperties, False),
        AOwner,
        TList<IInterface>.Create,
        AAutoLoadData,
        False)
    end
    // else if the master property type is a class...
    else
    begin
      // Get the context
      AContext := TioContextFactory.Context(FTypeName, Self);
      // Create the BSA
      Result := TioActiveListBindSourceAdapter.Create(
        AContext.GetClassRef,
        Self.GetSql(AContext.GetProperties, False),
        AOwner,
        TObjectList<TObject>.Create(AOwnsObject),
//        TList<TObject>.Create,
        AAutoLoadData,
        False);
    end;
  finally
    // Destroy itself at the end to avoid memory leak
    Self.Free;
  end;
end;





function TioWhere.ToActiveObjectBindSourceAdapter(const AOwner: TComponent; const AAutoLoadData:Boolean; const AOwnsObject: Boolean): TBindSourceAdapter;
var
  AResolvedTypeList: IioResolvedTypeList;
  AContext: IioContext;
begin
  try
    // If the master property type is an interface...
    if TioRttiUtilities.IsAnInterfaceTypeName(FTypeName) then
    begin
      // Resolve the type and alias and get the context
      AResolvedTypeList := TioResolverFactory.GetResolver(rsByDependencyInjection).Resolve(FTypeName, FTypeAlias, rmAll);
      AContext := TioContextFactory.Context(AResolvedTypeList[0], Self);
      // Create the BSA
      Result := TioActiveInterfaceObjectBindSourceAdapter.Create(
        FTypeName,
        FTypeAlias,
        Self.GetSql(AContext.GetProperties, False),
        AOwner,
        nil,   // AObject:TObject
        AAutoLoadData,  // AutoLoadData := True
        AContext.ObjStatusExist,  // Use ObjStatus async persist
        False)
    end
    // else if the master property type is a class...
    else
    begin
      // Get the context
      AContext := TioContextFactory.Context(FTypeName, Self);
      // Create the BSA
      Result := TioActiveObjectBindSourceAdapter.Create(
        AContext.GetClassRef,
        Self.GetSql(AContext.GetProperties, False),
        AOwner,
        nil,   // AObject:TObject
        AAutoLoadData,  // AutoLoadData := True
        AContext.ObjStatusExist,  // Use ObjStatus async persist
        False);
    end;
  finally
    // Destroy itself at the end to avoid memory leak
    Self.Free;
  end;
end;

procedure TioWhere.ToList(const AList: TObject);
var
  AResolvedTypeList: IioResolvedTypeList;
  AResolvedTypeName: String;
  AContext: IioContext;
  ATransactionCollection: IioTransactionCollection;
  ADuckTypedList: IioDuckTypedList;
    // Nested
    procedure NestedLoadToList;
    var
      AQuery: IioQuery;
      AObj: TObject;
    begin
      // Create & open query
      AQuery := TioDbFactory.QueryEngine.GetQuerySelectForList(AContext);
      AQuery.Open;
      try
        // Loop
        while not AQuery.Eof do
        begin
          // Clean the DataObject (it contains the previous)
          AContext.DataObject := nil;
          // Create the object as TObject
          AObj := TioObjectMakerFactory.GetObjectMaker(AContext.IsClassFromField).MakeObject(AContext, AQuery);
          // Add current object to the list
          ADuckTypedList.Add(AObj);
          // Next
          AQuery.Next;
        end;
      finally
        // Close query
        AQuery.Close;
      end;
    end;
begin
  try
    // Resolve the type and alias
    AResolvedTypeList := TioResolverFactory.GetResolver(rsByDependencyInjection).Resolve(FTypeName, FTypeAlias, rmAll);
    // Wrap the list into a DuckTypedList
    ADuckTypedList := TioDuckTypedFactory.DuckTypedList(AList);
    // Get the transaction collection
    ATransactionCollection := TioDBFactory.TransactionCollection;
    try
      // Loop for all classes in the sesolved type list
      for AResolvedTypeName in AResolvedTypeList do
      begin
        // Get the Context for the current ResolverTypeName
        AContext := TioContextFactory.Context(AResolvedTypeName, Self);
        // Start transaction
        ATransactionCollection.StartTransaction(AContext.GetConnectionDefName);
        // Load the current class data into the list
        NestedLoadToList;
      end;
      // Commit ALL transactions
      ATransactionCollection.CommitAll;
    except
      // Rollback ALL transactions
      ATransactionCollection.RollbackAll;
      raise;
    end;
  finally
    Self.Free;
  end;
end;





function TioWhere.ToList(const AInterfacedListTypeName, AAlias: String; const AOwnsObjects:Boolean): TObject;
begin
  Result := Self.ToList(
              TIupOrm.DependencyInjection.Locate(AInterfacedListTypeName).Alias(AAlias).GetItem.RttiType,
              AOwnsObjects
            );
end;

function TioWhere.ToList(const AListRttiType: TRttiType; const AOwnsObjects:Boolean): TObject;
begin
  // Create the list
  Result := TioObjectMakerFactory.GetObjectMaker(False).CreateListByRttiType(AListRttiType, AOwnsObjects);
  // Fill the list
  Self.ToList(Result);
end;

function TioWhere.ToList(const AListClassRef: TioClassRef; const AOwnsObjects:Boolean=True): TObject;
begin
  Result := Self.ToList(
              TioRttiUtilities.ClassRefToRttiType(AListClassRef),
              AOwnsObjects
            );
end;

function TioWhere.ToList<TRESULT>(const AAlias:String; const AOwnsObjects: Boolean): TRESULT;
begin
  if TioRttiUtilities.IsAnInterface<TRESULT> then
    Result := TioRttiUtilities.CastObjectToGeneric<TRESULT>(
                Self.ToList(
                  TioRttiUtilities.GenericToString<TRESULT>,
                  AAlias,
                  AOwnsObjects
                )
              )
  else
    Result := TioRttiUtilities.CastObjectToGeneric<TRESULT>(
                Self.ToList(
                  TioRttiContextFactory.RttiContext.GetType(PTypeInfo(TypeInfo(TRESULT))),
                  AOwnsObjects
                )
              );
end;

function TioWhere.ToListBindSourceAdapter(AOwner: TComponent; AOwnsObject: Boolean): TBindSourceAdapter;
var
  AContext: IioContext;
begin
  // If the master property type is an interface...
  if TioRttiUtilities.IsAnInterfaceTypeName(FTypeName) then
    Result := TInterfaceListBindSourceAdapter.Create(
      AOwner,
      Self.ToList<TList<IInterface>>,
      FTypeAlias,
      FTypeName,
      AOwnsObject)
  // else if the master property type is a class...
  else
  begin
    AContext := TioContextFactory.Context(FTypeName);
    Result := TListBindSourceAdapter.Create(
      AOwner,
      Self.ToList<TList<TObject>>,
      AContext.GetClassRef,
      AOwnsObject);
  end;
end;

function TioWhere.ToObject(const AObj:TObject): TObject;
var
  AResolvedTypeList: IioResolvedTypeList;
  AContext: IioContext;
  AQuery: IioQuery;
begin
  try
    // Init
    Result := AObj;
    // Resolve the type and alias
    AResolvedTypeList := TioResolverFactory.GetResolver(rsByDependencyInjection).Resolve(FTypeName, FTypeAlias, rmSingle);
    // Get the Context
    AContext := TioContextFactory.Context(AResolvedTypeList.Items[0], Self, Result);
    // Start the transaction
    TIupOrm.StartTransaction(AContext.GetConnectionDefName);
    try
      // Create & open query
      AQuery := TioDbFactory.QueryEngine.GetQuerySelectForObject(AContext);
      AQuery.Open;
      // Create the object as TObject
      if not AQuery.IsEmpty then
        Result := TioObjectMakerFactory.GetObjectMaker(AContext.IsClassFromField).MakeObject(AContext, AQuery);
      // Close query
      AQuery.Close;
      // Commit the transaction
      TIupOrm.CommitTransaction(AContext.GetConnectionDefName);
    except
      // Rollback the transaction
      TIupOrm.RollbackTransaction(AContext.GetConnectionDefName);
      raise;
    end;
  finally
    // Destroy itself at the end to avoid memory leak
    Self.Free;
  end;
end;

function TioWhere.ToObjectBindSourceAdapter(AOwner: TComponent; AOwnsObject: Boolean): TBindSourceAdapter;
var
  AContext: IioContext;
begin
  // If the master property type is an interface...
  if TioRttiUtilities.IsAnInterfaceTypeName(FTypeName) then
    Result := TInterfaceObjectBindSourceAdapter.Create(
      AOwner,
      Self.ToObject,
      FTypeAlias,
      FTypeName,
      AOwnsObject)
  // else if the master property type is a class...
  else
  begin
    AContext := TioContextFactory.Context(FTypeName);
    Result := TObjectBindSourceAdapter.Create(
      AOwner,
      Self.ToObject,
      AContext.GetClassRef,
      AOwnsObject);
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

function TioWhere._PropertyEqualsTo(APropertyName: String; AValue: TValue): TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.WhereItemPropertyEqualsTo(APropertyName, AValue));
end;

function TioWhere._PropertyOID: TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.WhereItemPropertyOID);
end;

function TioWhere._PropertyOIDEqualsTo(AValue: TValue): TioWhere;
begin
  Result := Self;
  Self.FWhereItems.Add(TioDbFactory.WhereItemPropertyOIDEqualsTo(AValue));
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

function TioWhere<T>.ToInterfacedList: IioList<T>;
begin
  Result := TioContainersFactory.GetInterfacedList<T>;
  Self.ToList(   TObject(Result)   );
end;

//function TioWhere<T>.ToInterfacedObjectList(const AOwnsObjects:Boolean): IioList<T>;
//begin
//  Result := TioContainersFactory.GetInterfacedObjectList<T>(AOwnsObjects);
//  Self.ToList(   TObject(Result)   );
//end;

function TioWhere<T>.ToList: TList<T>;
begin
  Result := TList<T>.Create;
  Self.ToList(Result);
end;

function TioWhere<T>.ToObject(const AObj:TObject): T;
begin
  Result := TioRttiUtilities.CastObjectToGeneric<T>(   TioWhere(Self).ToObject(AObj)   );
end;

//function TioWhere<T>.ToObjectList(const AOwnsObjects: Boolean): TObjectList<T>;
//begin
//  Result := TObjectList<T>.Create(AOwnsObjects);
//  Self.ToList(Result);
//end;

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

function TioWhere<T>._PropertyEqualsTo(APropertyName: String; AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._PropertyEqualsTo(APropertyName, AValue);
end;

function TioWhere<T>._PropertyOID: TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._PropertyOID;
end;

function TioWhere<T>._PropertyOIDEqualsTo(AValue: TValue): TioWhere<T>;
begin
  Result := Self;
  TioWhere(Self)._PropertyOIDEqualsTo(AValue);
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
