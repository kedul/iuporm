unit IupOrm.ObjectsForge.Interfaces;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.Context.Interfaces,
  IupOrm.DB.Interfaces,
  System.Rtti, IupOrm.CommonTypes;

type
  // ClassRef to ObjectMaker
  TioObjectMakerRef = class of TioObjectMakerIntf;

  // ObjectMaker interface
  TioObjectMakerIntf = class abstract
  strict protected
    class function CheckOrCreateRelationChildObject(const AContext:IioContext; const AProperty:IioContextProperty): TObject;
    class function LoadPropertyHasMany(AContext:IioContext; AQuery:IioQuery; AProperty:IioContextProperty): TObject;
    class function LoadPropertyHasOne(AContext:IioContext; AQuery:IioQuery; AProperty:IioContextProperty): TObject;
    class function LoadPropertyBelongsTo(AContext:IioContext; AQuery:IioQuery; AProperty:IioContextProperty): TObject;
    class function LoadPropertyStreamable(AContext:IioContext; AQuery:IioQuery; AProperty:IioContextProperty): TObject;
    class procedure LoadPropertyStream(AContext:IioContext; AQuery:IioQuery; AProperty:IioContextProperty);
    class function InternalFindMethod(ARttiType:TRttiType; AMethodName,AMarkerText:String; IsConstructor:Boolean; const AParameters:Array of TValue): TRttiMethod;
    class function FindConstructor(ARttiType:TRttiType; const AParameters:Array of TValue; AMarkerText:String=''; AMethodName:String=''): TRttiMethod;
    class function FindMethod(ARttiType:TRttiType; AMethodName:String; const AParameters:Array of TValue; AMarkerText:String=''): TRttiMethod;
  public
    class function CreateObjectFromBlobField(AQuery:IioQuery; AProperty:IioContextProperty): TObject;
    class function CreateObjectByClassRef(AClassRef: TClass): TObject;
    class function CreateObjectByClassRefEx(AClassRef: TClass; const AConstructorParams:array of TValue; AConstructorMarkerText:String=''; AConstructorMethodName:String=''): TObject;
    class function CreateObjectByRttiType(ARttiType:TRttiType): TObject;
    class function CreateObjectByRttiTypeEx(ARttiType:TRttiType; const AConstructorParams:array of TValue; AConstructorMarkerText:String=''; AConstructorMethodName:String=''): TObject;
    class function CreateListByClassRef(AClassRef:TClass; AOwnsObjects:Boolean=True): TObject;
    class function CreateListByRttiType(const ARttiType:TRttiType; const AOwnsObject:Boolean=True): TObject;
    class function MakeObject(AContext:IioContext; AQuery:IioQuery): TObject; virtual; abstract;
  end;

implementation

uses
  System.TypInfo, IupOrm.Exceptions, IupOrm, IupOrm.RttiContext.Factory,
  IupOrm.DuckTyped.Interfaces, IupOrm.DuckTyped.Factory, System.Classes,
  Data.DB, IupOrm.LazyLoad.Interfaces, System.SysUtils, IupOrm.Attributes, FMX.Dialogs,
  IupOrm.Resolver.Interfaces, IupOrm.Resolver.Factory;

{ TioObjectMakerIntf }

class function TioObjectMakerIntf.CheckOrCreateRelationChildObject(const AContext: IioContext; const AProperty: IioContextProperty): TObject;
begin
  Result := nil;
  // If the AProperty is of interface type...
  if AProperty.IsInterface then
  begin
    // Create the list if it isn't not already created by the master class constructor
    Result := AProperty.GetValue(AContext.DataObject).AsInterface as TObject;
    if not Assigned(Result) then
      Result := TIupOrm.DependencyInjection.Locate(AProperty.GetTypeName).Alias(AProperty.GetTypeAlias).Get;
    Result.ioAsInterface<IInterface>._AddRef;    // Adjust the RefCount to prevent an access violation
  end else
  // If the AProperty is of instance (class) type...
  begin
    // Create the list if it isn't not already created by the master class constructor
    Result := AProperty.GetValue(AContext.DataObject).AsObject;
    if not Assigned(Result) then
      if AProperty.GetRelationType = ioRTHasMany then
        Result := Self.CreateListByRttiType(   AProperty.GetRttiProperty.PropertyType   )
      else
        Result := Self.CreateObjectByRttiType(   AProperty.GetRttiProperty.PropertyType   );
  end;
end;

class function TioObjectMakerIntf.CreateListByClassRef(AClassRef: TClass;
  AOwnsObjects: Boolean): TObject;
