program PizzaProject;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  Main in 'Main.pas' {MainForml},
  Model in 'Model.pas',
  IupOrm, IupOrm.DB.DBCreator.Factory;

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
  TIupOrm.Init('Pizza');
  // AutoCreation and AutoUpdate of the database
//  TioDBCreatorFactory.GetDBCreator.AutoCreateDatabase;
  // ============ IupOrm initialization ====================

  Application.Initialize;
  Application.CreateForm(TMainForml, MainForml);
  Application.Run;
end.
