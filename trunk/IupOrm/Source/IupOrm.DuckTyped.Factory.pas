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
  IupOrm.DuckTyped.List, IupOrm;

{ TioDuckTypeFactory }


{ TioDuckTypeFactory }

class function TioDuckTypedFactory.DuckTypedList(
  AListObject: TObject): IioDuckTypedList;
begin
  Result := TioDuckTypedList.Create(AListObject);
end;

class function TioDuckTypedFactory.DuckTypedStreamObject(
  AObj: TObject): IioDuckTypedStreamObject;
var
  AAlias: String;
begin
  // Init
  AAlias := AObj.ClassName;
  // If a custom implementation of the DuckTypedStreamObject (for the class of AObj; ClassName as Alias) is present in the
  //  dependency injection cantainer then use it, else retrieve the standard implementation (no Alias)
  if not TIupOrm.DependencyInjection.Locate<IioDuckTypedStreamObject>.Alias(AAlias).Exist then
    AAlias := '';
  // Return the result
  Result := TIupOrm.DependencyInjection.Locate<IioDuckTypedStreamObject>
                                       .Alias(AAlias)
                                       .ConstructorParams([AObj])
                                       .Get;
end;

end.
