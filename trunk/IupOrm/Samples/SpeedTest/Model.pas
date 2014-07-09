unit Model;

interface

uses
  IupOrm.Attributes;

type

  [ioTable('Articoli')]
  TArticolo = class
  private
    FID: Integer;
    FDescrizione: String;
  public
    constructor Create(AID: Integer; ADescrizione: String);
    property ID:Integer read FID write FID;
    property Descrizione:String read FDescrizione write FDescrizione;
  end;

implementation

{ TArticoli }

constructor TArticolo.Create(AID: Integer; ADescrizione: String);
begin
  inherited Create;
  FID := AID;
  FDescrizione := ADescrizione;
end;

end.
