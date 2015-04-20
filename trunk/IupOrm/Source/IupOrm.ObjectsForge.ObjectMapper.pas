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
    // Object
    class function SerializeEmbeddedObject(AObj:TObject): TJSONObject;
    class function DeserializeEmbeddedObject(AJObj:TJSONObject; AObj:TObject=nil): TObject;
    // List
    class function SerializeEmbeddedList(AList:TObject): TJSONValue;
    class function DeserializeEmbeddedList(AJValue:TJSONValue; AList:TObject=nil): TObject;
  end;

implementation

uses
  ObjMapperEngine;


{ TioObjectMapper }


{ TioObjectMapperIntf }

class function TioObjectMapperIntf.DeserializeEmbeddedList(AJValue: TJSONValue; AList: TObject): TObject;
begin
  Result := omEngine.DeserializeList(AList, AJValue, stFields, True);
end;

class function TioObjectMapperIntf.DeserializeEmbeddedObject(AJObj:TJSONObject; AObj:TObject): TObject;
begin
  Result := omEngine.DeserializeObject(AJObj, AObj, stFields, True);
end;

class function TioObjectMapperIntf.SerializeEmbeddedObject(AObj: TObject): TJSONObject;
begin
  Result := omEngine.SerializeObject(AObj, stFields, True, []);
end;

class function TioObjectMapperIntf.SerializeEmbeddedList(AList: TObject): TJSONValue;
begin
  Result := omEngine.SerializeList(AList, stFields, True);
end;



end.
