unit IupOrm.Where.SqlItems;

interface

uses
  IupOrm.SqlItems,
  IupOrm.Where.SqlItems.Interfaces,
  IupOrm.Context.Properties.Interfaces,
  System.Rtti, IupOrm.Where;

type

  // Base class for specialized SqlItemWhere needing reference ContextProperties
  TioSqlItemsWhere = class(TioSqlItem, IioSqlItemWhere)
  public
    function GetSql(AProperties:IioContextProperties): String; reintroduce; virtual; abstract;
    function GetSqlParamName(AProperties:IioContextProperties): String; virtual;
    function GetValue(AProperties:IioContextProperties): TValue; virtual;
    function HasParameter: Boolean; virtual; abstract;
  end;

  // Specialized SqlItemWhere for property (PropertyName to FieldName)
  //  NB: Property.Name is in FSqlText ancestor field
  TioSqlItemsWhereProperty = class(TioSqlItemsWhere)
  public
    function GetSql(AProperties:IioContextProperties): String; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere for OID property of the referenced class
  //  return che OID property sql field name
  TioSqlItemsWherePropertyOID = class(TioSqlItemsWhereProperty)
  public
    constructor Create; overload;
    function GetSql(AProperties:IioContextProperties): String; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere returning an SQL compatible repreentation
  //  of TValue
  TioSqlItemsWhereTValue = class(TioSqlItemsWhere)
  strict private
    FValue: TValue;
  public
    constructor Create(ASqlText:String); overload;  // raise exception
    constructor Create(AValue:TValue); overload;
    function GetSql(AProperties:IioContextProperties): String; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere for text conditions with tags translating
  //  property to fieldname
  TioSqlItemsWhereText  = class(TioSqlItemsWhere)
  public
    function GetSql(AProperties:IioContextProperties): String; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere for property equals to for param (best for internal use)
  TioSqlItemsWherePropertyEqualsTo = class(TioSqlItemsWhere)
  strict private
    FValue: TValue;
  public
    constructor Create(ASqlText:String); overload;  // raise exception
    constructor Create(ASqlText:String; AValue:TValue); overload;
    function GetSql(AProperties:IioContextProperties): String; override;
    function GetSqlParamName(AProperties:IioContextProperties): String; override;
    function GetValue(AProperties:IioContextProperties): TValue; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere for propertyID equals to for param (best for internal use)
  TioSqlItemsWherePropertyOIDEqualsTo = class(TioSqlItemsWhere)
  strict private
    FValue: TValue;
  public
    constructor Create(ASqlText:String); overload;  // raise exception
    constructor Create(AValue:TValue); overload;
    function GetSql(AProperties:IioContextProperties): String; override;
    function GetSqlParamName(AProperties:IioContextProperties): String; override;
    function GetValue(AProperties:IioContextProperties): TValue; override;
    function HasParameter: Boolean; override;
  end;

implementation

uses
  IupOrm.Exceptions, IupOrm.DB.Factory, IupOrm.SqlTranslator;

{ TioSqlItemsWhereValue }

constructor TioSqlItemsWhereTValue.Create(AValue: TValue);
begin
  FValue := AValue;
end;

constructor TioSqlItemsWhereTValue.Create(ASqlText: String);
begin
  EIupOrmException.Create('TioSqlItemsWhereValue wrong constructor called');
end;

function TioSqlItemsWhereTValue.GetSql(AProperties:IioContextProperties): String;
begin
  // NB: No inherited
  Result := TioDBFactory.SqlDataConverter.TValueToSql(FValue);
end;

function TioSqlItemsWhereTValue.HasParameter: Boolean;
begin
  Result := False;
end;

{ TioSqlItemsWhereProperty }

function TioSqlItemsWhereProperty.GetSql(AProperties:IioContextProperties): String;
begin
  // NB: No inherited
  Result := AProperties.GetPropertyByName(FSqlText).GetSqlQualifiedFieldName;
