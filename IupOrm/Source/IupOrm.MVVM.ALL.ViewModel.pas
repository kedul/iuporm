unit IupOrm.MVVM.ALL.ViewModel;

interface

uses
  System.Classes, IupOrm.MVVM.ViewModelBase, System.Actions,
{$IF DECLARED(TFmxObject)}
  FMX.ActnList,
{$ELSE}
  VCL.ActnList,
{$IFEND}
  System.SysUtils, FMX.ActnList;

type
  TioViewModel = class(TioViewModelBase)
    Commands: TActionList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
