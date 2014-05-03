unit Service.SQLite;

interface

uses
  Model.BaseInterfaces, Service.Interfaces, Model.CostType, Model.CostTypeWithCostList, Model.Travel, Model.Cost,
  Data.SqlExpr, Data.DB,
  System.Generics.Collections, System.Classes, System.IOUtils,
  Model.BaseClasses, Model.BaseListClasses;

type

  // Factory per SQLite
  TServiceSQLiteFactory<T:TBaseClass, constructor> = class(TInterfacedObject, IConcreteServiceFactory<T>)
  public
    function Connection: IServiceConnectionFactory;
    function CostType: IServiceGeneric<T>;
    function CostTypeWithCostList: IServiceGenericWithCostList<T>;
    function Travel: IServiceGeneric<T>;
    function Cost: IServiceGenericCost<T>;
  end;

  // Classe statica per la creazione di una connessione al database
  TServiceSQLiteConnectionFactory = class(TInterfacedObject, IServiceConnectionFactory)
  strict protected
    procedure CheckForTablesCreation(AConn:TSQLConnection);
    procedure CheckForTableRowsInitialization(AConn:TSQLConnection);
    procedure DBCheckForInit(DBConn: TSQLConnection);
  public
    function GetNewConnection(AOwner:TComponent): TSQLConnection;
  end;

  // Classe astratta di base per ogni servizio di storage su SQLite
  TServiceSQLite = class abstract(TInterfacedObject)
  strict private
    FSQLConnection: TSQLConnection;
  strict protected
    function Connection: TSQLConnection;
    procedure FreeConnection;
    function CreateQuery(AConnection: TSQLConnection; ASQL: String): TSQLQuery;
    function GetLastInsertRowID: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  // Classe service per i tipi di costo TCostType
  TServiceSQLiteCostType<T:TBaseClass, constructor> = class(TServiceSQLite, IServiceGeneric<T>)
  strict private
    const
      SQL_INSERT = 'INSERT INTO COSTTYPES (ID, DESCRIZIONE, OBJECTTYPE) VALUES (:ID, :DESCRIZIONE, :OBJECTTYPE)';
      SQL_UPDATE = 'UPDATE COSTTYPES SET DESCRIZIONE=:DESCRIZIONE, OBJECTTYPE=:OBJECTTYPE WHERE ID=:ID';
      SQL_DELETE = 'DELETE FROM COSTTYPES WHERE ID = :ID';
      SQL_SELECT = 'SELECT ID, DESCRIZIONE, OBJECTTYPE FROM COSTTYPES';
      SQL_SELECT_BY_ID = SQL_SELECT + ' WHERE ID = :ID';
      SQL_SELECT_ALL = SQL_SELECT;
  public
    procedure Add(AObj:T);
    function  GetByID(AID: Integer): T; virtual;
    procedure Update(AObj:T);
    procedure DeleteByID(AID: Integer);
    function  GetAll: TBaseObjectList<T>; virtual;
  end;
  // Classe service per i tipi di costo TCostTypeWithCostList
  TServiceSQLiteCostTypeWithCostList<T:TBaseClass, constructor> = class(TServiceSQLiteCostType<T>, IServiceGenericWithCostList<T>)
  public
    function  GetByID(AID:Integer; ATravelID:Integer): T; overload;
    function  GetAll(ATravelID:Integer): TBaseObjectList<T>; overload;
  end;

  // Classe service per  i viaggi TTravel
  TServiceSQLiteTravel<T:TBaseClass, constructor> = class(TServiceSQLite, IServiceGeneric<T>)
  strict private
  const
    SQL_INSERT = 'INSERT INTO TRAVELS (ID, DESCRIZIONE, STARTDATE, ENDDATE, STARTKM, ENDKM) VALUES (:ID, :DESCRIZIONE, :STARTDATE, :ENDDATE, :STARTKM, :ENDKM)';
    SQL_UPDATE = 'UPDATE TRAVELS SET DESCRIZIONE=:DESCRIZIONE, STARTDATE=:STARTDATE, ENDDATE=:ENDDATE, STARTKM=:STARTKM, ENDKM=:ENDKM WHERE ID=:ID';
    SQL_DELETE = 'DELETE FROM TRAVELS WHERE ID = :ID';
    SQL_SELECT = 'SELECT ID, DESCRIZIONE, STARTDATE, ENDDATE, STARTKM, ENDKM FROM TRAVELS';
    SQL_SELECT_BY_ID = SQL_SELECT + ' WHERE ID = :ID';
    SQL_SELECT_ALL = SQL_SELECT;
  public
    procedure Add(AObj:T);
    function  GetByID(AID: Integer): T;
    procedure Update(AObj:T);
    procedure DeleteByID(AID: Integer);
    function GetAll: TBaseObjectList<T>;
