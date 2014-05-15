unit IupOrm.ObjectsForge.Factory;

interface

uses
  IupOrm.ObjectsForge.Interfaces;

type

  TioObjectMakerFactory = class
  public
    class function GetObjectMaker(ClassFromField:Boolean): TioObjectMakerRef;
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

end.                                                                                                                                s
