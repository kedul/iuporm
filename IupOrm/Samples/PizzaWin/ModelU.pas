unit ModelU;

interface

uses
  FMX.Graphics, IupOrm.Attributes;

type

  [ioTable('PIZZE')]
  TPizza = class
  private
    FName: String;
    FID: Integer;
    FImg: TBitmap;
    procedure SetImg(const Value: TBitmap);
  public
    constructor Create;
    destructor Destroy;
    property ID:Integer read FID write FID;
    property Name:String read FName write FName;
    property Img:TBitmap read FImg write SetImg;
  end;

implementation

{ TPizza }

constructor TPizza.Create;
begin
  inherited;
  FImg := TBitmap.Create;
end;

destructor TPizza.Destroy;
begin
  if Assigned(FImg) then FImg.Free;

end;

procedure TPizza.SetImg(const Value: TBitmap);
begin
  if Assigned(FImg) then FImg.Free;
  FImg := Value;
end;

end.
