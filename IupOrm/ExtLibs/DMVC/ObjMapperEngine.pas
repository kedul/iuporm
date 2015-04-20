unit ObjMapperEngine;

interface

uses
  System.Rtti, System.JSON, DuckPropFieldU, System.Generics.Collections,
  System.SysUtils;

type

  TSerializationType = (stProperties, stFields);

  TJSONBox = TJSONObject;

  TJSONObjectActionProc = reference to procedure(const AJSONObject: TJSONObject);


  omEngine = class
  private
    class var Ctx: TRTTIContext;
    class function HasAttribute<T: class>(const ARTTIMember: TRttiNamedObject): boolean; overload;
    class function HasAttribute<T: class>(const ARTTIMember: TRttiNamedObject; out AAttribute: T): boolean; overload;
    class function GetKeyName(const ARttiMember: TRttiNamedObject; const AType: TRttiType): string;
  public
    class function GetCtx: TRttiContext;
    // Serializers
    class function SerializeObject(const AObject: TObject; const ASerializationType: TSerializationType; AUseClassName: Boolean; const AIgnoredProperties: array of string): TJSONBox; overload; static;
    class function SerializeObject(const AInterfacedObject: IInterface; const ASerializationType: TSerializationType; AUseClassName: Boolean; const AIgnoredProperties: array of string): TJSONBox; overload; static;
    class function SerializeObjectList(const AList:TObjectList<TObject>; const ASerializationType: TSerializationType; AUseClassName: Boolean; AOwnsInstance: boolean; AForEach: TJSONObjectActionProc): TJSONBox;
    class function SerializePropField(const AValue: TValue; const APropField: TRttiNamedObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean): TJSONValue;
    class function SerializeFloat(const AValue: TValue; const AQualifiedTypeName: String): TJSONValue;
    class function SerializeEnumeration(const AValue: TValue; const AQualifiedTypeName: String): TJSONValue;
    class function SerializeInteger(const AValue: TValue): TJSONValue;
    class function SerializeString(const AValue: TValue): TJSONValue;
    class function SerializeRecord(const AValue: TValue; const AQualifiedTypeName: String): TJSONValue;
    class function SerializeClass(const AValue: TValue; const APropField: TRttiNamedObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean): TJSONValue;
    class function SerializeInterface(const AValue: TValue; const APropField: TRttiNamedObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean): TJSONValue;
    class function SerializeList(const AList: TObject; const ASerializationType: TSerializationType; AUseClassName: Boolean): TJSONValue; static;
    // Deserializers
    class function DeserializeObject(const AJSONBox: TJSONBox; AObject:TObject; const ASerializationType: TSerializationType; const AUseClassName: Boolean): TObject;
    class function DeserializeObjectByClass(const AJSONBox: TJSONBox; const AClassName: String; const ASerializationType: TSerializationType; const AUseClassName: Boolean): TObject;
    class procedure DeserializeObjectList<T: class, constructor>(const AJSONBox: TJSONBox; AList: TObjectList<T>; const ASerializationType: TSerializationType; const AUseClassName: Boolean);
    class procedure DeserializePropField(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; const AMasterObj: TObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean);
    class function DeserializeFloat(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): TValue;
    class function DeserializeEnumeration(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): TValue;
    class function DeserializeInteger(const AJSONValue: TJSONValue): TValue;
    class function DeserializeString(const AJSONValue: TJSONValue): TValue;
    class function DeserializeRecord(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): TValue;
    class procedure DeserializeClass(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; AMasterObj: TObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean);
    class procedure DeserializeClassCommon(AChildObj: TObject; const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; AMasterObj: TObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean);
    class procedure DeserializeInterface(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; AMasterObj: TObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean);
    class function DeserializeList(AList: TObject; const AJSONValue: TJSONValue; const ASerializationType: TSerializationType; const AUseClassName:Boolean): TObject;
  end;

  EMapperException = class(Exception)

  end;



function ISODateTimeToString(ADateTime: TDateTime): string;
function ISODateToString(ADate: TDateTime): string;
function ISOTimeToString(ATime: TTime): string;

function ISOStrToDateTime(DateTimeAsString: string): TDateTime;
function ISOStrToDate(DateAsString: string): TDate;
function ISOStrToTime(TimeAsString: string): TTime;

