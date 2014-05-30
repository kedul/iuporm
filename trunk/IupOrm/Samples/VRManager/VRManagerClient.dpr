program VRManagerClient;

uses
  FMX.Forms,
  MainForm in 'MainForm.pas' {TabbedwithNavigationForm},
  Model.BaseConst in 'Model.BaseConst.pas',
  Model.BaseInterfaces in 'Model.BaseInterfaces.pas',
  Model.BaseClasses in 'Model.BaseClasses.pas',
  Model.CostType in 'Model.CostType.pas',
  Model.Travel in 'Model.Travel.pas',
  Model.Cost in 'Model.Cost.pas',
  Service.Interfaces in 'Service.Interfaces.pas',
  Service.SQLite in 'Service.SQLite.pas',
  Service in 'Service.pas',
  UVMBase in 'UVMBase.pas',
  View.TravelListFrame in 'View.TravelListFrame.pas' {ViewTravelListFrame: TFrame},
  Model.CostTypeWithCostListInterface in 'Model.CostTypeWithCostListInterface.pas',
  Model.CostTypeWithCostList in 'Model.CostTypeWithCostList.pas',
  ViewModel.Interfaces in 'ViewModel.Interfaces.pas',
  UVMTravelList in 'UVMTravelList.pas',
  UVMFactory in 'UVMFactory.pas',
  UViewFactory in 'UViewFactory.pas',
  Model.BaseListClasses in 'Model.BaseListClasses.pas',
  Model.CostTypeListWithCostList in 'Model.CostTypeListWithCostList.pas',
  ViewModel.GenericsVM in 'ViewModel.GenericsVM.pas',
  ViewModel in 'ViewModel.pas',
  Model.TravelWithCostListInterface in 'Model.TravelWithCostListInterface.pas',
  Model.TravelWithCostList in 'Model.TravelWithCostList.pas';

{$R *.res}
{$STRONGLINKTYPES ON}

begin
//  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TTabbedwithNavigationForm, TabbedwithNavigationForm);
  Application.Run;
end.
