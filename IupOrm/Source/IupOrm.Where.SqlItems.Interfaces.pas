unit IupOrm.Where.SqlItems.Interfaces;

interface

uses
  IupOrm.Interfaces,
  IupOrm.Context.Properties.Interfaces, System.Generics.Collections;

type

  TWhereItems = TList<IioSqlItem>;

  IioSqlItemWhere = interface(IioSqlItem)
    ['{EF666208-9854-4D68-93E6-DACEF5B1CF2E}']
    procedure SetContextProperties(AContextProperties: IioContextProperties);
  end;

implementation

end.
