unit IupOrm.Containers.Factory;

interface

uses
  IupOrm.Containers.Interfaces;

type

  TioContainersFactory = class
  public
    class function GetInterfacedList<T>: IioList<T>;
    class function GetInterfacedObjectList<T: class>(AOwnsObjects:Boolean=True): IioList<T>;
  end;

implementation

uses
  IupOrm.Containers.List, IupOrm.Containers.ObjectList;

{ TioContainersFactory }

class function TioContainersFactory.GetInterfacedList<T>: IioList<T>;
begin
  Result := TioInterfacedList<T>.Create;
end;

class function TioContainersFactory.GetInterfacedObjectList<T>(AOwnsObjects: Boolean): IioList<T>;
begin
  Result := TioInterfacedObjectList<T>.Create(AOwnsObjects);
end;

end.
