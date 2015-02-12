unit ViewModel1;

interface

uses
  System.SysUtils, System.Classes,FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.Actions, FMX.ActnList, IupOrm.MVVM.ALL.ViewModel, Vcl.ActnList;

type

  TioViewModel1 = class(TioViewModel)
    acHello: TAction;
    FDQuery1: TFDQuery;
    acEnableDisable: TAction;
    procedure acHelloExecute(Sender: TObject);
    procedure acEnableDisableExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses IupOrm, Vcl.Dialogs;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TioViewModel1.acEnableDisableExecute(Sender: TObject);
begin
  inherited;
  acHello.Enabled := not acHello.Enabled;
end;

procedure TioViewModel1.acHelloExecute(Sender: TObject);
begin
  inherited;
  ShowMessage('Hello from ViewModel1');
end;

initialization

  TIupOrm.DependencyInjection.RegisterClass(TioViewModel1).Implements('IioViewModel').Execute;

end.