begin
  Result := Self.CreateListByRttiType(   TioRttiContextFactory.RttiContext.GetType(AClassref)   , AOwnsObjects);
end;

class function TioObjectMakerIntf.CreateListByRttiType(const ARttiType:TRttiType; const AOwnsObject:Boolean): TObject;
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
  if Assigned(Prop) then Prop.SetValue(PTypeInfo(Result), AOwnsObject);
end;

class function TioObjectMakerIntf.CreateObjectByClassRef(
  AClassRef: TClass): TObject;
begin
  Result := Self.CreateObjectByClassRefEx(AClassRef, []);
end;

class function TioObjectMakerIntf.CreateObjectByClassRefEx(AClassRef: TClass; const AConstructorParams: array of TValue;
  AConstructorMarkerText, AConstructorMethodName: String): TObject;
begin
  // Create object
  Result := Self.CreateObjectByRttiTypeEx(
                                          TioRttiContextFactory.RttiContext.GetType(AClassref),
                                          AConstructorParams,
                                          AConstructorMarkerText,
                                          AConstructorMethodName
                                         );
end;

class function TioObjectMakerIntf.CreateObjectByRttiType(ARttiType: TRttiType): TObject;
begin
  Result := Self.CreateObjectByRttiTypeEx(ARttiType, []);
end;

class function TioObjectMakerIntf.CreateObjectByRttiTypeEx(ARttiType: TRttiType;
  const AConstructorParams:array of TValue; AConstructorMarkerText,
  AConstructorMethodName: String): TObject;
var
  AMethod: TRttiMethod;
begin
  // init
  Result := nil;
  AMethod := nil;
  // Find the constructor
  AMethod := Self.FindConstructor(ARttiType, AConstructorParams, AConstructorMarkerText, AConstructorMethodName);
  // If constructor not found...
  if not Assigned(AMethod) then EIupOrmException.Create(Self.ClassName + ': Constructor not found for class "' + ARttiType.Name + '"');
  // Execute
  Result := AMethod.Invoke(ARttiType.AsInstance.MetaclassType, AConstructorParams).AsObject;

  // Second solution, dirty and fast (by Daniele Teti DORM)
//   Result := TObject(ARttiType.GetMethod('Create')
//   .Invoke(ARttiType.AsInstance.MetaclassType, []).AsObject);
end;

class function TioObjectMakerIntf.InternalFindMethod(ARttiType:TRttiType; AMethodName,AMarkerText:String; IsConstructor:Boolean; const AParameters:Array of TValue): TRttiMethod;
var
  AMethod: TRttiMethod;
  function CheckForMarker(ARttiMethod:TRttiMethod; AMarkerText:String): Boolean;
  var
    AAttribute: TCustomAttribute;
  begin
    Result := False;
    for AAttribute in ARttiMethod.GetAttributes do
      if  (AAttribute is ioMarker)
      and (ioMarker(AAttribute).Value.Equals(AMarkerText))
      then Exit(True);
  end;
begin
  // init
  Result := nil;
  // Loop for all methods
  for AMethod in ARttiType.GetMethods do
  begin
    if  AMethod.HasExtendedInfo
    and (   (AMethodName = '') or AMethod.Name.Equals(AMethodName)   )  // Check for method name
    and (AMethod.IsConstructor = IsConstructor)                         // Check for IsConstructor
    and (Length(AMethod.GetParameters) = Length(AParameters))           // Check for parameters count
    and (   (AMarkerText = '') or CheckForMarker(AMethod, AMarkerText)   )   // Check for marker
    then Exit(AMethod);
  end;
  // If method/constructor not found...
  EIupOrmException.Create(Self.ClassName + ': Method "' + AMethodName + '" not found');
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
  if AQuery.Fields.FieldByName(AProperty.GetSqlFieldAlias).IsNull then Exit;
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

class function TioObjectMakerIntf.FindConstructor(ARttiType: TRttiType;
  const AParameters: Array of TValue; AMarkerText,
  AMethodName: String): TRttiMethod;
begin
  Result := Self.InternalFindMethod(ARttiType, AMethodName, AMarkerText, True, AParameters);
end;

class function TioObjectMakerIntf.FindMethod(ARttiType: TRttiType;
  AMethodName: String; const AParameters: Array of TValue;
  AMarkerText: String): TRttiMethod;
begin
  Result := Self.InternalFindMethod(ARttiType, AMethodName, AMarkerText, True, AParameters);
end;

class function TioObjectMakerIntf.LoadPropertyBelongsTo(AContext: IioContext; AQuery: IioQuery;
  AProperty: IioContextProperty): TObject;
