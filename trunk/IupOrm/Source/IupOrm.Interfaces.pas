unit IupOrm.Interfaces;

interface

uses
  Data.Bind.ObjectScope;

type

  IioSqlItem = interface
    ['{C29DAA7F-55F7-4393-BB36-3E0F2375A0A9}']
    procedure Free;
    function GetSql: String;
  end;

implementation

end.
