unit IupOrm.MVVM.FMX.ViewModel;

interface

uses
  System.SysUtils, System.Classes, IupOrm.MVVM.ViewModel, System.Actions,
  FMX.ActnList;

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

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
