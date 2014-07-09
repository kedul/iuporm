unit IupOrm.Context.Properties.Interfaces;

interface

uses
  IupOrm.Attributes,
  IupOrm.CommonTypes,
  IupOrm.Interfaces,
  System.Rtti,
  System.Generics.Collections, IupOrm.Context.Table.Interfaces;

type

  IioContextProperty = interface
    ['{A79DD7E8-D2B2-4F78-A07A-7757605AC94C}']
    function GetName: string;
    function GetQualifiedSqlFieldName: string;
    function GetFullQualifiedSqlFieldName: String;
    function GetSqlFieldName: String;
    function GetSqlFieldAlias: String;
    function GetSqlParamName: String;
    function GetFieldType: String;
    function IsBlob: Boolean;
    function GetValue(Instance: Pointer): TValue;
    procedure SetValue(Instance: Pointer; AValue: TValue);
    function GetSqlValue(ADataObject: TObject): string;
    function GetRttiProperty: TRttiProperty;
    function GetRelationType: TioRelationType;
    function GetRelationChildClassRef: TioClassRef;
    function GetRelationChildPropertyName: String;
    function GetRelationChildObject(Instance: Pointer): TObject;
    function GetRelationChildObjectID(Instance: Pointer): String;
    procedure SetTable(ATable:IioContextTable);
    procedure SetFieldData;
  end;

  IioContextProperties = interface(IioSqlItem)
    ['{AB30A3A2-640C-4BEF-B301-2CB7C855037B}']
    function GetEnumerator: TEnumerator<IupOrm.Context.Properties.Interfaces.IioContextProperty>;
    procedure Add(AProperty: IioContextProperty; AIsId: Boolean = False);
    function GetIdProperty: IioContextProperty;
    function GetPropertyByName(APropertyName:String): IioContextProperty;
    procedure SetTable(ATable:IioContextTable);
    function GetSqlQualified: String;
    function GetSqlFullQualified: String;
    procedure SetFieldData;
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