end;

{ TioSqlItemsWhere }

function TioSqlItemsWhereProperty.HasParameter: Boolean;
begin
  Result := False;
end;

{ TioSqlItemsWherePropertyOID }

constructor TioSqlItemsWherePropertyOID.Create;
begin
  // Nothing
end;

function TioSqlItemsWherePropertyOID.GetSql(AProperties:IioContextProperties): String;
begin
  Result := AProperties.GetIdProperty.GetSqlQualifiedFieldName;
end;

function TioSqlItemsWherePropertyOID.HasParameter: Boolean;
begin
  Result := False;
end;

{ TioSqlItemsWhereText }

function TioSqlItemsWhereText.GetSql(AProperties:IioContextProperties): String;
begin
  // NB: No inherited
  Result := TioSqlTranslator.Translate(FSqlText);
end;

function TioSqlItemsWhereText.HasParameter: Boolean;
begin
  Result := False;
end;

{ TioSqlItemsWherePropertyEqualsTo }

constructor TioSqlItemsWherePropertyEqualsTo.Create(ASqlText: String);
begin
  EIupOrmException.Create(Self.ClassName + ': wrong constructor called');
end;

constructor TioSqlItemsWherePropertyEqualsTo.Create(ASqlText: String; AValue: TValue);
begin
  inherited Create(ASqlText);
  FValue := AValue;
end;

function TioSqlItemsWherePropertyEqualsTo.GetSql(AProperties:IioContextProperties): String;
var
  AProp: IioContextProperty;
begin
  // NB: No inherited
  AProp := AProperties.GetPropertyByName(FSqlText);
  Result := AProp.GetSqlQualifiedFieldName
          + TioDBFactory.CompareOperator._Equal.GetSql
          + ':' + AProp.GetSqlParamName;
end;

function TioSqlItemsWherePropertyEqualsTo.GetSqlParamName(AProperties:IioContextProperties): String;
begin
  Result := AProperties.GetPropertyByName(FSqlText).GetSqlParamName;
end;

function TioSqlItemsWherePropertyEqualsTo.GetValue(AProperties:IioContextProperties): TValue;
begin
  Result := FValue;
end;

function TioSqlItemsWherePropertyEqualsTo.HasParameter: Boolean;
begin
  Result := True;
end;

{ TioSqlItemsWherePropertyOIDEqualsTo }

constructor TioSqlItemsWherePropertyOIDEqualsTo.Create(ASqlText: String);
begin
  EIupOrmException.Create(Self.ClassName + ': wrong constructor called');
end;

constructor TioSqlItemsWherePropertyOIDEqualsTo.Create(AValue: TValue);
begin
  inherited Create('');
  FValue := AValue;
end;

function TioSqlItemsWherePropertyOIDEqualsTo.GetSql(AProperties:IioContextProperties): String;
begin
  // NB: No inherited
  Result := AProperties.GetIdProperty.GetSqlQualifiedFieldName
          + TioDBFactory.CompareOperator._Equal.GetSql
          + ':' + AProperties.GetIdProperty.GetSqlParamName;
end;

function TioSqlItemsWherePropertyOIDEqualsTo.GetSqlParamName(AProperties:IioContextProperties): String;
begin
  Result := AProperties.GetIdProperty.GetSqlParamName;
end;

function TioSqlItemsWherePropertyOIDEqualsTo.GetValue(AProperties:IioContextProperties): TValue;
begin
  Result := FValue;
end;


function TioSqlItemsWherePropertyOIDEqualsTo.HasParameter: Boolean;
begin
  Result := True;
end;

{ TioSqlItemsWhere }

function TioSqlItemsWhere.GetSqlParamName(AProperties: IioContextProperties): String;
begin
  // Default
  Result := '';
end;

function TioSqlItemsWhere.GetValue(AProperties: IioContextProperties): TValue;
begin
  // Default
  Result := nil;
end;

end.
