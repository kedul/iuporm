unit IupOrm.ObjectsForge.Interfaces;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.Context.Interfaces,
  IupOrm.DB.Interfaces,
  System.Rtti;

type
  // ClassRef to ObjectMaker
  TioObjectMakerRef = class of TioObjectMakerIntf;

  // ObjectMaker interface
  TioObjectMakerIntf = class abstract
  strict protected
    class function LoadPropertyHasMany(AContext:IioContext; AQuery:IioQuery; AProperty:IioContextProperty): TObject;
    class function LoadPropertyHasOne(AContext:IioContext; AQuery:IioQuery; AProperty:IioContextProperty): TObject;
  public
    class function CreateObjectFromBlobField(AQuery:IioQuery; AProperty:IioContextProperty): TObject;
    class function CreateObjectByClassRef(AClassRef: TClass): TObject;
    class function CreateObjectByRttiType(ARttiType: TRttiType): TObject;
    class function CreateListByClassRef(AClassRef:TClass; AOwnsObjects:Boolean=True): TObject;
    class function CreateListByRttiType(ARttiType: TRttiType): TObject;
    class function MakeObject(AContext:IioContext; AQuery:IioQuery): TObject; virtual; abstract;
  end;

implementation

uses
  System.TypInfo, IupOrm.Exceptions, IupOrm, IupOrm.RttiContext.Factory,
  IupOrm.DuckTyped.Interfaces, IupOrm.DuckTyped.Factory, System.Classes,
  Data.DB;

{ TioObjectMakerIntf }

class function TioObjectMakerIntf.CreateListByClassRef(AClassRef: TClass;
  AOwnsObjects: Boolean): TObject;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  inherited;
  // Init
  Result := nil;
  // Prepare Rtti
  Ctx := TioRttiContextFactory.RttiContext;
  Typ := Ctx.GetType(AClassRef);
  // Create and return New List
  Result := Self.CreateListByRttiType(Typ);
end;

class function TioObjectMakerIntf.CreateListByRttiType(
  ARttiType: TRttiType): TObject;
var
  Prop: TRttiProperty;
begin
  inherited;
  // Init
  Result := nil;
  // Proprerty "OwnsObjects" by Rtti
  Prop := ARttiType.GetProperty('OwnsObjects');
  // Create object
  Result := Self.CreateObjectByRttiType(ARttiType);
  // Set "OwnsObjects" if exists
  if Assigned(Prop) then Prop.SetValue(PTypeInfo(Result), True);
end;

class function TioObjectMakerIntf.CreateObjectByClassRef(
  AClassRef: TClass): TObject;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  inherited;
  // Init
  Result := nil;
  // Prepare Rtti
  Ctx := TioRttiContextFactory.RttiContext;
  Typ := Ctx.GetType(AClassRef);
  // Create object
  Result := Self.CreateObjectByRttiType(Typ);
end;

class function TioObjectMakerIntf.CreateObjectByRttiType(
  ARttiType: TRttiType): TObject;
var
  AMethod: TRttiMethod;
begin
  inherited;
  // init
  Result := nil;
  AMethod := nil;
  // Loop for all methods
  for AMethod in ARttiType.GetMethods do
    // If current method is a parameterless constructor
    if  AMethod.HasExtendedInfo
    and AMethod.IsConstructor
    and (Length(AMethod.GetParameters) = 0)
    then
    begin
      // Create the object and exit
      Result := AMethod.Invoke(ARttiType.AsInstance.MetaclassType, []).AsObject;
      Exit;
    end;
  // If constructor not found...
  EIupOrmException.Create(Self.ClassName + ': Constructor (no params) not found');

  // Second solution, dirty and fast (by Daniele Teti DORM)
  // Result := TObject(ARttiType.GetMethod('Create')
  // .Invoke(ARttiType.AsInstance.MetaclassType, []).AsObject);
end;

class function TioObjectMakerIntf.CreateObjectFromBlobField(
  AQuery: IioQuery; AProperty: IioContextProperty): TObject;
var
  ADuckTypedStreamObject: IioDuckTypedStreamObject;
  AStream: TStream;
begin
  // Create the object
  Result := Self.CreateObjectByRttiType(   AProperty.GetRttiProperty.PropertyType   );
  // If the field is null then exit
  if AQuery.Fields.FieldByName(AProperty.GetSqlFieldName).IsNull then Exit;
  // Wrap the object into a DuckTypedStreamObject
  ADuckTypedStreamObject := TioDuckTypedFactory.DuckTypedStreamObject(Result);
  // Get the BlobStream
  AStream := AQuery.CreateBlobStream(AProperty, bmRead);
  try
    // Load stream o the object
    AStream.Position := 0;
    ADuckTypedStreamObject.LoadFromStream(AStream);
  finally
    AStream.Free;
  end;
end;

class function TioObjectMakerIntf.LoadPropertyHasMany(AContext:IioContext;
  AQuery: IioQuery; AProperty: IioContextProperty): TObject;
begin
  // Create the list
  Result := Self.CreateListByRttiType(   AProperty.GetRttiProperty.PropertyType   );
  // Fill the list
  TIupOrm.Load(AProperty.GetRelationChildClassRef)._Where
                                                  ._Property(AProperty.GetRelationChildPropertyName)
                                                  ._EqualTo(AQuery.GetValue(AContext.GetProperties.GetIdProperty))
                                                  .ToList(Result);
end;

class function TioObjectMakerIntf.LoadPropertyHasOne(AContext: IioContext;
  AQuery: IioQuery; AProperty: IioContextProperty): TObject;
begin
  // Load the relation child object
  Result := TIupOrm.Load(AProperty.GetRelationChildClassRef)._Where
                                                            ._Property(AProperty.GetRelationChildPropertyName)
                                                            ._EqualTo(AQuery.GetValue(AContext.GetProperties.GetIdProperty))
                                                            .ToObject;
end;

end.
