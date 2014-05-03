unit ViewModel.Interfaces;

interface

uses Model.BaseClasses, Model.BaseListClasses, Data.Bind.ObjectScope;

type

  // Interfaccia base di un ViewModel
  IViewModel = interface
    ['{21067A0F-E7B7-49DD-B547-117DFC7F3E9A}']
    // Metodi
    procedure New;
    procedure Load;
    procedure Save;
    procedure Delete;
    function GetBindSourceAdapter(AOwner:TPrototypeBindSource): TBindSourceAdapter;
  end;

  // Interfaccia base di un ViewModel per le liste
  IViewModelList = interface
    ['{D446AB0F-2E2A-42BE-8A8F-2B8357ACD570}']
    // Metodi
    procedure New;
    procedure Load;
    procedure Save(AObj:TBaseClass);
    procedure Delete(AObj:TBaseClass);
    procedure SaveAll;
    procedure DeleteAll;
    procedure SetBindSource(ABindSource:TBaseObjectBindSource);
  end;






  // Interfaccia base di un ViewModel
  IVMBase = interface
    ['{CBB6A042-1E6E-4746-987F-56887B1400A9}']
    // Metodi
    procedure New;
    procedure Get;
    procedure Post;
    procedure Delete;
  end;

  // Interfaccia base per un VM elenco viaggi
  IVMTravelList = interface(IVMBase)
    ['{9AAD0241-E76B-41C3-93BF-B9E0CCCEE386}']
    // Methods
    function GetDataObject: TTravelList;
    function GetDataObjectBindSourceAdapter(AOwner:TPrototypeBindSource): TBindSourceAdapter;
    // Properties
    property DataObject: TTravelList read GetDataObject;
  end;

implementation

end.
