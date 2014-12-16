unit IupOrm.DB.ConnectionContainer;

interface

uses
  IupOrm.DB.Interfaces, System.Generics.Collections, FireDAC.Comp.Client,
  IupOrm.CommonTypes;

type

  // IL connection manager ha il compito di mantenere i parametri delle connessioni impostate all'avvio
  //  dell'applicazione per una loro successiva istanziazione e di gestione del connection pooling
  //  se richiesto.
  //  In realtà questa classe utilizza il TFDManager fornito da FireDAC e non fa molto altro
  //  se non aggiungere un campo per mantenere un riferimento al nome della ConnectionDef
  //  di default. Una gestione di una connessione di default mi serviva perchè volevo fare in modo che
  //  fosse necessario specificare esplicitamente una ConnectionDef (con un attribute) per ogni classe/entità
  //  e quindi ho deciso di mantenere un riferimento al nome della connectionDef di dafault in modo che per tutte le classi
  //  che non indicano una connection esplicitamente utilizzino quella di default e quindi anche che normalmente nelle applicazioni
  //  che utilizzano una sola ConnectionDef non è necessario specificare nulla nella dichiarazione delle classi perchè
  //  tanto utilizzano automaticamente la ConnectionDef di default (l'unica).
  TioConnectionManagerRef = class of TioConnectionManager;
  TioConnectionManager = class
    strict private
      class var FDefaultConnectionName: String;
    public
      class function NewCustomConnectionDef(const AConnectionName:String=IO_CONNECTIONDEF_DEFAULTNAME; const AsDefault:Boolean=False): IIoConnectionDef;
      class function NewSQLiteConnectionDef(const ADatabase: String; const AConnectionName:String=IO_CONNECTIONDEF_DEFAULTNAME): IIoConnectionDef;
      class function NewFirebirdConnectionDef(const AServer, ADatabase, AUserName, APassword, ACharSet: String; const AConnectionName:String=IO_CONNECTIONDEF_DEFAULTNAME): IIoConnectionDef;
      class function NewSQLServerConnectionDef(const AServer, ADatabase, AUserName, APassword: String; const AConnectionName:String=IO_CONNECTIONDEF_DEFAULTNAME): IIoConnectionDef;
      class function NewMySQLConnectionDef(const AServer, ADatabase, AUserName, APassword, ACharSet: String; const AConnectionName:String=IO_CONNECTIONDEF_DEFAULTNAME): IIoConnectionDef;
      class function GetConnectionDefByName(AConnectionName:String=''): IIoConnectionDef;
      class function GetDefaultConnectionName: String;
      class procedure SetDefaultConnectionName(const AConnectionName:String=IO_CONNECTIONDEF_DEFAULTNAME);
  end;

  // Il ConnectionContainer contiene le connessioni attive in un dato momento, cioè quelle
  //  connections che sono effettivamente in uso al momento; il loro ciclo di vita (delle connessioni)
  //  coincide con il ciclo della transazion in essere sulla connessione stessa, quando la transazione
  //  termina (con un commit/rollback) anche la connessione viene elimimata.
  //  Le connessioni sono separate per thread in modo da predisporeìle fin da subito ad eventuali sviluppi in
  //  senso multithreading.
  //  NB: Questa classe non gestisce l'eventuale connection pooling e non contiene i parametri della/e connesioni
  //       da creare ma è semplicemente un repository delle sole connessioni in uso in modo che chiamate ricorsive
  //       all'ORM all'interno di una singola operazione (ad esempio quando carichiamo una classe che ha al suo interno
  //       proprietà con relazioni il caricamento degli oggetti dettaglio avviene con una chiamata ricorsiva all'ORM
  //       e questa chicìamata deve svolgersi all'interno della stessa transazione del master e quindi con la stessa connection)
  //       possano accedere allo stesso oggetto connection (via factory).
  TioInternalContainerType = TDictionary<String, IioConnection>;
  TioConnectionContainerRef = class of TioConnectionContainer;
  TioConnectionContainer = class
  strict private
    class var FContainer: TioInternalContainerType;
    class function GetCurrentThreadID: TThreadID;
    class function ConnectionNameToContainerKey(AConnectionName:String): String;
  public
    class procedure CreateInternalContainer;
    class procedure FreeInternalContainer;
    class procedure AddConnection(const AConnection:IioConnection);
    class procedure FreeConnection(const AConnection:IioConnection);
    class function GetConnection(const AConnectionName:String): IioConnection;
    class function ConnectionExist(const AConnectionName:String): Boolean;
  end;

implementation

uses
  System.Classes, System.SysUtils, IupOrm.Exceptions;

{ TioConnectionContainer }

class procedure TioConnectionContainer.AddConnection(const AConnection: IioConnection);
begin
  FContainer.Add(   Self.ConnectionNameToContainerKey(AConnection.GetConnectionDefName), AConnection   );
end;

class function TioConnectionContainer.ConnectionExist(const AConnectionName:String): Boolean;
begin
  Result := FContainer.ContainsKey(   Self.ConnectionNameToContainerKey(AConnectionName)   );
