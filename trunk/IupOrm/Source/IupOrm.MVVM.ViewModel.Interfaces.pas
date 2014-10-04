unit IupOrm.MVVM.ViewModel.Interfaces;

interface

uses
  IupOrm.LiveBindings.Interfaces;

type

  IioViewData = interface
    ['{A8E74DA6-81BF-446C-A524-7E98F0D09CEF}']
    function DataObj: TObject;
    procedure SetDataObj(ADataObj:TObject);
    function BindSourceAdapter: IioActiveBindSourceAdapter;
    procedure SetBindSourceAdapter(ABindSourceAdapter: IioActiveBindSourceAdapter);
  end;

  IioViewModel = interface
    ['{B8A32927-A4DA-4B8D-8545-AB68DEDF17BC}']
  end;

implementation

end.
