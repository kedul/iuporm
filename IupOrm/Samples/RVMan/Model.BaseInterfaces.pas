unit Model.BaseInterfaces;

interface

uses Rtti, IupOrm.CommonTypes;

type

  // Interfaccia base da usare per tutte le altre interfacce
  IBaseInterface = interface
    ['{DD98E0CD-F1EB-45CE-A4AB-2D0D6E73261A}']
    // Methods
    function GetID: Integer;
    procedure SetID(Value: Integer);
    function GetDescrizione: String;
    procedure SetDescrizione(Value: String);
    function GetListViewItem_Caption: String;
    function GetListViewItem_DetailText: String;
    function GetListViewItem_GroupHeader: String;
    // Properties
    property ID: Integer read GetID write SetID;
    property Descrizione: String read GetDescrizione write SetDescrizione;
    property ListViewItem_Caption: String read GetListViewItem_Caption;
    property ListViewItem_DetailText: String read GetListViewItem_DetailText;
    property ListViewItem_GroupHeader: String read GetListViewItem_GroupHeader;
  end;

  // ===========================================================================
  // TIPI DI COSTO
  // ---------------------------------------------------------------------------
  // Interfaccia per i tipi di costo
  ICostType = interface(IBaseInterface)
    ['{7678E168-8DC4-464A-8D61-D685E10A2E9E}']
    // Methods
    function GetObjectType: Byte;
    procedure SetObjectType(Value: Byte);
    // Properties
    property ObjectType: Byte read GetObjectType write SetObjectType;
  end;
  // ===========================================================================

  // ===========================================================================
  // VAGGI
  // ---------------------------------------------------------------------------
  // Interfaccia per i viaggi
  ITravel = interface(IBaseInterface)
    ['{CD85F85E-E65D-405A-81F3-FC60F301ADA8}']
    // Methods
    function GetStartDate: TDateTime;
    procedure SetStartDate(Value: TDateTime);
    function GetEndDate: TDateTime;
    procedure SetEndDate(Value: TDateTime);
    function GetStartKM: Integer;
    procedure SetStartKM(Value: Integer);
    function GetEndKM: Integer;
    procedure SetEndKM(Value: Integer);
    function GetTraveledKM: Integer;
    // Properties
    property StartDate:TDateTime read GetStartDate write SetStartDate;
    property EndDate:TDateTime read GetEndDate write SetEndDate;
    property StartKM:Integer read GetStartKM write SetStartKM;
    property EndKM:Integer read GetEndKM write SetEndKM;
    property TraveledKM:Integer read GetTraveledKM;
  end;
  // ===========================================================================

  // ===========================================================================
  // SPESE
  // ---------------------------------------------------------------------------
  // Interfaccia per spesa generica
  ICostGeneric = interface (IBaseInterface)
    ['{1E496639-6A6D-4884-A12B-17C0CF067997}']
    // Methods
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
    // Properties
    property TravelID: Integer read GetTravelID write SetTravelID;
    property CostDate:TDateTime read GetCostDate write SetCostDate;
    property CostType:ICostType read GetCostType write SetCostType;
    property CostAmount:Currency read GetCostAmount write SetCostAmount;
    property CostNote:String read GetCostNote write SetCostNote;
  end;

  // Interfaccia per spesa di carburante
  ICostFuel = interface (ICostGeneric)
    ['{09B06E3B-48A1-4022-9A7D-57D54CFCAD2A}']
    // Methods
    function GetLiters: Double;
    procedure SetLiters(Value: Double);
    function GetKMTraveled: Double;
    procedure SetKMTraveled(Value: Double);
    function GetKMPerLiter: Double;
    function GetLiters100KM: Double;
    // Properties
    property Liters:Double read GetLiters write SetLiters;
    property KMTraveled:Double read GetKMTraveled write SetKMTraveled;
    property KMPerLiter:Double read GetKMPerLiter;
    property Liters100KM:Double read GetLiters100KM;
  end;
  // ===========================================================================

implementation

end.
