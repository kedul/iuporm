unit IupOrm.DB.Query;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.DB.Interfaces,
  System.Classes,
  Data.SqlExpr,
  System.Rtti;

type

  // Classe che incapsula una query
  TioQuery = class(TInterfacedObject, IioQuery)
  strict private
    FSqlConnection: IioConnection;
    FSqlQuery: TSQLQuery;
  strict protected
    function GetValueByFieldIndexAsVariant(Idx:Integer): Variant;
  public
    constructor Create(AConnection:IioConnection; ASQLQuery:TSQLQuery);
    destructor Destroy; override;
    procedure First;
    procedure Last;
    procedure Next;
    procedure Prior;
    function Eof: Boolean;
    function GetValue(AProperty:IioContextProperty): TValue;
    function GetValueByFieldNameAsVariant(AFieldName:String): Variant;
    procedure Open;
    procedure Close;
    function ExecSQL: Integer; virtual;
    function GetSQL: TStrings;
    function Fields: TioFields;
    function Connection: IioConnection;
    property SQL: TStrings read GetSQL;
  end;

  // Classe che incapsula una query specifica per query insert
  TioQueryInsert = class(TioQuery)
  strict private
    FGetLastIdSql: String;
  public
    constructor Create(AConnection:IioConnection; ASQLQuery:TSQLQuery; AGetLastIdSql:String='');
    function ExecSQL: Integer; override;
  end;

implementation

uses
  System.TypInfo;

{ TioQuerySqLite }

procedure TioQuery.Close;
begin
  FSqlQuery.Close;
end;

function TioQuery.Connection: IioConnection;
begin
  Result := FSqlConnection;
end;

constructor TioQuery.Create(AConnection: IioConnection;
  ASQLQuery: TSQLQuery);
begin
  inherited Create;
  FSqlQuery := ASQLQuery;
  FSqlConnection := AConnection;  // Per utilizzare il reference counting
  if Assigned(AConnection)
    then FSqlQuery.SQLConnection := AConnection.GetConnection as TSQLConnection;
end;

destructor TioQuery.Destroy;
begin
  FSqlQuery.Free;
  inherited;
end;

function TioQuery.Eof: Boolean;
begin
  Result := FSqlQuery.Eof;
end;

function TioQuery.ExecSQL: Integer;
begin
  Result := FSqlQuery.ExecSQL(True);
end;

function TioQuery.Fields: TioFields;
begin
  Result := FSqlQuery.Fields;
end;

procedure TioQuery.First;
begin
  FSqlQuery.First;
end;

function TioQuery.GetSQL: TStrings;
begin
  Result := FSqlQuery.SQL;
end;

function TioQuery.GetValue(AProperty:IioContextProperty): TValue;
begin
  if FSqlQuery.FieldByName(AProperty.GetSqlFieldName).IsNull then Exit;
  case AProperty.GetRttiProperty.PropertyType.TypeKind of
    tkInt64, tkInteger, tkClass, tkInterface:  // NB: tkClass e tkInterface perchè assumo che, in caso di campo di tipo oggetto (classe o interfaccia) il campo sia sempre un ID integer
      Result := FSqlQuery.FieldByName(AProperty.GetSqlFieldName).AsInteger;
    tkFloat:
      Result := FSqlQuery.FieldByName(AProperty.GetSqlFieldName).AsFloat;
    tkString, tkUString, tkWChar, tkLString, tkWString, tkChar:
      Result := FSqlQuery.FieldByName(AProperty.GetSqlFieldName).AsString;
  end;
end;

function TioQuery.GetValueByFieldIndexAsVariant(Idx: Integer): Variant;
begin
  Result := FSqlQuery.Fields[Idx].Value;
end;

function TioQuery.GetValueByFieldNameAsVariant(AFieldName: String): Variant;
begin
  Result := FSqlQuery.FieldByName(AFieldName).Value;
end;

procedure TioQuery.Last;
begin
  FSqlQuery.Last;
end;

procedure TioQuery.Next;
begin
  FSqlQuery.Next;
end;

procedure TioQuery.Open;
begin
  FSqlQuery.Open;
end;

procedure TioQuery.Prior;
begin
  FSqlQuery.Prior;
end;

{ TioQueryInsert }

constructor TioQueryInsert.Create(AConnection: IioConnection;
  ASQLQuery: TSQLQuery; AGetLastIdSql: String);
begin
  inherited Create(AConnection, ASQLQuery);
  FGetLastIdSql := AGetLastIdSql;
end;

function TioQueryInsert.ExecSQL: Integer;
begin
  // Execute the defined query (normally insert query)
  inherited;
  // If assigned, set and execute the query for retrieve the
  //  last ID inserted
  Result := -1;
  if FGetLastIdSql = '' then Exit;
  Self.SQL.Clear;
  Self.SQL.Add(FGetLastIdSql);
  Self.Open;
  try
    Result := Self.GetValueByFieldIndexAsVariant(0);
  finally
    Self.Close;
  end;
end;

end.
