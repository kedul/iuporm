unit ObjMapper;

interface

uses
  ObjMapperEngine, System.Rtti, System.JSON;

type

  om = class
  public
    // From
    class function FromJSONObject(AJSONObject: TJSONObject): TJSONBox;
    class function FromObject(AObj: TObject; AUseClassName: Boolean = False): TJSONBox; overload; static;
    class function FromObject(AInterfacedObj: IInterface; AUseClassName: Boolean = False): TJSONBox; overload; static;
    class function FromObjectFields(AObj: TObject; AUseClassName: Boolean = True): TJSONBox; overload; static;
    class function FromObjectFields(AInterfacedObj: IInterface; AUseClassName: Boolean = True): TJSONBox; overload; static;
    class function FromJSONObjectString(const AJSONObjectString: string): TJSONBox;
    // To
    class function ToJSONObject(const From: TJSONBox): TJSONObject;
    class function ToObject(const From: TJSONBox; AObj: TObject = nil; AUseClassName: Boolean = False): TObject; overload; static;
    class function ToObject(const From: TJSONBox; const AClassName: string; AUseClassName: Boolean = False): TObject; overload; static;
    class function ToObject<T:class,constructor>(const From: TJSONBox; AUseClassName: Boolean = False): T; overload; static;
    class function ToObject<T:IInterface>(const From: TJSONBox; AObj: TObject = nil; AUseClassName: Boolean = False): T; overload; static;
    class function ToObjectFields(const From: TJSONBox; AObj: TObject = nil; AUseClassName: Boolean = True): TObject; overload; static;
    class function ToObjectFields(const From: TJSONBox; const AClassName: string; AUseClassName: Boolean = True): TObject; overload; static;
    class function ToObjectFields<T:class,constructor>(const From: TJSONBox; AUseClassName: Boolean = True): T; overload; static;
    class function ToObjectFields<T:IInterface>(const From: TJSONBox; AObj: TObject = nil; AUseClassName: Boolean = True): T; overload; static;
    class function ToJSONArray(const From: TJSONBox): TJSONArray;
  end;

implementation

uses
  RTTIUtilsU, System.SysUtils, System.TypInfo;

{ om }

class function om.FromJSONObject(AJSONObject: TJSONObject): TJSONBox;
begin
  Result := AJSONObject;
end;

class function om.FromObject(AInterfacedObj: IInterface; AUseClassName: Boolean): TJSONBox;
begin
  Result := omEngine.SerializeObject(AInterfacedObj, stProperties, AUseClassName, []);
end;

class function om.FromObjectFields(AInterfacedObj: IInterface; AUseClassName: Boolean): TJSONBox;
begin
  Result := omEngine.SerializeObject(AInterfacedObj, stFields, AUseClassName, []);
end;

class function om.FromObjectFields(AObj: TObject; AUseClassName: Boolean): TJSONBox;
begin
  Result := omEngine.SerializeObject(Aobj, stFields, AUseClassName, []);
end;

class function om.FromJSONObjectString(const AJSONObjectString: string): TJSONBox;
begin
  Result := TJSONObject.ParseJSONValue(AJSONObjectString) as TJSONObject;
end;

class function om.FromObject(AObj: TObject; AUseClassName: Boolean): TJSONBox;
begin
  Result := omEngine.SerializeObject(Aobj, stProperties, AUseClassName, []);
end;

class function om.ToJSONArray(const From: TJSONBox): TJSONArray;
var
  LJArray: TJSONArray;
  LJPair: TJSONPair;
begin
  try
    LJArray := TJSONArray.Create;
    try
      for LJPair in From do
        LJArray.AddElement(LJPair.JSONValue);
      Result := LJArray;
    except
      LJArray.Free;
      raise;
    end;
  finally
    From.Free;
  end;
end;

class function om.ToJSONObject(const From: TJSONBox): TJSONObject;
begin
  Result := From;
end;

class function om.ToObject(const From: TJSONBox; AObj: TObject; AUseClassName: Boolean): TObject;
begin
  try
    Result := omEngine.DeserializeObject(From, AObj, stProperties, AUseClassName);
  finally
    From.Free;
  end;
end;

class function om.ToObject(const From: TJSONBox; const AClassName: string; AUseClassName: Boolean): TObject;
begin
  try
    Result := omEngine.DeserializeObjectByClass(From, AClassName, stProperties, AUseClassName);
  finally
    From.Free;
  end;
end;

class function om.ToObject<T>(const From: TJSONBox; AObj: TObject; AUseClassName: Boolean): T;
begin
  try
    AObj := omEngine.DeserializeObject(From, AObj, stProperties, AUseClassName);
    if not Supports(AObj, GetTypeData(TypeInfo(T))^.GUID, Result) then
      Exception.Create('Mapper: Interface not implemented by the object.');
  finally
    From.Free;
  end;
end;

class function om.ToObject<T>(const From: TJSONBox; AUseClassName: Boolean): T;
begin
  try
    Result := omEngine.DeserializeObjectByClass(From, T.ClassName, stProperties, AUseClassName) as T;
  finally
    From.Free;
  end;
end;

class function om.ToObjectFields(const From: TJSONBox; const AClassName: string; AUseClassName: Boolean): TObject;
begin
  try
    Result := omEngine.DeserializeObjectByClass(From, AClassName, stFields, AUseClassName);
  finally
    From.Free;
  end;
end;

class function om.ToObjectFields<T>(const From: TJSONBox; AObj: TObject; AUseClassName: Boolean): T;
begin
  try
    AObj := omEngine.DeserializeObject(From, AObj, stFields, AUseClassName);
    if not Supports(AObj, GetTypeData(TypeInfo(T))^.GUID, Result) then
      Exception.Create('Mapper: Interface not implemented by the object.');
  finally
    From.Free;
  end;
end;

class function om.ToObjectFields<T>(const From: TJSONBox; AUseClassName: Boolean): T;
begin
  try
    Result := omEngine.DeserializeObjectByClass(From, T.ClassName, stFields, AUseClassName) as T;
  finally
    From.Free;
  end;
end;

class function om.ToObjectFields(const From: TJSONBox; AObj: TObject; AUseClassName: Boolean): TObject;
begin
  try
    Result := omEngine.DeserializeObject(From, AObj, stFields, AUseClassName);
  finally
    From.Free;
  end;
end;

end.
