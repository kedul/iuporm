unit IupOrm.Context.Properties;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.CommonTypes,
  IupOrm.Attributes,
  IupOrm.SqlItems,
  System.Rtti,
  System.Generics.Collections;

type

  // Classe che rappresenta una proprietà
  TioProperty = class (TInterfacedObject, IioContextProperty)
  strict private
    FRttiProperty: TRttiProperty;
    FSqlFieldName: String;
    FFieldType: String;
    FRelationType: TioRelationType;
    FRelationChildClassRef: TioClassRef;
    FRelationChildPropertyName: String;
  public
    constructor Create(ARttiProperty:TRttiProperty; ASqlFieldName:String; AFieldType:String; ARelationType:TioRelationType; ARelationChildClassRef:TioClassRef; ARelationChildPropertyName:String);
    function GetName: String;
    function GetSqlFieldName: String;
    function GetSqlParamName: String;
    function GetFieldType: String;
    function IsBlob: Boolean;
    function GetValue(Instance: Pointer): TValue;
    procedure SetValue(Instance: Pointer; AValue:TValue);
    function GetSqlValue(ADataObject:TObject): String;
    function GetRttiProperty: TRttiProperty;
    function GetRelationType: TioRelationType;
    function GetRelationChildClassRef: TioClassRef;
    function GetRelationChildPropertyName: String;
    function GetRelationChildObject(Instance: Pointer): TObject;
    function GetRelationChildObjectID(Instance: Pointer): String;
  end;

  // Classe con l'elenco delle proprietà della classe
  TioProperties = class (TioSqlItem, IioContextProperties)
  strict private
    FPropertyItems: TList<IioContextProperty>;
    FIdProperty: IioContextProperty;
    FObjStatusProperty: IioContextProperty;
    FBlobFieldExists: Boolean;
  strict protected
    // ObjectStatus property
    function GetObjStatusProperty: IioContextProperty;
    procedure SetObjStatusProperty(AValue: IioContextProperty);
  public
    constructor Create;
    destructor Destroy; override;
    function GetEnumerator
      : TEnumerator<IioContextProperty>;
    function GetSql: String; override;
    procedure Add(AProperty:IioContextProperty; AIsId:Boolean=False);
    function GetIdProperty:IioContextProperty;
    function GetPropertyByName(APropertyName:String): IioContextProperty;
    // Blob field present
    function BlobFieldExists: Boolean;
    // ObjectStatus Exist
    function ObjStatusExist: Boolean;
    // ObjectStatus property
    property ObjStatusProperty:IioContextProperty read GetObjStatusProperty write SetObjStatusProperty;
  end;


implementation

uses
  System.TypInfo, IupOrm.Context.Interfaces, IupOrm.Context.Factory,
  IupOrm.DB.Factory, IupOrm.Exceptions, System.SysUtils;

{ TioProperty }

constructor TioProperty.Create(ARttiProperty:TRttiProperty; ASqlFieldName:String; AFieldType:String;
ARelationType:TioRelationType; ARelationChildClassRef:TioClassRef;
ARelationChildPropertyName:String);
begin
  FRttiProperty := ARttiProperty;
  FSqlFieldName := ASqlFieldName;
  FFieldType := AFieldType;
  // Relation fields
  FRelationType := ARelationType;
  FRelationChildClassRef := ARelationChildClassRef;
  FRelationChildPropertyName := ARelationChildPropertyName;
end;

function TioProperty.GetFieldType: String;
begin
  if FFieldType.IsEmpty
    then Result := TioDbFactory.SqlDataConverter.PropertyToFieldType(Self)
    else Result := FFieldType;
end;

function TioProperty.GetName: String;
begin
  Result := FRttiProperty.Name;
end;

function TioProperty.GetRelationChildClassRef: TioClassRef;
begin
  Result := FRelationChildClassRef;
end;

function TioProperty.GetRelationChildObject(Instance: Pointer): TObject;
var
  AValue: TValue;
begin
  // Init
  Result := nil;
  // Extract the child related object
  AValue := Self.GetValue(Instance);
  case AValue.TypeInfo.Kind of
    tkClass: Result := AValue.AsObject;
    tkInterface: Result := AValue.AsInterface As TObject;
  end;
