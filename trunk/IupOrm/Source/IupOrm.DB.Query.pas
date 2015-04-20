unit IupOrm.DB.Query;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.DB.Interfaces,
  System.Classes,
  System.Rtti,
  FireDAC.Comp.Client,
  Data.DB, IupOrm.Context.Interfaces;

type

  // A class reference to a query (used in the DB.Factory)
  TioQueryRef = class of TioQuery;

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
    function IsSqlEmpty: Boolean;
    function ExecSQL: Integer; virtual;
    function GetSQL: TStrings;
    function Fields: TioFields;
    function ParamByName(AParamName:String): TioParam;
    function ParamByProp(AProp:IioContextProperty): TioParam;
    procedure SetParamValueByContext(AProp:IioContextProperty; AContext:IioContext);
    procedure SetParamValueToNull(AProp:IioContextProperty; AForceDataType:TFieldType=ftUnknown);
    function Connection: IioConnection;
    procedure CleanConnectionRef;
    function CreateBlobStream(AProperty: IioContextProperty; Mode: TBlobStreamMode): TStream;
    procedure SaveStreamObjectToSqlParam(AObj:TObject; AProperty: IioContextProperty);
    property SQL: TStrings read GetSQL;
  end;

implementation

uses
  System.TypInfo, IupOrm.Exceptions, IupOrm.Attributes,
  IupOrm.ObjectsForge.Factory, IupOrm.DuckTyped.Interfaces,
  IupOrm.DuckTyped.Factory, IupOrm.DB.Factory, System.JSON;

{ TioQuerySqLite }

procedure TioQuery.CleanConnectionRef;
begin
  // Remove the reference to the connection
  //  NB: Viene richiamato alla distruzione di una connessione perch� altrimenti avrei un riferimento incrociato
  //       tra la connessione che, attraverso il proprio QueryContainer, manteine un riferimento a tutte le query
  //       che sono state preparate ela query che mantiene un riferimento alla connessione al suo interno; in pratica
  //       questo causava molti memory leaks perch� questi oggetti rimanevano in vita perenne in quanto si sostenevano
  //       a vicenda e rendevano inefficace il Reference Count
  FSqlConnection := nil;
end;

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
    then Exit(FSqlQuery.FieldByName(AProperty.GetSqlFieldAlias).AsInteger);

  // If the property is mapped into a blob field
  //  NB: Non pi� usato per il caricamento degli oggetti, per il caricamento dei campi
  //       BLOB vedere a partire dal metodo "MakeObject" dell'ObjectMaker
//  if AProperty.IsBlob
//    then Exit(TioObjectMakerFactory.GetObjectMaker(False).CreateObjectFromBlobField(Self, AProperty));

  // Else return the value for the field related to the AProperty as TValue
  Result := TioDBFactory.SqlDataConverter.QueryToTValue(Self, AProperty);
end;

function TioQuery.GetValueByFieldIndexAsVariant(Idx: Integer): Variant;
begin
  Result := FSqlQuery.Fields[Idx].Value;
end;

function TioQuery.GetValueByFieldNameAsVariant(AFieldName: String): Variant;
begin
  Result := FSqlQuery.FieldByName(AFieldName).Value;
end;

function TioQuery.IsSqlEmpty: Boolean;
begin
  Result := (FSqlQuery.SQL.Count = 0);
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

function TioQuery.ParamByName(AParamName: String): TioParam;
begin
  Result := Self.FSqlQuery.ParamByName(AParamName);
end;