implementation

uses
{$IFDEF ioPresent}
  IupOrm.DMVC.ObjectsMappersAdapter,
{$ELSE}
  DuckObjU,
{$ENDIF}
  DuckListU, System.Classes, Soap.EncdDecd,
  RTTIUtilsU, System.TypInfo, ObjMapperAttributes, System.DateUtils;




const
  DMVC_CLASSNAME = '$dmvc_classname';



function ISOTimeToString(ATime: TTime): string;
var
  fs: TFormatSettings;
begin
  fs.TimeSeparator := ':';
  Result := FormatDateTime('hh:nn:ss', ATime, fs);
end;

function ISODateToString(ADate: TDateTime): string;
begin
  Result := FormatDateTime('YYYY-MM-DD', ADate);
end;

function ISODateTimeToString(ADateTime: TDateTime): string;
var
  fs: TFormatSettings;
begin
  fs.TimeSeparator := ':';
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', ADateTime, fs);
end;

function ISOStrToDateTime(DateTimeAsString: string): TDateTime;
begin
  Result := EncodeDateTime(StrToInt(Copy(DateTimeAsString, 1, 4)),
    StrToInt(Copy(DateTimeAsString, 6, 2)), StrToInt(Copy(DateTimeAsString, 9, 2)),
    StrToInt(Copy(DateTimeAsString, 12, 2)), StrToInt(Copy(DateTimeAsString, 15, 2)),
    StrToInt(Copy(DateTimeAsString, 18, 2)), 0);
end;

function ISOStrToTime(TimeAsString: string): TTime;
begin
  Result := EncodeTime(StrToInt(Copy(TimeAsString, 1, 2)), StrToInt(Copy(TimeAsString, 4, 2)),
    StrToInt(Copy(TimeAsString, 7, 2)), 0);
end;

function ISOStrToDate(DateAsString: string): TDate;
begin
  Result := EncodeDate(StrToInt(Copy(DateAsString, 1, 4)), StrToInt(Copy(DateAsString, 6, 2)),
    StrToInt(Copy(DateAsString, 9, 2)));
  // , StrToInt
  // (Copy(DateAsString, 12, 2)), StrToInt(Copy(DateAsString, 15, 2)),
  // StrToInt(Copy(DateAsString, 18, 2)), 0);
end;


// function ISODateToStr(const ADate: TDate): String;
// begin
// Result := FormatDateTime('YYYY-MM-DD', ADate);
// end;
//
// function ISOTimeToStr(const ATime: TTime): String;
// begin
// Result := FormatDateTime('HH:nn:ss', ATime);
// end;


{ Serializer }

class procedure omEngine.DeserializeClass(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; AMasterObj: TObject;
  const ASerializationType: TSerializationType; const AUseClassName:Boolean);
var
  AChildObj: TObject;
begin
  AChildObj := TDuckPropField.GetValue(AMasterObj, APropField).AsObject;
  Self.DeserializeClassCommon(AChildObj, AJSONValue, APropField, AMasterObj, ASerializationType, AUseClassName);
end;

class procedure omEngine.DeserializeClassCommon(AChildObj: TObject; const AJSONValue: TJSONValue; const APropField: TRttiNamedObject;
  AMasterObj: TObject; const ASerializationType: TSerializationType; const AUseClassName: Boolean);
var
  _attrser: MapperSerializeAsString;
  SerStreamASString: string;
  SerEnc: TEncoding;
  SS: TStringStream;
  sw: TStreamWriter;
  MS: TMemoryStream;
  LClassName: string;
  Arr: TJSONArray;
  list: IWrappedList;
  I: Integer;
  wObj: IWrappedObject;
  jvalue: TJSONValue;
begin
  if not Assigned(AJSONValue) then   // JSONKey not present
  begin
