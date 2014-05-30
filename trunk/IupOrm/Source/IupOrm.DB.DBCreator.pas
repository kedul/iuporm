unit IupOrm.DB.DBCreator;

interface

uses
  IupOrm.DB.DBCreator.Interfaces, System.Generics.Collections, System.Rtti,
  IupOrm.DB.Interfaces, IupOrm.Context.Properties.Interfaces;

type

  TioDBCreatorField = class(TInterfacedObject, IioDBCreatorField)
  strict private
    FFieldName: String;
    FIsKeyField: Boolean;
    FProperty: IioContextProperty;
    FSqlGenerator: IioDBCreatorSqlGenerator;
    FDBFieldExist: Boolean;
    FDBFieldSameType: Boolean;
    FIsClassFromField: Boolean;
  strict protected
    // FieldName
    function GetFieldName: String;
    // FieldType
    function GetFieldType: String;
    // IsKeyFeld
    function GetIsKeyField: Boolean;
    // DBFieldExists
    procedure SetDBFieldExist(AValue:Boolean);
    function GetDBFieldExist: Boolean;
    // DBFieldSameType
    procedure SetDBFieldSameType(AValue:Boolean);
    function GetDBFieldSameType: Boolean;
    // IsClassFromFIeld
    function GetIsClassFromField: Boolean;
    property IsClassFromField:Boolean read GetIsClassFromField;
  public
    constructor Create(AFieldName:String; AIsKeyField:Boolean; AProperty:IioContextProperty; ASqlGenerator:IioDBCreatorSqlGenerator; AIsClassFromField:Boolean);
    property FieldName:String read GetFieldName;
    property FieldType:String read GetFieldType;
    property IsKeyField:Boolean read GetIsKeyField;
    property DBFieldExist:Boolean read GetDBFieldExist write SetDBFieldExist;
    property DBFieldSameType:Boolean read GetDBFieldSameType write SetDBFieldSameType;
    // Rtti property reference
    function GetProperty: IioContextProperty;
  end;

  TioDBCreatorTable = class(TInterfacedObject, IioDBCreatorTable)
  strict private
    FTableName: String;
    FFields: TioDBCreatorFieldList;
    FIsClassFromField: Boolean;
    FSqlGenerator: IioDBCreatorSqlGenerator;
  strict protected
    // TableName
    function GetTableName: String;
    Procedure SetTableName(AValue:String);
    // Fields
    function GetFields: TioDBCreatorFieldList;
    // TableState
    function TableState: TioDBCreatorTableState;
    // IsClassFromField
    function IsClassFromField: Boolean;
  public
    constructor Create(ATableName:String; AIsClassFromField:Boolean; ASqlGenerator:IioDBCreatorSqlGenerator);
    destructor Destroy; override;
    function FieldExists(AFieldName:String): Boolean;
    function IDField: IioDBCreatorField;
    property TableName:String read GetTableName write SetTableName;
    property Fields:TioDBCreatorFieldList read GetFields;
  end;

  TioDBCreator = class(TInterfacedObject, IioDBCreator)
  strict private
    FTables: TioDBCreatorTableList;
    FSqlGenerator: IioDBCreatorSqlGenerator;
  strict protected
    function FindOrCreateTable(ATableName:String; AIsClassFromField:Boolean): IioDBCreatorTable;
    procedure LoadTableStructureFromRtti(ARttiContext:TRttiContext; ARttiType:TRttiInstanceType);
    function IsValidEntity(AType:TRttiInstanceType): Boolean;
    procedure LoadDBStructureFromRtti;
  public
    constructor Create(ASqlGenerator:IioDBCreatorSqlGenerator); overload;
    destructor Destroy; override;
    procedure AutoCreateDatabase;
    function Tables: TioDBCreatorTableList;
  end;


implementation