end;

class function TioConnectionContainer.ConnectionNameToContainerKey(AConnectionName: String): String;
begin
  Result := AConnectionName + '-' + Self.GetCurrentThreadID.ToString;
end;

class procedure TioConnectionContainer.CreateInternalContainer;
begin
  Self.FContainer := TioInternalContainerType.Create;
end;

class procedure TioConnectionContainer.FreeConnection(const AConnection:IioConnection);
begin
  FContainer.Remove(   Self.ConnectionNameToContainerKey(AConnection.GetConnectionDefName)   );
end;

class procedure TioConnectionContainer.FreeInternalContainer;
begin
  Self.FContainer.Free;
end;

class function TioConnectionContainer.GetConnection(const AConnectionName:String): IioConnection;
begin
  Result := FContainer.Items[   Self.ConnectionNameToContainerKey(AConnectionName)   ];
end;

class function TioConnectionContainer.GetCurrentThreadID: TThreadID;
begin
  Result := System.Classes.TThread.CurrentThread.ThreadID;
end;

{ TioConnectionManager }

{ TioConnectionManager }

class function TioConnectionManager.GetConnectionDefByName(AConnectionName: String): IIoConnectionDef;
begin
  // If desired ConnectionName is empty then get then Default one.
  if AConnectionName = '' then Self.GetDefaultConnectionName;
  // Get the ConnectionDef info's
  Result := FDManager.ConnectionDefs.FindConnectionDef(AConnectionName);
end;

class function TioConnectionManager.GetDefaultConnectionName: String;
begin
  Result := Self.FDefaultConnectionName;
end;

class function TioConnectionManager.NewCustomConnectionDef(const AConnectionName: String; const AsDefault: Boolean): IIoConnectionDef;
begin
   // Create the ConnectionDef object and set his name
  //  NB: The nae of the connectionDef should never be chenged after
  Result := FDManager.ConnectionDefs.AddConnectionDef;
  Result.Name := AConnectionName;
  // If the AsDefault param is True or this is the first ConnectionDef of the application
  //  then set it as default
  if AsDefault or (Self.FDefaultConnectionName = '') then
    Self.FDefaultConnectionName := AConnectionName;
end;

class function TioConnectionManager.NewFirebirdConnectionDef(const AServer, ADatabase, AUserName, APassword, ACharSet,
  AConnectionName: String): IIoConnectionDef;
begin
  Result := Self.NewCustomConnectionDef(AConnectionName);
  Result.Params.Values['DriverID'] := 'FB';
  Result.Params.Values['Server'] := AServer;
  Result.Params.Values['Database'] := ADatabase;
  Result.Params.Values['User_Name'] := AUserName;
  Result.Params.Values['Password'] := APassword;
  Result.Params.Values['Protocol'] := 'TCPIP';
  if ACharSet <> '' then Result.Params.Values['CharacterSet'] := ACharSet;
end;

class function TioConnectionManager.NewMySQLConnectionDef(const AServer, ADatabase, AUserName, APassword, ACharSet,
  AConnectionName: String): IIoConnectionDef;
begin
  Result := Self.NewCustomConnectionDef(AConnectionName);
  Result.Params.Values['DriverID'] := 'MySQL';
  Result.Params.Values['Server'] := AServer;
  Result.Params.Values['Database'] := ADatabase;
  Result.Params.Values['User_Name'] := AUserName;
  Result.Params.Values['Password'] := APassword;
  if ACharSet <> '' then Result.Params.Values['CharacterSet'] := ACharSet;
end;

class function TioConnectionManager.NewSQLiteConnectionDef(const ADatabase, AConnectionName: String): IIoConnectionDef;
begin
  Result := Self.NewCustomConnectionDef(AConnectionName);
  Result.Params.Values['DriverID'] := 'SQLite';
//  Result.Params.Values['Server'] := 'localhost';
  Result.Params.Values['Database'] := ADatabase;
  Result.Params.Values['FailIfMissing'] := 'False';
end;

class function TioConnectionManager.NewSQLServerConnectionDef(const AServer, ADatabase, AUserName, APassword,
  AConnectionName: String): IIoConnectionDef;
begin
  Result := Self.NewCustomConnectionDef(AConnectionName);
  Result.Params.Values['DriverID'] := 'MSSQL';
  Result.Params.Values['Server'] := AServer;
  Result.Params.Values['Database'] := ADatabase;
  Result.Params.Values['User_Name'] := AUserName;
  Result.Params.Values['Password'] := APassword;
end;

class procedure TioConnectionManager.SetDefaultConnectionName(const AConnectionName: String);
begin
  // If a connectionDef with thie name is not founded then raise an exception
  if not Assigned(FDManager.FindConnection(AConnectionName)) then
    raise EIupOrmException.Create(Self.ClassName + ': Connection params definition "' + AConnectionName + '" not found!');
  // Set the connection as default
  Self.FDefaultConnectionName := AConnectionName;
end;

initialization

  TioConnectionContainer.CreateInternalContainer;

finalization

  TioConnectionContainer.FreeInternalContainer;

end.
