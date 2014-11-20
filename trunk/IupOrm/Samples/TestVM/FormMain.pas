unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DM2, System.TypInfo, Data.Bind.Components, Data.Bind.ObjectScope,
  IupOrm.LiveBindings.PrototypeBindSource, IupOrm.Attributes, System.SyncObjs;

type

  [ioMarker('IDog')]
  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    ioPrototypeBindSource1: TioPrototypeBindSource;
    Button11: TButton;
    Button12: TButton;
    [ioAction('acHello')]
    ButtonHello: TButton;
    [ioAction('acEnableDisable')]
    ButtonHelloEnableDisable: TButton;
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
  private
    { Private declarations }
    FDM2_1: TDataModule2;
    FDM2_2: TDataModule2;
    FCriticalSection: TCriticalSection;
  public
    { Public declarations }
    function GetInterfaceData<T:IInterface>: String; overload;
    function GetInterfaceData(pinfo:PTypeInfo): String; overload;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Form2, Interfaces, Dog, IupOrm,
  System.Rtti, ViewModel1;

{$R *.dfm}

procedure TfrmMain.Button10Click(Sender: TObject);
var
  ADog: IDog;
begin
  ADog := TIupOrm.DependencyInjection.Locate<IDog>.Get;
  ADog.Abbaia;
end;

procedure TfrmMain.Button11Click(Sender: TObject);
begin
  if FCriticalSection.TryEnter then ShowMessage('Critical section acquired');
end;

procedure TfrmMain.Button12Click(Sender: TObject);
begin
  FCriticalSection.Release;
end;

procedure TfrmMain.Button5Click(Sender: TObject);
begin
  FDM2_1 := TDataModule2.Create(Self);
end;

procedure TfrmMain.Button6Click(Sender: TObject);
begin
  FDM2_2 := TDataModule2.Create(Self);
  FDM2_2.Name := 'Modified';
end;

procedure TfrmMain.Button7Click(Sender: TObject);
begin
  Tfrm2.Create(nil).Show;
end;

procedure TfrmMain.Button8Click(Sender: TObject);
begin
  ShowMessage(Self.GetInterfaceData<IViewModel>);
end;

procedure TfrmMain.Button9Click(Sender: TObject);
var
  AViewModel: IViewModel;
begin
  ShowMessage(GetInterfaceData(PTypeInfo(AviewModel)));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FCriticalSection := TCriticalSection.Create;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FCriticalSection.Free;
end;

function TfrmMain.GetInterfaceData(pinfo: PTypeInfo): String;
var
  pdata: PTypeData;
begin
  if pinfo = nil then Exit('No GUID in the interface!');
  pdata := GetTypeData(pinfo);
  Result:=pinfo.name+': '+GUIDtoString(pdata.Guid);
end;

function TfrmMain.GetInterfaceData<T>: String;
var
  pinfo: PTypeInfo;
  pdata: PTypeData;
begin
  pinfo := TypeInfo(T);
  if pinfo = nil then Exit('No GUID in the interface!');
  pdata := GetTypeData(pinfo);
  Result:=pinfo.name+': '+GUIDtoString(pdata.Guid);
end;

end.
