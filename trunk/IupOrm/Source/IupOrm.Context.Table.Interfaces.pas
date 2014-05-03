unit IupOrm.Context.Table.Interfaces;

interface

uses
  IupOrm.Interfaces;

type

  IioClassFromField = interface
    ['{D15A9A28-FB90-4753-BE4A-7484A834CD2D}']
    function GetSqlFieldName: string;
    function GetValue: String;
    function GetSqlValue: string;
    function GetClassName: String;
    function GetQualifiedClassName: String;
    function QualifiedClassNameFromClassInfoFieldValue(AValue:String): String;
  end;

  IioContextTable = interface(IioSqlItem)
    ['{715BFF11-0A82-4B39-B002-451854729DC2}']
    function GetClassFromField: IioClassFromField;
    function IsClassFromField: Boolean;
    function TableName: String;
  end;

implementation

end.
