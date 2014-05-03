unit IupOrm.Context.Table;

interface

uses
  IupOrm.Context.Interfaces,
  IupOrm.SqlItems, IupOrm.Context.Table.Interfaces;

type

  // Classe che incapsula le informazioni per la funzione ClassFromField
  TioClassFromField = class (TInterfacedObject, IioClassFromField)
  strict private
    FClassName: String;
    FQualifiedClassName: String;
    FAncestors: String;
    FSqlFieldName: String;
  public
    constructor Create(ASqlFieldName, AClassName, AQualifiedClassName, AAncestors: String);
    function GetSqlFieldName: string;
    function GetValue: String;
    function GetSqlValue: string;
    function GetClassName: String;
    function GetQualifiedClassName: String;
    function QualifiedClassNameFromClassInfoFieldValue(AValue:String): String;
  end;

  // Classe che incapsula le info sulla tabella
  TioContextTable = class (TioSqlItem, IioContextTable)
  strict private
    FClassFromField: IioClassFromField;
  public
    constructor Create(ASqlText:String; AClassFromField:IioClassFromField); overload;
    function GetClassFromField: IioClassFromField;
    function IsClassFromField: Boolean;
    function TableName: String;
  end;

implementation

uses
  IupOrm.DB.Factory, System.SysUtils;

{ TioContextTable }

constructor TioContextTable.Create(ASqlText:String; AClassFromField:IioClassFromField);
begin
  inherited Create(ASqlText);
  FClassFromField := AClassFromField;
end;

function TioContextTable.GetClassFromField: IioClassFromField;
begin
  Result := FClassFromField;
end;

function TioContextTable.IsClassFromField: Boolean;
begin
  Result := Assigned(FClassFromField);
end;


function TioContextTable.TableName: String;
begin
  Result := Self.FSqlText;
end;

{ TioClassFromField }

constructor TioClassFromField.Create(ASqlFieldName, AClassName, AQualifiedClassName, AAncestors: String);
begin
  FSqlFieldName := ASqlFieldName;
  FClassName := AClassName;
  FQualifiedClassName := AQualifiedClassName;
  FAncestors := AAncestors;
end;

function TioClassFromField.GetClassName: String;
begin
  Result := FClassName;
end;

function TioClassFromField.GetQualifiedClassName: String;
begin
  Result := FQualifiedClassName;
end;

function TioClassFromField.GetSqlFieldName: string;
begin
  Result := FSqlFieldName;
end;

function TioClassFromField.GetSqlValue: string;
begin
  Result := TioDbFactory.SqlDataConverter.StringToSQL(Self.GetValue);
end;

function TioClassFromField.GetValue: String;
begin
  Result := Self.FQualifiedClassName + ';' + Self.FAncestors;
end;


function TioClassFromField.QualifiedClassNameFromClassInfoFieldValue(
  AValue: String): String;
begin
  Result := Copy(AValue,0,Pos(';',AValue)-1);
end;

end.
