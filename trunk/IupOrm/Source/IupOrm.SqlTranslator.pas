unit IupOrm.SqlTranslator;

interface

uses
  System.RegularExpressions;

type

  TioSqlTranslator = class
  strict protected
    class function RemoveDelimiters(const AValue:string): String;
    class function GetClassName(const AValue:string): String;
    class function GetPropertyName(const AValue:String): String;
    class function ReplaceEval(const Match: TMatch): string;
  public
    class function Translate(const AValue:String): String;
  end;

implementation

uses
  SysUtils, IupOrm.Context.Interfaces, IupOrm.Context.Factory,
  IupOrm.Context.Container, IupOrm.Context.Map.Interfaces;

{ TioSqlTranslator }

class function TioSqlTranslator.GetClassName(const AValue: string): String;
var
  DotPos: Smallint;
begin
  Result := '';
  DotPos := AValue.IndexOf('.');
  if DotPos = -1
    then Result := AValue
    else Result := AValue.Substring(0, AValue.IndexOf('.'));
end;

class function TioSqlTranslator.GetPropertyName(const AValue: String): String;
var
  DotPos: Smallint;
begin
  Result := '';
  DotPos := AValue.IndexOf('.');
  if DotPos > -1
    then Result := AValue.Substring(DotPos+1, 99999999);
end;

class function TioSqlTranslator.RemoveDelimiters(const AValue: string): String;
begin
  Result := AValue.Substring(1, AValue.Length-2);
end;

class function TioSqlTranslator.ReplaceEval(const Match: TMatch): string;
var
  ASqlTag, AClassName, APropName: String;
  AMap: IioMap;
begin
  ASqlTag := Self.RemoveDelimiters(Match.Value);
  AClassName := Self.GetClassName(ASqlTag);
  APropName := Self.GetPropertyName(ASqlTag);
  AMap := TioMapContainer.GetMap(AClassName);
  Result := AMap.GetTable.TableName;
  if APropName <> ''
    then Result := Result + '.' + AMap.GetProperties.GetPropertyByName(APropName).GetSqlFieldName;
end;

class function TioSqlTranslator.Translate(const AValue: String): String;
var
  AEvaluator: TMatchEvaluator;
begin
  Result := '';
  AEvaluator := ReplaceEval;
  Result := TRegEx.Replace(AValue, '\[.*?\]', AEvaluator);
end;

end.