//    function GetAll: TBaseList; override;
  end;

  // Classe service per i costi TCostGeneric e TCostFuel
  TServiceSQLiteCost<T:TBaseClass, constructor> = class(TServiceSQLite, IServiceGenericCost<T>)
  strict private
  const
    SQL_INSERT = 'INSERT INTO COSTS (ID, DESCRIZIONE, TRAVELID, COSTTYPEID, COSTDATE, COSTAMOUNT, COSTNOTE, LITERS, KMTRAVELED) VALUES (:ID, :DESCRIZIONE, :TRAVELID, :COSTTYPEID, :COSTDATE, :COSTAMOUNT, :COSTNOTE, :LITERS, :KMTRAVELED)';
    SQL_UPDATE = 'UPDATE COSTS SET DESCRIZIONE=:DESCRIZIONE, TRAVELID=:TRAVELID, COSTTYPEID=:COSTTYPEID, COSTDATE=:COSTDATE, COSTAMOUNT=:COSTAMOUNT, COSTNOTE=:COSTNOTE, LITERS=:LITERS, KMTRAVELED=:KMTRAVELED WHERE ID=:ID';
    SQL_DELETE = 'DELETE FROM COSTS WHERE ID = :ID';
    SQL_SELECT = 'SELECT ID, DESCRIZIONE, TRAVELID, COSTTYPEID, COSTDATE, COSTAMOUNT, COSTNOTE, LITERS, KMTRAVELED FROM COSTS';
    SQL_SELECT_BY_ID = SQL_SELECT + ' WHERE ID = :ID';
    SQL_SELECT_ALL = SQL_SELECT + ' WHERE TRAVELID = :TRAVELID';
  public
    procedure Add(AObj:T);
    function  GetByID(AID: Integer): T;
    procedure Update(AObj:T);
    procedure DeleteByID(AID: Integer);
    function  GetAll: TBaseObjectList<T>; overload;
    function  GetAll(ATravelID, ACostTypeID: Integer): TBaseObjectList<T>; overload;
  end;

implementation

uses Model.BaseConst, System.SysUtils, FMX.Dialogs, IupOrm;

{ TServiceSQLiteBase<T> }

function TServiceSQLite.Connection: TSQLConnection;
begin
  Result := FSQLConnection;
end;

constructor TServiceSQLite.Create;
begin
  inherited Create;
  FSQLConnection := TServiceSQLiteFactory<TBaseClass>.Create.Connection.GetNewConnection(nil);
end;

function TServiceSQLite.CreateQuery(AConnection: TSQLConnection;
  ASQL: String): TSQLQuery;
begin
  Result := TSQLQuery.Create(nil);
  Result.SQLConnection := AConnection;
  Result.CommandText := ASQL;
end;

destructor TServiceSQLite.Destroy;
begin
  if Assigned(FSQLConnection) then FSQLConnection.Free;
  inherited;
end;

procedure TServiceSQLite.FreeConnection;
begin
  if Assigned(FSQLConnection) then FSQLConnection.Free;
end;

function TServiceSQLite.GetLastInsertRowID: Integer;
var
  Query: TSQLQuery;
begin
  inherited;
  Result := 0;
  Query := Self.CreateQuery(Connection, 'SELECT last_insert_rowid()');
  try
    Query.Open;
    if Query.IsEmpty then Exit;
    Result := Query.Fields[0].AsInteger;
    Query.Close;
  finally
    Query.Free;
  end;
end;

{ TServiceSQLiteTravel }

