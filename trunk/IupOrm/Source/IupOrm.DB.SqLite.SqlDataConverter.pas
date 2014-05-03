unit IupOrm.DB.SqLite.SqlDataConverter;

interface

uses
  IupOrm.DB.Interfaces,
  System.Rtti;

type

  // Classe che si occupa di convertire i dati per la compilazione
  //  dell'SQL
  TioSqlDataConverterSqLite = class(TioSqlDataConverter)
  strict protected
  public
    class function StringToSQL(AString:String): String; override;
    class function FloatToSQL(AFloat:Extended): String; override;
    class function TValueToSql(AValue:TValue): String; override;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.TypInfo;

{ TioSqlConverterSqLite }

class function TioSqlDataConverterSqLite.FloatToSQL(AFloat: Extended): String;
var
  Sign, IntegerPart, DecimalPart: String;
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  Result := AFloat.ToString;
  Result := ReplaceText(Result, FormatSettings.ThousandSeparator, #0);
  Result := ReplaceText(Result, FormatSettings.DecimalSeparator, Char('.'));
end;

class function TioSqlDataConverterSqLite.StringToSQL(AString: String): String;
begin
  Result := QuotedStr(AString);
end;

class function TioSqlDataConverterSqLite.TValueToSql(AValue: TValue): String;
begin
  // Default
  Result := 'NULL';
  // In base al tipo
  case AValue.TypeInfo.Kind of
    // String
    tkString, tkChar, tkWChar, tkLString, tkWString, tkUString: Result := QuotedStr(AValue.ToString);
    // Integer
    tkInteger: Result := AValue.ToString;
    // Se Float cerca di capire se è una data o similare, devo fare
    //  così perchè i TValue le date le esprimono come Float.
    tkFloat: begin
      if AValue.TypeInfo = System.TypeInfo(TDateTime)
        then Result := Self.FloatToSQL(AValue.AsExtended)
        else Result := Self.FloatToSQL(AValue.AsExtended);
    end;
  end;
{
NB: Tipi non ancora mappati
TTypeKind = (tkUnknown, tkEnumeration, tkSet, tkClass, tkMethod,
    tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray,
    tkClassRef, tkPointer, tkProcedure);
}
end;

end.
