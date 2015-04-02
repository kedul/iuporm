unit TabbedFormwithNavigation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.Forms, FMX.Dialogs, FMX.TabControl, FMX.StdCtrls,
  System.Actions, FMX.ActnList, FMX.Gestures, FMX.Edit, FMX.ListView.Types, Data.Bind.GenData, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.ObjectScope,
  IupOrm.LiveBindings.PrototypeBindSource, FMX.ListView, Fmx.Bind.GenData;

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
    GestureManager1: TGestureManager;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    DetailListView: TListView;
    MasterListView: TListView;
    TabControl3: TTabControl;
    EditFirstName: TEdit;
    Button8: TButton;
    BSMaster: TioPrototypeBindSource;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    LinkControlToField1: TLinkControlToField;
    BSDetail: TioPrototypeBindSource;
    LinkListControlToField2: TLinkListControlToField;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure TabControl1Gesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TabbedwithNavigationForm: TTabbedwithNavigationForm;

implementation

uses
  Model, IupOrm, Interfaces, System.Generics.Collections, IupOrm.Containers.List,
  IupOrm.Containers.Interfaces, IupOrm.LiveBindings.InterfaceListBindSourceAdapter,
  IupOrm.Rtti.Utilities;

{$R *.fmx}

procedure TTabbedwithNavigationForm.Button1Click(Sender: TObject);
var
  APerson: TPerson;
begin
  APerson := TIupOrm.Load<TPerson>.ByOID(Edit1.Text.ToInteger).ToObject;
  ShowMessage(APerson.ID.ToString + ' - ' + APerson.FullName + ' (' + APerson.ClassNameProp + ') ' + APerson.Phones.Count.ToString + ' Numbers');
  APerson.Free;
end;

procedure TTabbedwithNavigationForm.Button2Click(Sender: TObject);
var
  APerson: IPerson;
begin
  APerson := TIupOrm.Load<TPerson>.ByOID(Edit1.Text.ToInteger).ToObject;
  ShowMessage(APerson.ID.ToString + ' - ' + APerson.FullName + ' (' + APerson.ClassNameProp + ') ' + APerson.Phones.Count.ToString + ' Numbers');
end;

procedure TTabbedwithNavigationForm.Button3Click(Sender: TObject);
var
  AList: TList<IPerson>;
begin
  AList := TIupOrm.Load<IPerson>.ToList;
  ShowMessage(AList.Count.ToString + ' IPerson');
  AList.Free;
end;

procedure TTabbedwithNavigationForm.Button4Click(Sender: TObject);
var
  AList: TioInterfacedList<IPerson>;
begin
  AList := TioInterfacedList<IPerson>.Create;
  TIupOrm.Load<IPerson>.ToList(AList);
  ShowMessage(AList.Count.ToString + ' IPerson');
  AList.Free;
end;

procedure TTabbedwithNavigationForm.Button5Click(Sender: TObject);
var
  AList: IioList<IPerson>;
begin
  AList := TIupOrm.Load<IPerson>.ToInterfacedList;
  ShowMessage(AList.Count.ToString + ' IPerson');
end;

procedure TTabbedwithNavigationForm.Button6Click(Sender: TObject);
var
  AList: IioList<ICustomer>;
begin
  AList := TIupOrm.Load<ICustomer>.ToInterfacedList;
  ShowMessage(AList.Count.ToString + ' ICustomer');
end;

procedure TTabbedwithNavigationForm.Button7Click(Sender: TObject);
var
  AList: IioList<IPerson>;
begin
  AList := TIupOrm.Load<IPerson>('Customer').ToInterfacedList;
  ShowMessage(AList.Count.ToString + ' IPerson (as Customer)');
end;

procedure TTabbedwithNavigationForm.FormCreate(Sender: TObject);
begin
  { This defines the default active tab at runtime }
  TabControl1.ActiveTab := TabItem1;
{$IFDEF ANDROID}
  { This hides the toolbar back button on Android }
  btnBack.Visible := False;
{$ENDIF}
end;

procedure TTabbedwithNavigationForm.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    if (TabControl1.ActiveTab = TabItem1) and (TabControl2.ActiveTab = TabItem6) then
    begin
      ChangeTabAction2.Tab := TabItem5;
      ChangeTabAction2.ExecuteTarget(Self);
      ChangeTabAction2.Tab := TabItem6;
      Key := 0;
    end;
  end;
end;

procedure TTabbedwithNavigationForm.TabControl1Gesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
{$IFDEF ANDROID}
  case EventInfo.GestureID of
    sgiLeft:
    begin
      if TabControl1.ActiveTab <> TabControl1.Tabs[TabControl1.TabCount-1] then
        TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex+1];
      Handled := True;
    end;

    sgiRight:
    begin
      if TabControl1.ActiveTab <> TabControl1.Tabs[0] then
        TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex-1];
      Handled := True;
    end;
  end;
{$ENDIF}
end;

end.