procedure TServiceSQLiteTravel<T>.Add(AObj:T);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_INSERT);
  AObj.RttiSession_Begin;
  try
    Query.ParamByName('DESCRIZIONE').AsString := AObj.Descrizione;
    Query.ParamByName('STARTDATE').AsFloat := AObj.RttiSession_GetPropertyValue('StartDate').AsExtended;
    Query.ParamByName('ENDDATE').AsFloat := AObj.RttiSession_GetPropertyValue('EndDate').AsExtended;
    Query.ParamByName('STARTKM').AsInteger := AObj.RttiSession_GetPropertyValue('StartKM').AsInteger;
    Query.ParamByName('ENDKM').AsInteger := AObj.RttiSession_GetPropertyValue('EndKM').AsInteger;
    Query.ExecSQL;
    AObj.ID := Self.GetLastInsertRowID;
  finally
    AObj.RttiSession_End;
    if Assigned(Query) then Query.Free;
  end;
end;

procedure TServiceSQLiteTravel<T>.DeleteByID(AID: Integer);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_DELETE);
  try
    Query.ParamByName('ID').AsInteger := AID;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;


function TServiceSQLiteTravel<T>.GetAll: TBaseObjectList<T>;
var
  Query: TSQLQuery;
  NewObj: T;
begin
  Query := Self.CreateQuery(Connection, SQL_SELECT_ALL);
  try
    Query.Open;
    Result := TBaseObjectList<T>.Create(True);
    while not Query.Eof do
    begin
      NewObj := T.Create;
      NewObj.RttiSession_Begin;
      try
        NewObj.ID := Query.FieldByName('ID').AsInteger;
        NewObj.Descrizione := Query.FieldByName('DESCRIZIONE').AsString;
        NewObj.RttiSession_SetPropertyValue('StartDate', Query.FieldByName('STARTDATE').AsDateTime);
        NewObj.RttiSession_SetPropertyValue('EndDate', Query.FieldByName('ENDDATE').AsDateTime);
        NewObj.RttiSession_SetPropertyValue('StartKM', Query.FieldByName('STARTKM').AsInteger);
        NewObj.RttiSession_SetPropertyValue('EndKM', Query.FieldByName('ENDKM').AsInteger);
        Result.Add(NewObj);
        NewObj.RttiSession_End;
      except
        NewObj.RttiSession_End;
        FreeAndNil(NewObj);
        raise;
      end;
      Query.Next;
    end;
    Query.Close;
  finally
    if assigned(Query) then Query.Free;
  end;
end;


function TServiceSQLiteTravel<T>.GetByID(AID: Integer): T;
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_SELECT_BY_ID);
  try
    Query.ParamByName('ID').AsInteger := AID;
    Query.Open;
    if Query.IsEmpty then Exit;
    Result := T.Create;
    Result.RttiSession_Begin;
    try
      Result.ID := Query.FieldByName('ID').AsInteger;
      Result.Descrizione := Query.FieldByName('DESCRIZIONE').AsString;
      Result.RttiSession_SetPropertyValue('StartDate', Query.FieldByName('STARTDATE').AsDateTime);
      Result.RttiSession_SetPropertyValue('EndDate', Query.FieldByName('ENDDATE').AsDateTime);
      Result.RttiSession_SetPropertyValue('StartKM', Query.FieldByName('STARTKM').AsInteger);
      Result.RttiSession_SetPropertyValue('EndKM', Query.FieldByName('ENDKM').AsInteger);
      Result.RttiSession_End;
    except
      Result.RttiSession_End;
      FreeAndNil(Result);
      raise;
    end;
    Query.Close;
  finally
    Query.Free;
  end;
end;

procedure TServiceSQLiteTravel<T>.Update(AObj: T);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_UPDATE);
  AObj.RttiSession_Begin;
  try
    Query.ParamByName('ID').AsInteger := AObj.ID;
    Query.ParamByName('DESCRIZIONE').AsString := AObj.Descrizione;
    Query.ParamByName('STARTDATE').AsDate := AObj.RttiSession_GetPropertyValue('StartDate').AsExtended;
    Query.ParamByName('ENDDATE').AsDate := AObj.RttiSession_GetPropertyValue('EndDate').AsExtended;
    Query.ParamByName('STARTKM').AsInteger := AObj.RttiSession_GetPropertyValue('StartKM').AsInteger;
    Query.ParamByName('ENDKM').AsInteger := AObj.RttiSession_GetPropertyValue('EndKM').AsInteger;
    Query.ExecSQL;
  finally
    AObj.RttiSession_End;
    if Assigned(Query) then Query.Free;
  end;