//    if Assigned(AChildObj) then   // WHY???
//      FreeAndNil(AChildObj);      // WHY???
      Exit;
  end;

  if Assigned(AChildObj) then
  begin
    // ---------- Stream ----------
    if AChildObj is TStream then
    begin
      if AJSONValue is TJSONString then
      begin
        SerStreamASString := TJSONString(AJSONValue).Value;
      end
      else
        raise EMapperException.Create('Expected JSONString in ' + APropField.Name);

      if Self.HasAttribute<MapperSerializeAsString>(APropField, _attrser) then
      begin
        // serialize the stream as a normal string...
        TStream(AChildObj).Position := 0;
        SerEnc := TEncoding.GetEncoding(_attrser.Encoding);
        SS := TStringStream.Create(SerStreamASString, SerEnc);
        try
          SS.Position := 0;
          TStream(AChildObj).CopyFrom(SS, SS.Size);
        finally
          SS.Free;
        end;
      end
      else
      begin
        // deserialize the stream as Base64 encoded string...
        TStream(AChildObj).Position := 0;
        sw := TStreamWriter.Create(TStream(AChildObj));
        try
          sw.Write(DecodeString(SerStreamASString));
        finally
          sw.Free;
        end;
      end;
    end
    // ---------- End Stream ----------
    // ---------- List ----------
    else if TDuckTypedList.CanBeWrappedAsList(AChildObj) then
    begin // restore collection
      Self.DeserializeList(AChildObj, AJSONValue, ASerializationType, AUseClassName);
    end
    // ---------- End List ----------
    // ---------- StreamableObject ----------
    else if HasAttribute<StreamableAttribute>(APropField) then
    begin
      SerStreamASString := (jvalue as TJSONString).Value;
      SS := TSTringStream.Create;
      MS := TMemoryStream.Create;
      try
        SS.WriteString(SerStreamASString);
        SS.Position := 0;
        DecodeStream(SS, MS);
        MS.Position := 0;
        wObj := WrapAsObject(AChildObj);
        if Assigned(wObj) then
          wObj.LoadFromStream(MS);
      finally
        MS.Free;
        SS.Free;
      end;
    end
    // ---------- End StreamableObject ----------
    // ---------- Other type of object ----------
    else // try to deserialize into the property... but the json MUST be an object
    begin
      if AJSONValue is TJSONObject then
      begin
        Self.DeserializeObject(TJSONObject(AJSONValue), AChildObj, ASerializationType, AUseClassName);
      end
      else if jvalue is TJSONNull then
        FreeAndNil(AChildObj)
      else
        raise EMapperException.Create('Cannot deserialize property ' + APropField.Name);
    end;
    // ---------- End Other type of object ----------
  end;
end;

class function omEngine.DeserializeEnumeration(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): TValue;
var
  APropFieldRttiType: TRttiType;
begin
  APropFieldRttiType := TDuckPropField.RttiType(APropField);

//  if not Assigned(AJSONValue) then   // JSONKey not present
//    raise EMapperException.Create(APropField.Name + ' key field is not present in the JSONObject');

  if APropFieldRttiType.QualifiedName = 'System.Boolean' then
  begin
    if AJSONValue is TJSONTrue then
       Result := True
    else if AJSONValue is TJSONFalse then
       Result := False
    else
      raise EMapperException.Create('Invalid value for property ' + APropField.Name);
  end
  else // it is an enumerated value but it's not a boolean.
    TValue.Make((AJSONValue as TJSONNumber).AsInt, APropFieldRttiType.Handle, Result);
end;

class function omEngine.DeserializeFloat(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): TValue;
var
  APropFieldRttiType: TRttiType;
begin
  APropFieldRttiType := TDuckPropField.RttiType(APropField);

  if not Assigned(AJSONValue) then   // JSONKey not present
    Result := 0
  else
  begin
    if APropFieldRttiType.QualifiedName = 'System.TDate' then
    begin
      if AJSONValue is TJSONNull then
        Result := 0
      else
        Result := ISOStrToDateTime(AJSONValue.Value + ' 00:00:00');
    end
    else if APropFieldRttiType.QualifiedName = 'System.TDateTime' then
    begin
      if AJSONValue is TJSONNull then
        Result := 0
      else
        Result := ISOStrToDateTime(AJSONValue.Value);
    end
    else if APropFieldRttiType.QualifiedName = 'System.TTime' then
    begin
      if AJSONValue is TJSONString then
        Result := ISOStrToTime(AJSONValue.Value)
      else
        raise EMapperException.CreateFmt('Cannot deserialize [%s], expected [%s] got [%s]',
          [APropField.Name, 'TJSONString', AJSONValue.ClassName]);
    end
    else { if APropFieldRttiType.QualifiedName = 'System.Currency' then }
    begin
      if AJSONValue is TJSONNumber then
        Result := TJSONNumber(AJSONValue).AsDouble
      else
        raise EMapperException.CreateFmt('Cannot deserialize [%s], expected [%s] got [%s]',
          [APropField.Name, 'TJSONNumber', AJSONValue.ClassName]);
    end;
  end;
