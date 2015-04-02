unit IupOrm.Resolver.Interfaces;

interface

uses
  IupOrm.Containers.Interfaces;

type

  // Resolver mode
  TioResolverMode = (rmAll, rmSingle);

  // Resolver strategy
  TioResolverStrategy = (rsByDependencyInjection, rsByRtti, rsByMaps);

  // Interface for the resolved type list
  IioResolvedTypeList = IioList<String>;

  // Interface for the resolvers
  TioResolverRef = class of TioResolver;
  TioResolver = class abstract
  public
    class function Resolve(const ATypeName:String; const AAlias:String=''; const AResolverMode:TioResolverMode=rmAll): IioResolvedTypeList; virtual; abstract;
  end;

implementation

uses SysUtils;

{ TioResolver }

end.
