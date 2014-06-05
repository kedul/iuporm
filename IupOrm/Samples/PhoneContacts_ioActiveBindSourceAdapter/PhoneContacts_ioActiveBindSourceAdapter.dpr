program PhoneContacts_ioActiveBindSourceAdapter;

uses
  IupOrm,
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  MainForm in 'MainForm.pas' {Form1},
  Model in 'Model.pas',
  SampleData in 'SampleData.pas';

{$R *.res}
{$STRONGLINKTYPES ON}

begin


  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
  TIupOrm.SetDBFolderInDocuments('IupOrm PhoneContacts Database');
  // AutoCreation and AutoUpdate of the database
  TIupOrm.AutoCreateDatabase;
  // ============ IupOrm initialization ====================

  // Check for sample data creation
  TSampleData.CheckForSampleDataCreation;

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
