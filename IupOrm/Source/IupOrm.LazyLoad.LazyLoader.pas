unit IupOrm.LazyLoad.LazyLoader;

interface

uses
  IupOrm.CommonTypes, IupOrm.LazyLoad.Interfaces;

type

  TioLazyLoader<T:class,constructor> = class(TInterfacedObject, IioLazyLoader<T>)
  strict private
    FInternalObj: T;
    FOwnsObjects: Boolean;
    FioRelationChildClassRef: TioClassRef;
    FioRelationChildPropertyName: String;
    FioRelationChildID: Integer;
  strict protected
    procedure CreateInternalObj;
  public
    constructor Create(AOwnsObjects:Boolean=True); overload;
    destructor Destroy; override;
    procedure SetRelationInfo(ARelationChildClassRef:TioClassRef; ARelationChildPropertyName:String; ARelationChildID:Integer);
    function GetInternalObj: T;
    // OwnsObject property
    procedure SetOwnsObjects(Value: Boolean);
    function GetOwnsObjects: Boolean;
  end;

implementation

uses
  IupOrm;

{ TioLazyLoader<T> }

constructor TioLazyLoader<T>.Create(AOwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
  FInternalObj := nil;
end;

procedure TioLazyLoader<T>.CreateInternalObj;
begin
  if Self.FioRelationChildPropertyName = ''
    then FInternalObj := T.Create
    else FInternalObj := TIupOrm.Load(Self.FioRelationChildClassRef)
                                ._Where
                                ._Property(Self.FioRelationChildPropertyName)
                                ._EqualTo(Self.FioRelationChildID)
                                .ToList<T>(Self.FOwnsObjects);
end;

destructor TioLazyLoader<T>.Destroy;
begin
  if Assigned(FInternalObj) then FInternalObj.Free;
  inherited;
end;

function TioLazyLoader<T>.GetInternalObj: T;
begin
  if not Assigned(FInternalObj)
    then Self.CreateInternalObj;
  Result := FInternalObj;
end;

function TioLazyLoader<T>.GetOwnsObjects: Boolean;
begin
  Result := FOwnsObjects;
end;

procedure TioLazyLoader<T>.SetOwnsObjects(Value: Boolean);
begin
  FOwnsObjects := Value;
end;

procedure TioLazyLoader<T>.SetRelationInfo(ARelationChildClassRef: TioClassRef;
  ARelationChildPropertyName: String; ARelationChildID: Integer);
begin
  Self.FioRelationChildClassRef := ARelationChildClassRef;
  Self.FioRelationChildPropertyName := ARelationChildPropertyName;
  Self.FioRelationChildID := ARelationChildID;
end;

end.
