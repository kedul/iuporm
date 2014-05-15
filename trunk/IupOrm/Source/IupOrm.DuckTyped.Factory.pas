unit IupOrm.DuckTyped.Factory;

interface

uses
  IupOrm.DuckTyped.Interfaces;

type

  // Concrete factory for DuckTyped objects
  TioDuckTypedFactory = class
    class function DuckTypedStreamObject(AObj: TObject): IioDuckTypedStreamObject;
    class function DuckTypedList(AListObject: TObject): IioDuckTypedList;
  end;

implementation

uses
  IupOrm.DuckTyped.List, IupOrm.DuckTyped.StreamObject;

{ TioDuckTypeFactory }


{ TioDuckTypeFactory }

class function TioDuckTypedFactory.DuckTypedList(
  AListObject: TObject): IioDuckTypedList;
begin
  Result := TioDuckTypedList.Create(AListObject);
end;

class function TioDuckTypedFactory.DuckTypedStreamObject(
  AObj: TObject): IioDuckTypedStreamObject;
begin
  Result := TioDuckTypedStreamObject.Create(AObj);
end;

end.
