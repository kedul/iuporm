unit IupOrm.DuckTyped.Interfaces;

interface

type

  IioDuckTypedList = interface
    ['{BD3A3AC2-A7C4-46D1-9BE6-5C32E17D871C}']
    procedure Add(AObject: TObject);
    procedure Clear;
    function Count: Integer;
    function GetEnumerator: IEnumerator;
    function GetItem(Index: Integer): TObject;
  end;

implementation

end.
