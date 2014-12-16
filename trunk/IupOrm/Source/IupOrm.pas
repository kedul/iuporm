unit IupOrm;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.context.interfaces,
  IupOrm.Context.Factory,
  IupOrm.CommonTypes,
  IupOrm.Where,
  IupOrm.DB.Interfaces,
  IupOrm.Helpers.ObjectHelperTools.Interfaces,
  IupOrm.Helpers.BindSourceHelperTools.Interfaces,
  IupOrm.LiveBindings.Interfaces,
  IupOrm.Global.Factory,
  IupOrm.DependencyInjection,
  IupOrm.DB.ConnectionContainer;

type

  // TObject class helper
  TioTObjectHelper = class helper for TObject
  public
    function IupOrm: IioObjectHelperTools;
    function ioAsInterface<T>: T;
  end;

  // TioBaseBindSource class helper (PrototypeBindSource and so on)
  TioBindSourceHelper = class helper for TioBaseBindSource
  public
    function IupOrm: IioBindSourceHelperTools;
    procedure Append;
  end;

  // TIupOrm
  TIupOrm = class
  strict protected
    class procedure PersistObject(AContext:IioContext; ARelationPropertyName:String=''; ARelationOID:Integer=0);
    class procedure InsertObject(AContext:IioContext);
    class procedure UpdateObject(AContext:IioContext);
    class procedure DeleteObject(AContext:IioContext);
    class procedure PreProcessRelationChild(AContext:IioContext);
    class procedure PostProcessRelationChild(AContext:IioContext);
    class procedure PersistRelationChildList(AMasterContext:IioContext; AMasterProperty:IioContextProperty);
    class procedure PersistRelationChildObject(AMasterContext:IioContext; AMasterProperty:IioContextProperty);
    class procedure PersistCollection_Internal(ACollection:TObject; ARelationPropertyName:String=''; ARelationOID:Integer=0);
    class function ObjectExists(AContext:IioContext): Boolean;
  public
    class function GlobalFactory: TioGlobalFactoryRef;
    class function DependencyInjection: TioDependencyInjectionRef;
    class function RefTo(AClassRef:TioClassRef): TioWhere; overload;
    class function RefTo<T:class,constructor>: TioWhere<T>; overload;
    class function Load(AClassRef:TioClassRef): TioWhere; overload;
    class function Load<T:class,constructor>: TioWhere<T>; overload;
    class procedure Delete(AObj: TObject);
    class procedure Persist(AObj: TObject);
    class procedure PersistCollection(ACollection: TObject);
    class procedure StartTransaction(AConnectionName:String='');
    class procedure CommitTransaction(AConnectionName:String='');
    class procedure RollbackTransaction(AConnectionName:String='');
    class procedure AutoCreateDatabase;
    class function ConnectionManager: TioConnectionManagerRef;
  end;

implementation

uses
  IupOrm.DuckTyped.Interfaces,
  IupOrm.DuckTyped.Factory,
  IupOrm.Attributes,
  IupOrm.Exceptions,
  IupOrm.Helpers.ObjectHelperTools,
  IupOrm.Helpers.BindSourceHelperTools,
  System.SysUtils,
  System.TypInfo,
  IupOrm.DB.Factory,
  IupOrm.DB.DBCreator.Factory;


{ TIupOrm }

class function TIupOrm.Load<T>: TioWhere<T>;
begin
  Result := Self.RefTo<T>;
end;

class function TIupOrm.ObjectExists(AContext: IioContext): Boolean;
var
  AQuery: IioQuery;
begin
  // Generate and open the query
  AQuery := TioDbFactory.SqlGenerator.GenerateSqlForExists(AContext);
  AQuery.Open;
  // Result
  Result := AQuery.Fields[0].AsInteger <> 0;
end;

class procedure TIupOrm.Persist(AObj: TObject);
var
  AContext: IioContext;
begin
  // Check
  if not Assigned(AObj) then Exit;
  // Create Context
  AContext := TioContextFactory.Context(AObj.ClassName, nil, AObj);
  // Execute
  Self.PersistObject(AContext);
end;

class procedure TIupOrm.PersistCollection(ACollection: TObject);
begin
  // Redirect to the internal PersistCollection_Internal (same of PersistRelationChildList)
  PersistCollection_Internal(ACollection);
end;

class procedure TIupOrm.PersistCollection_Internal(ACollection: TObject;
  ARelationPropertyName: String; ARelationOID: Integer);
var
  ADuckTypedList: IioDuckTypedList;
  AObj: TObject;
  AContext: IioContext;
