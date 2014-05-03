unit IupOrm.Where.SqlItems;

interface

uses
  IupOrm.SqlItems,
  IupOrm.Where.SqlItems.Interfaces,
  IupOrm.Context.Properties.Interfaces,
  System.Rtti;

type

  // Base class for specialized SqlItemWhere needing reference ContextProperties
  TioSqlItemsWhere = class(TioSqlItem, IioSqlItemWhere)
  strict protected
    FContextProperties: IioContextProperties;
  public
    procedure SetContextProperties(AContextProperties: IioContextProperties);
  end;

  // Specialized SqlItemWhere for property (PropertyName to FieldName)
  //  NB: Property.Name is in FSqlText ancestor field
  TioSqlItemsWhereProperty = class(TioSqlItemsWhere)
  public
    function GetSql: String; override;
  end;

  // Specialized SqlItemWhere for OID property of the referenced class
  //  return che OID property sql field name
  TioSqlItemsWherePropertyOID = class(TioSqlItemsWhereProperty)
  public
    constructor Create; overload;
    function GetSql: String; override;
  end;

  // Specialized SqlItemWhere returning an SQL compatible repreentation
  //  of TValue
  TioSqlItemsWhereTValue = class(TioSqlItemsWhere)
  strict private
    FValue: TValue;
  public
    constructor Create(ASqlText:String); overload;  // raise exception
    constructor Create(AValue:TValue); overload;
    function GetSql: String; override;
  end;

implementation

uses
  IupOrm.Exceptions, IupOrm.DB.Factory;

{ TioSqlItemsWhereValue }

constructor TioSqlItemsWhereTValue.Create(AValue: TValue);
begin
  FValue := AValue;
end;

constructor TioSqlItemsWhereTValue.Create(ASqlText: String);
begin
  EIupOrmException.Create('TioSqlItemsWhereValue wrong constructor called');
end;

function TioSqlItemsWhereTValue.GetSql: String;
begin
  // NB: No inherited
  Result := TioDBFactory.SqlDataConverter.TValueToSql(FValue);
end;

{ TioSqlItemsWhereProperty }

function TioSqlItemsWhereProperty.GetSql: String;
begin
  // NB: No inherited
  Result := FContextProperties.GetPropertyByName(Self.FSqlText).GetSqlFieldName;
end;

{ TioSqlItemsWhere }

procedure TioSqlItemsWhere.SetContextProperties(
  AContextProperties: IioContextProperties);
begin
  FContextProperties := AContextProperties;
end;

{ TioSqlItemsWherePropertyOID }

constructor TioSqlItemsWherePropertyOID.Create;
begin
  // Nothing
end;

function TioSqlItemsWherePropertyOID.GetSql: String;
begin
  Result := FContextProperties.GetIdProperty.GetSqlFieldName;
end;

end.
