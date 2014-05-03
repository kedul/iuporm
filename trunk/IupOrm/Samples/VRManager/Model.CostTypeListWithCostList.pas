unit Model.CostTypeListWithCostList;

interface

uses
  Model.CostTypeWithCostList, Model.BaseListClasses;

type

  // Classe per una lista di CostType con all'interno una sottolista di Cost
  TCostTypeListWithCostList = class(TBaseObjectList<TCostTypeWithCostList>)
  end;

implementation

end.
