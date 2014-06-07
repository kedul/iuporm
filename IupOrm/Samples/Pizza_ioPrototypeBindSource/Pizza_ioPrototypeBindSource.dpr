program Pizza_ioPrototypeBindSource;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  Main in 'Main.pas' {MainForml},
  Model in 'Model.pas', IupOrm;

{$R *.res}
{$STRONGLINKTYPES ON}

begin
  ReportMemoryLeaksOnShutdown := True;

  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
  TIupOrm.SetDBFolderInDocuments('Pizza');
  // AutoCreation and AutoUpdate of the database
  TIupOrm.AutoCreateDatabase;
  // ============ IupOrm initialization ====================

  Application.Initialize;
  Application.CreateForm(TMainForml, MainForml);
  Application.Run;
end.
