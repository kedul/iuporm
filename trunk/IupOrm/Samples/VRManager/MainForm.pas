unit MainForm;

interface


uses System.Classes, Data.DbxSqlite, FMX.StdCtrls,System.Actions, FMX.ActnList,
  FMX.Forms, FMX.Controls, FMX.TabControl, FMX.Types,
  View.TravelListFrame, Model.CostType, Model.CostTypeWithCostList,
  Fmx.Bind.GenData, FMX.ListView.Types, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  FMX.ListView, Data.Bind.ObjectScope, Model.BaseInterfaces,
  System.Generics.Collections, Model.Cost;

type
  TTabbedwithNavigationForm = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    ActionList1: TActionList;
    TabControl2: TTabControl;
    TabItem5: TTabItem;
    TabItem6: TTabItem;
    ChangeTabAction1: TChangeTabAction;
    ToolBar1: TToolBar;
    lblTitle1: TLabel;
    ToolBar2: TToolBar;
    lblTitle2: TLabel;
    ToolBar3: TToolBar;
    lblTitle3: TLabel;
    ToolBar4: TToolBar;
    lblTitle4: TLabel;
    ToolBar5: TToolBar;
    lblTitle5: TLabel;
    ChangeTabAction2: TChangeTabAction;
    btnBack: TSpeedButton;
    btnNext: TSpeedButton;
    TabItem7: TTabItem;
    Button3: TButton;
    Button2: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ButtonNewTravel: TButton;
    ButtonDeleteTravelByID: TButton;
    ButtonDeleteTravelEmptyDesc: TButton;
    ButtonUpdateTravel: TButton;
    ButtonChangeCostType1: TButton;
    ButtonChangeCostType2: TButton;
    ToolBar6: TToolBar;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    ChangeTabAction3: TChangeTabAction;
    ChangeTabAction4: TChangeTabAction;
    SpeedButton2: TSpeedButton;
    PrototypeBindSource1: TPrototypeBindSource;
    ListView1: TListView;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    ButtonCOstsTCostFuel: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure ButtonNewTravelClick(Sender: TObject);
    procedure ButtonDeleteTravelByIDClick(Sender: TObject);
    procedure ButtonDeleteTravelEmptyDescClick(Sender: TObject);
    procedure ButtonUpdateTravelClick(Sender: TObject);
    procedure ButtonChangeCostType1Click(Sender: TObject);
    procedure ButtonChangeCostType2Click(Sender: TObject);
    procedure PrototypeBindSource1CreateAdapter(Sender: TObject;
      var ABindSourceAdapter: TBindSourceAdapter);
    procedure ButtonCOstsTCostFuelClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  strict private
    { Private declarations }
    FViewTravelListFrame: TViewTravelListFrame;
  public
    { Public declarations }
  end;

var
  TabbedwithNavigationForm: TTabbedwithNavigationForm;

implementation

uses
  UViewFactory, IupOrm, FMX.Dialogs, IupOrm.Context.Properties,
  IupOrm.Context.Factory, Model.Travel, IupOrm.Attributes,
  IupOrm.Interfaces, Service,
  Model.BaseClasses, System.SysUtils,
  IupOrm.Where, Model.CostTypeWithCostListInterface, Model.BaseListClasses,
  Model.TravelWithCostList, Model.TravelWithCostListInterface,
  IupOrm.DB.DBCreator.Interfaces, IupOrm.DB.DBCreator.Factory,
  IupOrm.DB.Interfaces, IupOrm.DB.Factory, IupOrm.CommonTypes,
  System.IOUtils;

{$R *.fmx}

procedure TTabbedwithNavigationForm.Button1Click(Sender: TObject);
var
  AList: TList<IBaseInterface>;
  ATravel: IBaseInterface;
  StrToShow: String;
begin
  AList := TIupOrm.Load<TTravel>._where._Property('ID')._EqualTo(1)._Or._Property('ID')._EqualTo(2).ToList<TList<IBaseInterface>>;
  try
    for ATravel in AList do
    begin
      StrToShow := StrToShow + ATravel.ListViewItem_Caption + #13;
    end;
    ShowMessage(StrToShow);
  finally
    AList.Free;
  end;
end;

procedure TTabbedwithNavigationForm.Button2Click(Sender: TObject);
var
  AList: TList<TTravel>;
  ATravel: TTravel;
  StrToShow: String;
