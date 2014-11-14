unit IupOrm.MVVM.FMX.ViewModel;

interface

uses
  System.SysUtils, System.Classes, System.Actions,
  FMX.ActnList, IupOrm.MVVM.ViewModelBase;

type
  TioViewModel = class(TioViewModelBase)
    Commands: TActionList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
