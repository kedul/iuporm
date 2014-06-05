unit IupOrm.Where.SqlItems.Interfaces;

interface

uses
  IupOrm.Interfaces,
  IupOrm.Context.Properties.Interfaces, System.Generics.Collections;

type

  IioSqlItemWhere = interface(IioSqlItem)
    ['{0916A6EC-167E-4CD2-8C0B-ADE755E5157B}']
    procedure SetContextProperties(AContextProperties: IioContextProperties);
  end;

  TWhereItems = TList<IioSqlItem>;

implementation

end.
