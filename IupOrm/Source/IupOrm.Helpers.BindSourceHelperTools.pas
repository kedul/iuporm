unit IupOrm.Helpers.BindSourceHelperTools;

interface

uses
  IupOrm.Helpers.BindSourceHelperTools.Interfaces,
  IupOrm.LiveBindings.Interfaces, Data.Bind.ObjectScope, System.Classes;

type

  TioBindSourceHelperTools = class(TInterfacedObject, IioBindSourceHelperTools)
  strict private
    FBindSource: TioBaseBindSource;
  public
    constructor Create(ABindSource: TioBaseBindSource);
    function GetDetailBindSourceAdapter(AOwner:TComponent; AMasterPropertyName:String): TBindSourceAdapter;
    function GetNaturalObjectBindSourceAdapter(AOwner:TComponent): TBindSourceAdapter;
  end;

implementation

{ TioBindSourceHelperTools }

constructor TioBindSourceHelperTools.Create(ABindSource: TioBaseBindSource);
begin
  inherited Create;
  FBindSource := ABindSource;
end;

function TioBindSourceHelperTools.GetDetailBindSourceAdapter(AOwner:TComponent;
  AMasterPropertyName: String): TBindSourceAdapter;
begin
  Result := (FBindSource.InternalAdapter as IioContainedBindSourceAdapter).GetDetailBindSourceAdapter(AOwner, AMasterPropertyName);
end;

function TioBindSourceHelperTools.GetNaturalObjectBindSourceAdapter(
  AOwner: TComponent): TBindSourceAdapter;
begin
  Result := (FBindSource.InternalAdapter as IioNaturalBindSourceAdapterSource).GetNaturalObjectBindSourceAdapter(AOwner);
end;

end.
