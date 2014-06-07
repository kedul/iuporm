unit Model;

interface

uses
  IupOrm.Attributes, FMX.Graphics, System.SysUtils, IupOrm.CommonTypes;

type

  [ioTable('PIZZE')]
  TPizza = class
  private
    FName: String;
    FImg: TBitmap;
    FID: Integer;
    FObjectStatus: TIupOrmObjectStatus;
  public
    constructor Create;
    destructor Destroy; override;
//    [ioOID]
    property ID:Integer read FID write FID;
    property Name:String read FName write FName;
    property Img:TBitmap read FImg write FImg;
    property ObjStatus: TIupOrmObjectStatus read FObjectStatus write FObjectStatus;
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
  FImg.Free;
  inherited;
end;

end.
