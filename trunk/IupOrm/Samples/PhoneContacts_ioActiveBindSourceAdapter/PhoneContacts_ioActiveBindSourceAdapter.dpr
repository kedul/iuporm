program PhoneContacts_ioActiveBindSourceAdapter;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  MainForm in 'MainForm.pas' {Form1},
  Model in 'Model.pas',
  SampleData in 'SampleData.pas',
  System.IOUtils,
  IupOrm;

{$R *.res}
{$STRONGLINKTYPES ON}

begin


  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
  TIupOrm.ConnectionManager.NewSQLiteConnectionDef(TPath.Combine(TPath.GetDocumentsPath, 'Contacts.db')).Apply;
  // AutoCreation and AutoUpdate of the database
//  TIupOrm.AutoCreateDatabase;
  // Check for sample data creation
//  TSampleData.CheckForSampleDataCreation;
  // ============ IupOrm initialization ====================

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
