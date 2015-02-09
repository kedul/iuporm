unit IupOrm.Context.Properties;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.CommonTypes,
  IupOrm.Attributes,
  IupOrm.SqlItems,
  System.Rtti,
  System.Generics.Collections, IupOrm.Context.Table.Interfaces;

type

  // Classe che rappresenta una proprietà
  TioProperty = class (TInterfacedObject, IioContextProperty)
  strict private
    FIsID: Boolean;
    FRttiProperty: TRttiProperty;
    FFieldDefinitionString, FSqlFieldTableName, FSqlFieldName, FSqlFieldAlias: String;
    FQualifiedSqlFieldName: String;
    FFullQualifiedSqlFieldName: String;
    FLoadSql: String;
    FFieldType: String;
    FRelationType: TioRelationType;
    FRelationChildClassRef: TioClassRef;
    FRelationChildPropertyName: String;
    FRelationLoadType: TioLoadType;
    FTable:IioContextTable;
    FReadWrite: TioReadWrite;
    FEmbedded: Boolean;
    // NB: Gli altri due attributes (ioEmbeddedSkip e ioEmbeddedStreamable) non sono necessari qui
    //      perchè li usa solo l'ObjectsMappers al suo interno, iupORM non li usa
  public
    constructor Create(ARttiProperty:TRttiProperty; AFieldDefinitionString:String; ALoadSql:String; AFieldType:String; AReadWrite:TioReadWrite; ARelationType:TioRelationType; ARelationChildClassRef:TioClassRef; ARelationChildPropertyName:String; ARelationLoadType:TioLoadType);
    function GetLoadSql: String;
    function LoadSqlExist: Boolean;
    function GetName: String;
    function GetSqlQualifiedFieldName: String;
    function GetSqlFullQualifiedFieldName: String;
    function GetSqlFieldTableName: String;
    function GetSqlFieldName: String;
    function GetSqlFieldAlias: String;
    function GetSqlParamName: String;
    function GetFieldType: String;
    function IsBlob: Boolean;
    function IsStream: Boolean;
    function GetValue(Instance: Pointer): TValue;
    procedure SetValue(Instance: Pointer; AValue:TValue);
    function GetSqlValue(ADataObject:TObject): String;
    function GetRttiProperty: TRttiProperty;
    function GetRelationType: TioRelationType;
    function GetRelationChildClassRef: TioClassRef;
    function GetRelationChildPropertyName: String;
    function GetRelationLoadType: TioLoadType;
    function GetRelationChildObject(Instance: Pointer): TObject;
    function GetRelationChildObjectID(Instance: Pointer): String;
    procedure SetTable(ATable:IioContextTable);
    procedure SetFieldData;
    procedure SetLoadSqlData;
    function IsSqlRequestCompliant(ASqlRequestType:TioSqlRequestType): Boolean;
    procedure SetIsID(AValue:Boolean);
    function IsID: Boolean;
    function IsWriteEnabled: Boolean;
    function IsReadEnabled: Boolean;
    function IsEmbedded: Boolean;
  end;

  // Classe con l'elenco delle proprietà della classe
  TioPropertiesGetSqlFunction = reference to function(AProperty:IioContextProperty):String;
  TioProperties = class (TioSqlItem, IioContextProperties)
  strict private
    FPropertyItems: TList<IioContextProperty>;
    FIdProperty: IioContextProperty;
    FObjStatusProperty: IioContextProperty;
    FBlobFieldExists: Boolean;
  strict protected
    function InternalGetSql(ASqlRequestType:TioSqlRequestType; AFunc:TioPropertiesGetSqlFunction): String;
    // ObjectStatus property
    function GetObjStatusProperty: IioContextProperty;
    procedure SetObjStatusProperty(AValue: IioContextProperty);
  public
    constructor Create;
    destructor Destroy; override;
    function GetEnumerator
      : TEnumerator<IioContextProperty>;
    function GetSql: String; overload;
    function GetSql(ASqlRequestType:TioSqlRequestType=ioAll): String; overload;
    procedure Add(AProperty:IioContextProperty; AIsId:Boolean=False);
    function GetIdProperty:IioContextProperty;
    function GetPropertyByName(APropertyName:String): IioContextProperty;
    procedure SetTable(ATable:IioContextTable);
    procedure SetFieldData;
    procedure SetLoadSqlData;
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
  IupOrm.DB.Factory, IupOrm.Exceptions, System.SysUtils, IupOrm.SqlTranslator,
  System.StrUtils, System.Classes;

