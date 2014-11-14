program IupOrm.MVVM.VCL;

uses
  Vcl.Forms,
  IupOrm.MVVM.ViewModelBase in 'IupOrm.MVVM.ViewModelBase.pas' {ioViewModelBase: TDataModule},
  IupOrm.MVVM.VCL.ViewModel in 'IupOrm.MVVM.VCL.ViewModel.pas' {ioViewModel: TDataModule},
  IupOrm.MVVM.Interfaces in 'IupOrm.MVVM.Interfaces.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
