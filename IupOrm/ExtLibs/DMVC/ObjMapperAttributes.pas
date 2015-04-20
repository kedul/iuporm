unit ObjMapperAttributes;

interface

type

  TJSONNameCase = (JSONNameUpperCase, JSONNameLowerCase);

  StreamableAttribute = class(TCustomAttribute)

  end;

  MapperTransientAttribute = class(TCustomAttribute)

  end;

  DoNotSerializeAttribute = class(TCustomAttribute)

  end;

  MapperJSONNaming = class(TCustomAttribute)
  private
    FJSONKeyCase: TJSONNameCase;
    function GetKeyCase: TJSONNameCase;

  public
    constructor Create(JSONKeyCase: TJSONNameCase);
    property KeyCase: TJSONNameCase read GetKeyCase;
  end;

  MapperJSONSer = class(TCustomAttribute)
  private
    FName: string;
    function GetName: string;

  public
    constructor Create(AName: string);
    property name: string read GetName;
  end;

  MapperSerializeAsString = class(TCustomAttribute)
  strict private
    FEncoding: string;
    procedure SetEncoding(const Value: string);

  const
    DefaultEncoding = 'utf-8';
  public
    constructor Create(AEncoding: string = DefaultEncoding);
    property Encoding: string read FEncoding write SetEncoding;
  end;

implementation

uses System.SysUtils;

{ MapperSerializeAsString }

constructor MapperSerializeAsString.Create(AEncoding: string);
begin
  inherited Create;
  if AEncoding.IsEmpty then
    FEncoding := DefaultEncoding
  else
    FEncoding := AEncoding;
end;

procedure MapperSerializeAsString.SetEncoding(const Value: string);
begin
  FEncoding := Value;
end;

{ JSONSer }

constructor MapperJSONSer.Create(AName: string);
begin
  inherited Create;
  FName := AName;
end;

function MapperJSONSer.GetName: string;
begin
  Result := FName;
end;

{ JSONNaming }

constructor MapperJSONNaming.Create(JSONKeyCase: TJSONNameCase);
begin
  inherited Create;
  FJSONKeyCase := JSONKeyCase;
end;

function MapperJSONNaming.GetKeyCase: TJSONNameCase;
begin
  Result := FJSONKeyCase;
end;


end.
