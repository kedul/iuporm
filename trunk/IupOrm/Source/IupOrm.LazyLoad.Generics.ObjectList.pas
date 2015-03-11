unit IupOrm.LazyLoad.Generics.ObjectList;

interface

uses
  System.Generics.Collections, IupOrm.CommonTypes, System.Types,
  System.Generics.Defaults, IupOrm.LazyLoad.Interfaces;

type

  TioObjectList<T: class> = class(TObjectList<T>, IioLazyLoadable)



  // ===========================================================================
  // PARTE AGGIUNTA/MODIFICATA DA IUPORM PER LA GESTIONE DEL LAZY LOAD
  // ---------------------------------------------------------------------------
  strict private type
    TInternalObjType = TObjectList<T>;
    arrayofT = array of T;  // Già presente nell'antenato
  strict private
    FioLazyLoader: IioLazyLoader<TInternalObjType>;
    function GetCapacity: Integer;
    function GetCount: Integer;
    function GetItem(Index: Integer): T;
    function GetItems: arrayofT;
    procedure SetCapacity(const Value: Integer);
    procedure SetCount(const Value: Integer);
    procedure SetItem(Index: Integer; const Value: T);
  strict protected
    function ioLazyLoader: IioLazyLoader<TInternalObjType>;
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);
  public
    constructor Create;
    procedure SetRelationInfo(const ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName:String; const ARelationChildID:Integer);
    function GetInternalObject: TObject;
    // Part for the support of the IioLazyLoadable interfaces (Added by IupOrm)
    //  because is not implementing IInterface
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  // ===========================================================================



  public

    class procedure Error(const Msg: string; Data: NativeInt); overload; virtual;
{$IFNDEF NEXTGEN}
    class procedure Error(Msg: PResStringRec; Data: NativeInt); overload;
{$ENDIF  NEXTGEN}

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

    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;  // IupOrm added (modified with getter and setter methods)

    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: T read GetItem write SetItem; default;
    property List: arrayofT read GetItems;

    function GetEnumerator: TList<T>.TEnumerator;
  end;

implementation

uses
  IupOrm, IupOrm.LazyLoad.Factory;

{ TioList<T> }

function TioObjectList<T>.Add(const Value: T): Integer;
begin
  Result := ioLazyLoader.GetInternalObj.Add(Value);
end;

procedure TioObjectList<T>.AddRange(const Collection: IEnumerable<T>);
begin
  ioLazyLoader.GetInternalObj.AddRange(Collection);
end;

procedure TioObjectList<T>.AddRange(const Values: array of T);
begin
  ioLazyLoader.GetInternalObj.AddRange(Values);
end;

procedure TioObjectList<T>.AddRange(const Collection: TEnumerable<T>);
begin
  ioLazyLoader.GetInternalObj.AddRange(Collection);
end;

function TioObjectList<T>.BinarySearch(const Item: T; out Index: Integer): Boolean;
begin
  Result := ioLazyLoader.GetInternalObj.BinarySearch(Item, Index);
end;

function TioObjectList<T>.BinarySearch(const Item: T; out Index: Integer;
  const AComparer: IComparer<T>): Boolean;
begin
  Result := ioLazyLoader.GetInternalObj.BinarySearch(Item, Index, AComparer);
end;

procedure TioObjectList<T>.Clear;
begin
  ioLazyLoader.GetInternalObj.Clear;
end;

function TioObjectList<T>.Contains(const Value: T): Boolean;
begin
  Result := ioLazyLoader.GetInternalObj.Contains(Value);
end;

constructor TioObjectList<T>.Create;
begin
  inherited Create;
  FioLazyLoader := TioLazyLoadFactory.LazyLoader<TInternalObjType>;
end;

procedure TioObjectList<T>.Delete(Index: Integer);
begin
  ioLazyLoader.GetInternalObj.Delete(Index);
end;

procedure TioObjectList<T>.DeleteRange(AIndex, ACount: Integer);
begin
  ioLazyLoader.GetInternalObj.DeleteRange(AIndex, ACount);
end;

class procedure TioObjectList<T>.Error(const Msg: string; Data: NativeInt);
begin
  TList<T>.Error(Msg, Data);
end;

{$IFNDEF NEXTGEN}
class procedure TioObjectList<T>.Error(Msg: PResStringRec; Data: NativeInt);
begin
  TList<T>.Error(Msg, Data);
end;
{$ENDIF  NEXTGEN}

procedure TioObjectList<T>.Exchange(Index1, Index2: Integer);
begin
  ioLazyLoader.GetInternalObj.Exchange(Index1, Index2);
end;

function TioObjectList<T>.Expand: TList<T>;
begin
  Result := ioLazyLoader.GetInternalObj.Expand;
end;

function TioObjectList<T>.Extract(const Value: T): T;
begin
  Result := ioLazyLoader.GetInternalObj.Extract(Value);
end;

function TioObjectList<T>.ExtractItem(const Value: T; Direction: TDirection): T;
begin
  Result := ioLazyLoader.GetInternalObj.ExtractItem(Value, Direction);
