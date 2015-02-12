program Pizza_ioActiveBindSourceAdapter;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  Main in 'Main.pas' {MainForml},
  Model in 'Model.pas',
  IOUtils,
  IupOrm;

{$R *.res}
{$STRONGLINKTYPES ON}

begin
  ReportMemoryLeaksOnShutdown := True;

  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
  TIupOrm.ConnectionManager.NewSQLiteConnectionDef(TPath.Combine(TPath.GetDocumentsPath, 'Pizza.db')).Apply;
  // AutoCreation and AutoUpdate of the database
  TIupOrm.AutoCreateDatabase;
  // ============ IupOrm initialization ====================

  Application.Initialize;
  Application.CreateForm(TMainForml, MainForml);
  Application.Run;
end.
