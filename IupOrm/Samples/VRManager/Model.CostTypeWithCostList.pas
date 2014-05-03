unit Model.CostTypeWithCostList;

interface

uses Model.CostTypeWithCostListInterface, Model.BaseListClasses, Model.CostType,
Model.Cost, IupOrm.Attributes, System.Generics.Collections, FMX.Dialogs;

type

  // Classe che rappresenta i tipi di spesa possibili comprensivo
  // però anche della lista dei costi e dell'importo totale
  [ioTable('COSTTYPES')]
  TCostTypeWithCostList = class(TCostType, ICostTypeWithCostList)
  strict private
    FCostList: TObjectList<TCostGeneric>;
  strict protected
    // Methods
    function GetCostList: TObjectList<TCostGeneric>;
    procedure SetCostList(Value: TObjectList<TCostGeneric>);
    function GetCostTotalAmount: Currency;
  public
    destructor Destroy; override;
    [ioHasMany(TCostGeneric, 'CostType')]
    property CostList:TObjectList<TCostGeneric> read GetCostList write SetCostList;
    [ioSkip]
    property CostTotalAmount: Currency read GetCostTotalAmount;
  end;

implementation

{ TCostTypeWithCostList }

destructor TCostTypeWithCostList.Destroy;
begin
  FCostList.Free;
  inherited;
end;

function TCostTypeWithCostList.GetCostList: TObjectList<TCostGeneric>;
begin
  Result := FCostList;
end;

function TCostTypeWithCostList.GetCostTotalAmount: Currency;
var
  Cost: TCostGeneric;
begin
  Result := 0;
  for Cost in FCostList do
    Result := Result + Cost.CostAmount;
end;

procedure TCostTypeWithCostList.SetCostList(Value: TObjectList<TCostGeneric>);
begin
  if Value = FCostList then
    Exit;
  FCostList := Value;
end;

end.