end;

class function omEngine.DeserializeInteger(const AJSONValue: TJSONValue): TValue;
begin
  if not Assigned(AJSONValue) then  // JSONKey not present
    Result := 0
  else
    Result := StrToIntDef(AJSONValue.Value, 0);
end;

class procedure omEngine.DeserializeInterface(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; AMasterObj: TObject;
  const ASerializationType: TSerializationType; const AUseClassName: Boolean);
var
  AChildObj: TObject;
begin
  AChildObj := TDuckPropField.GetValue(AMasterObj, APropField).AsInterface as TObject;
  Self.DeserializeClassCommon(AChildObj, AJSONValue, APropField, AMasterObj, ASerializationType, AUseClassName);
end;

class function omEngine.DeserializeList(AList: TObject; const AJSONValue: TJSONValue; const ASerializationType: TSerializationType;
  const AUseClassName: Boolean): TObject;
var
  LClassName: string;
  LJValue: TJSONValue;
  AJSONArray: TJSONArray;
  ADuckList: IWrappedList;
  I: Integer;
begin
  // If AUseClassName is true then get the "items" JSONArray containing che containing the list items
  //  else AJSONValue is the JSONArray containing che containing the list items
  if AUseClassName then
  begin
    if not (AJSONValue is TJSONObject) then
      raise EMapperException.Create('Wrong serialization for ' + AList.QualifiedClassName);
    LClassName := TJSONObject(AJSONValue).Get(DMVC_CLASSNAME).JsonValue.Value;
    if AList = nil then // recreate the object as it should be
      AList := TRTTIUtils.CreateObject(LClassName);
    LJValue := TJSONObject(AJSONValue).Get('items').JsonValue;
  end
  else
    LJValue := AJSONValue;
  if LJValue is TJSONArray then
  begin
    AJSONArray := TJSONArray(LJValue);
    ADuckList := WrapAsList(AList);
    for I := 0 to AJSONArray.Size - 1 do
    begin
      ADuckList.Add(   Self.DeserializeObject(AJSONArray.Get(I) as TJSONObject, nil, ASerializationType, AUseClassName)   );
    end;
  end
  else
    raise EMapperException.Create('Cannot restore the list because the related JSONValue is not an array');
  Result := AList;
end;

class procedure omEngine.DeserializePropField(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject;
  const AMasterObj: TObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean);
begin
  case TDuckPropField.RttiType(APropField).TypeKind of
    tkEnumeration:
      TDuckPropField.SetValue(AMasterObj, APropField, Self.DeserializeEnumeration(AJSONValue, APropField));
    tkInteger, tkInt64:
      TDuckPropField.SetValue(AMasterObj, APropField, Self.DeserializeInteger(AJSONValue));
    tkFloat:
      TDuckPropField.SetValue(AMasterObj, APropField, Self.DeserializeFloat(AJSONValue, APropField));
    tkString, tkLString, tkWString, tkUString:
      TDuckPropField.SetValue(AMasterObj, APropField, Self.DeserializeString(AJSONValue));
    tkRecord:
      TDuckPropField.SetValue(AMasterObj, APropField, Self.DeserializeRecord(AJSONValue, APropField));
    tkClass:
        Self.DeserializeClass(AJSONValue,
                              APropField,
                              AMasterObj,
                              ASerializationType,
                              AUseClassName
                              );
    tkInterface:
        Self.DeserializeInterface(AJSONValue,
                                  APropField,
                                  AMasterObj,
                                  ASerializationType,
                                  AUseClassName
                                  );
  end;
end;

class function omEngine.DeserializeRecord(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): TValue;
var
  APropFieldRttiType: TRttiType;
begin
  APropFieldRttiType := TDuckPropField.RttiType(APropField);
  if APropFieldRttiType.QualifiedName = 'System.SysUtils.TTimeStamp' then
  begin
    if not Assigned(AJSONValue) then  // JSONKey not present
      Result := TValue.From<TTimeStamp>(MSecsToTimeStamp(0))
    else
      Result := TValue.From<TTimeStamp>(MSecsToTimeStamp(   (AJSONValue as TJSONNumber).AsInt64   ));
  end;
