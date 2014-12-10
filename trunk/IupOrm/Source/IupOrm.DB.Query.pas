unit IupOrm.DB.Query;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.DB.Interfaces,
  System.Classes,
  System.Rtti,
  FireDAC.Comp.Client,
  Data.DB;

type

  // Classe che incapsula una query
  TioQuery = class(TInterfacedObject, IioQuery)
  strict private
    FSqlConnection: IioConnection;
    FSqlQuery: TioInternalSqlQuery;
  strict protected
    function GetValueByFieldIndexAsVariant(Idx:Integer): Variant;
  public
    constructor Create(AConnection:IioConnection; ASQLQuery:TioInternalSqlQuery);
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
    function IsEmpty: Boolean;
    function ExecSQL: Integer; virtual;
    function GetSQL: TStrings;
    function Fields: TioFields;
    function Params: TioParams;
    function Connection: IioConnection;
    function CreateBlobStream(AProperty: IioContextProperty; Mode: TBlobStreamMode): TStream;
    procedure SaveStreamObjectToSqlParam(AObj:TObject; AProperty: IioContextProperty);
    property SQL: TStrings read GetSQL;
  end;

  // Classe che incapsula una query specifica per query insert
  TioQueryInsert = class(TioQuery)
  strict private
    FGetLastIdSql: String;
  public
    constructor Create(AConnection:IioConnection; ASQLQuery:TioInternalSqlQuery; AGetLastIdSql:String='');
    function ExecSQL: Integer; override;
  end;

implementation

uses
  System.TypInfo, IupOrm.Exceptions, IupOrm.Attributes,
  IupOrm.ObjectsForge.Factory, IupOrm.DuckTyped.Interfaces,
  IupOrm.DuckTyped.Factory;

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
  ASQLQuery: TioInternalSqlQuery);
begin
  inherited Create;
  FSqlQuery := ASQLQuery;
  FSqlConnection := AConnection;  // Per utilizzare il reference counting
  if Assigned(AConnection)
    then FSqlQuery.Connection := AConnection.GetConnection;
end;

function TioQuery.CreateBlobStream(AProperty: IioContextProperty;
  Mode: TBlobStreamMode): TStream;
begin
  Result := FSqlQuery.CreateBlobStream(   Fields.FieldByName(AProperty.GetSqlFieldAlias)   , Mode);
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
  Result := 0;
  FSqlQuery.ExecSQL;
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
  // If the property is a BelongsTo relation then return data as Integer
  //  (the type for ID)
  if AProperty.GetRelationType = ioRTBelongsTo
    then Result := FSqlQuery.FieldByName(AProperty.GetSqlFieldAlias).AsInteger

  // If the property is mapped into a blob field
  else if AProperty.IsBlob
    then Result := TioObjectMakerFactory.GetObjectMaker(False).CreateObjectFromBlobField(Self, AProperty)

  // If the field is null
  else if FSqlQuery.FieldByName(AProperty.GetSqlFieldAlias).IsNull
    then Exit

  // Otherwise data type is by Property.TypeKind
  else
  begin
    case AProperty.GetRttiProperty.PropertyType.TypeKind of
      tkInt64, tkInteger:
        Result := FSqlQuery.FieldByName(AProperty.GetSqlFieldAlias).AsInteger;
      tkFloat:
        Result := FSqlQuery.FieldByName(AProperty.GetSqlFieldAlias).AsFloat;
      tkString, tkUString, tkWChar, tkLString, tkWString, tkChar:
        Result := FSqlQuery.FieldByName(AProperty.GetSqlFieldAlias).AsString;
    end;
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

function TioQuery.IsEmpty: Boolean;
begin
  Result := FSqlQuery.IsEmpty;
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

function TioQuery.Params: TioParams;
begin
  Result := FSqlQuery.Params;
end;

procedure TioQuery.Prior;
begin
  FSqlQuery.Prior;
end;

procedure TioQuery.SaveStreamObjectToSqlParam(AObj: TObject;
  AProperty: IioContextProperty);
var
  AParam: TioParam;
  ADuckTypedStreamObject: IioDuckTypedStreamObject;
  AStream: TStream;
begin
  // First prepare the query in it is not
//  Self.FSqlQuery.Prepare;
  // Get the param
  AParam := Self.FSqlQuery.Params.ParamByName(AProperty.GetSqlParamName);
  if not Assigned(AParam) then raise EIupOrmException.Create(Self.ClassName +  ': ' + AProperty.GetSqlParamName + ' Sql parameter not found');
  // Wrap the object into a DuckTypedStreamObject
  ADuckTypedStreamObject := TioDuckTypedFactory.DuckTypedStreamObject(AObj);
  // If the wrapped object IsEmpty set the Param value to NULL then exit
  if ADuckTypedStreamObject.IsEmpty then
  begin
    AParam.DataType := ftBlob;
    AParam.Clear;
    Exit;
  end;
  // Create the MemoryStream
  AStream := TMemoryStream.Create;
  try
    // Save the object content into the stream
    ADuckTypedStreamObject.SaveToStream(AStream);
    // Load the stream content into the Param
    AParam.LoadFromStream(AStream, ftBlob);
  finally
    // CleanUp
    AStream.Free;
  end;
end;


{ TioQueryInsert }

constructor TioQueryInsert.Create(AConnection: IioConnection;
  ASQLQuery: TioInternalSqlQuery; AGetLastIdSql: String);
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