end;

{ TServiceSQLiteCost }

procedure TServiceSQLiteCost<T>.Add(AObj: T);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_INSERT);
  AObj.RttiSession_Begin;
  try
    Query.ParamByName('DESCRIZIONE').AsString := AObj.Descrizione;
    Query.ParamByName('TRAVELID').AsInteger := AObj.RttiSession_GetPropertyValue('TravelID').AsInteger;
    Query.ParamByName('COSTTYPEID').AsInteger := (AObj.RttiSession_GetPropertyValue('CostType').AsObject as TCostType).ID;
    Query.ParamByName('COSTDATE').AsFloat := AObj.RttiSession_GetPropertyValue('CostDate').AsExtended;
    Query.ParamByName('COSTAMOUNT').AsFloat := AObj.RttiSession_GetPropertyValue('CostAmount').AsCurrency;
    Query.ParamByName('COSTNOTE').AsString := AObj.RttiSession_GetPropertyValue('CostNote').AsString;
    Query.ParamByName('LITERS').AsFloat := AObj.RttiSession_GetPropertyValue('Liters').AsExtended;
    Query.ParamByName('KMTRAVELED').AsFloat := AObj.RttiSession_GetPropertyValue('KMTraveled').AsExtended;
    Query.ExecSQL;
    AObj.ID := Self.GetLastInsertRowID;
  finally
    AObj.RttiSession_End;
    if Assigned(Query) then Query.Free;
  end;
end;

procedure TServiceSQLiteCost<T>.DeleteByID(AID: Integer);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_DELETE);
  try
    Query.ParamByName('ID').AsInteger := AID;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TServiceSQLiteCost<T>.GetAll(ATravelID, ACostTypeID: Integer): TBaseObjectList<T>;
var
  Query: TSQLQuery;
begin
  Query := Self.CreateQuery(Connection, SQL_SELECT_ALL);
  try
    Query.Open;
    Result := TBaseObjectList<T>.Create(True);
    while not Query.Eof do
    begin
      Result.Add(TCostFactory.NewCost(
                                     Query.FieldByName('ID').AsInteger
                                    ,Query.FieldByName('DESCRIZIONE').AsString
                                    ,Query.FieldByName('TRAVELID').AsInteger
                                    ,TServiceSQLiteCostType<TCostType>.Create.GetByID( Query.FieldByName('COSTTYPEID').AsInteger )
                                    ,Query.FieldByName('COSTDATE').AsDateTime
                                    ,Query.FieldByName('COSTAMOUNT').AsCurrency
                                    ,Query.FieldByName('COSTNOTE').AsString
                                    ,Query.FieldByName('LITERS').AsFloat
                                    ,Query.FieldByName('KMTRAVELED').AsFloat
      ));
      Query.Next;
    end;
    Query.Close;
  finally
    if assigned(Query) then Query.Free;
  end;
end;

function TServiceSQLiteCost<T>.GetAll: TBaseObjectList<T>;
begin

end;

function TServiceSQLiteCost<T>.GetByID(AID: Integer): T;
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_SELECT_BY_ID);
  try
    Query.ParamByName('ID').AsInteger := AID;
    Query.Open;
    if Query.IsEmpty then Exit;
    // Crea l'oggetto
    Result := TCostFactory.NewCost(
                                   Query.FieldByName('ID').AsInteger
                                  ,Query.FieldByName('DESCRIZIONE').AsString
                                  ,Query.FieldByName('TRAVELID').AsInteger
                                  ,TServiceSQLiteCostType<TCostType>.Create.GetByID( Query.FieldByName('COSTTYPEID').AsInteger )
                                  ,Query.FieldByName('COSTDATE').AsDateTime
                                  ,Query.FieldByName('COSTAMOUNT').AsCurrency
                                  ,Query.FieldByName('COSTNOTE').AsString
                                  ,Query.FieldByName('LITERS').AsFloat
                                  ,Query.FieldByName('KMTRAVELED').AsFloat
    );
    Query.Close;
  finally
    Query.Free;
  end;
end;

