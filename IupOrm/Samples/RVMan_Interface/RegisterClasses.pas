unit RegisterClasses;

interface

type

  TClassRegister = class
  public
    class procedure RegisterClasses;
  end;

implementation

uses
  IupOrm, Model.CostType.Interfaces, Model.CostType, Model.CostTypeWithCostList, Model.CostTypeWithCostList.Interfaces,
  Model.Cost, Model.Cost.Interfaces, Model.Travel, Model.Travel.Interfaces, Model.TravelWithCostTypeList,
  IupOrm.Containers.List, IupOrm.Containers.Interfaces, IupOrm.LazyLoad.Generics.List;

{ TClassRegister }

class procedure TClassRegister.RegisterClasses;
begin
  TIupOrm.DependencyInjection.RegisterClass<TCostType>.Implements<ICostType>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TCostTypeWithCostList>.Implements<ICostTypeWithCostList>.Execute;

  TIupOrm.DependencyInjection.RegisterClass<TCostGeneric>.Implements<ICostGeneric>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TCostFuel>.Implements<ICostFuel>.Execute;

  TIupOrm.DependencyInjection.RegisterClass<TTravel>.Implements<ITravel>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TTravelWithCostTypeList>.Implements<ITravelWithCostTypeList>.Execute;

  TIupOrm.DependencyInjection.RegisterClass<TioList<ICostTypeWithCostList>>.Implements<IioList<ICostTypeWithCostList>>.Execute;
  TIupOrm.DependencyInjection.RegisterClass<TioInterfacedList<ICostGeneric>>.Implements<IioList<ICostGeneric>>.Execute;
end;


initialization

  TClassRegister.RegisterClasses;

end.
