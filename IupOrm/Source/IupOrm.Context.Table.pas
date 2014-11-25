unit IupOrm.Context.Table;

interface

uses
  IupOrm.Context.Interfaces,
  IupOrm.SqlItems, IupOrm.Context.Table.Interfaces, IupOrm.Attributes,
  IupOrm.CommonTypes, System.Generics.Collections;

type

  // Classe che incapsula le informazioni per l'eventuale GroubBY
  //  almeno la parte fissa eventualmente dichiarata con gli attributes
  //  nella dichiarazione della classe (ci potrebbe poi essere in futuro
  //  anche una GroupBy non fissa e impostabile tramite TioWhere come
  //  se fosse una condizione prima del ToList o TObject, Qquest'ultima
  //  GroupBy avrebbe la precedenza su qquella fissa se specificata)
  TioGroupBy = class(TioSqlItem, IioGroupBy)
  public
    function GetSql:String; override;
  end;

  // Classe che incapsula le informazioni per gli eventuali JOIN
  TioJoinItem = class(TInterfacedObject, IioJoinItem)
  strict private
    FJoinCondition: String;
    FJoinType: TioJoinType;
    FJoinClassRef: TioClassRef;
  public
    constructor Create(const AJoinType:TioJoinType; AJoinClassRef:TioClassRef; AJoinCondition:String='');
    function GetSql: String;
    function GetJoinClassRef: TioClassRef;
    function GetJoinCondition: String;
    function GetJoinType: TioJoinType;
  end;

  TioJoinItemList = TList<IioJoinItem>;
  // Classe che incapsula una lista di JoinItems
  TioJoins = class(TInterfacedObject, IioJoins)
  strict private
    FJoinList: TioJoinItemList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(AJoinItem:IioJoinItem);
    function GetSql: String;
  end;

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
    FJoins: IioJoins;
    FGroupBy: IioGroupBy;
    FConnectionDefName: String;
  public
    constructor Create(const ASqlText:String; const AClassFromField:IioClassFromField;
    const AJoins:IioJoins; const AGroupBy:IioGroupBy; const AConnectionDefName:String); overload;
    function GetClassFromField: IioClassFromField;
    function IsClassFromField: Boolean;
    function TableName: String;
    function GetJoin: IioJoins;
    function GetGroupBy: IioGroupBy;
    function GetConnectionDefName: String;
  end;

implementation

uses
  IupOrm.DB.Factory, System.SysUtils, IupOrm.Exceptions, IupOrm.SqlTranslator;

{ TioContextTable }

constructor TioContextTable.Create(const ASqlText:String; const AClassFromField:IioClassFromField;
    const AJoins:IioJoins; const AGroupBy:IioGroupBy; const AConnectionDefName:String);
begin
  inherited Create(ASqlText);
  FClassFromField := AClassFromField;
  FJoins := AJoins;
  FGroupBy := AGroupBy;
  FConnectionDefName := AConnectionDefName;
end;

function TioContextTable.GetClassFromField: IioClassFromField;
begin
  Result := FClassFromField;
end;

function TioContextTable.GetConnectionDefName: String;
begin
  Result := FConnectionDefName;
end;

function TioContextTable.GetGroupBy: IioGroupBy;
begin
  Result := FGroupBy;
end;

function TioContextTable.GetJoin: IioJoins;
begin
  Result := FJoins;
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

{ TioJoin }

constructor TioJoinItem.Create(const AJoinType: TioJoinType;
  AJoinClassRef: TioClassRef; AJoinCondition: String);
begin
  inherited Create;
  FJoinType := AJoinType;
  FJoinClassRef := AJoinClassRef;
  FJoinCondition := AJoinCondition;
end;

function TioJoinItem.GetJoinClassRef: TioClassRef;
begin
  Result := Self.FJoinClassRef;
end;

function TioJoinItem.GetJoinCondition: String;
begin
  Result := Self.FJoinCondition;
end;

function TioJoinItem.GetJoinType: TioJoinType;
begin
  Result := Self.FJoinType;
end;

function TioJoinItem.GetSql: String;
begin
  Result := TioDBFactory.SqlGenerator.GenerateSqlJoinSectionItem(Self);
end;

{ TioJoins }

procedure TioJoins.Add(AJoinItem: IioJoinItem);
begin
  FJoinList.Add(AJoinItem);
end;

constructor TioJoins.Create;
begin
  FJoinList := TioJoinItemList.Create;
end;

destructor TioJoins.Destroy;
begin
  FJoinList.Free;
  inherited;
end;

function TioJoins.GetSql: String;
var
  aJoinItem: IioJoinItem;
begin
  Result := '';
  for aJoinItem in FJoinList do
    Result := Result + #13 + TioSqlTranslator.Translate(aJoinItem.GetSql);
end;

{ TioGroupBy }

function TioGroupBy.GetSql: String;
begin
  Result := TioSqlTranslator.Translate(inherited).Trim;
  if Result <> '' then Result := 'GROUP BY ' + Result;
  
end;

end.
