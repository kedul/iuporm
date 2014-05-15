unit IupOrm.DB.SqLite.SqlDataConverter;

interface

uses
  IupOrm.DB.Interfaces,
  System.Rtti, IupOrm.Context.Properties.Interfaces;

type

  // Classe che si occupa di convertire i dati per la compilazione
  //  dell'SQL
  TioSqlDataConverterSqLite = class(TioSqlDataConverter)
  strict protected
  public
    class function StringToSQL(AString:String): String; override;
    class function FloatToSQL(AFloat:Extended): String; override;
    class function TValueToSql(AValue:TValue): String; override;
    class function PropertyToFieldType(AProp:IioContextProperty): String; override;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.TypInfo, IupOrm.Attributes;

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

class function TioSqlDataConverterSqLite.PropertyToFieldType(
  AProp: IioContextProperty): String;
begin
  // According to the RelationType of the property...
  case AProp.GetRelationType of
    // Normal property, no relation, field type is by TypeKind of the property itself
    ioRTNone: begin
      case AProp.GetRttiProperty.PropertyType.TypeKind of
        tkInt64, tkInteger: Result := 'INTEGER';
        tkFloat: Result := 'REAL';
        tkString, tkUString, tkWChar, tkLString, tkWString, tkChar: Result := 'TEXT';
        tkClass, tkInterface: Result := 'BLOB';
      end;
    end;
    // If it's a BelongsTo relation property then field type is always INTEGER
    //  because the ID fields always are INTEGERS values
    iortBelongsTo: Result := 'INTEGER';
    // Otherwise return NULL field type
    else Result := 'NULL';
  end;
end;

class function TioSqlDataConverterSqLite.StringToSQL(AString: String): String;
begin
  Result := QuotedStr(AString);
end;

class function TioSqlDataConverterSqLite.TValueToSql(AValue: TValue): String;
begin
// ######BLOB
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