begin
  // Check if the result child relation object is alreaady created in the master object (by constructor); if it isn't
  //  then create it
  Result := Self.CheckOrCreateRelationChildObject(AContext, AProperty);
  // Load the relation child object
  TIupOrm.Load(AProperty.GetRelationChildTypeName, AProperty.GetRelationChildTypeAlias)
    .ByOID(AQuery.GetValue(AProperty).AsInteger)
    .ToObject(Result);
end;

class function TioObjectMakerIntf.LoadPropertyHasMany(AContext:IioContext;
  AQuery: IioQuery; AProperty: IioContextProperty): TObject;
var
  ALazyLoadableObj: IioLazyLoadable;
  AResolvedTypeList: IioResolvedTypeList;
  AInterface: IInterface;
begin
  // Check if the result child relation object is alreaady created in the master object (by constructor); if it isn't
  //  then create it
  Result := Self.CheckOrCreateRelationChildObject(AContext, AProperty);
  // If LazyLoadable then set LazyLoad data
  if (AProperty.GetRelationLoadType = ioLazyLoad)
  and Supports(Result, IioLazyLoadable, ALazyLoadableObj)
    // Set the lazy load relation data
    then ALazyLoadableObj.SetRelationInfo(
       AProperty.GetRelationChildTypeName
      ,AProperty.GetRelationChildTypeAlias
      ,AProperty.GetRelationChildPropertyName
      ,AQuery.GetValue(AContext.GetProperties.GetIdProperty).AsInteger
    )
    // Fill the list
    else TIupOrm.Load(AProperty.GetRelationChildTypeName, AProperty.GetRelationChildTypeAlias)._Where
      ._Property(AProperty.GetRelationChildPropertyName)
      ._EqualTo(AQuery.GetValue(AContext.GetProperties.GetIdProperty))
      .ToList(Result);
end;

class function TioObjectMakerIntf.LoadPropertyHasOne(AContext: IioContext;
  AQuery: IioQuery; AProperty: IioContextProperty): TObject;
begin
  // Check if the result child relation object is alreaady created in the master object (by constructor); if it isn't
  //  then create it
  Result := Self.CheckOrCreateRelationChildObject(AContext, AProperty);
  // Load the relation child object
  TIupOrm.Load(AProperty.GetRelationChildTypeName, AProperty.GetRelationChildTypeAlias)._Where
    ._Property(AProperty.GetRelationChildPropertyName)
    ._EqualTo(AQuery.GetValue(AContext.GetProperties.GetIdProperty))
    .ToObject(Result);
end;

class procedure TioObjectMakerIntf.LoadPropertyStream(AContext: IioContext; AQuery: IioQuery; AProperty: IioContextProperty);
var
  AStream, ABlobStream: TStream;
begin
  // If the field is null then exit
  if AQuery.Fields.FieldByName(AProperty.GetSqlFieldAlias).IsNull then Exit;
  // Get the stream from the DataObject property
  AStream := TStream(   AProperty.GetValue(AContext.DataObject).AsObject   );
  // If the stream is not assigned then raise an Exception
  //  (the stream must exist)
  if not Assigned(AStream) then raise EIupOrmException.Create(Self.ClassName + ': Stream not assigned.');
  // Get the BlobStream
  ABlobStream := AQuery.CreateBlobStream(AProperty, bmRead);
  try
    AStream.CopyFrom(ABlobStream, ABlobStream.Size);
    AStream.Position := 0;
  finally
    ABlobStream.Free;
  end;
end;

class function TioObjectMakerIntf.LoadPropertyStreamable(AContext: IioContext; AQuery: IioQuery;
  AProperty: IioContextProperty): TObject;
var
  ADuckTypedStreamObject: IioDuckTypedStreamObject;
  ABlobStream: TStream;
begin
  // Check if the result child relation object is alreaady created in the master object (by constructor); if it isn't
  //  then create it
  Result := Self.CheckOrCreateRelationChildObject(AContext, AProperty);
  // If the field is null then exit
  if AQuery.Fields.FieldByName(AProperty.GetSqlFieldAlias).IsNull then Exit;
  // Wrap the object into a DuckTypedStreamObject
  ADuckTypedStreamObject := TioDuckTypedFactory.DuckTypedStreamObject(Result);
  // Get the BlobStream
  ABlobStream := AQuery.CreateBlobStream(AProperty, bmRead);
  try
    // Load stream o the object
    ADuckTypedStreamObject.LoadFromStream(ABlobStream);
  finally
    ABlobStream.Free;
  end;
end;


end.
