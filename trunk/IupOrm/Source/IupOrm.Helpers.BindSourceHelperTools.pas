unit IupOrm.Helpers.BindSourceHelperTools;

interface

uses
  IupOrm.Helpers.BindSourceHelperTools.Interfaces,
  IupOrm.LiveBindings.Interfaces, Data.Bind.ObjectScope;

type

  TioBindSourceHelperTools = class(TInterfacedObject, IioBindSourceHelperTools)
  strict private
    FBindSource: TioBaseBindSource;
  public
    constructor Create(ABindSource: TioBaseBindSource);
    function GetDetailBindSourceAdapter(AMasterPropertyName:String): TBindSourceAdapter;
  end;

implementation

{ TioBindSourceHelperTools }

constructor TioBindSourceHelperTools.Create(ABindSource: TioBaseBindSource);
begin
  inherited Create;
  FBindSource := ABindSource;
end;

function TioBindSourceHelperTools.GetDetailBindSourceAdapter(
  AMasterPropertyName: String): TBindSourceAdapter;
begin
  Result := (FBindSource.InternalAdapter as IioContainedBindSourceAdapter).GetDetailBindSourceAdapter(AMasterPropertyName);
end;

end.
