unit IupOrm.Containers.List;

interface

uses
  System.Generics.Collections, IupOrm.Containers.Interfaces;

type

  TioInterfacedList<T> = class(TList<T>, IioList<T>)
  protected
// ---------------- Start: section added for IInterface support ---------------
{$IFNDEF AUTOREFCOUNT}
    [Volatile] FRefCount: Integer;
{$ENDIF}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
// ---------------- End: section added for IInterface support ---------------
  public
// ---------------- Start: section added for IInterface support ---------------
{$IFNDEF AUTOREFCOUNT}
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property RefCount: Integer read FRefCount;
{$ENDIF}
// ---------------- End: section added for IInterface support ---------------
    function GetCapacity: Integer;
    procedure SetCapacity(const Value: Integer);
    function GetCount: Integer;
    procedure SetCount(const Value: Integer);
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
  end;
// ---------------- Start: section added for IInterface support ---------------
  {$IFNDEF SYSTEM_HPP_DEFINES_OBJECTS}
//  {$NODEFINE TInterfacedObject}         { defined in systobj.h }
  {$ENDIF}
// ---------------- End: section added for IInterface support ---------------

implementation

{ TioInterfacedList<T> }

// ---------------- Start: section added for IInterface support ---------------
{$IFNDEF AUTOREFCOUNT}
procedure TioInterfacedList<T>.AfterConstruction;
begin
// Release the constructor's implicit refcount
  AtomicDecrement(FRefCount);
end;

procedure TioInterfacedList<T>.BeforeDestruction;
begin
  if RefCount <> 0 then
    System.Error(reInvalidPtr);
end;

class function TioInterfacedList<T>.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TioInterfacedList<T>(Result).FRefCount := 1;
end;
{$ENDIF}
// ---------------- End: section added for IInterface support ---------------

function TioInterfacedList<T>.GetCapacity: Integer;
begin
  Result := inherited Capacity;
end;

function TioInterfacedList<T>.GetCount: Integer;
begin
  Result := inherited Count;
end;

function TioInterfacedList<T>.GetItem(Index: Integer): T;
begin
  Result := inherited Items[Index];
end;

function TioInterfacedList<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TioInterfacedList<T>.SetCapacity(const Value: Integer);
begin
  inherited Capacity := Value;
end;

procedure TioInterfacedList<T>.SetCount(const Value: Integer);
begin
  inherited Count := Value;
end;

procedure TioInterfacedList<T>.SetItem(Index: Integer; const Value: T);
begin
   inherited Items[Index] := Value;
end;

function TioInterfacedList<T>._AddRef: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicIncrement(FRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function TioInterfacedList<T>._Release: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
    Destroy;
{$ELSE}
  Result := __ObjRelease;
{$ENDIF}
end;

end.