function TioQuery.ParamByProp(AProp: IioContextProperty): TioParam;
begin
  Result := Self.ParamByName(AProp.GetSqlParamName);
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

  // If AObj is a TStream then use it directly else wrap it with a
  //  DuckTypedSTreamObject wrapper, extract the stream and then use it.
  // -------------------------------------------------------------------------------------------------------------------------------
  // TStream or descendant
  // -------------------------------------------------------------------------------------------------------------------------------
  if AObj is TStream then
  begin
    AStream := TStream(AObj);
    // If the Stream is empty or nil then set the Param value to NULL and exit
    if (not Assigned(AStream)) or (AStream.Size = 0) then
    begin
      AParam.DataType := ftBlob;
      AParam.Clear;
      Exit;
    end;
    // Load the stream content into the Param
    AParam.LoadFromStream(AStream, ftBlob);
  end
  // -------------------------------------------------------------------------------------------------------------------------------
  // NOT TStream or descendant, wrap into a DuckTypedStreamObject
  // -------------------------------------------------------------------------------------------------------------------------------
  else
  begin
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
  // -------------------------------------------------------------------------------------------------------------------------------
end;


procedure TioQuery.SetParamValueByContext(AProp: IioContextProperty; AContext: IioContext);
var
  AObj: TObject;
  ADuckTypedStreamObject: IioDuckTypedStreamObject;
  AStream: TStream;
  AParam: TioParam;
  AJSONValue: TJSONValue;
begin
  AObj := nil;
  // -------------------------------------------------------------------------------------------------------------------------------
  // Normal property type (NO BLOB)
  // -------------------------------------------------------------------------------------------------------------------------------
  if not AProp.IsBlob then
  begin
    Self.ParamByProp(AProp).Value := AProp.GetValue(AContext.DataObject).AsVariant;
    Exit;
  end;
  // At this point the property refer to a blob field (and to an Object) type then
  //  check if the Object is assigned and if it isn't clear
  //  the parameter
  AObj := AProp.GetValueAsObject(AContext.DataObject);
  if not Assigned(AObj) then
  begin
    Self.SetParamValueToNull(AProp);
    Exit;
  end;
  // Get a Param reference
  AParam := Self.ParamByProp(AProp);
  // -------------------------------------------------------------------------------------------------------------------------------
  // Embedded property (ioRTEmbeddedHasMany & ioRTEmbeddedHasOne relation type)
  // -------------------------------------------------------------------------------------------------------------------------------
  if (AProp.GetRelationType = ioRTEmbeddedHasMany) or (AProp.GetRelationType = ioRTEmbeddedHasOne) then
  begin
    case AProp.GetRelationType of
      ioRTEmbeddedHasMany:
        AJSONValue := TioObjectMakerFactory.GetObjectMapper.SerializeEmbeddedList(AObj);
      ioRTEmbeddedHasOne:
        AJSONValue := TioObjectMakerFactory.GetObjectMapper.SerializeEmbeddedObject(AObj);
    end;
    try
      AParam.AsString := AJSONValue.ToString;
      Exit;
    finally
      AJSONValue.Free;
    end;
  end;
  // -------------------------------------------------------------------------------------------------------------------------------
  // TStream or descendant (BLOB)
  // -------------------------------------------------------------------------------------------------------------------------------
  if AProp.IsStream then
  begin
    AStream := TStream(AObj);
    // If the Stream is empty or nil then set the Param value to NULL and exit
    if (not Assigned(AStream)) or (AStream.Size = 0) then
    begin
      AParam.DataType := ftBlob;
      AParam.Clear;
      Exit;
    end;
    // Load the stream content into the Param
    AParam.LoadFromStream(AStream, ftBlob);
    Exit;
  end;
  // -------------------------------------------------------------------------------------------------------------------------------
  // NOT TStream or descendant, wrap into a DuckTypedStreamObject  (BLOB)
  // -------------------------------------------------------------------------------------------------------------------------------
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
  // -------------------------------------------------------------------------------------------------------------------------------
end;

procedure TioQuery.SetParamValueToNull(AProp: IioContextProperty; AForceDataType:TFieldType=ftUnknown);
begin
  // Set the parameter to NULL
  Self.ParamByProp(AProp).Clear;
  // If a DataType is specified then set the parameter DataType
  if AForceDataType <> ftUnknown
  then Self.ParamByProp(AProp).DataType := AForceDataType;
end;


end.