uses
  IupOrm.Attributes, IupOrm.DB.DBCreator.Factory, IupOrm.Context.Interfaces,
  IupOrm.Context.Factory, System.SysUtils,
  IupOrm.CommonTypes, IupOrm.RttiContext.Factory;

{ TioDBCreatorField }

constructor TioDBCreatorField.Create(AFieldName: String; AIsKeyField: Boolean; AProperty:IioContextProperty; ASqlGenerator:IioDBCreatorSqlGenerator; AIsClassFromField:Boolean);
begin
  FSqlGenerator := ASqlGenerator;
  FFieldName := AFieldName;
  FIsKeyField := AIsKeyField;
  FProperty := AProperty;
  FDBFieldExist := False;
  FDBFieldSameType := False;
  FIsClassFromField := AIsClassFromField;
end;

function TioDBCreatorField.GetDBFieldExist: Boolean;
begin
  Result := FDBFieldExist;
end;

function TioDBCreatorField.GetDBFieldSameType: Boolean;
begin
  Result := FDBFieldSameType;
end;

function TioDBCreatorField.GetFieldName: String;
begin
  Result := FFieldName;
end;

function TioDBCreatorField.GetFieldType: String;
begin
  if Self.IsClassFromField
    then Result := TioDBCreatorFactory.GetSqlGenerator.GetClassFromFieldColumnType
    else Result := FProperty.GetFieldType;
end;

function TioDBCreatorField.GetIsClassFromField: Boolean;
begin
  Result := FIsClassFromField;
end;

function TioDBCreatorField.GetIsKeyField: Boolean;
begin
  Result := FIsKeyField;
end;

function TioDBCreatorField.GetProperty: IioContextProperty;
begin
  Result := FProperty;
end;

procedure TioDBCreatorField.SetDBFieldExist(AValue: Boolean);
begin
  FDBFieldExist := AValue;
end;

procedure TioDBCreatorField.SetDBFieldSameType(AValue: Boolean);
begin
  FDBFieldSameType := AValue;
end;

{ TioDBCreatorTable }

constructor TioDBCreatorTable.Create(ATableName: String; AIsClassFromField:Boolean; ASqlGenerator:IioDBCreatorSqlGenerator);
begin
  FSqlGenerator := ASqlGenerator;
  FTableName := ATableName;
  FIsClassFromField := AIsClassFromField;
  FFields := TioDBCreatorFieldList.Create;
end;

destructor TioDBCreatorTable.Destroy;
begin
  FFields.Free;
  inherited;
end;

function TioDBCreatorTable.FieldExists(AFieldName: String): Boolean;
begin
  Result := FFields.ContainsKey(AFieldName);
end;

function TioDBCreatorTable.GetFields: TioDBCreatorFieldList;
begin
  Result := FFields;
end;

function TioDBCreatorTable.GetTableName: String;
begin
  Result := FTableName;
end;

function TioDBCreatorTable.IDField: IioDBCreatorField;
var
  AField: IioDBCreatorField;
begin
  Result := nil;
  for AField in Self.Fields.Values do
    if AField.IsKeyField then
    begin
      Result := AField;
      Exit;
    end;
end;

function TioDBCreatorTable.IsClassFromField: Boolean;
begin
  Result := FIsClassFromField;
end;

procedure TioDBCreatorTable.SetTableName(AValue: String);
begin
  FTableName := AValue;
end;

function TioDBCreatorTable.TableState: TioDBCreatorTableState;
var
  AField: IioDBCreatorField;
begin
  Result := tsOk;
  // Check if tsNewTable
  if not FSqlGenerator.TableExists(Self) then
  begin
    Result := tsNew;
    Exit;
  end;
  // Check if tsModified
  for AField in Fields.Values do
  begin
    FSqlGenerator.LoadFieldsState(Self);
    if (not AField.DBFieldExist) or (not AField.DBFieldSameType) then
    begin
      Result := tsModified;
      Exit;
    end;
  end;
end;

{ TioDBCreator }

procedure TioDBCreator.AutoCreateDatabase;
var
  ATable: IioDBCreatorTable;