procedure TServiceSQLiteCost<T>.Update(AObj: T);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_UPDATE);
  AObj.RttiSession_Begin;
  try
    Query.ParamByName('ID').AsInteger := AObj.ID;
    Query.ParamByName('DESCRIZIONE').AsString := AObj.Descrizione;
    Query.ParamByName('TRAVELID').AsInteger := AObj.RttiSession_GetPropertyValue('TravelID').AsInteger;
    Query.ParamByName('COSTTYPEID').AsInteger := (AObj.RttiSession_GetPropertyValue('CostType').AsObject as TCostType).ID;
    Query.ParamByName('COSTDATE').AsFloat := AObj.RttiSession_GetPropertyValue('CostDate').AsExtended;
    Query.ParamByName('COSTAMOUNT').AsFloat := AObj.RttiSession_GetPropertyValue('CostAmount').AsExtended;
    Query.ParamByName('COSTNOTE').AsString := AObj.RttiSession_GetPropertyValue('CostNote').AsString;
    Query.ParamByName('LITERS').AsFloat := AObj.RttiSession_GetPropertyValue('Liters').AsExtended;
    Query.ParamByName('KMTRAVELED').AsFloat := AObj.RttiSession_GetPropertyValue('KMTraveled').AsExtended;
    Query.ExecSQL;
  finally
    AObj.RttiSession_End;
    if Assigned(Query) then Query.Free;
  end;
end;

{ TServiceSQLiteCostType }

procedure TServiceSQLiteCostType<T>.Add(AObj: T);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_INSERT);
  AObj.RttiSession_Begin;
  try
    Query.ParamByName('DESCRIZIONE').AsString := AObj.Descrizione;
    Query.ParamByName('OBJECTTYPE').AsInteger := AObj.RttiSession_GetPropertyValue('ObjectType').AsInteger;
    Query.ExecSQL;
    AObj.ID := Self.GetLastInsertRowID;
  finally
    AObj.RttiSession_End;
    if Assigned(Query) then Query.Free;
  end;
end;

procedure TServiceSQLiteCostType<T>.DeleteByID(AID: Integer);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_DELETE);
  try
    Query.ParamByName('ID').AsInteger := AID;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TServiceSQLiteCostType<T>.GetAll: TBaseObjectList<T>;
var
  Query: TSQLQuery;
  NewObj: T;
begin
  Query := Self.CreateQuery(Connection, SQL_SELECT_ALL);
  try
    Query.Open;
    Result := TBaseObjectList<T>.Create(True);
    while not Query.Eof do
    begin
      NewObj := T.Create;
      NewObj.RttiSession_Begin;
      try
        NewObj.ID := Query.FieldByName('ID').AsInteger;
        NewObj.Descrizione := Query.FieldByName('DESCRIZIONE').AsString;
        NewObj.RttiSession_SetPropertyValue('ObjectType', Query.FieldByName('OBJECTTYPE').AsInteger);
        Result.Add(NewObj);
        NewObj.RttiSession_End;
      except
        NewObj.RttiSession_End;
        FreeAndNil(NewObj);
        raise;
      end;
      Query.Next;
    end;
    Query.Close;
  finally
    if assigned(Query) then Query.Free;
  end;
end;

function TServiceSQLiteCostType<T>.GetByID(AID: Integer): T;
var
  Query: TSQLQuery;
begin
  Result := nil;
  try
    Query := Self.CreateQuery(Connection, SQL_SELECT_BY_ID);
    Query.ParamByName('ID').AsInteger := AID;
    Query.Open;
    if Query.IsEmpty then raise Exception.Create('CostType not found');
    Result := T.Create;
    Result.RttiSession_Begin;
    try
      Result.ID := Query.FieldByName('ID').AsInteger;
      Result.Descrizione := Query.FieldByName('DESCRIZIONE').AsString;
      Result.RttiSession_SetPropertyValue('ObjectType', Query.FieldByName('OBJECTTYPE').AsInteger);
    except
      Result.RttiSession_End;
      FreeAndNil(Result);
      raise;
    end;
    Query.Close;
  finally
    if Assigned(Query) then Query.Free;
  end;
end;

procedure TServiceSQLiteCostType<T>.Update(AObj: T);
var
  Query: TSQLQuery;