end;

class function omEngine.DeserializeString(const AJSONValue: TJSONValue): TValue;
begin
  if not Assigned(AJSONValue) then  // JSONKey not present
    Result := ''
  else
    Result := AJSONValue.Value;
end;

class function omEngine.DeserializeObject(const AJSONBox: TJSONBox; AObject: TObject;
  const ASerializationType: TSerializationType; const AUseClassName: Boolean): TObject;
var
  PropField: System.Rtti.TRttiNamedObject;
  PropsFields: TArray<System.Rtti.TRttiNamedObject>;
  KeyName: String;
  lJClassName: TJSONString;
  JValue: TJSONValue;
  _type: TRttiType;
  AObjectIsValid: Boolean;
begin
  AObjectIsValid := Assigned(AObject);
  // If the AObject is not assigned then try to create the Object using the DMVC_ClassName value in the
  //  JSONBox
  if not AObjectIsValid then
  begin
{$IF CompilerVersion <= 26}
    if Assigned(AJSONBox.Get(DMVC_CLASSNAME)) then
    begin
      lJClassName := AJSONBox.Get(DMVC_CLASSNAME).JsonValue as TJSONString;
    end
    else
      raise EMapperException.Create('No $classname property in the JSON object');
{$ELSE}
    if not AJSONBox.TryGetValue<TJSONString>(DMVC_CLASSNAME, lJClassName) then
      raise EMapperException.Create('No $classname property in the JSON object');
{$ENDIF}
    AObject := TRTTIUtils.CreateObject(lJClassName.Value);
  end;

  JValue := nil;
  _type := ctx.GetType(AObject.ClassInfo);

  try
    // Get members list
    case ASerializationType of
      stProperties:
        PropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(ctx.GetType(AObject.ClassInfo).AsInstance.GetProperties));
      stFields:
        PropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(ctx.GetType(AObject.ClassInfo).AsInstance.GetFields));
    end;
    // Loop for all members
    for PropField in PropsFields do
    begin
      // Check to continue or not
      if (not TDuckPropField.IsWritable(PropField) and (TDuckPropField.RttiType(PropField).TypeKind <> tkClass)) or
        (HasAttribute<MapperTransientAttribute>(PropField)) then
        Continue;
      // Get the JSONPair KeyName
      KeyName := GetKeyName(PropField, _type);
      // Check if JSONPair exists
      if Assigned(AJSONBox.Get(KeyName)) then
        JValue := AJSONBox.Get(KeyName).JsonValue // as LJSONKeyIsNotPresent := False
      else
        JValue := nil; // as LJSONKeyIsNotPresent := True
      // Deserialize the currente member and assign it to the object member
      Self.DeserializePropField(JValue, PropField, AObject, ASerializationType, AUseClassName);
    end;
    Result := AObject;
  except
    if not AObjectIsValid then
      FreeAndNil(AObject);
    raise;
  end;
end;

class function omEngine.DeserializeObjectByClass(const AJSONBox: TJSONBox; const AClassName: String;
  const ASerializationType: TSerializationType; const AUseClassName: Boolean): TObject;
var
  AObject: TObject;
  _rttiType: TRttiType;
begin
  _rttiType := omEngine.GetCtx.FindType(AClassName);
  if Assigned(_rttiType) then
  begin
    AObject := TRTTIUtils.CreateObject(_rttiType);
    try
      AObject := Self.DeserializeObject(AJSONBox, AObject, ASerializationType, AUseClassName);
      Result := AObject;
    except
      AObject.Free;
      raise;
    end;
  end
  else
    raise EMapperException.CreateFmt('Class not found [%s]', [AClassName]);
end;

class procedure omEngine.DeserializeObjectList<T>(const AJSONBox: TJSONBox; AList: TObjectList<T>;
  const ASerializationType: TSerializationType; const AUseClassName: Boolean);
var
  I: Integer;
  JChildObj: TJSONObject;
begin
  if Assigned(AJSONBox) then
  begin
    for I := 0 to AJSONBox.Count - 1 do
    begin
      JChildObj := AJSONBox.Pairs[I].JsonValue as TJSONObject;
