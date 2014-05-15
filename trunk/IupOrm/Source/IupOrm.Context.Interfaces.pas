unit IupOrm.Context.Interfaces;

interface

uses
  IupOrm.Where, IupOrm.CommonTypes, IupOrm.Context.Table.Interfaces,
  IupOrm.Context.Properties.Interfaces, System.Rtti;

type

  //

  // Context interface
  IioContext = interface
    ['{6B512CDA-23C6-42A3-AC44-905344B019E9}']
    function GetClassRef: TioClassRef;
    function GetTable: IioContextTable;
    function GetProperties: IioContextProperties;
    function GetWhere: TioWhere;
    function ClassFromField: IioClassFromField;
    function IsClassFromField: Boolean;
    function RttiContext: TRttiContext;
    function RttiType: TRttiInstanceType;
    // Blob field present
    function BlobFieldExists: Boolean;
    // DataObject
    function GetDataObject: TObject;
    procedure SetDataObject(AValue: TObject);
    property DataObject:TObject read GetDataObject write SetDataObject;
    // ObjectStatus
    function GetObjectStatus: TIupOrmObjectStatus;
    procedure SetObjectStatus(AValue: TIupOrmObjectStatus);
    property ObjectStatus:TIupOrmObjectStatus read GetObjectStatus write SetObjectStatus;
  end;

implementation

end.
