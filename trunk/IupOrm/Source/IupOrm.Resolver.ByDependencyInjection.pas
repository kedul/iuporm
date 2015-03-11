unit IupOrm.Resolver.ByDependencyInjection;

interface

uses
  IupOrm.Resolver.Interfaces;

type

  // Service Locator Class
  TioResolverByDependencyInjection = class(TioResolver)
  public
    class function Resolve(const ATypeName:String; const AAlias:String=''; const AResolverMode:TioResolverMode=rmAll): IioResolvedTypeList; override;
  end;

implementation

uses
  IupOrm.DependencyInjection;

{ TioResolverByDependencyInjection }

class function TioResolverByDependencyInjection.Resolve(const ATypeName:String; const AAlias: String; const AResolverMode:TioResolverMode): IioResolvedTypeList;
begin
  inherited;
  Result := TioDependencyInjectionResolverBase.Resolve(ATypeName, AAlias, AResolverMode);
end;

end.
