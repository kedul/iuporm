unit RegisterClassesUnit;

interface

type

  TDIClassRegister = class
  public
    class procedure RegisterClasses;
  end;

implementation

uses
  IupOrm, Model, Interfaces, IupOrm.LazyLoad.Generics.List, IupOrm.Containers.Interfaces, IupOrm.Containers.List,
  AnotherModel;

{ TDIClassRegister }

class procedure TDIClassRegister.RegisterClasses;
begin
  TIupOrm.DependencyInjection.RegisterClass<TPerson>.Implements<IPerson>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TEmployee>.Implements<IEmployee>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TCustomer>.Implements<ICustomer>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TVipCustomer>.Implements<IVipCustomer>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TAnotherPerson>.Implements<IPerson>.Alias('AnotherPerson').Execute;

  TIupOrm.DependencyInjection.RegisterClass<TPhoneNumber>.Implements<IPhoneNumber>.Execute;

  TIupOrm.DependencyInjection.RegisterClass<TCustomer>.Implements<IPerson>.Alias('Customer').Execute;

  TIupOrm.DependencyInjection.RegisterClass<TioList<IPhoneNumber>>.Implements<IioList<IPhoneNumber>>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TioInterfacedList<IPhoneNumber>>.Implements<IioList<IPhoneNumber>>.Alias('Another').Execute;

end;

initialization

  TDIClassRegister.RegisterClasses;

end.
