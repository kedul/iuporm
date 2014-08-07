unit IupOrm.LiveBindings.Interfaces;

interface

uses
  System.Generics.Collections, Data.Bind.ObjectScope,
  IupOrm.Context.Properties.Interfaces, IupOrm.CommonTypes, System.Classes;

type

  // Bind source adapters notification type
  TioBSANotificationType = (ntAfterPost, ntAfterDelete);

  // Bind source adapters notification interface
  IioBSANotification = interface
    ['{CE7FCAD1-5D60-4C5C-9BE6-7D6E36571AE3}']
    function Sender: TObject;
    function Subject: TObject;
    function NotificationType: TioBSANotificationType;
  end;

  // Interface (without RefCount) for ioBindSources detection
  //  (useful for detect IupOrm bind sources to pass itself
  //  to the ActiveBindSourceAdapter for notify changes)
  IioNotifiableBindSource = interface
    ['{2DFC1B43-4AE2-4402-89B3-7A134938EFE6}']
    procedure Notify(Sender:TObject; ANotification:IioBSANotification);
  end;

  // The common ancestor for all PrototypeBindSource components
  TioBaseBindSource = TBaseObjectBindSource;

  // Bind source adapter container
  IioDetailBindSourceAdaptersContainer = interface
    ['{B374E226-D7A9-4A44-9BB6-DF85AC283598}']
    procedure SetMasterObject(AMasterObj: TObject);
    function GetBindSourceAdapter(AMasterClassName:String; AMasterPropertyName:String): TBindSourceAdapter;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification);
  end;

  IioActiveBindSourceAdapter = interface
    ['{F407B515-AE0B-48FD-B8C3-0D0C81774A58}']
    procedure Persist(ReloadData:Boolean=False);
  end;

  IioContainedBindSourceAdapter = interface
    ['{66AF6AD7-9093-4526-A18C-54447FB220A3}']
    procedure Free;
    procedure SetMasterAdapterContainer(AMasterAdapterContainer:IioDetailBindSourceAdaptersContainer);
    procedure SetMasterProperty(AMasterProperty: IioContextProperty);
    procedure SetBindSource(ABindSource:TObject);
    procedure ExtractDetailObject(AMasterObj: TObject); overload;
    function GetDetailBindSourceAdapter(AMasterPropertyName:String): TBindSourceAdapter;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification);
  end;

  // BindSourceAdapter List
  TioDetailAdapters = TDictionary<String, IioContainedBindSourceAdapter>;

implementation

end.
