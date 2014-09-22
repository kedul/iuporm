unit Model.CostTypeWithCostListInterface;

interface

uses Model.BaseInterfaces, Model.Cost, Model.BaseListClasses,
  System.Generics.Collections, IupOrm.LazyLoad.Generics.ObjectList;

type

  // ===========================================================================
  // TIPI DI COSTO CON LISTA DEI COSTI
  // ---------------------------------------------------------------------------
  // Interfaccia per i tipi di costo
  ICostTypeWithCostList = interface(ICostType)
    ['{7678E168-8DC4-464A-8D61-D685E10A2E9E}']
    // Methods
    function  GetCostList: TioObjectList<TCostGeneric>;
    procedure SetCostList(Value: TioObjectList<TCostGeneric>);
    function  GetCostTotalAmount: Currency;
    // Properties
    property CostList:TioObjectList<TCostGeneric> read GetCostList write SetCostList;
    property CostTotalAmount: Currency read GetCostTotalAmount;
  end;
  // ===========================================================================


implementation

end.
