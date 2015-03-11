program IupOrm.MVVM.FMX;

uses
  FMX.Forms,
  IupOrm.MVVM.ViewModelBase in 'IupOrm.MVVM.ViewModelBase.pas' {ioViewModelBase: TDataModule},
  IupOrm.MVVM.FMX.ViewModel in 'IupOrm.MVVM.FMX.ViewModel.pas' {ioViewModel: TDataModule},
  IupOrm.MVVM.Interfaces in 'IupOrm.MVVM.Interfaces.pas',
  RTTIUtilsU in '..\ExtLibs\DMVC\RTTIUtilsU.pas',
  ObjectsMappers in '..\ExtLibs\DMVC\ObjectsMappers.pas',
  DuckObjU in '..\ExtLibs\DMVC\DuckObjU.pas',
  DuckListU in '..\ExtLibs\DMVC\DuckListU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Run;
end.
