unit IupOrm.Context.Table.Interfaces;

interface

uses
  IupOrm.Interfaces, IupOrm.Attributes, IupOrm.CommonTypes;

type

  IioGroupBy = interface(IioSqlItem)
    ['{E57CDC09-3D2B-432B-9114-B7CCB1EDCCA3}']
  end;

  IioJoinItem = interface(IioSqlItem)
    ['{93E0B456-6BD1-464C-BDA7-FF1F014F6B76}']
    function GetJoinType: TioJoinType;
    function GetJoinClassRef: TioClassRef;
    function GetJoinCondition: String;
  end;

  IioJoins = interface(IioSqlItem)
    ['{8BAACD49-D42C-4278-97AA-EAE00A5EEA52}']
    procedure Add(AJoinItem:IioJoinItem);
  end;

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
    function GetJoin: IioJoins;
    function GetGroupBy: IioGroupBy;
    function GetConnectionDefName: String;
  end;

implementation

end.
