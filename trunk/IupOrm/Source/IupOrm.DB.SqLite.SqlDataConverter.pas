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
    class function PropertyToFieldType(AProp:IioContextProperty): String; override;
    class function TValueToSql(AValue:TValue): String; override;
    class function QueryToTValue(AQuery:IioQuery; AProperty:IioContextProperty): TValue; override;
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
        tkInt64, tkInteger, tkEnumeration: Result := 'INTEGER';
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

class function TioSqlDataConverterSqLite.QueryToTValue(AQuery: IioQuery; AProperty: IioContextProperty): TValue;
begin
  // If the field is null
  // HO levato questo controllo perchè nel caso in cui il campo fosse NULL mi dava un errore
  //  'Invalid Type cast' dovuto al fatto che il TValue da ritornare non veniva
  //  valorizzato per niente (nemmeno a NULL)
//  if AQuery.Fields.FieldByName(AProperty.GetSqlFieldAlias).IsNull
//    then Exit;
  // Convert the field value to a TValue by TypeKind
  case AProperty.GetRttiProperty.PropertyType.TypeKind of
    tkInt64, tkInteger:
      Result := AQuery.Fields.FieldByName(AProperty.GetSqlFieldAlias).AsInteger;
    tkFloat:
      Result := AQuery.Fields.FieldByName(AProperty.GetSqlFieldAlias).AsFloat;
    tkString, tkUString, tkWChar, tkLString, tkWString, tkChar:
      Result := AQuery.Fields.FieldByName(AProperty.GetSqlFieldAlias).AsString;
    tkEnumeration:
      Result := TValue.FromOrdinal(
                                    AProperty.GetRttiProperty.PropertyType.Handle,  // This is the PTypeInfo of the PropertyType
                                    AQuery.Fields.FieldByName(AProperty.GetSqlFieldAlias).AsInteger  // This is the ordinal value
                                  );
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
    tkInteger, tkInt64: Result := AValue.ToString;
    // Enumerated (boolean also)
    tkEnumeration: Result := AValue.AsOrdinal.ToString;
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
TTypeKind = (tkUnknown, tkSet, tkClass, tkMethod,
    tkVariant, tkArray, tkRecord, tkInterface, tkDynArray,
    tkClassRef, tkPointer, tkProcedure);
}
end;

end.
