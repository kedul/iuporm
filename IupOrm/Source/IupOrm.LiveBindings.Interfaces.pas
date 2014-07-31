unit IupOrm.LiveBindings.Interfaces;

interface

uses
  System.Generics.Collections, Data.Bind.ObjectScope,
  IupOrm.Context.Properties.Interfaces, IupOrm.CommonTypes;

type

  // The common ancestor for all PrototypeBindSource components
  TioBaseBindSource = TBaseObjectBindSource;

  IioActiveBindSourceAdapter = interface
    ['{F407B515-AE0B-48FD-B8C3-0D0C81774A58}']
    procedure Persist(ReloadData:Boolean=False);
  end;

  IioContainedBindSourceAdapter = interface
    ['{66AF6AD7-9093-4526-A18C-54447FB220A3}']
    procedure Free;
    procedure SetMasterProperty(AMasterProperty: IioContextProperty);
    procedure ExtractDetailObject(AMasterObj: TObject); overload;
    function GetDetailBindSourceAdapter(AMasterPropertyName:String): TBindSourceAdapter;
  end;

  // BindSourceAdapter List
  TioDetailAdapters = TDictionary<String, IioContainedBindSourceAdapter>;

  // Bind source adapter container
  IioDetailBindSourceAdaptersContainer = interface
    ['{B374E226-D7A9-4A44-9BB6-DF85AC283598}']
    procedure SetMasterObject(AMasterObj: TObject);
    function GetBindSourceAdapter(AMasterClassName:String; AMasterPropertyName:String): TBindSourceAdapter;
  end;

implementation

end.