//      AList.Add(Mapper.JSONObjectToObject<T>(AJSONArray.Get(I) as TJSONObject));

//    ***** NB: DA FINIRE *****

    end;
  end;
end;

class function omEngine.GetCtx: TRttiContext;
begin
  Result := Ctx;
end;

class function omEngine.GetKeyName(const ARttiMember: TRttiNamedObject; const AType: TRttiType): string;
var
  attrs: TArray<TCustomAttribute>;
  attr: TCustomAttribute;
begin
  // JSONSer property attribute handling
  attrs := ARttiMember.GetAttributes;
  for attr in attrs do
  begin
    if attr is MapperJSONSer then
      Exit(MapperJSONSer(attr).Name);
  end;

  // JSONNaming class attribute handling
  attrs := AType.GetAttributes;
  for attr in attrs do
  begin
    if attr is MapperJSONNaming then
    begin
      case MapperJSONNaming(attr).KeyCase of
        JSONNameUpperCase:
          begin
            Exit(UpperCase(ARttiMember.Name));
          end;
        JSONNameLowerCase:
          begin
            Exit(LowerCase(ARttiMember.Name));
          end;
      end;
    end;
  end;

  // Default
  Result := ARttiMember.Name;
end;

class function omEngine.HasAttribute<T>(const ARTTIMember: TRttiNamedObject): boolean;
var
  AAttribute: TCustomAttribute;
begin
  Result := HasAttribute<T>(ARTTIMember, AAttribute);
end;

class function omEngine.HasAttribute<T>(const ARTTIMember: TRttiNamedObject; out AAttribute: T): boolean;
var
  attrs: TArray<TCustomAttribute>;
  attr: TCustomAttribute;
begin
  AAttribute := nil;
  Result := false;
  attrs := ARTTIMember.GetAttributes;
  for attr in attrs do
    if attr is T then
    begin
      AAttribute := T(attr);
      Exit(True);
    end;
end;

class function omEngine.SerializeInterface(const AValue: TValue; const APropField: TRttiNamedObject;
  const ASerializationType: TSerializationType; const AUseClassName: Boolean): TJSONValue;
var
  AChildInterface: IInterface;
  AChildObj: TObject;
begin
  AChildInterface := AValue.AsInterface;
  AChildObj := AChildInterface as TObject;
  Result := Self.SerializeClass(AChildObj, APropField, ASerializationType, AUseClassName);
end;

class function omEngine.SerializeList(const AList: TObject; const ASerializationType: TSerializationType; AUseClassName: Boolean): TJSONValue;
var
  ACurrObj: TObject;
  ADuckList: IWrappedList;
  AJSONArray: TJSONArray;
  ResultJSONObj: TJSONObject;
  I: Integer;
begin
  ADuckList := WrapAsList(AList);
  // If AUseClassName is true then return a JSONObject with ClassName and a JSONArray containing the list items
  //  else return only the JSONArray containing the list items
  AJSONArray := TJSONArray.Create;
  if AUseClassName then
  begin
    ResultJSONObj := TJSONObject.Create;
    ResultJSONObj.AddPair(DMVC_CLASSNAME, AList.QualifiedClassName);
    ResultJSONObj.AddPair('items', AJSONArray);
    Result := ResultJSONObj;
  end
  else
    Result := AJSONArray;
  // Loop for all objects in the list (now compatible with interfaces)
  for I := 0 to ADuckList.Count-1 do
  begin
    ACurrObj := ADuckList.GetItem(I) as TObject;  // For interfaces compatibility
    AJSONArray.AddElement(   SerializeObject(ACurrObj, ASerializationType, AUseClassName, [])   );
  end;
end;

class function omEngine.SerializeClass(const AValue: TValue; const APropField: TRttiNamedObject; const ASerializationType: TSerializationType; const AUseClassName:Boolean): TJSONValue;
var
  AChildObj, Obj: TObject;
  list: IWrappedList;
  wObj: IWrappedObject;
  Arr: TJSONArray;
  ResultObj: TJSONObject;
  _attrser: MapperSerializeAsString;
  SerEnc: TEncoding;
  sr: TStringStream;
  SS: TStringStream;
  MS: TMemoryStream;
  EncBytes: TBytes;
  I: Integer;
