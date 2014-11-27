program SpeedTest;

uses
  System.IOUtils,
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {Form2},
  Model in 'Model.pas',
  IupOrm;  // *** AFTER FMX.Forms ABSOLUTELY (altrimenti memory leak) ***

{$R *.res}
{$STRONGLINKTYPES ON}

begin
  ReportMemoryLeaksOnShutdown := True;

  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
//  TioConnectionManager.NewSQLiteConnectionDef(TPath.Combine(TPath.GetDocumentsPath, 'SpeedTest.db')).Apply;
  TIupOrm.ConnectionManager.NewSQLiteConnectionDef(TPath.Combine(TPath.GetDocumentsPath, 'SpeedTest.db')).Apply;
  // AutoCreation and AutoUpdate of the database
//  TioDBCreatorFactory.GetDBCreator.AutoCreateDatabase;
  TIupOrm.AutoCreateDatabase;
  // ============ IupOrm initialization ====================

  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
