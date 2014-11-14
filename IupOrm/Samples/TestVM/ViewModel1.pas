unit ViewModel1;

interface

uses
  System.SysUtils, System.Classes, IupOrm.MVVM.VCL.ViewModel, System.Actions, Vcl.ActnList,
  IupOrm.MVVM.Interfaces, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type

  TioViewModel1 = class(TioViewModel)
    acHello: TAction;
    FDQuery1: TFDQuery;
    procedure acHelloExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses IupOrm, Vcl.Dialogs;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TioViewModel1.acHelloExecute(Sender: TObject);
begin
  inherited;
  ShowMessage('Hello from ViewModel1');
end;

initialization

  TIupOrm.DependencyInjection.RegisterClass(TioViewModel1).Implements('IioViewModel').Execute;

end.
