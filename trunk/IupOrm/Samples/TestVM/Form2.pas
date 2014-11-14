unit Form2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DM2, Vcl.ExtCtrls;

type
  Tfrm2 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FDM: TDataModule2;
  public
    { Public declarations }
  end;

var
  frm2: Tfrm2;

implementation

uses
  Vcl.ActnList;

{$R *.dfm}

procedure Tfrm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure Tfrm2.FormCreate(Sender: TObject);
var
  Obj: TObject;
begin
  FDM := TDataModule2.Create(Self);
  FDM.Name := 'CratedByForm2';
  // ---------------------------------------------------------------------------
//  Button1.Action := FDM.acCiao;
  // ---------------------------------------------------------------------------
  Obj := nil;
  Obj := FDM.FindComponent(Button1.Action.Name);
  if Assigned(Obj) then Button1.Action := Obj as TAction;
  // ---------------------------------------------------------------------------
end;

end.