begin
  inherited;
  Query := Self.CreateQuery(Connection, SQL_UPDATE);
  AObj.RttiSession_Begin;
  try
    Query.ParamByName('ID').AsInteger := AObj.ID;
    Query.ParamByName('DESCRIZIONE').AsString := AObj.Descrizione;
    Query.ParamByName('OBJECTTYPE').AsInteger := AObj.RttiSession_GetPropertyValue('ObjectType').AsInteger;
    Query.ExecSQL;
  finally
    AObj.RttiSession_End;
    if Assigned(Query) then Query.Free;
  end;
end;

{ TServiceSQLiteConnectionFactory }

procedure TServiceSQLiteConnectionFactory.CheckForTableRowsInitialization(
  AConn: TSQLConnection);
const
  COSTTYPES_SQL = 'INSERT OR REPLACE INTO COSTTYPES (ID, DESCRIZIONE, OBJECTTYPE) VALUES';
  TRAVELS_SQL = 'INSERT OR REPLACE INTO TRAVELS (ID, DESCRIZIONE, STARTDATE, ENDDATE, STARTKM, ENDKM) VALUES';
  COSTS_SQL = 'INSERT OR REPLACE INTO COSTS (ID, DESCRIZIONE, TRAVELID, COSTTYPEID, COSTDATE, COSTAMOUNT, COSTNOTE, LITERS, KMTRAVELED, CLASSTYPE) VALUES';
var
  ACostGeneric: TCostGeneric;
  ACostFuel: TCostFuel;
