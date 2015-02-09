unit IupOrm.Context.Properties.Interfaces;

interface

uses
  IupOrm.Attributes,
  IupOrm.CommonTypes,
  IupOrm.Interfaces,
  System.Rtti,
  System.Generics.Collections, IupOrm.Context.Table.Interfaces;

type

  // ReadWrite options (for properties and even classes)
  TioReadWrite = (iorwReadOnly, iorwReadWrite, iorwWriteOnly);

  // Options set for GetSql functions parameter
  TioSqlRequestType = (ioAll=0, ioSelect, ioUpdate, ioInsert, ioDelete, ioExist);

  IioContextProperty = interface
    ['{A79DD7E8-D2B2-4F78-A07A-7757605AC94C}']
    function GetLoadSql: String;
    function LoadSqlExist: Boolean;
    function GetName: string;
    function GetSqlQualifiedFieldName: String;
    function GetSqlFullQualifiedFieldName: String;
    function GetSqlFieldName: String;
    function GetSqlFieldAlias: String;
    function GetSqlParamName: String;
    function GetFieldType: String;
    function IsBlob: Boolean;
    function IsStream: Boolean;
    function GetValue(Instance: Pointer): TValue;
    procedure SetValue(Instance: Pointer; AValue: TValue);
    function GetSqlValue(ADataObject: TObject): string;
    function GetRttiProperty: TRttiProperty;
    function GetRelationType: TioRelationType;
    function GetRelationChildClassRef: TioClassRef;
    function GetRelationChildPropertyName: String;
    function GetRelationLoadType: TioLoadType;
    function GetRelationChildObject(Instance: Pointer): TObject;
    function GetRelationChildObjectID(Instance: Pointer): String;
    procedure SetTable(ATable:IioContextTable);
    procedure SetFieldData;
    procedure SetLoadSqlData;
    function IsSqlRequestCompliant(ASqlRequestType:TioSqlRequestType): Boolean;
    procedure SetIsID(AValue:Boolean);
    function IsID: Boolean;
    function IsWriteEnabled: Boolean;
    function IsReadEnabled: Boolean;
  end;

  IioContextProperties = interface(IioSqlItem)
    ['{AB30A3A2-640C-4BEF-B301-2CB7C855037B}']
    function GetEnumerator: TEnumerator<IupOrm.Context.Properties.Interfaces.IioContextProperty>;
    procedure Add(AProperty: IioContextProperty; AIsId: Boolean = False);
    function GetIdProperty: IioContextProperty;
    function GetPropertyByName(APropertyName:String): IioContextProperty;
    procedure SetTable(ATable:IioContextTable);
    function GetSql(ASqlRequestType:TioSqlRequestType=ioAll): String; overload;
    procedure SetFieldData;
    procedure SetLoadSqlData;
    // Blob field present
    function BlobFieldExists: Boolean;
    // ObjectStatus Exist
    function ObjStatusExist: Boolean;
    // ObjectStatus property
    function GetObjStatusProperty: IioContextProperty;
    procedure SetObjStatusProperty(AValue: IioContextProperty);
    property ObjStatusProperty:IioContextProperty read GetObjStatusProperty write SetObjStatusProperty;
  end;

implementation

end.
