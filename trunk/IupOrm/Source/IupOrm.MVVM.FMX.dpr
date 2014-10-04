program IupOrm.MVVM.FMX;

uses
  FMX.Forms,
  IupOrm.MVVM.ViewModel in 'IupOrm.MVVM.ViewModel.pas' {ioViewModelBase: TDataModule},
  IupOrm.MVVM.FMX.ViewModel in 'IupOrm.MVVM.FMX.ViewModel.pas' {ioViewModel: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TioViewModel, ioViewModel);
  Application.Run;
end.