{ TioProperty }

constructor TioProperty.Create(ARttiProperty:TRttiProperty; AFieldDefinitionString:String; ALoadSql:String; AFieldType:String;
AReadWrite:TioReadWrite; ARelationType:TioRelationType; ARelationChildClassRef:TioClassRef;
ARelationChildPropertyName:String; ARelationLoadType:TioLoadType);
begin
  FRttiProperty := ARttiProperty;
  FFieldDefinitionString := AFieldDefinitionString;
  FFieldType := AFieldType;
  FReadWrite := AReadWrite;
  FLoadSql := ALoadSql;
  // Relation fields
  FRelationType := ARelationType;
  FRelationChildClassRef := ARelationChildClassRef;
  FRelationChildPropertyName := ARelationChildPropertyName;
  FRelationLoadType := ARelationLoadType;
end;

function TioProperty.GetFieldType: String;
begin
  if FFieldType.IsEmpty
    then Result := TioDbFactory.SqlDataConverter.PropertyToFieldType(Self)
    else Result := FFieldType;
end;

function TioProperty.GetLoadSql: String;
begin
  Result := '(' + Self.FLoadSql + ') AS ' + Self.GetSqlFieldAlias;
end;

function TioProperty.GetSqlFullQualifiedFieldName: String;
begin
  Result := FFullQualifiedSqlFieldName;
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

function TioProperty.GetRelationLoadType: TioLoadType;
begin
  Result := FRelationLoadType;
end;

function TioProperty.GetRelationType: TioRelationType;
begin
  Result := FRelationType;
end;

function TioProperty.GetRttiProperty: TRttiProperty;
begin
  Result := FRttiProperty;
end;

function TioProperty.GetSqlFieldAlias: String;
begin
  Result := FSqlFieldAlias;
end;

function TioProperty.GetSqlFieldName: String;
begin
  Result := FSqlFieldName;
end;

function TioProperty.GetSqlFieldTableName: String;
begin
  Result := FSqlFieldTableName;
end;

function TioProperty.GetSqlQualifiedFieldName: String;
begin
  Result := FQualifiedSqlFieldName;
end;

function TioProperty.GetSqlParamName: String;
begin
  Result := 'P_' + Self.GetSqlFieldAlias;
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
  Result := (FRelationType = ioRTNone) and Self.GetFieldType.StartsWith('BLOB');
end;

function TioProperty.IsEmbedded: Boolean;
begin
  Result := Self.FEmbedded;
end;

function TioProperty.IsID: Boolean;
begin
  Result := FIsID;
end;

function TioProperty.IsReadEnabled: Boolean;
begin
  Result := (FReadWrite <= iorwReadWrite);
end;

function TioProperty.IsSqlRequestCompliant(
  ASqlRequestType: TioSqlRequestType): Boolean;
begin
  Result := False;
  case ASqlRequestType of
    ioSelect: Result := (FReadWrite <= iorwReadWrite);
    ioInsert: Result := (FReadWrite >= iorwReadWrite);
    ioUpdate: Result := (FReadWrite >= iorwReadWrite);
  else Result := True;
  end;
end;

function TioProperty.IsStream: Boolean;
begin
  Result := (Self.GetRttiProperty.PropertyType.IsInstance)
        and (Self.GetRttiProperty.PropertyType.AsInstance.InheritsFrom(TSTream));
end;

function TioProperty.IsWriteEnabled: Boolean;
begin
  Result := (FReadWrite >= iorwReadWrite);
end;

function TioProperty.LoadSqlExist: Boolean;
begin
  Result := Self.FLoadSql <> '';
end;

procedure TioProperty.SetFieldData;
var
  DotPos, AsPos: Smallint;
  AValue: String;
