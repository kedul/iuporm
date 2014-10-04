unit IupOrm.MVVM.VCL.ViewModel;

interface

uses
  System.SysUtils, System.Classes, IupOrm.MVVM.ViewModel, System.Actions,
  Vcl.ActnList;

type
  TioViewModel = class(TioViewModelBase)
    Commands: TActionList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ioViewModel: TioViewModel;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