begin
  AChildObj := AValue.AsObject;
  if Assigned(AChildObj) then
  begin
    // ---------- List ----------
    if TDuckTypedList.CanBeWrappedAsList(AChildObj) then
    begin
      Result := Self.SerializeList(AChildObj, ASerializationType, AUseClassName);
    end
    // ---------- End List ----------
    // ---------- Stream ----------
    else if AChildObj is TStream then
    begin
      if Self.HasAttribute<MapperSerializeAsString>(APropField, _attrser) then
      begin
        // serialize the stream as a normal string...
        TStream(AChildObj).Position := 0;
        SerEnc := TEncoding.GetEncoding(_attrser.Encoding);
        sr := TStringStream.Create('', SerEnc);
        try
          sr.LoadFromStream(TStream(AChildObj));
          Result := TJSONString.Create(sr.DataString);
        finally
          sr.Free;
        end;
      end
      else
      begin
        // serialize the stream as Base64 encoded string...
        TStream(AChildObj).Position := 0;
        SS := TStringStream.Create;
        try
          EncodeStream(TStream(AChildObj), SS);
          Result := TJSONString.Create(SS.DataString);
        finally
          SS.Free;
        end;
      end;
    end
    // ---------- End Stream ----------
    // ---------- StreamableObject ----------
    else if HasAttribute<StreamableAttribute>(APropField) then
    begin
      wObj := WrapAsObject(AChildObj);
      if Assigned(wObj) then
      begin
        MS := TMemoryStream.Create;
        SS := TStringStream.Create;
        try
          wObj.SaveToStream(MS);
          EncodeStream(MS, SS);
          Result := TJSONString.Create(SS.DataString);
        finally
          MS.Free;
          SS.Free;
        end;
      end;
    end
    // ---------- End StreamableObject ----------
    // ---------- Other type of object ----------
    else
    begin
      Result := Self.SerializeObject(AChildObj, ASerializationType, AUseClassName, []);
    end;
    // ---------- End other type of object ----------
  // Object (o) not assigned
  end
  else
  begin
    if Self.HasAttribute<MapperSerializeAsString>(APropField) then
      Result := TJSONString.Create('')
    else
      Result := TJSONNull.Create;
  end;
end;

class function omEngine.SerializeEnumeration(const AValue: TValue; const AQualifiedTypeName: String): TJSONValue;
begin
  if AQualifiedTypeName = 'System.Boolean' then
  begin
    if AValue.AsBoolean then
      Result := TJSONTrue.Create
    else
      Result := TJSONFalse.Create;
  end
  else
  begin
    Result := TJSONNumber.Create(AValue.AsOrdinal);
  end;
end;

class function omEngine.SerializeFloat(const AValue: TValue; const AQualifiedTypeName: String): TJSONValue;
begin
  if AQualifiedTypeName = 'System.TDate' then
  begin
    if AValue.AsExtended = 0 then
      Result := TJSONNull.Create
    else
      Result := TJSONString.Create(ISODateToString(AValue.AsExtended))
  end
  else if AQualifiedTypeName = 'System.TDateTime' then
  begin
    if AValue.AsExtended = 0 then
      Result := TJSONNull.Create
    else
      Result := TJSONString.Create(ISODateTimeToString(AValue.AsExtended))
  end
  else if AQualifiedTypeName = 'System.TTime' then
    Result := TJSONString.Create(ISOTimeToString(AValue.AsExtended))
  else
    Result := TJSONNumber.Create(AValue.AsExtended);
end;

class function omEngine.SerializeInteger(const AValue: TValue): TJSONValue;
begin
  Result := TJSONNumber.Create(AValue.AsInteger)
end;

class function omEngine.SerializeObject(const AObject: TObject; const ASerializationType: TSerializationType;
  AUseClassName: Boolean; const AIgnoredProperties: array of string): TJSONBox;
var
  PropField: System.Rtti.TRttiNamedObject;
  PropsFields: TArray<System.Rtti.TRttiNamedObject>;
  ThereAreIgnoredProperties: boolean;
  DoNotSerializeThis: boolean;
  KeyName: String;
  _type: TRttiType;
  I: Integer;
  JValue: TJSONValue;
  Value: TValue;
