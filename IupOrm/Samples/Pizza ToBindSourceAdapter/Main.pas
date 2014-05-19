unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, Data.Bind.GenData,
  Fmx.Bind.GenData, Data.Bind.Components, Data.Bind.ObjectScope, FMX.Layouts,
  FMX.ListBox, FMX.StdCtrls, FMX.Graphics, FMX.TabControl, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, FMX.Objects, FMX.Edit, System.Actions, FMX.ActnList,
  FMX.ListView.Types, FMX.ListView, System.Generics.Collections, Model;

type

  TPizzaList = TObjectList<TPizza>;

  TMainForml = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    MasterToolbar: TToolBar;
    MasterLabel: TLabel;
    DetailToolbar: TToolBar;
    DetailLabel: TLabel;
    PrototypeBindSource1: TPrototypeBindSource;
    BindingsList1: TBindingsList;
    lblName: TLabel;
    imgContact: TImage;
    BackButton: TSpeedButton;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    ChangeTabAction2: TChangeTabAction;
    ListView1: TListView;
    LinkListControlToField2: TLinkListControlToField;
    LinkPropertyToFieldBitmap: TLinkPropertyToField;
    acLoad: TAction;
    btLoad: TButton;
    lblID: TLabel;
    LinkPropertyToFieldText2: TLinkPropertyToField;
    btPersist: TButton;
    edName: TEdit;
    LinkControlToField1: TLinkControlToField;
    btPost: TButton;
    btNew: TButton;
    OpenDialog1: TOpenDialog;
    Button6: TButton;
    acDelete: TAction;
    acNew: TAction;
    acPersist: TAction;
    btDelete: TButton;
    acIupOrmInit: TAction;
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure PrototypeBindSource1CreateAdapter(Sender: TObject;
      var ABindSourceAdapter: TBindSourceAdapter);
    procedure FormDestroy(Sender: TObject);
    procedure btPostClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure acNewExecute(Sender: TObject);
    procedure acPersistExecute(Sender: TObject);
    procedure acLoadExecute(Sender: TObject);
    procedure acIupOrmInitExecute(Sender: TObject);
    procedure acNewUpdate(Sender: TObject);
  private
    { Private declarations }
    FPizzaList: TPizzaList;
    FPizzaListAdapter: TListBindSourceAdapter<TPizza>;
  public
    { Public declarations }
  end;

var
  MainForml: TMainForml;

implementation

uses IupOrm, IupOrm.DB.DBCreator.Factory, IupOrm.CommonTypes;


{$R *.fmx}

procedure TMainForml.acDeleteExecute(Sender: TObject);
begin
  PrototypeBindSource1.Delete;
end;

procedure TMainForml.acIupOrmInitExecute(Sender: TObject);
begin
  // Set the directory name (under the Documents folder)
  TIupOrm.Init('Pizza');
  // AutoCreation and AutoUpdate of the database
  TioDBCreatorFactory.GetDBCreator.AutoCreateDatabase;
end;

procedure TMainForml.acLoadExecute(Sender: TObject);
begin
  PrototypeBindSource1.Refresh;
  Exit;

  FPizzaListAdapter.First; //Bug
  if Assigned(FPizzaList) then FPizzaList.Free;

  // IupOrm call
  FPizzaList := TIupOrm.Load<TPizza>.ToList<TPizzaList>;

  FPizzaListAdapter.SetList(FPizzaList, False);
  FPizzaListAdapter.Active := True;
end;

procedure TMainForml.acNewExecute(Sender: TObject);
begin
  PrototypeBindSource1.InternalAdapter.Append;
end;

procedure TMainForml.acNewUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := PrototypeBindSource1.Active;
end;

procedure TMainForml.acPersistExecute(Sender: TObject);
begin
  TIupOrm.PersistCollection(FPizzaList);
  ShowMessage('Persisted!');
end;

procedure TMainForml.Button6Click(Sender: TObject);
begin
  if not OpenDialog1.Execute
    then Exit;
  if FPizzaListAdapter.State = seBrowse
    then FPizzaListAdapter.Edit;
  (FPizzaListAdapter.Current as TPizza).Img.LoadFromFile(OpenDialog1.FileName);
//  imgContact.Bitmap.LoadFromFile(OpenDialog1.FileName);
end;

procedure TMainForml.FormCreate(Sender: TObject);
begin

  { This defines the default active tab at runtime }
  TabControl1.ActiveTab := TabItem1;
{$IFDEF ANDROID}
  { This hides the toolbar back button on Android }
  BackButton.Visible := False;
{$ENDIF}
end;

procedure TMainForml.FormDestroy(Sender: TObject);
begin
  if Assigned(FPizzaList) then FPizzaList.Free;
end;

procedure TMainForml.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    if TabControl1.ActiveTab = TabItem2 then
    begin
      ChangeTabAction1.Tab := TabItem1;
      ChangeTabAction1.ExecuteTarget(Self);
      Key := 0;
    end;
  end;
end;

procedure TMainForml.ListView1ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
{ This triggers the slide animation }
  ChangeTabAction1.Tab := TabItem2;
  ChangeTabAction1.ExecuteTarget(Self);
  ChangeTabAction1.Tab := TabItem1;
end;

procedure TMainForml.btPostClick(Sender: TObject);
begin
  PrototypeBindSource1.Post;
end;

procedure TMainForml.PrototypeBindSource1CreateAdapter(Sender: TObject;
  var ABindSourceAdapter: TBindSourceAdapter);
begin
  // Directly get the BindSourceAdapter from IupOrm
  ABindSourceAdapter := TIupOrm.Load<TPizza>._Where._Property('ID')._GreaterThan(3).ToActiveListBindSourceAdapter(Self);
end;

end.
