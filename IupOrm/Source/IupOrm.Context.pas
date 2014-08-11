unit IupOrm.Context;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.Context.Interfaces,
  IupOrm.CommonTypes,
  IupOrm.Where, IupOrm.Context.Table.Interfaces, System.Rtti,
  IupOrm.Context.Map.Interfaces;

type

  TioContext = class(TInterfacedObject, IioContext)
  strict private
    FMap: IioMap;
    FDataObject: TObject;
    FWhere: TioWhere;
    FSelfCreatedWhere: Boolean;
  strict protected
    // Map
    function Map: IioMap;
    // DataObject
    function GetDataObject: TObject;
    procedure SetDataObject(AValue: TObject);
    // ObjectStatus
    function GetObjectStatus: TIupOrmObjectStatus;
    procedure SetObjectStatus(AValue: TIupOrmObjectStatus);
    // Where
    function GetWhere: TioWhere;
    procedure SetWhere(AWhere: TioWhere);
  public
    constructor Create(AClassName:String; AMap:IioMap; AWhere:TioWhere=nil; ADataObject:TObject=nil); overload;
    destructor Destroy; override;
    function GetClassRef: TioClassRef;
    function GetTable: IioContextTable;
    function GetProperties: IioContextProperties;
    function ClassFromField: IioClassFromField;
    function IsClassFromField: Boolean;
    function RttiContext: TRttiContext;
    function RttiType: TRttiInstanceType;
    // Blob field present
    function BlobFieldExists: Boolean;
    // ObjStatusExist
    function ObjStatusExist: Boolean;
    // DataObject
    property DataObject:TObject read GetDataObject write SetDataObject;
    // ObjectStatus
    property ObjectStatus:TIupOrmObjectStatus read GetObjectStatus write SetObjectStatus;
    // Where
    property Where:TioWhere read GetWhere write SetWhere;
    // GroupBy
    function GetGroupBySql: String;
    // Join
    function GetJoin: IioJoins;
  end;

implementation

uses
  IupOrm.Context.Factory, IupOrm.DB.Factory, System.TypInfo,
  IupOrm.Context.Container;

{ TioContext }

function TioContext.BlobFieldExists: Boolean;
begin
  Result := Self.GetProperties.BlobFieldExists;
end;

function TioContext.ClassFromField: IioClassFromField;
begin
  Result := Self.Map.GetTable.GetClassFromField;
end;

constructor TioContext.Create(AClassName:String; AMap:IioMap; AWhere:TioWhere=nil; ADataObject:TObject=nil);
begin
  inherited Create;
  FMap := AMap;
  FDataObject := ADataObject;
  // ---------------------------------------------------------------------------
  // Create TioWhere if nil
  FSelfCreatedWhere := False;
  if not Assigned(AWhere)then
  begin
    FSelfCreatedWhere := True;
    AWhere := TioContextFactory.Where;
    if Assigned(FDataObject)
      then AWhere.Add(Self.GetProperties.GetIdProperty.GetSqlQualifiedFieldName + TioDbFactory.CompareOperator._Equal.GetSql + Self.GetProperties.GetIdProperty.GetSqlValue(FDataObject));
  end;
  // Add ContextProperties to TioWhere and assign it to the field
  AWhere.SetContextProperties(Self.GetProperties);
  FWhere := AWhere;
  // ---------------------------------------------------------------------------
end;

destructor TioContext.Destroy;
begin
  if FSelfCreatedWhere then FWhere.Free;
  inherited;
end;

function TioContext.GetClassRef: TioClassRef;
begin
  Result := Self.Map.GetClassRef;
end;

function TioContext.GetDataObject: TObject;
begin
  Result := FDataObject;
end;

function TioContext.GetGroupBySql: String;
begin
  Result := '';
  // Ritorna il GroupBy fisso (attribute nella dichiarazione della classe)
  if Assigned(Self.GetTable.GetGroupBy)
    then Result := Self.GetTable.GetGroupBy.GetSql;
  // Aggiungere qui l'eventuale futuro codice per aggiungere/sostituire
  //  l'eventuale GroupBy specificato nel ioWhere e che quindi è nel
  //  context e che sostituisce il GroupBy fisso
end;

function TioContext.GetJoin: IioJoins;
begin
  Result := Self.GetTable.GetJoin;
end;

function TioContext.GetObjectStatus: TIupOrmObjectStatus;
begin
  if Self.GetProperties.ObjStatusExist
    then Result := TIupOrmObjectStatus(   Self.GetProperties.ObjStatusProperty.GetValue(Self.FDataObject).AsOrdinal   )
    else Result := osDirty;
end;

function TioContext.GetProperties: IioContextProperties;
begin
  Result := Self.Map.GetProperties;
end;

function TioContext.RttiContext: TRttiContext;
begin
  Result := Self.Map.RttiContext;
end;

function TioContext.RttiType: TRttiInstanceType;
begin
  Result := Self.Map.RttiType;
end;

procedure TioContext.SetDataObject(AValue: TObject);
begin
  FDataObject := AValue;
end;

procedure TioContext.SetObjectStatus(AValue: TIupOrmObjectStatus);
var
  PropValue: TValue;
begin
  // If ObjectStatus property non exist then exit
  if not Self.GetProperties.ObjStatusExist then Exit;
  // If exist set the property value
  PropValue := TValue.From<TIupOrmObjectStatus>(AValue);
  Self.GetProperties.ObjStatusProperty.SetValue(Self.FDataObject, PropValue);
end;

procedure TioContext.SetWhere(AWhere: TioWhere);
begin
  FWhere := AWhere;
end;

function TioContext.GetTable: IioContextTable;
begin
  Result := Self.Map.GetTable;
end;

function TioContext.GetWhere: TioWhere;
begin
  Result := FWhere;
end;

function TioContext.IsClassFromField: Boolean;
begin
  Result := Self.GetTable.IsClassFromField and not FWhere.GetDisableClassFromField;
end;

function TioContext.Map: IioMap;
begin
  Result := FMap;
end;

function TioContext.ObjStatusExist: Boolean;
begin
  Result := Self.GetProperties.ObjStatusExist;
end;

end.
