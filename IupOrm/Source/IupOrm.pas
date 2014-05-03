unit IupOrm;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.context.interfaces,
  IupOrm.Context.Factory,
  IupOrm.CommonTypes,
  IupOrm.Where,
  IupOrm.DB.Interfaces,
  IupOrm.ObjectHelperTools.Interfaces;

type

  // TObject class helper
  TioTObjectHelper = class helper for TObject
  public
    function IupOrm: IioObjectHelperTools;
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
  public
    class function RefTo(AClassRef:TioClassRef): TioWhere; overload;
    class function RefTo<T:class,constructor>: TioWhere<T>; overload;
    class function Load(AClassRef:TioClassRef): TioWhere; overload;
    class function Load<T:class,constructor>: TioWhere<T>; overload;
    class procedure Delete(AObj: TObject);
    class procedure Persist(AObj: TObject);
  end;

implementation

uses
  IupOrm.DuckTyped.Interfaces, IupOrm.DuckTyped.Factory, IupOrm.Attributes,
  IupOrm.DB.Factory, IupOrm.Exceptions, IupOrm.ObjectHelperTools;


{ TIupOrm }

class function TIupOrm.Load<T>: TioWhere<T>;
begin
  Result := Self.RefTo<T>;
end;

class procedure TIupOrm.Persist(AObj: TObject);
var
  AContext: IioContext;
begin
  // Check
  if not Assigned(AObj) then Exit;
  // Create Context
  AContext := TioContextFactory.Context(AObj.ClassType, nil, AObj);
  // Execute
  Self.PersistObject(AContext);
end;

class procedure TIupOrm.PersistRelationChildList(AMasterContext:IioContext; AMasterProperty:IioContextProperty);
var
  ADuckTypedList: IioDuckTypedList;
  AObj: TObject;
  AContext: IioContext;
begin
  // Wrap the DestList into a DuckTypedList
  ADuckTypedList := TioDuckTypedFactory.DuckTypedList(   AMasterProperty.GetRelationChildObject(AMasterContext.DataObject)   );
  // Loop the list
  for AObj in ADuckTypedList do
  begin
    // Create context for current object
    AContext := TioContextFactory.Context(AObj.ClassType, nil, AObj);
    // Persist object
    Self.PersistObject(AContext
                      , AMasterProperty.GetRelationChildPropertyName
                      , AMasterContext.GetProperties.GetIdProperty.GetValue(AMasterContext.DataObject).AsInteger
                      );
  end;
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
  AContext := TioContextFactory.Context(AObj.ClassType, nil, AObj);
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
  // Set/Update MasterID property if this is a relation child object (HasMany, HasOne, BelongsTo)
  if (ARelationPropertyName <> '') and (ARelationOID <> 0)
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
      if AContext.GetProperties.GetIdProperty.GetValue(AContext.DataObject).AsInteger = 0
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

class procedure TIupOrm.UpdateObject(AContext: IioContext);
begin
  // Create and execute query
  TioDbFactory.SqlGenerator.GenerateSqlUpdate(AContext).ExecSQL;
end;

class procedure TIupOrm.Delete(AObj: TObject);
var
  AContext: IioContext;
begin
  // Check
  if not Assigned(AObj) then Exit;
  // Create Context
  AContext := TioContextFactory.Context(AObj.ClassType, nil, AObj);
  // Execute
  Self.DeleteObject(AContext);
end;

class procedure TIupOrm.DeleteObject(AContext: IioContext);
begin
  // Create and execute query
  TioDbFactory.SqlGenerator.GenerateSqlDelete(AContext).ExecSQL;
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

function TioTObjectHelper.IupOrm: IioObjectHelperTools;
begin
  Result := TioObjectHelperTools.Create(Self);
end;

end.
