unit DM2;

interface

uses
  System.SysUtils, System.Classes, System.Actions, Vcl.ActnList;

type
  TDataModule2 = class(TDataModule)
    ActionList1: TActionList;
    acCiao: TAction;
    procedure acCiaoExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Vcl.Dialogs;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDataModule2.acCiaoExecute(Sender: TObject);
begin
  ShowMessage('Ciao da: ' + Self.Name);
end;

end.
