unit IupOrm.LazyLoad.Factory;

interface

uses
  IupOrm.LazyLoad.Interfaces;

type

  TioLazyLoadFactory = class
  public
    class function LazyLoader<T:class,constructor>(AOwnsObjects:Boolean=True): IioLazyLoader<T>;
  end;

implementation

uses
  IupOrm.LazyLoad.LazyLoader;

{ TioLazyLoadFactory }

class function TioLazyLoadFactory.LazyLoader<T>(
  AOwnsObjects: Boolean): IioLazyLoader<T>;
begin
  Result := TioLazyLoader<T>.Create(AOwnsObjects);
end;

end.
