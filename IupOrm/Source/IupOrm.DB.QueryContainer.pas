unit IupOrm.DB.QueryContainer;

interface

uses
  IupOrm.DB.Interfaces, IupOrm.Context.Interfaces,
  IupOrm.Context.Properties.Interfaces, System.Generics.Collections;

type

  // Contiene la collezione di tutte gli oggetti IioQuery creati
  //  per una connessione. In pratica ogni connessione (IioConnection) contiene la collezione di query
  //  create per la connessione stessa in modo da poterle riutilizzare. Il ciclo di vita di questi oggetti query
  //  coincide quindi con quello della connessione che a sua volta coincide con quello della transazione.
  TioQueryContainer = class(TInterfacedObject, IioQueryContainer)
  type
    TioInternalQueryContainerType = TDictionary<String, IioQuery>;
  strict private
    FContainer: TioInternalQueryContainerType;
  public
    constructor Create;
    destructor Destroy; override;
    function Exist(AQueryIdentity:String): Boolean;
    function GetQuery(AQueryIdentity:String): IioQuery;
    procedure AddQuery(AQueryIdentity:String; AQuery:IioQuery);
    procedure CleanQueryConnectionsRef;
  end;

implementation

uses System.SysUtils;

{ TioQueryContainer }

procedure TioQueryContainer.AddQuery(AQueryIdentity:String; AQuery: IioQuery);
begin
  FContainer.Add(AQueryIdentity, AQuery);
end;

procedure TioQueryContainer.CleanQueryConnectionsRef;
var
  AQuery: IioQuery;
begin
  // Remove the reference to the connection
  //  NB: Viene richiamato alla distruzione di una connessione perchè altrimenti avrei un riferimento incrociato
  //       tra la connessione che, attraverso il proprio QueryContainer, manteine un riferimento a tutte le query
  //       che sono state preparate ela query che mantiene un riferimento alla connessione al suo interno; in pratica
  //       questo causava molti memory leaks perchè questi oggetti rimanevano in vita perenne in quanto si sostenevano
  //       a vicenda e rendevano inefficace il Reference Count
  for AQuery in Self.FContainer.Values
  do AQuery.CleanConnectionRef;
end;

constructor TioQueryContainer.Create;
begin
  inherited;
  FContainer := TioInternalQueryContainerType.Create;
end;

destructor TioQueryContainer.Destroy;
begin
  FContainer.Free;
  inherited;
end;

function TioQueryContainer.Exist(AQueryIdentity:String): Boolean;
begin
  Result := (not AQueryIdentity.IsEmpty) and FContainer.ContainsKey(AQueryIdentity);
end;

function TioQueryContainer.GetQuery(AQueryIdentity:String): IioQuery;
begin
  Result := FContainer.Items[AQueryIdentity];
end;

end.
