unit DuckPropFieldU;

interface

uses
  System.Rtti;

type

  TDuckPropFieldType = (ptProperty, ptField);

  TDuckPropField = class
  public
    class function GetPropFieldType(const APropField: TRttiNamedObject): TDuckPropFieldType;
    class function GetValue(const Instance: TObject; const APropField: TRttiNamedObject): TValue;
    class procedure SetValue(const Instance: TObject; const APropField: TRttiNamedObject; const AValue: TValue);
    class function RttiType(const APropField: TRttiNamedObject): TRttiType;
    class function IsWritable(const APropField: TRttiNamedObject): Boolean;
  end;

implementation

{ TDuckPropField }

class function TDuckPropField.GetPropFieldType(const APropField: TRttiNamedObject): TDuckPropFieldType;
begin
  if APropField is TRttiProperty then
    Result := ptProperty
  else
    Result := ptField;
end;

class function TDuckPropField.GetValue(const Instance: TObject; const APropField: TRttiNamedObject): TValue;
var
  LRttiProperty: TRttiProperty;
begin
  case Self.GetPropFieldType(APropField) of
    ptField:
      Result := TRttiField(APropField).GetValue(Instance);
    ptProperty:
      Result := TRttiProperty(APropField).GetValue(Instance);
  end;
end;

class function TDuckPropField.IsWritable(const APropField: TRttiNamedObject): Boolean;
begin
  case Self.GetPropFieldType(APropField) of
    ptField:
      Result := True;
    ptProperty:
      Result := TRttiProperty(APropField).IsWritable;
  end;
end;

class function TDuckPropField.RttiType(const APropField: TRttiNamedObject): TRttiType;
begin
  case Self.GetPropFieldType(APropField) of
    ptField:
      Result := TRttiField(APropField).FieldType;
    ptProperty:
      Result := TRttiProperty(APropField).PropertyType;
  end;
end;

class procedure TDuckPropField.SetValue(const Instance: TObject; const APropField: TRttiNamedObject; const AValue: TValue);
begin
  case Self.GetPropFieldType(APropField) of
    ptField:
      TRttiField(APropField).SetValue(Instance, AValue);
    ptProperty:
      TRttiProperty(APropField).SetValue(Instance, AValue);
  end;
end;

end.
