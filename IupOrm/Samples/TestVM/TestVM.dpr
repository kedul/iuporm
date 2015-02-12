program TestVM;

uses
  Vcl.Forms,
  FormMain in 'FormMain.pas' {frmMain},
  DM1 in 'DM1.pas' {DataModule1: TDataModule},
  Interfaces in 'Interfaces.pas',
  DM2 in 'DM2.pas' {DataModule2: TDataModule},
  Form2 in 'Form2.pas' {frm2},
  Dog in 'Dog.pas',
  ViewModel1 in 'ViewModel1.pas' {ioViewModel1: TDataModule},
  System.IOUtils,
  IupOrm,
  IupOrm.MVVM.ALL.ViewModel in '..\..\Source\IupOrm.MVVM.ALL.ViewModel.pas' {ioViewModel: TDataModule};

{$R *.res}
{$STRONGLINKTYPES ON}

begin
  ReportMemoryLeaksOnShutdown := True;


  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
  TIupOrm.ConnectionManager.NewSQLiteConnectionDef(TPath.Combine(TPath.GetDocumentsPath, 'TestVM.db')).Apply;
  // AutoCreation and AutoUpdate of the database
  TIupOrm.AutoCreateDatabase;
  // ============ IupOrm initialization ====================


  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