end;

function TioObjectList<T>.First: T;
begin
  Result := ioLazyLoader.GetInternalObj.First;
end;

function TioObjectList<T>.GetCapacity: Integer;
begin
  Result := ioLazyLoader.GetInternalObj.Capacity;
end;

function TioObjectList<T>.GetCount: Integer;
begin
  Result := ioLazyLoader.GetInternalObj.Count;
end;

function TioObjectList<T>.GetEnumerator: TList<T>.TEnumerator;
begin
  Result := ioLazyLoader.GetInternalObj.GetEnumerator;
end;

function TioObjectList<T>.GetInternalObject: TObject;
begin
  Result := ioLazyLoader.GetInternalObj;
end;

function TioObjectList<T>.GetItem(Index: Integer): T;
begin
  Result := ioLazyLoader.GetInternalObj.Items[Index];
end;

function TioObjectList<T>.GetItems: arrayofT;
begin
  Result := ioLazyLoader.GetInternalObj.List;
end;

function TioObjectList<T>.GetOwnsObjects: Boolean;
begin
  Result := ioLazyLoader.OwnsObjects;
end;

function TioObjectList<T>.IndexOf(const Value: T): Integer;
begin
  Result := ioLazyLoader.GetInternalObj.IndexOf(Value);
end;

function TioObjectList<T>.IndexOfItem(const Value: T; Direction: TDirection): Integer;
begin
  Result := ioLazyLoader.GetInternalObj.IndexOfItem(Value, Direction);
end;

procedure TioObjectList<T>.Insert(Index: Integer; const Value: T);
begin
  ioLazyLoader.GetInternalObj.Insert(Index, Value);
end;

procedure TioObjectList<T>.InsertRange(Index: Integer;
  const Collection: TEnumerable<T>);
begin
  ioLazyLoader.GetInternalObj.InsertRange(Index, Collection);
end;

function TioObjectList<T>.ioLazyLoader: IioLazyLoader<TInternalObjType>;
begin
  Result := FioLazyLoader;
end;

procedure TioObjectList<T>.InsertRange(Index: Integer;
  const Collection: IEnumerable<T>);
begin
  ioLazyLoader.GetInternalObj.InsertRange(Index, Collection);
end;

procedure TioObjectList<T>.InsertRange(Index: Integer; const Values: array of T);
begin
  ioLazyLoader.GetInternalObj.InsertRange(Index, Values);
end;

function TioObjectList<T>.Last: T;
begin
  Result := ioLazyLoader.GetInternalObj.Last;
end;

function TioObjectList<T>.LastIndexOf(const Value: T): Integer;
begin
  Result := ioLazyLoader.GetInternalObj.LastIndexOf(Value);
end;

procedure TioObjectList<T>.Move(CurIndex, NewIndex: Integer);
begin
  ioLazyLoader.GetInternalObj.Move(CurIndex, NewIndex);
end;

procedure TioObjectList<T>.Pack;
begin
  ioLazyLoader.GetInternalObj.Pack;
end;

function TioObjectList<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  // The interfaces support is intended only as LazyLoadable support flag
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TioObjectList<T>.Remove(const Value: T): Integer;
begin
  Result := ioLazyLoader.GetInternalObj.Remove(Value);
end;

function TioObjectList<T>.RemoveItem(const Value: T; Direction: TDirection): Integer;
begin
  Result := ioLazyLoader.GetInternalObj.RemoveItem(Value, Direction);
end;

procedure TioObjectList<T>.Reverse;
begin
  ioLazyLoader.GetInternalObj.Reverse;
end;

procedure TioObjectList<T>.SetCapacity(const Value: Integer);
begin
  ioLazyLoader.GetInternalObj.Capacity := Value;
end;

procedure TioObjectList<T>.SetCount(const Value: Integer);
begin
  ioLazyLoader.GetInternalObj.Count := Value;
end;

procedure TioObjectList<T>.SetItem(Index: Integer; const Value: T);
begin
  ioLazyLoader.GetInternalObj.Items[Index] := Value;
end;

procedure TioObjectList<T>.SetOwnsObjects(const Value: Boolean);
begin
  ioLazyLoader.OwnsObjects := Value;
end;

procedure TioObjectList<T>.SetRelationInfo(const ARelationChildTypeName, ARelationChildTypeAlias,
  ARelationChildPropertyName: String; const ARelationChildID: Integer);
begin
  ioLazyLoader.SetRelationInfo(ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName, ARelationChildID);
end;

procedure TioObjectList<T>.Sort(const AComparer: IComparer<T>);
begin
  ioLazyLoader.GetInternalObj.Sort(AComparer);
end;

procedure TioObjectList<T>.Sort;
begin
  ioLazyLoader.GetInternalObj.Sort;
end;

procedure TioObjectList<T>.TrimExcess;
begin
  ioLazyLoader.GetInternalObj.TrimExcess;
end;



function TioObjectList<T>._AddRef: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

function TioObjectList<T>._Release: Integer;
begin
  // Nothing, the interfaces support is intended only as LazyLoadable support flag
end;

end.
