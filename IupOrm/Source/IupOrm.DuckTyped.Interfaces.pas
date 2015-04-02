unit IupOrm.DuckTyped.Interfaces;

interface

uses
  System.Classes;

type

  IioDuckTypedStreamObject = interface
    ['{D95AD3B5-02AC-49E6-B54E-2ECAA7D5B54B}']
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    function IsEmpty: Boolean;
  end;

  IioDuckTypedList = interface
    ['{BD3A3AC2-A7C4-46D1-9BE6-5C32E17D871C}']
    procedure Add(AObject: TObject);
    procedure Clear;
    function Count: Integer;
    function GetEnumerator: IEnumerator;
    function GetItem(Index: Integer): TObject;
    // OwnsObjects property
    procedure SetOwnsObjects(AValue:Boolean);
    function GetOwnsObjects: Boolean;
    property OwnsObjects:Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

end.
