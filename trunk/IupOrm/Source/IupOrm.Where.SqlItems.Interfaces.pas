unit IupOrm.Where.SqlItems.Interfaces;

interface

uses
  IupOrm.Interfaces, IupOrm.Context.Properties.Interfaces, System.Rtti,
  System.Generics.Collections;

type

  IioSqlItemWhere = interface(IioSqlItem)
    ['{0916A6EC-167E-4CD2-8C0B-ADE755E5157B}']
    function GetSql(AProperties:IioContextProperties): String;
    function GetSqlParamName(AProperties:IioContextProperties): String;
    function GetValue(AProperties:IioContextProperties): TValue;
    function HasParameter: Boolean;
  end;

  TWhereItems = TList<IioSqlItem>;

implementation

end.