begin
  AValue := FFieldDefinitionString;
  // Translate (if contains tags)
  AValue := TioSqlTranslator.Translate(AValue);
  // Retrieve the markers position
  DotPos := Pos('.', AValue);
  AsPos := Pos(' AS ', AValue, DotPos);
  if AsPos = 0 then AsPos := AValue.Length+1;
  // Retrieve Table reference
  FSqlFieldTableName := LeftStr(AValue, DotPos-1);
  if FSqlFieldTableName = '' then FSqlFieldTableName := FTable.TableName;
  // Retrieve FieldName
  FSqlFieldName := MidStr(AValue, DotPos+1, AsPos-DotPos-1);
  // Retrieve Field Alias
  FSqlFieldAlias := MidStr(AValue, AsPos+4, AValue.Length);
  if FSqlFieldAlias = '' then FSqlFieldAlias := FSqlFieldTableName + '_' + FSqlFieldName;
  // Set QualifiedFieldName
  FQualifiedSqlFieldName := FSqlFieldTableName + '.' + FSqlFieldName;
  // Set FullQualifiedFieldName
  FFullQualifiedSqlFieldName := FQualifiedSqlFieldName + ' AS ' + FSqlFieldAlias;
end;

procedure TioProperty.SetIsID(AValue: Boolean);
begin
  FisID := AValue;
end;

procedure TioProperty.SetLoadSqlData;
begin
  // Set LoadSql statement (if exist)
  if Self.FLoadSql <> ''
    then FLoadSql := TioSqlTranslator.Translate(FLoadSql);
end;

procedure TioProperty.SetTable(ATable: IioContextTable);
begin
  FTable := ATable;
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
  AProperty.SetIsID(AIsId);
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
begin
  // Use Internal function with an anonomous method
  Result := Self.InternalGetSql(
    ioAll,
    function (AProp:IioCOntextProperty): String
    begin
      Result := AProp.GetSqlFieldName;
    end
  );
end;


function TioProperties.GetSql(ASqlRequestType: TioSqlRequestType): String;
var
  AFunc: TioPropertiesGetSqlFunction;
begin
  // Get the function by ASqlRequestType value
  case ASqlRequestType of
    ioSelect: AFunc := function (AProp:IioCOntextProperty): String
                       begin
                         if AProp.LoadSqlExist
                           then Result := AProp.GetLoadSql
                           else Result := AProp.GetSqlFullQualifiedFieldName;
                       end;
  else AFunc := function (AProp:IioCOntextProperty): String
                begin
                  Result := AProp.GetSqlFieldName;
                end;
  end;
  // Use Internal function with an anonomous method
  Result := Self.InternalGetSql(ASqlRequestType, AFunc);
end;

function TioProperties.InternalGetSql(ASqlRequestType:TioSqlRequestType;
  AFunc: TioPropertiesGetSqlFunction): String;
var
  Prop: IioContextProperty;
begin
  for Prop in FPropertyItems do
  begin
    // If the property is not compliant with the request then skip it
    if not Prop.IsSqlRequestCompliant(ASqlRequestType) then Continue;
    // If current prop is a list of HasMany related objects skip this property
    if Prop.GetRelationType = ioRTHasMany then Continue;
    // Add the current property
    if Result <> '' then Result := Result + ', ';
    Result := Result + AFunc(Prop);
  end;
end;

function TioProperties.ObjStatusExist: Boolean;
begin
  Result := Assigned(FObjStatusProperty);
end;

procedure TioProperties.SetFieldData;
var
  AProperty: IioContextProperty;
begin
  for AProperty in FPropertyItems
    do AProperty.SetFieldData;
end;

procedure TioProperties.SetLoadSqlData;
var
  AProperty: IioContextProperty;
begin
  for AProperty in FPropertyItems
    do AProperty.SetLoadSqlData;
end;

procedure TioProperties.SetObjStatusProperty(AValue: IioContextProperty);
begin
  FObjStatusProperty := AValue;
end;

procedure TioProperties.SetTable(ATable: IioContextTable);
var
  AProperty: IioContextProperty;
begin
  for AProperty in FPropertyItems do
    AProperty.SetTable(ATable);
end;

end.