begin
  AList := TIupOrm.Load<TTravel>.ToList<TList<TTravel>>;
  try
    for ATravel in AList do
    begin
      StrToShow := StrToShow + IntToStr(ATravel.ID) + ': ' + ATravel.Descrizione + #13;
      ATravel.Free;
    end;
    ShowMessage(StrToShow);
  finally
    AList.Free;
  end;
end;

procedure TTabbedwithNavigationForm.Button3Click(Sender: TObject);
begin
  TServiceFactory<TBaseClass>.Connection.GetNewConnection(nil);
end;

procedure TTabbedwithNavigationForm.Button4Click(Sender: TObject);
var
//  AList: TObjectList<TBaseClass>;
  AList: TBaseList;
  ATravel: TBaseClass;
  StrToShow: String;
begin
//  AList := TIupOrm.Load<TTravel>.ToList<TObjectList<TBaseClass>>;
  AList := TIupOrm.Load<TTravel>.ToList<TBaseList>;
  try
    for ATravel in AList do
    begin
      StrToShow := StrToShow + ATravel.ListViewItem_Caption + #13;
    end;
    ShowMessage(StrToShow);
  finally
    AList.Free;
  end;
end;

procedure TTabbedwithNavigationForm.Button5Click(Sender: TObject);
var
  AList: TList<ICostGeneric>;
  AItem: ICostGeneric;
  StrToShow: String;
begin
  AList := TIupOrm.Load<TCostGeneric>.ToList<TList<ICostGeneric>>;
  try
    for AItem in AList do
    begin
      StrToShow := StrToShow + AItem.ListViewItem_Caption + ' of type ' + AItem.CostType.ListViewItem_Caption + ' (' + (AItem as TObject).ClassName + ')' + #13;
    end;
    ShowMessage(StrToShow);
  finally
    AList.Free;
  end;
end;

procedure TTabbedwithNavigationForm.Button6Click(Sender: TObject);
var
  AList: TList<ICostGeneric>;
  AItem: ICostGeneric;
  StrToShow: String;
begin
  AList := TIupOrm.Load(TCostGeneric).ToList<TList<ICostGeneric>>;
  try
    for AItem in AList do
    begin
      StrToShow := StrToShow + AItem.ListViewItem_Caption + ' of type ' + AItem.CostType.ListViewItem_Caption + #13;
    end;
    ShowMessage(StrToShow);
  finally
    AList.Free;
  end;
end;

procedure TTabbedwithNavigationForm.Button7Click(Sender: TObject);
var
  DBCreator: IioDBCreator;
begin
  DBCreator := TioDBCreatorFactory.GetDBCreator;
  DBCreator.AutoCreateDatabase;
end;

procedure TTabbedwithNavigationForm.Button8Click(Sender: TObject);
var
  AList: TList<ITravelWithCostList>;
  AItem: ITravelWithCostList;
  ACost: ICostGeneric;
  StrToShow: String;
begin
  AList := TIupOrm.Load<TTravelWithCostList>.ToList<TList<ITravelWithCostList>>;
  try
    for AItem in AList do
    begin
      StrToShow := StrToShow + AItem.ListViewItem_Caption + ' (' + IntToStr(AItem.CostList.Count) + ' items) ' + BoolToStr(AItem.CostList.OwnsObjects) + #13;
    end;
    ShowMessage(StrToShow);
  finally
    AList.Free;
  end;
end;

procedure TTabbedwithNavigationForm.ButtonChangeCostType1Click(Sender: TObject);
var
  ACost: TCostGeneric;
  ACostType: TCostType;
begin
  ACost := TIupOrm.Load<TCostGeneric>.ByOID(2).ToObject;
  ACostType := TIupOrm.Load<TCostType>.ByOID(3).ToObject;
  try
    ACost.CostType := ACostType;
    TIupOrm.Persist(ACost);
    ShowMessage('Operazione completata');
  finally
    ACost.Free;
  end;
end;

procedure TTabbedwithNavigationForm.ButtonChangeCostType2Click(Sender: TObject);
var
  ACost: TCostGeneric;
  ACostType: TCostType;
begin
  ACost := TIupOrm.Load<TCostGeneric>.ByOID(2).ToObject;
  ACostType := TIupOrm.Load<TCostType>.ByOID(2).ToObject;
  try
    ACost.CostType := ACostType;
    ACost.IupOrm.Persist;
