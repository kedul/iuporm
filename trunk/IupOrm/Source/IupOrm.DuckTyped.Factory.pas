unit IupOrm.DuckTyped.Factory;

interface

uses
  IupOrm.DuckTyped.Interfaces;

type

  // Concrete factory for DuckTyped objects
  TioDuckTypedFactory = class
    class function DuckTypedList(AListObject: TObject): IioDuckTypedList;
  end;

implementation

uses
  IupOrm.DuckTyped.List;

{ TioDuckTypeFactory }


{ TioDuckTypeFactory }

class function TioDuckTypedFactory.DuckTypedList(
  AListObject: TObject): IioDuckTypedList;
begin
  Result := TioDuckTypedList.Create(AListObject);
end;

end.