begin
  // Creazione tipi di costo
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(1, "TUTTO", ' + IntToStr(COST_OBJECT_TYPE_TOTAL) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(2, "CARBURANTE", ' + IntToStr(COST_OBJECT_TYPE_FUEL) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(3, "PEDAGGI", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(4, "SOSTA/CAMPEGGIO", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(5, "SVAGO/DIVERTIMENTI", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(6, "ALIMENTARI", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(7, "RISTORANTE", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(8, "VARIE", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(9, "MANUTENZIONI", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(10, "ASSICURAZIONI", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );
  AConn.ExecuteDirect(COSTTYPES_SQL
                      +'(11, "BOLLI E TASSE", ' + IntToStr(COST_OBJECT_TYPE_GENERIC) + ')'
                      );

  // Creazione Viaggi
  AConn.ExecuteDirect(TRAVELS_SQL
                      +'(1, "FUSSEN", ' + FloatToStr(StrToDate('01/01/2012')) + ',' + FloatToStr(StrToDate('06/01/2012')) + ', 15000, 16250)'
                      );
  AConn.ExecuteDirect(TRAVELS_SQL
                      +'(2, "LAGO DI GARDA", ' + FloatToStr(StrToDate('03/10/2012')) + ',' + FloatToStr(StrToDate('10/10/2012')) + ', 26500, 27500)'
                      );
  AConn.ExecuteDirect(TRAVELS_SQL
                      +'(3, "GARGANO", ' + FloatToStr(StrToDate('06/06/2012')) + ',' + FloatToStr(StrToDate('06/12/2012')) + ', 22500, 23650)'
                      );

  // Creazione Costi
  ACostGeneric := TCostFactory.NewCost(0
                                      ,'AUTOSTRADA'
                                      ,1
                                      ,TIupOrm.Load<TCostType>.ByOID(3).ToObject
                                      ,StrToDate('01/01/2012')
                                      ,20.25
                                      ,'PROVA'
                                      ,0
                                      ,0
                                      );
  TIupOrm.Persist(ACostGeneric);
  ACostGeneric.Free;
  ACostGeneric := TCostFactory.NewCost(0
                                      ,'GASOLIO'
                                      ,1
                                      ,TIupOrm.Load<TCostType>.ByOID(2).ToObject
                                      ,StrToDate('03/01/2012')
                                      ,65.32
                                      ,'PROVA'
                                      ,45.4
                                      ,465
                                      );
  TIupOrm.Persist(ACostGeneric);
  ACostGeneric.Free;
end;

procedure TServiceSQLiteConnectionFactory.CheckForTablesCreation(
  AConn: TSQLConnection);
begin
  // Tabella COSTTYPES
  AConn.ExecuteDirect('CREATE TABLE IF NOT EXISTS COSTTYPES'
                      +'(ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
                      +',DESCRIZIONE VARCHAR(60)'
                      +',OBJECTTYPE INTEGER)'
                      );
  // Tabella TRAVELS
  AConn.ExecuteDirect('CREATE TABLE IF NOT EXISTS TRAVELS'
                      +'(ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
                      +',DESCRIZIONE VARCHAR(60)'
                      +',STARTDATE FLOAT'
                      +',ENDDATE FLOAT'
                      +',STARTKM FLOAT'
                      +',ENDKM FLOAT)'
                      );
  // Tabella COSTS
  AConn.ExecuteDirect('CREATE TABLE IF NOT EXISTS COSTS'
                      +'(ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
                      +',DESCRIZIONE VARCHAR(60)'
                      +',TRAVELID INTEGER'
                      +',COSTTYPEID INTEGER'
                      +',COSTDATE FLOAT'
                      +',COSTAMOUNT FLOAT'
                      +',COSTNOTE TEXT'
                      +',LITERS FLOAT'
                      +',KMTRAVELED FLOAT'
                      +',CLASSINFO VARCHAR(255))'
                      );
end;

procedure TServiceSQLiteConnectionFactory.DBCheckForInit(DBConn: TSQLConnection);
begin
  CheckForTablesCreation(DBConn);
  CheckForTableRowsInitialization(DBConn);
end;

function TServiceSQLiteConnectionFactory.GetNewConnection(AOwner:TComponent): TSQLConnection;
var
  DBFileNameFull: String;
  goDBInit: Boolean;
begin
  // Compone il nome completo del file database
{$IFDEF IOS}
  DBFileNameFull := TPath.Combine(TPath.GetDocumentsPath, 'VRManager.db');
{$ELSE}
  DBFileNameFull := TPath.Combine(TPath.GetDocumentsPath, 'VRManager.db');
{$ENDIF}

  // Se il database non esiste significa che deve essere creato e inizializzato
  goDBInit := not FileExists(DBFileNameFull);

  // Crea la connessione al DB
  Result := TSQLConnection.Create(AOwner);
  Result.DriverName := 'SQLite';
  Result.LoginPrompt := False;
  Result.Params.Values['FailIfMissing'] := 'False';
  Result.Params.Values['HostName'] := 'localhost';
  Result.Params.Values['Database'] := DBFileNameFull;
  Result.Open;

  // Se il DB deve essere inizializzato...
  if goDBInit then Self.DBCheckForInit(Result);
end;

{ TServiceSQLiteFactory }

function TServiceSQLiteFactory<T>.Connection: IServiceConnectionFactory;
begin
  Result := TServiceSQLiteConnectionFactory.Create;
end;

function TServiceSQLiteFactory<T>.Cost: IServiceGenericCost<T>;
begin
  Result := TServiceSQLiteCost<T>.Create;
end;

function TServiceSQLiteFactory<T>.CostType: IServiceGeneric<T>;
begin
  Result := TServiceSQLiteCostType<T>.Create;
end;

function TServiceSQLiteFactory<T>.CostTypeWithCostList: IServiceGenericWithCostList<T>;
begin
  Result := TServiceSQLiteCostTypeWithCostList<T>.Create;
end;

function TServiceSQLiteFactory<T>.Travel: IServiceGeneric<T>;
begin
  Result := TServiceSQLiteTravel<T>.Create;
end;


{ TServiceSQLiteCostTypeWithCostList }

function TServiceSQLiteCostTypeWithCostList<T>.GetAll(ATravelID: Integer): TBaseObjectList<T>;
var
  CostType: T;
begin
  Result := inherited GetAll;
  for CostType in Result do
  begin
    TCostTypeWithCostList(CostType).CostList := TServiceSQLiteFactory<TCostGeneric>.Create.Cost.GetAll(ATravelID, CostType.ID);
  end;
end;

function TServiceSQLiteCostTypeWithCostList<T>.GetByID(AID:Integer; ATravelID:Integer): T;
begin
  Result := inherited GetByID(AID);
  TCostTypeWithCostList(Result).CostList := TServiceSQLiteFactory<TCostGeneric>.Create.Cost.GetAll(ATravelID, Result.ID);
end;

end.
