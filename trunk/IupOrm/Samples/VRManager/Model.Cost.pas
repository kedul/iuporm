unit Model.Cost;

interface

uses
  Model.BaseConst, Model.BaseInterfaces, Model.BaseClasses, Model.Travel, System.SysUtils, System.Generics.Collections,
  IupOrm.Attributes, Model.CostType;

type

  // Classe che rappresenta un costo generico
  [ioTable('COSTS')]
  [ioClassFromField]
  TCostGeneric = class(TBaseClass, ICostGeneric)
  strict private
    {$REGION 'ICostGeneric'}
    FTravelID: Integer;
    FCostDate: TDatetime;
    FCostType: ICostType;
    FCostAmount: Currency;
    FCostNote: String;
    {$ENDREGION}
  strict
  private
//    FXXXXX: Integer;
  strict protected
    {$REGION 'ICostGeneric'}
    function GetTravelID: Integer;
    procedure SetTravelID(Value: Integer);
    function GetCostDate: TDateTime;
    procedure SetCostDate(Value: TDateTime);
    function GetCostType: ICostType;
    procedure SetCostType(Value: ICostType);
    function GetCostAmount: Currency;
    procedure SetCostAmount(Value: Currency);
    function GetCostNote: String;
    procedure SetCostNote(Value: String);
    {$ENDREGION}
  public
    constructor Create(AID:Integer; ADescrizione:String; ATravelID:Integer; ACostType:ICostType;
                       ACostDate:TDatetime; ACostAmount:Currency; ACostNote:String); overload;
    {$REGION 'ICostGeneric'}
    property TravelID: Integer read GetTravelID write SetTravelID;
    property CostDate:TDateTime read GetCostDate write SetCostDate;
    [ioField('CostTypeID')]
    [ioBelongsTo(TCostType)]
    property CostType:ICostType read GetCostType write SetCostType;
    property CostAmount:Currency read GetCostAmount write SetCostAmount;
    property CostNote:String read GetCostNote write SetCostNote;
//    property XXXXX:Integer read FXXXXX write FXXXXX;
    {$ENDREGION}
  end;



  // Classe che rappresenta un costo di carburante
  [ioTable('COSTS')]
  [ioClassFromField]
  TCostFuel = class(TCostGeneric, ICostFuel)
  strict private
    {$REGION 'ICostFuel'}
    FLiters: Double;
    FKMTraveled: Double;
    {$ENDREGION}
  strict protected
    {$REGION 'ICostFuel'}
    function GetLiters: Double;
    procedure SetLiters(Value: Double);
    function GetKMTraveled: Double;
    procedure SetKMTraveled(Value: Double);
    function GetKMPerLiter: Double;
    function GetLiters100KM: Double;
    {$ENDREGION}
  public
    constructor Create(AID:Integer; ADescrizione:String; ATravelID:Integer; ACostType:ICostType;
                       ACostDate:TDatetime; ACostAmount:Currency; ACostNote:String;
                       ALiters:Double; AKMTraveled:Double); overload;
    {$REGION 'ICostFuel'}
    property Liters:Double read GetLiters write SetLiters;
    property KMTraveled:Double read GetKMTraveled write SetKMTraveled;
    [ioSkip]
    property KMPerLiter:Double read GetKMPerLiter;
    [ioSkip]
    property Liters100KM:Double read GetLiters100KM;
    {$ENDREGION}
  end;

  // Factory per la creazione del giusto tipo di costo in base alla situazione
  TCostFactory = class
  public
//    class function NewCost(AID:Integer; ADescrizione:String; ATravelID:Integer; ACostTypeID:Integer;
//                       ACostDate:TDatetime; ACostAmount:Currency; ACostNote:String;
//                       ALiters:Double; AKMTraveled:Double): TCostGeneric;
    class function NewCost(AID:Integer; ADescrizione:String; ATravelID:Integer; ACostType:ICostType;
                       ACostDate:TDatetime; ACostAmount:Currency; ACostNote:String;
                       ALiters:Double; AKMTraveled:Double): TCostGeneric;
  end;


implementation

uses
  System.Math, Service;

{ TCostGeneric }

constructor TCostGeneric.Create(AID: Integer; ADescrizione: String;
  ATravelID: Integer; ACostType: ICostType; ACostDate: TDatetime;
  ACostAmount: Currency; ACostNote: String);
begin
  inherited Create(AID, ADescrizione);
  TravelID := ATravelID;
  CostType := ACostType;
  CostDate := ACostDate;
  CostAmount := ACostAmount;
  CostNote := ACostNote;
