program IupOrm.MVVM.VCL;

uses
  Vcl.Forms,
  IupOrm.MVVM.ViewModel in 'IupOrm.MVVM.ViewModel.pas' {ioViewModelBase: TDataModule},
  IupOrm.MVVM.VCL.ViewModel in 'IupOrm.MVVM.VCL.ViewModel.pas' {ioViewModel: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TioViewModel, ioViewModel);
  Application.Run;
end.