begin
  // Build DB structure analizing Rtti informations
  Self.LoadDBStructureFromRtti;
  // Create or restructure database
  FSqlGenerator.AutoCreateDatabase(Self);
end;

constructor TioDBCreator.Create(ASqlGenerator:IioDBCreatorSqlGenerator);
begin
  inherited Create;
  FSqlGenerator := ASqlGenerator;
  FTables := TioDBCreatorTableList.Create;
end;

procedure TioDBCreator.LoadDBStructureFromRtti;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
  Inst: TRttiInstanceType;
begin
  Ctx := TioRttiContextFactory.RttiContext;
  for Typ in Ctx.GetTypes do
  begin
    // Only instance type
    if not (Typ is TRttiInstanceType) then Continue;
    Inst := TRttiInstanceType(Typ);
    // Only classes with explicit ioTable attribute
    if not Self.IsValidEntity(Inst) then Continue;
    // Load Table structure
    Self.LoadTableStructureFromRtti(Ctx, Inst);
  end;
end;

procedure TioDBCreator.LoadTableStructureFromRtti(ARttiContext: TRttiContext;
  ARttiType: TRttiInstanceType);
var
  AContext: IioContext;
  AProperty: IioContextProperty;
  ATable: IioDBCreatorTable;
  AField: IioDBCreatorField;
begin
  // Create the context
  AContext := TioContextFactory.Context(ARttiType.MetaclassType);
  // Find or Create Table
  ATable := Self.FindOrCreateTable(AContext.GetTable.TableName, AContext.GetTable.IsClassFromField);
  // Loop for properties
  for AProperty in AContext.GetProperties do
  begin
    // For creation purpose a HasMany or HasOne relation property
    //  must not create the field
    if (AProperty.GetRelationType = ioRTHasMany)
    or (AProperty.GetRelationType = ioRTHasOne)
      then Continue;
    // If not already exixts create and add it to the list
    if ATable.FieldExists(AProperty.GetSqlFieldName) then Continue;
    AField := TioDBCreatorFactory.GetField(AProperty.GetSqlFieldName
                                          ,(AProperty = AContext.GetProperties.GetIdProperty)
                                          ,AProperty
                                          ,FSqlGenerator
                                          ,False
                                          );
    ATable.Fields.Add(AField.FieldName, AField);
  end;
  // If ClassFromField is enabled then add the field
  if ATable.IsClassFromField then
  begin
    // If not already exixts create and add it to the list
    if ATable.FieldExists(IO_CLASSFROMFIELD_FIELDNAME) then Exit;
    AField := TioDBCreatorFactory.GetField(IO_CLASSFROMFIELD_FIELDNAME
                                          ,False
                                          ,nil
                                          ,FSqlGenerator
                                          ,True
                                          );
    ATable.Fields.Add(AField.FieldName, AField);
  end;
end;

function TioDBCreator.Tables: TioDBCreatorTableList;
begin
  Result := FTables;
end;

destructor TioDBCreator.Destroy;
begin
  FTables.Free;
  inherited;
end;

function TioDBCreator.FindOrCreateTable(ATableName: String; AIsClassFromField:Boolean): IioDBCreatorTable;
begin
  // If table is already present return it
  if Self.FTables.ContainsKey(ATableName) then
  begin
    Result := Self.FTables.Items[ATableName];
    Exit;
  end;
  // Otherwise create a new Table and add it to the list then return it
  Result := TioDBCreatorFactory.GetTable(ATableName, AIsClassFromField, FSqlGenerator);
  Self.FTables.Add(ATableName, Result);
end;

function TioDBCreator.IsValidEntity(AType: TRttiInstanceType): Boolean;
var
  Attr: TCustomAttribute;
begin
  Result := False;
  for Attr in AType.GetAttributes do
    if Attr is ioTable then
    begin
      Result := True;
      Exit;
    end;
end;

end.
