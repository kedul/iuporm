unit IupOrm.Context.Map;

interface

uses
  IupOrm.CommonTypes, IupOrm.Context.Table.Interfaces,
  IupOrm.Context.Properties.Interfaces, System.Rtti,
  IupOrm.Context.Map.Interfaces;

type

  TioMap = class(TInterfacedObject, IioMap)
  strict private
    FClassRef: TioClassRef;
    FTable: IioContextTable;
    FProperties: IioContextProperties;
    FRttiContext: TRttiContext;
    FRttiType: TRttiInstanceType;
    FAncestorMap: IioMap;
  strict protected
  public
    constructor Create(AClassRef:TioClassRef; ARttiContext:TRttiContext; ARttiType:TRttiInstanceType; ATable:IioContextTable; AProperties:IioContextProperties); overload;
    function GetClassRef: TioClassRef;
    function GetTable: IioContextTable;
    function GetProperties: IioContextProperties;
    function ClassFromField: IioClassFromField;
    function RttiContext: TRttiContext;
    function RttiType: TRttiInstanceType;
    // ObjStatusExist
    function ObjStatusExist: Boolean;
    // Blob field present
    function BlobFieldExists: Boolean;
    // Reference to a map of the ancestor if the ancestor itself is mapped (is an entity)
    function AncestorMap: Iiomap;
    // True if the class has a mapped ancestor (the ancestor is even an entity)
    function HasMappedAncestor: Boolean;
  end;

implementation

uses
  IupOrm.Context.Container;

{ TioMap }

function TioMap.AncestorMap: Iiomap;
begin
  Result := FAncestorMap;
end;

function TioMap.BlobFieldExists: Boolean;
begin
  Result := FProperties.BlobFieldExists;
end;

function TioMap.ClassFromField: IioClassFromField;
begin
  Result := FTable.GetClassFromField;
end;

constructor TioMap.Create(AClassRef: TioClassRef; ARttiContext: TRttiContext;
  ARttiType: TRttiInstanceType; ATable: IioContextTable;
  AProperties: IioContextProperties);
begin
  inherited Create;
  FClassRef := AClassRef;
  FRttiContext := ARttiContext;
  FRttiType := ARttiType;
  FTable := ATable;
  // Set properties
  FProperties := AProperties;
  FProperties.SetTable(FTable);
  // Reference to a map of the ancestor if the ancestor itself is mapped (is an entity)
  //  NB: The second parameter must be False
  FAncestorMap := TioMapContainer.GetMap(ARttiType.BaseType.Name, False);
end;

function TioMap.GetClassRef: TioClassRef;
begin
  Result := FClassRef;
end;

function TioMap.GetProperties: IioContextProperties;
begin
  Result := FProperties;
end;

function TioMap.GetTable: IioContextTable;
begin
  Result := FTable;
end;

function TioMap.HasMappedAncestor: Boolean;
begin
  Result := Assigned(FAncestorMap);
end;

function TioMap.ObjStatusExist: Boolean;
begin
  Result := Self.GetProperties.ObjStatusExist;
end;

function TioMap.RttiContext: TRttiContext;
begin
  Result := FRttiContext;
end;

function TioMap.RttiType: TRttiInstanceType;
begin
  Result := FRttiType;
end;

end.