begin
  ThereAreIgnoredProperties := Length(AIgnoredProperties) > 0;
  Result := TJSONBox.Create;
  try
    _type := ctx.GetType(AObject.ClassInfo);
    // add the $dmvc.classname property to allows a strict deserialization
    if AUseClassName then
      Result.AddPair(DMVC_CLASSNAME, AObject.QualifiedClassName);
    // Get members list
    case ASerializationType of
      stProperties:
        PropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(ctx.GetType(AObject.ClassInfo).AsInstance.GetProperties));
      stFields:
        PropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(ctx.GetType(AObject.ClassInfo).AsInstance.GetFields));
    end;
    // Loop for all members
    for PropField in PropsFields do
    begin
      // Skip the RefCount
      if PropField.Name = 'FRefCount' then Continue;
      // f := LowerCase(_property.Name);
      KeyName := GetKeyName(PropField, _type);
      // Delete(f, 1, 1);
      if ThereAreIgnoredProperties then
      begin
        DoNotSerializeThis := false;
        for I := low(AIgnoredProperties) to high(AIgnoredProperties) do
          if SameText(KeyName, AIgnoredProperties[I]) then
          begin
            DoNotSerializeThis := True;
            Break;
          end;
        if DoNotSerializeThis then
          Continue;
      end;

      if HasAttribute<DoNotSerializeAttribute>(PropField) then
        Continue;

      // Serialize the currente member and add it to the JSONBox
      Value := TDuckPropField.GetValue(AObject, PropField);
      JValue := SerializePropField(Value, PropField, ASerializationType, AUseClassName);
      Result.AddPair(KeyName, JValue);
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

class function omEngine.SerializeObject(const AInterfacedObject: IInterface; const ASerializationType: TSerializationType;
  AUseClassName: Boolean; const AIgnoredProperties: array of string): TJSONBox;
var
  AObj: TObject;
begin
  AObj := AInterfacedObject as TObject;
  Result := SerializeObject(AObj, ASerializationType, AUseClassName, AIgnoredProperties);
end;

class function omEngine.SerializeObjectList(const AList: TObjectList<TObject>; const ASerializationType: TSerializationType;
  AUseClassName, AOwnsInstance: boolean; AForEach: TJSONObjectActionProc): TJSONBox;
var
  I: Integer;
  JV: TJSONObject;
  KeyName: String;
begin
  Result := TJSONBox.Create;
  if Assigned(AList) then
    for I := 0 to AList.Count - 1 do
    begin
      JV := Self.SerializeObject(AList[I], ASerializationType, AUseClassName, []);
      if Assigned(AForEach) then
        AForEach(JV);
      KeyName := 'Item ' + I.ToString;
      Result.AddPair(KeyName, JV);
    end;
  if AOwnsInstance then
    AList.Free;
end;

class function omEngine.SerializePropField(const AValue: TValue; const APropField: TRttiNamedObject; const ASerializationType: TSerializationType;
  const AUseClassName:Boolean): TJSONValue;
begin
  case TDuckPropField.RttiType(APropField).TypeKind of
    tkInteger, tkInt64:
      Result := Self.SerializeInteger(AValue);
    tkFloat:
      Result := Self.SerializeFloat(AValue, TDuckPropField.RttiType(APropField).QualifiedName);
    tkString, tkLString, tkWString, tkUString:
      Result := Self.SerializeString(AValue);
    tkEnumeration:
      Result := Self.SerializeEnumeration(AValue, TDuckPropField.RttiType(APropField).QualifiedName);
    tkRecord:
      Result := Self.SerializeRecord(AValue, TDuckPropField.RttiType(APropField).QualifiedName);
    tkClass:
      Result := Self.SerializeClass(AValue, APropField, ASerializationType, AUseClassName);
    tkInterface:
      Result := Self.SerializeInterface(AValue, APropField, ASerializationType, AUseClassName);
  end;
end;

class function omEngine.SerializeRecord(const AValue: TValue; const AQualifiedTypeName: String): TJSONValue;
var
  ts: TTimeStamp;
begin
  if AQualifiedTypeName = 'System.SysUtils.TTimeStamp' then
  begin
    ts := AValue.AsType<System.SysUtils.TTimeStamp>;
    Result := TJSONNumber.Create(TimeStampToMsecs(ts));
  end;
end;

class function omEngine.SerializeString(const AValue: TValue): TJSONValue;
begin
  Result := TJSONString.Create(AValue.AsString);
end;




end.
