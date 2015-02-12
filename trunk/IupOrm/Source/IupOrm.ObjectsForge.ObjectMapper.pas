unit IupOrm.ObjectsForge.ObjectMapper;

interface

uses
  System.JSON;

type

  // ClassRef to ObjectMapper
  TioObjectMapperRef = class of TioObjectMapperIntf;

  // Object mapper (thank's to Daniele Teti)
  TioObjectMapperIntf = class
  public
    class function ObjectToJSONObject(AObject: TObject): TJSONObject; overload;
    class function JSONObjectToObject<T: constructor, class>(AJSONObject: TJSONObject): T; overload; static;
    class function JSONObjectToObject(Clazz: TClass; AJSONObject: TJSONObject): TObject; overload; static;
    class function JSONObjectToObject(ClazzName: string; AJSONObject: TJSONObject): TObject; overload; static;
  end;

implementation

uses
  ObjectsMappers;

{ TioObjectMapper }

class function TioObjectMapperIntf.JSONObjectToObject(Clazz: TClass; AJSONObject: TJSONObject): TObject;
begin
  Result := ObjectsMappers.Mapper.JSONObjectToObject(Clazz, AJSONObject);
end;

class function TioObjectMapperIntf.JSONObjectToObject(ClazzName: string; AJSONObject: TJSONObject): TObject;
begin
  Result := ObjectsMappers.Mapper.JSONObjectToObject(ClazzName, AJSONObject);
end;

class function TioObjectMapperIntf.JSONObjectToObject<T>(AJSONObject: TJSONObject): T;
begin
  Result := ObjectsMappers.Mapper.JSONObjectToObject<T>(AJSONObject);
end;

class function TioObjectMapperIntf.ObjectToJSONObject(AObject: TObject): TJSONObject;
begin
  Result := ObjectsMappers.Mapper.ObjectToJSONObject(AObject);
end;

end.
