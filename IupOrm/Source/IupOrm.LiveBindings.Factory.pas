unit IupOrm.LiveBindings.Factory;

interface

uses
  IupOrm.LiveBindings.Interfaces, IupOrm.CommonTypes, System.Classes,
  System.Generics.Collections, IupOrm.Context.Properties.Interfaces,
  Data.Bind.ObjectScope, IupOrm.LiveBindings.PrototypeBindSource,
  IupOrm.Rtti.Utilities;

type

  TioLiveBindingsFactory = class
  public
    class function DetailAdaptersContainer(AMasterAdapter:IioContainedBindSourceAdapter): IioDetailBindSourceAdaptersContainer;
    class function ContainedListBindSourceAdapter(AOwner:TComponent; AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
    class function ContainedObjectBindSourceAdapter(AOwner:TComponent; AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
    class function NaturalObjectBindSourceAdapter(AOwner:TComponent; ASourceAdapter:IioNaturalBindSourceAdapterSource): TBindSourceAdapter;
    class function Notification(ASender:TObject; ASubject:TObject; ANotificationType:TioBSANotificationType): IioBSANotification;
    class function GetBSAfromMasterBindSource(AOwner:TComponent; AMAsterBindSource:TioMasterBindSource; AMasterPropertyName:String=''): TBindSourceAdapter;
    class function GetBSAfromDB(const AOwner:TComponent; const ATypeName, ATypeAlias:String; const AWhere:String=''): TBindSourceAdapter;
  end;

implementation

uses
  IupOrm,
  IupOrm.LiveBindings.DetailAdaptersContainer,
  IupOrm.LiveBindings.ActiveListBindSourceAdapter,
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter,
  IupOrm.LiveBindings.Notification,
  IupOrm.LiveBindings.NaturalActiveObjectBindSourceAdapter,
  IupOrm.Context.Container, IupOrm.Context.Interfaces,
  IupOrm.Resolver.Interfaces, IupOrm.Resolver.Factory, IupOrm.Context.Factory,
  IupOrm.LiveBindings.ActiveInterfaceListBindSourceAdapter,
  IupOrm.LiveBindings.ActiveInterfaceObjectBindSourceAdapter;

{ TioLiveBindingsFactory }

class function TioLiveBindingsFactory.ContainedListBindSourceAdapter(AOwner:TComponent; AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
var
  AContext: IioContext;
begin
  // If the master property type is an interface...
  if TioRttiUtilities.IsAnInterfaceTypeName(AMasterProperty.GetRelationChildTypeName) then
    Result := TioActiveInterfaceListBindSourceAdapter.Create(
      AMasterProperty.GetRelationChildTypeName,
      AMasterProperty.GetRelationChildTypeAlias,
      '',
      AOwner,
      TList<IInterface>.Create,
      False,
      False)
  // else if the master property type is a class...
  else
  begin
    AContext := TioContextFactory.Context(AMasterProperty.GetRelationChildTypeName);
    Result := TioActiveListBindSourceAdapter.Create(
       AContext.GetClassRef
      ,''
      ,AOwner
      ,TList<TObject>.Create
      ,False
      ,False);
  end;
  // Set MasterProperty for the adapter
  Result.SetMasterProperty(AMasterProperty);
end;

class function TioLiveBindingsFactory.ContainedObjectBindSourceAdapter(AOwner:TComponent; AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
var
  AContext: IioContext;
begin
  // If the master property type is an interface...
  if TioRttiUtilities.IsAnInterfaceTypeName(AMasterProperty.GetRelationChildTypeName) then
    Result := TioActiveInterfaceObjectBindSourceAdapter.Create(
      AMasterProperty.GetRelationChildTypeName,
      AMasterProperty.GetRelationChildTypeAlias,
      '',
      AOwner,
      nil,     // AObject:TObject;
      False,
      False)
  // else if the master property type is a class...
  else
  begin
    AContext := TioContextFactory.Context(AMasterProperty.GetRelationChildTypeName);
    Result := TioActiveObjectBindSourceAdapter.Create(
       AContext.GetClassRef
      ,''
      ,AOwner
      ,nil     // AObject:TObject;
      ,False
      ,False);
  end;
  // Set MasterProperty for the adapter
  Result.SetMasterProperty(AMasterProperty);
end;

class function TioLiveBindingsFactory.DetailAdaptersContainer(AMasterAdapter:IioContainedBindSourceAdapter): IioDetailBindSourceAdaptersContainer;
begin
  Result := TioDetailAdaptersContainer.Create(AMasterAdapter);
end;

class function TioLiveBindingsFactory.GetBSAfromDB(const AOwner: TComponent; const ATypeName, ATypeAlias,
  AWhere: String): TBindSourceAdapter;
begin
  // Get the adapter directly from IupOrm
  Result := TIupOrm.Load(ATypeName, ATypeAlias)
                   ._Where(AWhere)
                   .ToActiveListBindSourceAdapter(AOwner);
end;

class function TioLiveBindingsFactory.GetBSAfromMasterBindSource(AOwner:TComponent; AMAsterBindSource: TioMasterBindSource;
  AMasterPropertyName: String): TBindSourceAdapter;
begin
  // If the MasterPropertyName property is empty then get a NaturalActiveBindSourceAdapter
  //  from the MasterBindSource else get a detail ActiveBindSourceAdapter even from the
  //  MasterBindSource.
  if (AMasterPropertyName <> '')
    then Result := AMAsterBindSource.IupOrm.GetDetailBindSourceAdapter(AOwner, AMasterPropertyName)
    else Result := AMAsterBindSource.IupOrm.GetNaturalObjectBindSourceAdapter(AOwner);
end;

class function TioLiveBindingsFactory.NaturalObjectBindSourceAdapter(
  AOwner: TComponent;
  ASourceAdapter: IioNaturalBindSourceAdapterSource): TBindSourceAdapter;
begin
  Result := TioNaturalActiveObjectBindSourceAdapter.Create(AOwner, ASourceAdapter);
end;

class function TioLiveBindingsFactory.Notification(ASender, ASubject: TObject;
  ANotificationType: TioBSANotificationType): IioBSANotification;
begin
  Result := TioBSANotification.Create(ASender, ASubject, ANotificationType);
end;

end.
