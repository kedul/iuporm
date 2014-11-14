program TestVM;

uses
  Vcl.Forms,
  FormMain in 'FormMain.pas' {frmMain},
  DM1 in 'DM1.pas' {DataModule1: TDataModule},
  Interfaces in 'Interfaces.pas',
  DM2 in 'DM2.pas' {DataModule2: TDataModule},
  Form2 in 'Form2.pas' {frm2},
  Dog in 'Dog.pas',
  IupOrm.MVVM.VCL.ViewModel in '..\..\Source\IupOrm.MVVM.VCL.ViewModel.pas' {ioViewModel: TDataModule},
  ViewModel1 in 'ViewModel1.pas' {ioViewModel1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