//    TIupOrm.Persist(ACost);
    ShowMessage('Operazione completata');
  finally
    ACost.Free;
  end;
end;

procedure TTabbedwithNavigationForm.ButtonCOstsTCostFuelClick(Sender: TObject);
var
  AList: TList<ICostGeneric>;
  AItem: ICostGeneric;
  StrToShow: String;
begin
  AList := TIupOrm.Load<TCostFuel>.ToList<TList<ICostGeneric>>;
  try
    for AItem in AList do
    begin
      StrToShow := StrToShow + AItem.ListViewItem_Caption + ' of type ' + AItem.CostType.ListViewItem_Caption + ' (' + (AItem as TObject).ClassName + ')' + #13;
    end;
    ShowMessage(StrToShow);
  finally
    AList.Free;
  end;
end;

procedure TTabbedwithNavigationForm.ButtonDeleteTravelByIDClick(
  Sender: TObject);
var
  OID: Integer;
begin
  OID := StrToInt(InputBox('New Travel', 'Type new travel description', ''));
  TIupOrm.RefTo(TTravel).ByOID(OID).Delete;
end;

procedure TTabbedwithNavigationForm.ButtonDeleteTravelEmptyDescClick(
  Sender: TObject);
begin
  TIupOrm.RefTo<TTravel>._Where._Property('DESCRIZIONE')._EqualTo('').Delete;
end;

procedure TTabbedwithNavigationForm.ButtonNewTravelClick(Sender: TObject);
var
  InStr: String;
  ATravel: TTravelWithCostList;
  ACost: TCostGeneric;
begin
  InStr := Trim(InputBox('New Travel', 'Type new travel description', ''));
  ATravel := TTravelWithCostList.Create;
  try
    ATravel.Descrizione := InStr;


    ACost := TCostFactory.NewCost(0
                                 ,'Gasolio ***'
                                 ,0
                                 ,TIupOrm.Load<TCostType>.ByOID(2).ToObject
                                 ,StrToDate('26/03/2014')
                                 ,115
                                 ,'Prova'
                                 ,65
                                 ,650
                                 );
    ATravel.CostList.Add(ACost);

    ACost := TCostFactory.NewCost(0
                                 ,'Magnuga ***'
                                 ,0
                                 ,TIupOrm.Load<TCostType>.ByOID(3).ToObject
                                 ,StrToDate('26/03/2014')
                                 ,23.45
                                 ,'Prova'
                                 ,0
                                 ,0
                                 );
    ATravel.CostList.Add(ACost);

    TIupOrm.Persist(ATravel);
//    ACost.IupOrm.Persist;
    ShowMessage('New travel is: ' + IntToStr(ATravel.ID) + ' - ' + ATravel.Descrizione);
  finally
    ATravel.Free;
  end;
end;

procedure TTabbedwithNavigationForm.ButtonUpdateTravelClick(Sender: TObject);
var
  OID: Integer;
  ATravel: TTravel;
begin
  OID := StrToInt(InputBox('Update Travel', 'Type ID', ''));
  ATravel := TIupOrm.Load<TTravel>.ByOID(OID).ToObject;
  ShowMessage(ATravel.ID.ToString + ': ' + ATravel.Descrizione + ' dal ' + DateToStr(ATravel.StartDate) + ' al ' + DateToStr(ATravel.EndDate));
  try
    ATravel.Descrizione := InputBox('Update Travel', 'Descrizione', ATravel.Descrizione);
    ATravel.ObjStatus := osDirty;
    TIupOrm.Persist(ATravel);
  finally
    ATravel.Free;
  end;
end;

procedure TTabbedwithNavigationForm.FormCreate(Sender: TObject);
begin
  TIupOrm.Init('VRManager');
end;

procedure TTabbedwithNavigationForm.FormShow(Sender: TObject);
begin
//  FViewTravelListFrame := TViewFactory.ViewTravelListFrame(TabItem5);
end;

procedure TTabbedwithNavigationForm.PrototypeBindSource1CreateAdapter(
  Sender: TObject; var ABindSourceAdapter: TBindSourceAdapter);
begin
//  ABindSourceAdapter := TListBindSourceAdapter<TCostGeneric>.Create(PrototypeBindSource1, TIupOrm.Load<TCostGeneric>.ToList<TObjectList<TCostGeneric>>);
end;

end.

