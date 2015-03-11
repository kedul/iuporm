unit IupOrm.Containers.Interfaces;

interface

uses
  System.Generics.Collections, System.Types, System.Generics.Defaults;

type

  // Interfaces for generic lists
  IioList<T> = interface
    ['{4493AF3A-ECD6-4754-B56E-23FFAB4BDF33}']
    function Add(const Value: T): Integer;

    procedure AddRange(const Values: array of T); overload;
    procedure AddRange(const Collection: IEnumerable<T>); overload;
    procedure AddRange(const Collection: TEnumerable<T>); overload;

    procedure Insert(Index: Integer; const Value: T);

    procedure InsertRange(Index: Integer; const Values: array of T); overload;
    procedure InsertRange(Index: Integer; const Collection: IEnumerable<T>); overload;
    procedure InsertRange(Index: Integer; const Collection: TEnumerable<T>); overload;

    procedure Pack; overload;
//    procedure Pack(const IsEmpty: TEmptyFunc); overload;

    function Remove(const Value: T): Integer;
    function RemoveItem(const Value: T; Direction: TDirection): Integer;
    procedure Delete(Index: Integer);
    procedure DeleteRange(AIndex, ACount: Integer);
    function Extract(const Value: T): T;
    function ExtractItem(const Value: T; Direction: TDirection): T;

    procedure Exchange(Index1, Index2: Integer);
    procedure Move(CurIndex, NewIndex: Integer);

    function First: T;
    function Last: T;

    procedure Clear;

    function Expand: TList<T>;

    function Contains(const Value: T): Boolean;
    function IndexOf(const Value: T): Integer;
    function IndexOfItem(const Value: T; Direction: TDirection): Integer;
    function LastIndexOf(const Value: T): Integer;

    procedure Reverse;

    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;
    function BinarySearch(const Item: T; out Index: Integer): Boolean; overload;
    function BinarySearch(const Item: T; out Index: Integer; const AComparer: IComparer<T>): Boolean; overload;

    procedure TrimExcess;

    function GetCapacity: Integer;
    procedure SetCapacity(const Value: Integer);
    property Capacity: Integer read GetCapacity write SetCapacity;

    function GetCount: Integer;
    procedure SetCount(const Value: Integer);
    property Count: Integer read GetCount write SetCount;

    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
    property Items[Index: Integer]: T read GetItem write SetItem; default;

    function GetEnumerator: TList<T>.TEnumerator;
  end;

implementation

end.
