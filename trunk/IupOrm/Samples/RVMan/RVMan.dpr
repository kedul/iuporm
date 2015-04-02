program RVMan;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  System.IOUtils,
  Main in 'Main.pas' {MainForm},
  GlobalFactory in 'GlobalFactory.pas',
  Model.BaseClasses in 'Model.BaseClasses.pas',
  Model.BaseConst in 'Model.BaseConst.pas',
  Model.BaseListClasses in 'Model.BaseListClasses.pas',
  Model.Cost in 'Model.Cost.pas',
  Model.CostType in 'Model.CostType.pas',
  Model.CostTypeListWithCostList in 'Model.CostTypeListWithCostList.pas',
  Model.CostTypeWithCostList in 'Model.CostTypeWithCostList.pas',
  Model.Travel in 'Model.Travel.pas',
  Model.TravelWithCostTypeList in 'Model.TravelWithCostTypeList.pas',
  Service.DefaultData in 'Service.DefaultData.pas',
  Model.Factory in 'Model.Factory.pas',
  View.CostGeneric in 'View.CostGeneric.pas' {ViewCostGeneric: TFrame},
  View.Factory in 'View.Factory.pas',
  View.CostFuel in 'View.CostFuel.pas' {ViewCostFuel: TFrame},
  IupOrm;

{$R *.res}
{$STRONGLINKTYPES ON}

begin
  ReportMemoryLeaksOnShutdown := True;


  // ============ IupOrm initialization ====================
  // Set the directory name (under the Documents folder)
  TIupOrm.ConnectionManager.NewSQLiteConnectionDef(TPath.Combine(TPath.GetDocumentsPath, 'RVMan.db')).Apply;
  // AutoCreation and AutoUpdate of the database
//  TIupOrm.AutoCreateDatabase;
  // Check for default data
//  TDefaultData.CheckForDefaultData;
  // ============ IupOrm initialization ====================


  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