begin
  // NB: Qui avvio la transazione per fare in modo che tutto il Persist di tutti gli oggetti contenuti
  //      nella collection vengano persistiti o annullati ma poi ogni chiamata a PersistObject riavvia
  //      una transazione per l'oggetto singolo (che non avrà praticamente effetto perchè inglobata
  //      da quella avviata qua sotto.
  //      Nel caso particolare in cui uno o più singoli oggetti contenuti dela collection siano di una
  //      qualche classe che opera su una ConnectionDef diversa da quella di default verrà avviata (all'interno
  //      della chiamata a "PersistObject" una transazione sulla Connection diversa da quella di default e quindi
  //      al di fuori della transazione principale sulla connessione di default avviata qui sotto e in pratica
  //      per questi oggetti ogni chiamata a "PersistObject" verrà eseguita nel contesto di una singola transazione
  //      slegata dalle altre e quindi è possibile che (solo in questo specifico e particolare caso) alcune operazioni
  //      vadano a buon fine mentre altre no.
  //      AL momento non ho una soluzione al problema.
  // NB: Qui non posso conoscere con certezza il tipo di oggetti realmente contenuto nella collection
  //      in quanto il tipo reale dell'oggetto potrebbe essere diverso dal genericType della lista stessa
  //      (a maggior ragione nel caso di una TList<IInterface> di interfacce, quindi avvio una transazione
  //      sulla connessione di default che va bene nel 99% delle volte (raramente l'applicazione dichiererà classi
  //      che operano su Database diversi contemporaneamente.
  Self.StartTransaction;
  try
    // Wrap the DestList into a DuckTypedList
    ADuckTypedList := TioDuckTypedFactory.DuckTypedList(ACollection);
    // Loop the list
    for AObj in ADuckTypedList do
    begin
      // Create context for current object
      AContext := TioContextFactory.Context(AObj.ClassName, nil, AObj);
      // Persist object
      Self.PersistObject(AContext
                        , ARelationPropertyName
                        , ARelationOID
                        );
    end;

    Self.CommitTransaction;
  except
    Self.RollbackTransaction;
    raise;
  end;
end;

class procedure TIupOrm.PersistRelationChildList(AMasterContext:IioContext; AMasterProperty:IioContextProperty);
begin
  // Redirect to the internal PersistCollection_Internal (same of PersistCollection)
  PersistCollection_Internal( AMasterProperty.GetRelationChildObject(AMasterContext.DataObject)  // The collection
                            , AMasterProperty.GetRelationChildPropertyName
                            , AMasterContext.GetProperties.GetIdProperty.GetValue(AMasterContext.DataObject).AsInteger
                            );
end;

class procedure TIupOrm.PersistRelationChildObject(AMasterContext: IioContext;
  AMasterProperty: IioContextProperty);
var
  AObj: TObject;
  AContext: IioContext;
begin
  // Get the child object
  AObj := AMasterProperty.GetRelationChildObject(AMasterContext.DataObject);
  // Create context for current child object
  AContext := TioContextFactory.Context(AObj.ClassName, nil, AObj);
  // Persist object
  Self.PersistObject(AContext
                    , AMasterProperty.GetRelationChildPropertyName
                    , AMasterContext.GetProperties.GetIdProperty.GetValue(AMasterContext.DataObject).AsInteger
                    );
end;

class procedure TIupOrm.PreProcessRelationChild(AContext: IioContext);
var
  Prop: IioContextProperty;
begin
  // Loop for all properties
  for Prop in AContext.GetProperties do
  begin
    // If the property is not WriteEnabled then skip it
    if not Prop.IsWriteEnabled then Continue;
    case Prop.GetRelationType of
      // If relation BelongsTo: persist the child object to retrieve the ID (if new object or ID changed)
      ioRTBelongsTo: begin
//        TIupOrm.Persist(Prop.GetRelationChildObject(AContext.DataObject));
        {Nothing}  // Non persiste più nulla in caso di relazione BelongsTo
      end;
      // If relation HasMany
      ioRTHasMany: {Nothing};
      // If relation HasOne
      ioRTHasOne: {Nothing};
    end;
  end;
end;

class procedure TIupOrm.PostProcessRelationChild(AContext: IioContext);
var
  Prop: IioContextProperty;
begin
  // Loop for all properties
  for Prop in AContext.GetProperties do
  begin
    // If the property is not WriteEnabled then skip it
    if not Prop.IsWriteEnabled then Continue;
    case Prop.GetRelationType of
      // If relation HasBelongsToOne
      ioRTBelongsTo: {Nothing};
      // If relation HasMany
      ioRTHasMany: PersistRelationChildList(AContext, Prop);
      // If relation HasOne
      ioRTHasOne: PersistRelationChildObject(AContext, Prop);
    end;
  end;
end;

