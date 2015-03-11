unit IupOrm.Resolver.Factory;

interface

uses
  IupOrm.Resolver.Interfaces;

type

  TioResolverFactory = class
  public
    class function GetResolvedTypeList: IioResolvedTypeList;
    class function GetResolver(const AResolverMode:TioResolverStrategy): TioResolverRef;
  end;

implementation

uses
  IupOrm.Containers.List, IupOrm.Resolver.ByDependencyInjection, IupOrm.Exceptions;

{ TioResolverFactory }

class function TioResolverFactory.GetResolvedTypeList: IioResolvedTypeList;
begin
  Result := TioInterfacedList<String>.Create;
end;

class function TioResolverFactory.GetResolver(const AResolverMode: TioResolverStrategy): TioResolverRef;
begin
  case AResolverMode of
    rsByDependencyInjection: Result := TioResolverByDependencyInjection;
    rsByRtti: EIupOrmException.Create(Self.ClassName + ': "rtByRtti" resolver mode not yet implemented.');
    rsByMaps: EIupOrmException.Create(Self.ClassName + ': "rtByMaps" resolver mode not yet implemented.');
  end;
end;

end.
