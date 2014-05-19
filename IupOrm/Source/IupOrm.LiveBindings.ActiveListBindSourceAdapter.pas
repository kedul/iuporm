unit IupOrm.LiveBindings.ActiveListBindSourceAdapter;

interface

uses
  Data.Bind.ObjectScope, IupOrm.Where, System.Classes,
  System.Generics.Collections, IupOrm.Where.SqlItems.Interfaces,
  IupOrm.CommonTypes;

type

  TioActiveListBindSourceAdapter<T:class,constructor> = class(TListBindSourceAdapter<T>)
  strict private
    FWhereStr: String;
    FClassRef: TioClassRef;
  strict protected
    procedure DoBeforeOpen; override;
    procedure DoBeforeRefresh; override;
    procedure DoBeforeDelete; override;
    procedure DoAfterPost; override;
  public
    constructor Create(AClassRef:TioClassRef; AWhereStr:String; AOwner: TComponent; AList: TList<T>; AOwnsObject: Boolean = True); overload;
  end;

implementation

uses
  IupOrm;

{ TioActiveListBindSourceAdapter<T> }

constructor TioActiveListBindSourceAdapter<T>.Create(AClassRef:TioClassRef; AWhereStr: String;
  AOwner: TComponent; AList: TList<T>; AOwnsObject: Boolean);
begin
  inherited Create(AOwner, AList, AOwnsObject);
  FWhereStr := AWhereStr;
  FClassRef := AClassRef;
end;

procedure TioActiveListBindSourceAdapter<T>.DoAfterPost;
begin
  inherited;
  TIupOrm.Persist(Self.Current);
end;

procedure TioActiveListBindSourceAdapter<T>.DoBeforeDelete;
begin
  inherited;
  TIupOrm.Delete(Self.Current);
end;

procedure TioActiveListBindSourceAdapter<T>.DoBeforeOpen;
begin
  inherited;
  TIupOrm.Load(FClassRef)._Where(FWhereStr).ToList(Self.List);
end;

procedure TioActiveListBindSourceAdapter<T>.DoBeforeRefresh;
begin
  inherited;
  Self.First;  // Bug
  Self.Active := False;
  Self.List.Clear;
  Self.Active := True;
end;


end.