class procedure TIupOrm.PersistObject(AContext:IioContext; ARelationPropertyName:String=''; ARelationOID:Integer=0);
begin
  Self.StartTransaction(AContext.GetConnectionDefName);
  try
    // Set/Update MasterID property if this is a relation child object (HasMany, HasOne, BelongsTo)
    if  (ARelationPropertyName <> '')
    and (ARelationOID <> 0)
    and (AContext.GetProperties.GetPropertyByName(ARelationPropertyName).GetRelationType = ioRTNone) // Altrimenti in alcuni casi particolare dava errori
      then AContext.GetProperties.GetPropertyByName(ARelationPropertyName).SetValue(AContext.DataObject, ARelationOID);
    // PreProcess (persist) relation childs (BelongsTo)
    Self.PreProcessRelationChild(AContext);
    // Process the current object
    // --------------------------
    case AContext.ObjectStatus of
      // DIRTY
      //  If the ID property of the object is not assigned then insert
      //  the object else update
      osDirty:
      begin
        if AContext.GetProperties.GetIdProperty.GetValue(AContext.DataObject).AsInteger = IO_INTEGER_NULL_VALUE
        then Self.InsertObject(AContext)
        else Self.UpdateObject(AContext);
        AContext.ObjectStatus := osClean;
      end;
      // DELETE
      osDeleted: begin
        Self.DeleteObject(AContext);
        AContext.ObjectStatus := osClean;
      end;
    end;
    // --------------------------
    // PostProcess (persist) relation childs (HasMany, HasOne)
    Self.PostProcessRelationChild(AContext);

    Self.CommitTransaction(AContext.GetConnectionDefName);
  except
    Self.RollbackTransaction(AContext.GetConnectionDefName);
    raise;
  end;
end;

class function TIupOrm.RefTo(AClassRef: TioClassRef): TioWhere;
begin
  Result := TioWhere.Create;
  Result.SetClassRef(AClassRef);
end;

class function TIupOrm.RefTo<T>: TioWhere<T>;
begin
  Result := TioWhere<T>.Create;
  Result.SetClassRef(T);
end;

class procedure TIupOrm.RollbackTransaction(AConnectionName:String);
begin
  TioDBFactory.Connection(AConnectionName).Rollback;
end;

class procedure TIupOrm.StartTransaction(AConnectionName:String);
begin
  TioDBFactory.Connection(AConnectionName).StartTransaction;
end;

class procedure TIupOrm.UpdateObject(AContext: IioContext);
begin
  // If the object is not present in the database then perform
  //  an Insert instead of an Update to prevent a data loss
  if not Self.ObjectExists(AContext) then
  begin
    Self.InsertObject(AContext);
    Exit;
  end;
  // Create and execute query
  TioDbFactory.SqlGenerator.GenerateSqlUpdate(AContext).ExecSQL;
end;

class procedure TIupOrm.AutoCreateDatabase;
begin
  TioDBCreatorFactory.GetDBCreator.AutoCreateDatabase;
end;

class procedure TIupOrm.CommitTransaction(AConnectionName:String);
begin
  TioDBFactory.Connection(AConnectionName).Commit;
end;

class function TIupOrm.ConnectionManager: TioConnectionManagerRef;
begin
  Result := Self.GlobalFactory.DBFactory.ConnectionManager;
end;

class procedure TIupOrm.Delete(AObj: TObject);
var
  AContext: IioContext;
begin
  // Check
  if not Assigned(AObj) then Exit;
  // Create Context
  AContext := TioContextFactory.Context(AObj.ClassName, nil, AObj);
  // Execute
  Self.DeleteObject(AContext);
end;

class procedure TIupOrm.DeleteObject(AContext: IioContext);
begin
  // Create and execute query
  TioDbFactory.SqlGenerator.GenerateSqlDelete(AContext).ExecSQL;
end;

class function TIupOrm.DependencyInjection: TioDependencyInjectionRef;
begin
  Result := TioDependencyInjection;
end;

class function TIupOrm.GlobalFactory: TioGlobalFactoryRef;
begin
  Result := TioGlobalFactory;
end;

class procedure TIupOrm.InsertObject(AContext: IioContext);
var
  AQuery: IioQuery;
  LastInsertID: Integer;
begin
  // Create query
  AQuery := TioDbFactory.SqlGenerator.GenerateSqlInsert(AContext);
  // Execute query
  LastInsertID := AQuery.ExecSQL;
  if LastInsertID = -1 then raise EIupOrmException.Create(Self.ClassName + ': last insert ID not valid');
  // Retrieve ID
  AContext.GetProperties.GetIdProperty.SetValue(AContext.DataObject, LastInsertID);
end;

class function TIupOrm.Load(AClassRef:TioClassRef): TioWhere;
begin
  Result := Self.RefTo(AClassRef);
end;

{ TioTObjectHelper }

function TioTObjectHelper.ioAsInterface<T>: T;
begin
  if not Supports(Self, GetTypeData(TypeInfo(T))^.Guid, Result) then
    raise EIupOrmException.Create(Self.ClassName + ': interface non implemented by object!');
end;

function TioTObjectHelper.IupOrm: IioObjectHelperTools;
begin
  Result := TioObjectHelperTools.Create(Self);
end;

{ TioBindSourceHelper }

procedure TioBindSourceHelper.Append;
begin
  Self.InternalAdapter.Append;
end;

function TioBindSourceHelper.IupOrm: IioBindSourceHelperTools;
begin
  Result := TioBindSourceHelperTools.Create(Self);
end;

end.


