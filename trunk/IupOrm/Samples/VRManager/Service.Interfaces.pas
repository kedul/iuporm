unit Service.Interfaces;

interface

uses
  System.Classes,
  Data.SqlExpr,

  Model.BaseInterfaces,
  Model.CostType,
  Model.Travel,
  Model.Cost,
  Model.BaseClasses,
  Model.BaseListClasses;

type

  IServiceGeneric<T:TBaseClass, constructor> = interface
    ['{5E691198-4B77-4B5A-8494-9D04ABA67E13}']
    procedure Add(AObj: T);
    function  GetByID(AID:Integer): T;
    procedure Update(AObj: T);
    procedure DeleteByID(AID:Integer);
    function GetAll: TBaseObjectList<T>;
  end;

  IServiceGenericWithCostList<T:TBaseClass, constructor> = interface(IServiceGeneric<T>)
    ['{150A755F-F74B-4657-8488-AB35EBA9364D}']
    function  GetByID(AID:Integer; ATravelID:Integer): T;
    function  GetAll(ATravelID:Integer): TBaseObjectList<T>;
  end;

  IServiceGenericCost<T:TBaseClass, constructor> = interface(IServiceGeneric<T>)
    ['{5E691198-4B77-4B5A-8494-9D04ABA67E13}']
    function GetAll(ATravelID, ACostTypeID: Integer): TBaseObjectList<T>;
  end;

  // Interfaccia per i servizi di creazione di una connessione a database
  IServiceConnectionFactory = interface
    ['{B19E20DF-17DB-4C41-B116-4C3BC49EFD88}']
    function GetNewConnection(AOwner:TComponent): TSQLConnection;
  end;

  IConcreteServiceFactory<T:TBaseClass, constructor> = interface
    ['{C46FC5B4-535B-4C13-99C2-3EE38CC42F87}']
    function Connection: IServiceConnectionFactory;
    function Cost: IServiceGenericCost<T>;
    function CostType: IServiceGeneric<T>;
//    function CostTypeWithCostList: IServiceCostTypeWithCostList;
//    function Travel: IServiceTravel;
  end;














  // Interfaccia di base per tutti i serivzi di storage di ogni classe
  IService = interface
    ['{4B99AE00-C5C4-4888-BC62-850BFB4358FC}']
    procedure Add(AObj: IBaseInterface);
    function  GetByID(AID:Integer): IBaseInterface;
    procedure Update(AObj: IBaseInterface);
    procedure DeleteByID(AID:Integer);
    function GetAll: TBaseList;
  end;

  // Interfaccia service CostTypes
  IServiceCostType = interface(IService)
    ['{00C2120C-185E-4E13-8867-EAD270AC68C0}']
    procedure Add(AObj: ICostType);
    function  GetByID(AID:Integer): ICostType;
    procedure Update(AObj: ICostType);
    procedure DeleteByID(AID:Integer);
    function GetAll: TCostTypeList;
  end;
  // Interfaccia service CostTypeWithCOstList
  IServiceCostTypeWithCostList = interface(IServiceCostType)
    ['{9FB982F1-935B-46BD-A3AF-175864EDA029}']
    function  GetByID(AID:Integer; ATravelID:Integer): ICostType;
    function  GetAll(ATravelID:Integer): TCostTypeList;
  end;

  // Interfaccia service Travels
  IServiceTravel = interface(IService)
    ['{54D52EAB-A506-486E-81A9-2EC90C894467}']
    procedure Add(AObj: TTravel);
    function  GetByID(AID:Integer): TTravel;
    procedure Update(AObj: TTravel);
    procedure DeleteByID(AID:Integer);
    function GetAll: TTravelList;
//    function GetAll: TBaseList;
  end;

  // Interfaccia service Costs
  IServiceCost = interface(IService)
    ['{37C64CFB-29D2-42F9-A272-8BF422F6B288}']
    procedure Add(AObj: TCostGeneric);
    function  GetByID(AID:Integer): TCostGeneric;
    procedure Update(AObj: TCostGeneric);
    procedure DeleteByID(AID:Integer);
    function GetAll(ATravelID, ACostTypeID: Integer): TCostList;
  end;


implementation

end.
