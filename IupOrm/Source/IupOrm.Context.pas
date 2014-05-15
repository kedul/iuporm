unit IupOrm.Context;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.Context.Interfaces,
  IupOrm.CommonTypes,
  IupOrm.Where, IupOrm.Context.Table.Interfaces, System.Rtti;

type

  TioContext = class(TInterfacedObject, IioContext)
  strict private
    FClassRef: TioClassRef;
    FDataObject: TObject;
    FTable: IioContextTable;
    FProperties: IioContextProperties;
    FWhere: TioWhere;
    FSelfCreatedWhere: Boolean;
    FRttiContext: TRttiContext;
    FRttiType: TRttiInstanceType;
  strict protected
    // DataObject
    function GetDataObject: TObject;
    procedure SetDataObject(AValue: TObject);
    // ObjectStatus
    function GetObjectStatus: TIupOrmObjectStatus;
    procedure SetObjectStatus(AValue: TIupOrmObjectStatus);
  public
    constructor Create(AClassRef:TioClassRef; ARttiContext:TRttiContext; ARttiType:TRttiInstanceType; ATable:IioContextTable; AProperties:IioContextProperties; AWhere:TioWhere; ADataObject:TObject=nil); overload;
    destructor Destroy; override;
    function GetClassRef: TioClassRef;
    function GetTable: IioContextTable;
    function GetProperties: IioContextProperties;
    function GetWhere: TioWhere;
    function ClassFromField: IioClassFromField;
    function IsClassFromField: Boolean;
    function RttiContext: TRttiContext;
    function RttiType: TRttiInstanceType;
    // Blob field present
    function BlobFieldExists: Boolean;
    // DataObject
    property DataObject:TObject read GetDataObject write SetDataObject;
    // ObjectStatus
    property ObjectStatus:TIupOrmObjectStatus read GetObjectStatus write SetObjectStatus;
  end;

implementation

uses
  IupOrm.Context.Factory, IupOrm.DB.Factory, System.TypInfo;

{ TioContext }

function TioContext.BlobFieldExists: Boolean;
begin
  Result := Self.GetProperties.BlobFieldExists;
end;

function TioContext.ClassFromField: IioClassFromField;
begin
  Result := FTable.GetClassFromField;
end;

constructor TioContext.Create(AClassRef: TioClassRef; ARttiContext:TRttiContext;
  ARttiType:TRttiInstanceType; ATable: IioContextTable;
  AProperties: IioContextProperties; AWhere: TioWhere; ADataObject: TObject);
begin
  inherited Create;
  FSelfCreatedWhere := False;
  FClassRef := AClassRef;
  FRttiContext := ARttiContext;
  FRttiType := ARttiType;
  FTable := ATable;
  FProperties := AProperties;
  FDataObject := ADataObject;
  // Create TioWhere if nil
  if not Assigned(AWhere)then
  begin
    FSelfCreatedWhere := True;
    AWhere := TioContextFactory.Where;
    if Assigned(ADataObject)
      then AWhere.Add(AProperties.GetIdProperty.GetSqlFieldName + TioDbFactory.CompareOperator._Equal.GetSql + AProperties.GetIdProperty.GetSqlValue(ADataObject));
  end;
  // Add ContextProperties to TioWhere and assign it to the field
  AWhere.SetContextProperties(FProperties);
  FWhere := AWhere;
end;

destructor TioContext.Destroy;
begin
  if FSelfCreatedWhere then FWhere.Free;
  inherited;
end;

function TioContext.GetClassRef: TioClassRef;
begin
  Result := FClassRef;
end;

function TioContext.GetDataObject: TObject;
begin
  Result := FDataObject;
end;

function TioContext.GetObjectStatus: TIupOrmObjectStatus;
begin
  if FProperties.ObjStatusExist
    then Result := TIupOrmObjectStatus(   FProperties.ObjStatusProperty.GetValue(Self.FDataObject).AsOrdinal   )
    else Result := osDirty;
end;

function TioContext.GetProperties: IioContextProperties;
begin
  Result := FProperties;
end;

function TioContext.RttiContext: TRttiContext;
begin
  Result := FRttiContext;
end;

function TioContext.RttiType: TRttiInstanceType;
begin
  Result := FRttiType;
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
  FProperties.ObjStatusProperty.SetValue(Self.FDataObject, PropValue);
end;

function TioContext.GetTable: IioContextTable;
begin
  Result := FTable;
end;

function TioContext.GetWhere: TioWhere;
begin
  Result := FWhere;
end;

function TioContext.IsClassFromField: Boolean;
begin
  Result := FTable.IsClassFromField and not FWhere.GetDisableClassFromField;
end;

end.
