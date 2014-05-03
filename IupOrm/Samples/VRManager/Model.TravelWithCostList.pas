unit Model.TravelWithCostList;

interface

uses
  Model.Travel, Model.TravelWithCostListInterface, System.Generics.Collections,
  Model.Cost, IupOrm.Attributes;

type

  [ioTable('TRAVELS')]
  TTravelWithCostList = class(TTravel, ITravelWithCostList)
  strict private
    FCostList: TObjectList<TCostGeneric>;
  strict protected
    // Methods
    function  GetCostList: TObjectList<TCostGeneric>;
    procedure SetCostList(Value: TObjectList<TCostGeneric>);
  public
    constructor Create;
    destructor Destroy; override;
    // Properties
    [ioHasMany(TCostGeneric, 'TravelID')]
    property CostList:TObjectList<TCostGeneric> read GetCostList write SetCostList;
  end;

implementation

uses
  System.SysUtils, FMX.Dialogs;

{ TTravelWithCostList }

constructor TTravelWithCostList.Create;
begin
  FCostList := TObjectList<TCostGeneric>.Create;
end;

destructor TTravelWithCostList.Destroy;
begin
  FreeAndNil(FCostList);
  inherited;
end;

function TTravelWithCostList.GetCostList: TObjectList<TCostGeneric>;
begin
  Result := FCostList;
end;

procedure TTravelWithCostList.SetCostList(Value: TObjectList<TCostGeneric>);
begin
  FCostList := Value;
end;

end.
