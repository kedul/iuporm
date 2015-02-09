unit IupOrm.ObjectsForge.Factory;

interface

uses
  IupOrm.ObjectsForge.Interfaces, IupOrm.ObjectsForge.ObjectMapper;

type

  TioObjectMakerFactory = class
  public
    class function GetObjectMaker(ClassFromField:Boolean): TioObjectMakerRef;
    class function GetObjectMapper: TioObjectMapperRef;
  end;

implementation

uses
  IupOrm.ObjectsForge.ObjectMakerClassFromField,
  IupOrm.ObjectsForge.ObjectMaker;

{ TioObjectMakerFactory }

class function TioObjectMakerFactory.GetObjectMaker(ClassFromField:Boolean): TioObjectMakerRef;
begin
  if ClassFromField
    then Result := TioObjectMakerClassFromField
    else Result := TioObjectMaker;
end;

class function TioObjectMakerFactory.GetObjectMapper: TioObjectMapperRef;
begin
  Result := TioObjectMapperIntf;
end;

end.                                                                                                                                s
