unit Service;

interface

uses
  Service.Interfaces, Model.BaseClasses;

type

  TServiceFactory<T:TBaseClass, constructor> = class
  strict protected
    // Fornisce la class reference alla factory corretta
    class function GetConcreteServiceFactory: IConcreteServiceFactory<T>;
  public
    class function Connection: IServiceConnectionFactory;
    class function CostType: IServiceGeneric<T>;
    class function CostTypeWithCostList: IServiceGenericWithCostList<T>;
    class function Travel: IServiceGeneric<T>;
  end;

implementation

uses
  Service.SQLite;

{ TServiceFactory<T> }


{ TServiceFactory }

class function TServiceFactory<T>.Connection: IServiceConnectionFactory;
begin
  Result := GetConcreteServiceFactory.Connection;
end;

class function TServiceFactory<T>.CostType: IServiceGeneric<T>;
begin
  Result := GetConcreteServiceFactory.CostType;
end;

class function TServiceFactory<T>.CostTypeWithCostList: IServiceGenericWithCostList<T>;
begin
//  Result := GetConcreteServiceFactory.CostTypeWithCostList;
end;

class function TServiceFactory<T>.GetConcreteServiceFactory: IConcreteServiceFactory<T>;
begin
  Result := TServiceSQLiteFactory<T>.Create;
end;

class function TServiceFactory<T>.Travel: IServiceGeneric<T>;
begin
//  Result := GetConcreteServiceFactory.Travel;
end;

end.
