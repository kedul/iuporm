unit IupOrm.MVVM.VCL.ViewModel;

interface

uses
  System.SysUtils, System.Classes, System.Actions,
  Vcl.ActnList, IupOrm.MVVM.ViewModelBase;

type
  TioViewModel = class(TioViewModelBase)
    Commands: TActionList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


end.
