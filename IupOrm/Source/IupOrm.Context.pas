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
    FLastInsertNullID: Boolean;
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
    // LastInsertNullID
    procedure SetLastInsertNullID(AValue:Boolean);
    function GetLastInsertNullID: Boolean;
  public
    constructor Create(AClassName:String; AMap:IioMap; AWhere:TioWhere=nil; ADataObject:TObject=nil); overload;
    function GetClassRef: TioClassRef;
    function GetTable: IioContextTable;
    function GetProperties: IioContextProperties;
    function ClassFromField: IioClassFromField;
    function IsClassFromField: Boolean;
    function RttiContext: TRttiContext;
    function RttiType: TRttiInstanceType;
    function WhereExist: Boolean;
    // Blob field present
    function BlobFieldExists: Boolean;
    // ObjStatusExist
    function ObjStatusExist: Boolean;
    // GroupBy
    function GetGroupBySql: String;
    // Join
    function GetJoin: IioJoins;
    // ConnectionDefName
    function GetConnectionDefName: String;
    // DataObject
    property DataObject:TObject read GetDataObject write SetDataObject;
    // ObjectStatus
    property ObjectStatus:TIupOrmObjectStatus read GetObjectStatus write SetObjectStatus;
    // Where
    property Where:TioWhere read GetWhere write SetWhere;
    // LastInsertNullID
    property LastInsertNullID:Boolean read GetLastInsertNullID write SetLastInsertNullID;
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
  FWhere := AWhere;
end;

function TioContext.GetClassRef: TioClassRef;
begin
  Result := Self.Map.GetClassRef;
end;

function TioContext.GetConnectionDefName: String;
begin
  Result := GetTable.GetConnectionDefName;
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
  //  l'eventuale GroupBy specificato nel ioWhere e che quindi � nel
  //  context e che sostituisce il GroupBy fisso
end;

function TioContext.GetJoin: IioJoins;
begin
  Result := Self.GetTable.GetJoin;
end;

function TioContext.GetLastInsertNullID: Boolean;
begin
  Result := FLastInsertNullID;
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

procedure TioContext.SetLastInsertNullID(AValue: Boolean);
begin
  FLastInsertNullID := AValue;
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

function TioContext.WhereExist: Boolean;
begin
  Result := Assigned(FWhere);
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
  Result := Self.GetTable.IsClassFromField
            and (   (not Assigned(FWhere)) or (not FWhere.GetDisableClassFromField)   );
end;

function TioContext.Map: IioMap;
begin
  Result := FMap;
end;

function TioContext.ObjStatusExist: Boolean;
begin
  Result := Self.Map.ObjStatusExist;
end;

end.
