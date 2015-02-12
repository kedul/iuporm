program IupOrm.MVVM.VCL;

uses
  Vcl.Forms,
  IupOrm.MVVM.ViewModelBase in 'IupOrm.MVVM.ViewModelBase.pas' {ioViewModelBase: TDataModule},
  IupOrm.MVVM.VCL.ViewModel in 'IupOrm.MVVM.VCL.ViewModel.pas' {ioViewModel: TDataModule},
  IupOrm.MVVM.Interfaces in 'IupOrm.MVVM.Interfaces.pas',
  DuckListU in '..\ExtLibs\DMVC\DuckListU.pas',
  DuckObjU in '..\ExtLibs\DMVC\DuckObjU.pas',
  ObjectsMappers in '..\ExtLibs\DMVC\ObjectsMappers.pas',
  RTTIUtilsU in '..\ExtLibs\DMVC\RTTIUtilsU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
