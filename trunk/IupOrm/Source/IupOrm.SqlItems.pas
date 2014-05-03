unit IupOrm.SqlItems;

interface

uses
  IupOrm.Interfaces;

type

  // Base per tuttle SqlItems basate su un valore costante
  //  Derivare una classe specificando solo il valore costante.
  TioSqlItem = class (TInterfacedObject, IioSqlItem)
  strict protected
    FSqlText: String;
  public
    constructor Create(ASqlText:String); virtual;
    function GetSql: String; virtual;
  end;

implementation

{ TiuSqlItem }

constructor TioSqlItem.Create(ASqlText: String);
begin
  FSqlText := ASqlText;
end;

function TioSqlItem.GetSql: String;
begin
  Result := FSqlText;
end;

end.
