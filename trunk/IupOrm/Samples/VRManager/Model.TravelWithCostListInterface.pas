unit Model.TravelWithCostListInterface;

interface

uses
  Model.BaseInterfaces, System.Generics.Collections, Model.Cost;

type

  // ===========================================================================
  // TRAVEL CON LISTA DEI COSTI
  // ---------------------------------------------------------------------------
  ITravelWithCostList = interface(ITravel)
    ['{74F69457-7F30-4B7E-9FC1-D79837498A14}']
    // Methods
    function  GetCostList: TObjectList<TCostGeneric>;
    procedure SetCostList(Value: TObjectList<TCostGeneric>);
    // Properties
    property CostList:TObjectList<TCostGeneric> read GetCostList write SetCostList;
  end;
  // ===========================================================================

implementation

end.