end;

function TioProperty.GetRelationChildObjectID(Instance: Pointer): String;
var
  ChildContext: IioContext;
  ChildObject: TObject;
  AValue: TValue;
begin
  // Init
  Result := 'NULL';
  // Extract the child related object
  ChildObject := Self.GetRelationChildObject(Instance);
  // If the related child object non exists then exit (return 'NULL')
  if not Assigned(ChildObject) then Exit;
  // Else create the ioContext for the object and return the ID
  ChildContext := TioContextFactory.Context(ChildObject.ClassName, nil);
  Result := ChildContext.GetProperties.GetIdProperty.GetSqlValue(ChildObject);
end;

function TioProperty.GetRelationChildPropertyName: String;
begin
  Result := FRelationChildPropertyName;
end;

function TioProperty.GetRelationType: TioRelationType;
begin
  Result := FRelationType;
end;

function TioProperty.GetRttiProperty: TRttiProperty;
begin
  Result := FRttiProperty;
end;

function TioProperty.GetSqlFieldName: String;
begin
  Result := FSqlFieldName;
end;

function TioProperty.GetSqlParamName: String;
begin
  Result := 'P_' + Self.GetSqlFieldName;
end;

function TioProperty.GetSqlValue(ADataObject:TObject): String;
begin
  Result := TioDbFactory.SqlDataConverter.TValueToSql(Self.GetValue(ADataObject));
end;

function TioProperty.GetValue(Instance: Pointer): TValue;
begin
  Result := FRttiProperty.GetValue(Instance);
end;

function TioProperty.IsBlob: Boolean;
begin
  Result := Self.GetFieldType.StartsWith('BLOB');
end;

procedure TioProperty.SetValue(Instance: Pointer; AValue: TValue);
begin
  FRttiProperty.SetValue(Instance, AValue);
end;

{ TioProperties }

procedure TioProperties.Add(AProperty: IioContextProperty; AIsId: Boolean);
begin
  FPropertyItems.Add(AProperty);
  if AIsId then FIdProperty := AProperty;
  if AProperty.IsBlob then Self.FBlobFieldExists := True;
end;

function TioProperties.BlobFieldExists: Boolean;
begin
  Result := FBlobFieldExists;
end;

constructor TioProperties.Create;
begin
  FBlobFieldExists := False;
  FObjStatusProperty := nil;
  FPropertyItems := TList<IioContextProperty>.Create;
end;

destructor TioProperties.Destroy;
begin
  FPropertyItems.Free;
  inherited;
end;

function TioProperties.GetEnumerator
  : TEnumerator<IioContextProperty>;
begin
  Result := FPropertyItems.GetEnumerator;
end;

function TioProperties.GetIdProperty: IioContextProperty;
begin
  Result := FIdProperty;
end;

function TioProperties.GetObjStatusProperty: IioContextProperty;
begin
  Result := FObjStatusProperty;
end;

function TioProperties.GetPropertyByName(
  APropertyName: String): IioContextProperty;
var
  CurrProp: IioContextProperty;
begin
  for CurrProp in FPropertyItems do if CurrProp.GetName.ToUpper.Equals(APropertyName.ToUpper) then
  begin
      Result := CurrProp;
      Exit;
  end;
  raise EIupOrmException.Create(Self.ClassName +  ': Context property "' + APropertyName + '" not found');
end;

function TioProperties.GetSql: String;
var
  Prop: IioContextProperty;
begin
  for Prop in FPropertyItems do
  begin
    // If current prop is a list of HasMany related objects skip this property
    if Prop.GetRelationType = ioRTHasMany then Continue;
    // Add the current property
    if Result <> '' then Result := Result + ', ';
    Result := Result + Prop.GetSqlFieldName;
  end;
end;


function TioProperties.ObjStatusExist: Boolean;
begin
  Result := Assigned(FObjStatusProperty);
end;

procedure TioProperties.SetObjStatusProperty(AValue: IioContextProperty);
begin
  FObjStatusProperty := AValue;
end;

end.
