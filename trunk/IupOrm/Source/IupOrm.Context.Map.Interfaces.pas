unit IupOrm.Context.Map.Interfaces;

interface

uses
  IupOrm.CommonTypes, IupOrm.Context.Table.Interfaces,
  IupOrm.Context.Properties.Interfaces, System.Rtti;

type

  // IioMap interface
  IioMap = interface
    ['{874979DB-BE8E-40CE-89DC-C265302D8E16}']
    function GetClassRef: TioClassRef;
    function GetTable: IioContextTable;
    function GetProperties: IioContextProperties;
    function ClassFromField: IioClassFromField;
    function RttiContext: TRttiContext;
    function RttiType: TRttiInstanceType;
    // Blob field present
    function BlobFieldExists: Boolean;
  end;

implementation

end.