end;

{$REGION 'ICostGeneric'}
function TCostGeneric.GetCostAmount: Currency;
begin
  Result := FCostAmount;
end;

function TCostGeneric.GetCostDate: TDateTime;
begin
  Result := FCostDate;
end;

function TCostGeneric.GetCostNote: String;
begin
  Result := FCostNote;
end;

function TCostGeneric.GetCostType: ICostType;
begin
  Result := FCostType;
end;

function TCostGeneric.GetTravelID: Integer;
begin
  Result := FTravelID;
end;

procedure TCostGeneric.SetCostAmount(Value: Currency);
begin
  if Value <> FCostAmount then
  begin
    FCostAmount := Value;
  end;
end;

procedure TCostGeneric.SetCostDate(Value: TDateTime);
begin
  if Value <> FCostDate then
  begin
    FCostDate := Value;
  end;
end;

procedure TCostGeneric.SetCostNote(Value: String);
begin
  if Value <> FCostNote then
  begin
    FCostNote := Value;
  end;
end;

procedure TCostGeneric.SetCostType(Value: ICostType);
begin
  if Value <> FCostType then
  begin
    FCostType := Value;
  end;
end;

procedure TCostGeneric.SetTravelID(Value: Integer);
begin
  if Value <> FTravelID then
  begin
    FTravelID := Value;
  end;
end;
{$ENDREGION}



// =============================================================================
// =============================================================================
// =============================================================================
// =============================================================================
// =============================================================================
// =============================================================================

{ TCostFuel }

constructor TCostFuel.Create(AID: Integer; ADescrizione: String;
  ATravelID: Integer; ACostType: ICostType; ACostDate: TDatetime;
  ACostAmount: Currency; ACostNote: String; ALiters, AKMTraveled: Double);
begin
   inherited Create(AID, ADescrizione, ATravelID, ACostType, ACostDate, ACostAmount, ACostNote);
   Liters := ALiters;
   KMTraveled := AKMTraveled;
end;

{$REGION 'ICostFuel'}
function TCostFuel.GetKMPerLiter: Double;
begin
  Result := 0;
  if FLiters = 0 then Exit;
  Result := SimpleRoundTo((FKMTraveled / FLiters), -1);
end;

function TCostFuel.GetKMTraveled: Double;
begin
  Result := FKMTraveled;
end;

function TCostFuel.GetLiters: Double;
begin
  Result := FLiters;
end;

function TCostFuel.GetLiters100KM: Double;
begin
  Result := 0;
  if FKMTraveled = 0 then Exit;
  Result := SimpleRoundTo((100 * FLiters / FKMTraveled), -1);
end;

procedure TCostFuel.SetKMTraveled(Value: Double);
begin
  if Value < 0 then raise Exception.Create('Invalid "KMTraveled" value!');
  if Value <> FKMTraveled then
  begin
    FKMTraveled := Value;
  end;
end;

procedure TCostFuel.SetLiters(Value: Double);
begin
  if Value < 0 then raise Exception.Create('Invalid "Liters" value!');
  if Value <> FLiters then
  begin
    FLiters := Value;
  end;
end;

{$ENDREGION}


{ TCostFactory }

//class function TCostFactory.NewCost(AID: Integer; ADescrizione: String;
//  ATravelID: Integer; ACostTypeID:Integer; ACostDate: TDatetime;
//  ACostAmount: Currency; ACostNote: String; ALiters,
//  AKMTraveled: Double): TCostGeneric;
class function TCostFactory.NewCost(AID: Integer; ADescrizione: String;
  ATravelID: Integer; ACostType:ICostType; ACostDate: TDatetime;
  ACostAmount: Currency; ACostNote: String; ALiters,
  AKMTraveled: Double): TCostGeneric;
begin
  Result := nil;
  // Se è un costo di carburante...
  if ACostType.ObjectType = COST_OBJECT_TYPE_FUEL then
  begin
    Result := TCostFuel.Create(
                                 AID
                                ,ADescrizione
                                ,ATravelID
                                ,ACostType
                                ,ACostDate
                                ,ACostAmount
                                ,ACostNote
                                ,ALiters
                                ,AKMTraveled
    );
  end
  // Altrimenti se è un costo generico...
  else
  begin
    Result := TCostGeneric.Create(
                                 AID
                                ,ADescrizione
                                ,ATravelID
                                ,ACostType
                                ,ACostDate
                                ,ACostAmount
                                ,ACostNote
    );
  end;
end;


end.
