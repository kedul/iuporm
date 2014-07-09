program SpeedTest;

uses
  IupOrm,
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  Main in 'Main.pas' {Form2},
  Model in 'Model.pas';

{$R *.res}
{$STRONGLINKTYPES ON}

begin

  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
  TIupOrm.SetDBFolderInDocuments('SpeedTest');
  // AutoCreation and AutoUpdate of the database
  TIupOrm.AutoCreateDatabase;
  // ============ IupOrm initialization ====================

  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
