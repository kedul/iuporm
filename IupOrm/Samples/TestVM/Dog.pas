unit Dog;

interface

uses IupOrm.Attributes;

type

  IDog = interface
    ['{B5ABA79A-7B61-4558-9B52-6A1EC921EC8D}']
    procedure Abbaia;
  end;

  [ioTable('DOGS')]
  TDog = class(TInterfacedObject, IDog)
  private
    FIsAnAnimal: Boolean;
    FID: Integer;
  public
    constructor Create;
    Procedure Abbaia;
    property ID:Integer Read FID write FID;
    property IsAnAnimal: Boolean Read FIsAnAnimal Write FIsAnAnimal;
  end;

implementation

uses
  Vcl.Dialogs, IupOrm;

{ TDog }

procedure TDog.Abbaia;
begin
  ShowMessage('Bau!');
end;

constructor TDog.Create;
begin
  inherited;
  FIsAnAnimal := True;
end;

initialization

//  TIupOrm.DependencyInjection.RegisterClass(TDog).Implements('IDog').Execute;
  TIupOrm.DependencyInjection.RegisterClass<TDog>.Implements<IDog>.Execute;

end.
