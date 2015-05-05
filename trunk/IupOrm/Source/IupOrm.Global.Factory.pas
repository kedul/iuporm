unit IupOrm.Global.Factory;

interface

uses
  IupOrm.Context.Factory, IupOrm.DB.DBCreator.Factory, IupOrm.DB.Factory,
  IupOrm.DuckTyped.Factory, IupOrm.LazyLoad.Factory,
  IupOrm.LiveBindings.Factory, IupOrm.ObjectsForge.Factory,
  IupOrm.RttiContext.Factory, IupOrm.MVVM.Factory, IupOrm.Containers.Factory;

Type

  TioContextFactoryRef = class of TioContextFactory;
  TioDBCreatorFactoryRef = class of TioDBCreatorFactory;
  TioDBFactoryRef = class of TioDBFactory;
  TioDuckTypedFactoryRef = class of TioDuckTypedFactory;
  TioLazyLoadFactoryRef = class of TioLazyLoadFactory;
  TioLiveBindingsFactoryRef = class of TioLiveBindingsFactory;
  TioObjectMakerFactoryRef = class of TioObjectMakerFactory;
  TioRttiContextFactoryRef = class of TioRttiContextFactory;
  TioMVVMFactoryRef = class of TioMVVMFactory;
  TioContainersFactoryRef = class of TioContainersFactory;

  TioGlobalFactory = class
  public
    class function ContextFactory: TioContextFactoryRef;
    class function DBCreatorFactory: TioDBCreatorFactoryRef;
    class function DBFactory: TioDBFactoryRef;
    class function DuckTypedFactory: TioDuckTypedFactoryRef;
    class function LazyLoadFactory: TioLazyLoadFactoryRef;
    class function LiveBindingsFactory: TioLiveBindingsFactoryRef;
    class function ObjectMakerFactory: TioObjectMakerFactoryRef;
    class function RttiFactory: TioRttiContextFactoryRef;
    class function MVVMFactory: TioMVVMFactoryRef;
    class function ContainersFactory: TioContainersFactoryRef;
  end;

  TioGlobalFactoryRef = class of TioGlobalFactory;

implementation

{ TioGlobalFactory }


{ TioGlobalFactory }

class function TioGlobalFactory.ContainersFactory: TioContainersFactoryRef;
begin
  Result := TioContainersFactory;
end;

class function TioGlobalFactory.ContextFactory: TioContextFactoryRef;
begin
  Result := TioContextFactory;
end;

class function TioGlobalFactory.DBCreatorFactory: TioDBCreatorFactoryRef;
begin
  Result := TioDBCreatorFactory;
end;

class function TioGlobalFactory.DBFactory: TioDBFactoryRef;
begin
  Result := TioDBFactory;
end;

class function TioGlobalFactory.DuckTypedFactory: TioDuckTypedFactoryRef;
begin
  Result := TioDuckTypedFactory;
end;

class function TioGlobalFactory.LazyLoadFactory: TioLazyLoadFactoryRef;
begin
  Result := TioLazyLoadFactory;
end;

class function TioGlobalFactory.LiveBindingsFactory: TioLiveBindingsFactoryRef;
begin
  Result := TioLiveBindingsFactory;
end;

class function TioGlobalFactory.MVVMFactory: TioMVVMFactoryRef;
begin
  Result := TioMVVMFactory;
end;

class function TioGlobalFactory.ObjectMakerFactory: TioObjectMakerFactoryRef;
begin
  Result := TioObjectMakerFactory;
end;

class function TioGlobalFactory.RttiFactory: TioRttiContextFactoryRef;
begin
  Result := TioRttiContextFactory;
end;

end.











