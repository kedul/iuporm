program ImpOrm.MVVM.ALL;

uses
  FMX.Forms,
  IupOrm.MVVM.Interfaces in 'IupOrm.MVVM.Interfaces.pas',
  IupOrm.MVVM.ViewModelBase in 'IupOrm.MVVM.ViewModelBase.pas' {ioViewModelBase: TDataModule},
  ObjectsMappers in '..\ExtLibs\DMVC\ObjectsMappers.pas',
  DuckListU in '..\ExtLibs\DMVC\DuckListU.pas',
  RTTIUtilsU in '..\ExtLibs\DMVC\RTTIUtilsU.pas',
  DuckObjU in '..\ExtLibs\DMVC\DuckObjU.pas',
  IupOrm.MVVM.ALL.ViewModel in 'IupOrm.MVVM.ALL.ViewModel.pas' {ioViewModel: TDataModule},
  IupOrm.MVVM.ViewModel.Commands in 'IupOrm.MVVM.ViewModel.Commands.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Run;
end.
