unit IupOrm.DB.DBCreator.Interfaces;

interface

uses
  System.Generics.Collections, System.Rtti, System.Classes,
  IupOrm.DB.Interfaces;

type

  TioDBCreatorTableState = (tsOk, tsNew, tsModified);

  IioDBCreatorField = interface;
  IioDBCreatorTable = interface;
  TioDBCreatorFieldList = TDictionary<String,IioDBCreatorField>;
  TioDBCreatorTableList = TDictionary<String,IioDBCreatorTable>;

  IioDBCreatorField = interface
    ['{45B1CD52-FBDA-460A-B0D4-C558960F8257}']
    // FieldName
    function GetFieldName: String;
    property FieldName:String read GetFieldName;
    // IsKeyFeld
    function GetIsKeyField: Boolean;
    property IsKeyField:Boolean read GetIsKeyField;
    // FieldType (contains field type description with length if necessary)
    function GetFieldType: String;
    property FieldType:String read GetFieldType;
    // Rtti property reference
    function GetRttiProperty: TRttiProperty;
    property RttiProperty:TRttiProperty read GetRttiProperty;
    // DBFieldExists
    procedure SetDBFieldExist(AValue:Boolean);
    function GetDBFieldExist: Boolean;
    property DBFieldExist:Boolean read GetDBFieldExist write SetDBFieldExist;
    // DBFieldSameType
    procedure SetDBFieldSameType(AValue:Boolean);
    function GetDBFieldSameType: Boolean;
    property DBFieldSameType:Boolean read GetDBFieldSameType write SetDBFieldSameType;
  end;

  IioDBCreatorTable = interface
    ['{B8CB16FA-96F5-4858-918B-610DADCE40A1}']
    function FieldExists(AFieldName:String): Boolean;
    // TableName
    function GetTableName: String;
    Procedure SetTableName(AValue:String);
    property TableName:String read GetTableName write SetTableName;
    // Fields
    function GetFields: TioDBCreatorFieldList;
    property Fields:TioDBCreatorFieldList read GetFields;
    // TableState
    function TableState: TioDBCreatorTableState;
    // IsClassFromField
    function IsClassFromField: Boolean;
    // IDField
    function IDField: IioDBCreatorField;
  end;

  IioDBCreator = interface
    ['{BE91C118-CF4A-495C-94B5-638149AED5DC}']
    procedure AutoCreateDatabase;
    function Tables: TioDBCreatorTableList;
  end;

  IioDBCreatorSqlGenerator = interface
    ['{8E138570-0918-495C-845A-A65D3FEF4961}']
    function RttiPropertyToFieldType(AProp:TRttiProperty): String;
    function TableExists(ATable:IioDBCreatorTable): Boolean;
    procedure LoadFieldsState(ATable:IioDBCreatorTable);
    procedure AutoCreateDatabase(ADBCreator: IioDBCreator);
  end;

implementation

end.
