program PizzaWin_ioActiveBindSourceAdapter;

uses
  FMX.Forms,
  Main in 'Main.pas' {Form1},
  ModelU in 'ModelU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
