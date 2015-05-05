unit IupOrm.MVVM.Interfaces;

interface

uses
  IupOrm.LiveBindings.Interfaces, Data.Bind.ObjectScope, System.Classes;

type

  TioViewDataType = (dtSingle, dtList);

  IioView = interface
    ['{AE9431A3-4D53-4ACF-98A1-7870DB6F7B0F}']
    function FindComponent(const AName: string): TComponent;
  end;

  IioViewData = interface
    ['{A8E74DA6-81BF-446C-A524-7E98F0D09CEF}']
    function DataObj: TObject;
    function BindSourceAdapter: TBindSourceAdapter;
  end;

  IioViewModel = interface
    ['{B8A32927-A4DA-4B8D-8545-AB68DEDF17BC}']
    function ViewData: IioViewData;
    function GetActionByName(AActionName:String): TBasicAction;
    procedure BindActions(const AView:IioView);
  end;

implementation

end.
