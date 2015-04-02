unit Model.TravelWithCostTypeList;

interface

uses
  Model.CostTypeWithCostList, Model.Travel,
  System.Generics.Collections, IupOrm.Attributes,
  IupOrm.LazyLoad.Generics.ObjectList;

type

  [ioTable('TRAVELS')]
  TTravelWithCostTypeList = class(TTravel)
  strict private
    FCostTypeList: TioObjectList<TCostTypeWithCostList>;
    FTotalAmount: Currency; protected
  strict protected
    // Methods
    function  GetCostTypeList: TioObjectList<TCostTypeWithCostList>;
    procedure SetCostTypeList(Value: TioObjectList<TCostTypeWithCostList>);
    function GetListViewItem_Detailtext: String; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RefreshTotals;
    // Properties
    [ioHasMany(TCostTypeWithCostList, 'TravelID', ioLazyLoad)]
    property CostTypeList:TioObjectList<TCostTypeWithCostList> read GetCostTypeList write SetCostTypeList;
    [ioLoadSql('select sum([TCostGeneric.CostAmount]) from [TCostGeneric] where [TCostGeneric.TravelID] = [TTravel.ID]')]
    property TotalAmount:Currency read FTotalAmount write FTotalAmount;
  end;

implementation

uses System.SysUtils;

{ TTravelWithCostTypeList }

function TTravelWithCostTypeList.GetCostTypeList: TioObjectList<TCostTypeWithCostList>;
begin
  Result := FCostTypeList;
end;

function TTravelWithCostTypeList.GetListViewItem_Detailtext: String;
begin
  Result := '';
  // Date
  if Self.StartDate > 0 then AddDetailText(Result, DateToStr(Self.StartDate), '');
  if Self.EndDate > 0 then AddDetailText(Result, DateToStr(Self.EndDate), '-');
  // Amount
  if Self.TotalAmount > 0 then AddDetailText(Result, CurrToStrF(Self.TotalAmount, ffCurrency, 2), '   ');
  // Km
  if Self.TraveledKM > 0
    then AddDetailText(Result, Self.TraveledKM.ToString + ' Km', '   ')
  else if Self.StartKM > 0
    then AddDetailText(Result, 'da Km ' + Self.StartKM.ToString, '   ');
end;

procedure TTravelWithCostTypeList.RefreshTotals;
var
  ACostType: TCostTypeWithCostList;
begin
  FTotalAmount := 0;
  for ACostType in CostTypeList do
    FTotalAmount := FTotalAmount + ACostType.CostTotalAmount;
end;

procedure TTravelWithCostTypeList.SetCostTypeList(
  Value: TioObjectList<TCostTypeWithCostList>);
begin
  if Assigned(FCostTypeList)
  and (Value <> FCostTypeList)
  then FreeAndNil(FCostTypeList);
  FCostTypeList := Value;
end;

constructor TTravelWithCostTypeList.Create;
begin
  inherited;
  FCostTypeList := TioObjectList<TCostTypeWithCostList>.Create(True);
end;

destructor TTravelWithCostTypeList.Destroy;
begin
  if Assigned(FCostTypeList) then FCostTypeList.Free;
  inherited;
end;

end.
