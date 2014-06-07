unit IupOrm.Context.Interfaces;

interface

uses
  IupOrm.Where, IupOrm.CommonTypes, IupOrm.Context.Table.Interfaces,
  IupOrm.Context.Properties.Interfaces, System.Rtti;

type

  // Context interface
  IioContext = interface
    ['{6B512CDA-23C6-42A3-AC44-905344B019E9}']
    function GetClassRef: TioClassRef;
    function GetTable: IioContextTable;
    function GetProperties: IioContextProperties;
    function ClassFromField: IioClassFromField;
    function IsClassFromField: Boolean;
    function RttiContext: TRttiContext;
    function RttiType: TRttiInstanceType;
    // Blob field present
    function BlobFieldExists: Boolean;
    // DataObject
    procedure SetDataObject(AValue: TObject);
    function GetDataObject: TObject;
    property DataObject:TObject read GetDataObject write SetDataObject;
    // ObjStatusExist
    function ObjStatusExist: Boolean;
    // ObjectStatus
    procedure SetObjectStatus(AValue: TIupOrmObjectStatus);
    function GetObjectStatus: TIupOrmObjectStatus;
    property ObjectStatus:TIupOrmObjectStatus read GetObjectStatus write SetObjectStatus;
    // Where
    procedure SetWhere(AWhere: TioWhere);
    function GetWhere: TioWhere;
    property Where:TioWhere read GetWhere write SetWhere;
  end;

implementation

end.
