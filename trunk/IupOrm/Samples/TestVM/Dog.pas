unit Dog;

interface

type

  IDog = interface
    ['{B5ABA79A-7B61-4558-9B52-6A1EC921EC8D}']
    procedure Abbaia;
  end;

  TDog = class(TInterfacedObject, IDog)
  public
    Procedure Abbaia;
  end;

implementation

uses
  Vcl.Dialogs, IupOrm;

{ TDog }

procedure TDog.Abbaia;
begin
  ShowMessage('Bau!');
end;

initialization

//  TIupOrm.DependencyInjection.RegisterClass(TDog).Implements('IDog').Execute;
  TIupOrm.DependencyInjection.RegisterClass<TDog>.Implements<IDog>.Execute;

end.
