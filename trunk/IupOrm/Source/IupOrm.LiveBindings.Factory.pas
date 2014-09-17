unit IupOrm.LiveBindings.Factory;

interface

uses
  IupOrm.LiveBindings.Interfaces, IupOrm.CommonTypes, System.Classes,
  System.Generics.Collections, IupOrm.Context.Properties.Interfaces,
  Data.Bind.ObjectScope;

type

  TioLiveBindingsFactory = class
  public
    class function DetailAdaptersContainer(AMasterAdapter:IioContainedBindSourceAdapter): IioDetailBindSourceAdaptersContainer;
    class function ContainedListBindSourceAdapter(AOwner:TComponent; AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
    class function ContainedObjectBindSourceAdapter(AOwner:TComponent; AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
    class function NaturalObjectBindSourceAdapter(AOwner:TComponent; ASourceAdapter:IioNaturalBindSourceAdapterSource): TBindSourceAdapter;
    class function Notification(ASender:TObject; ASubject:TObject; ANotificationType:TioBSANotificationType): IioBSANotification;
  end;

implementation

uses
  IupOrm.LiveBindings.DetailAdaptersContainer,
  IupOrm.LiveBindings.ActiveListBindSourceAdapter,
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter,
  IupOrm.LiveBindings.Notification,
  IupOrm.LiveBindings.NaturalActiveObjectBindSourceAdapter;

{ TioLiveBindingsFactory }

class function TioLiveBindingsFactory.ContainedListBindSourceAdapter(AOwner:TComponent; AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
begin
  Result := TioActiveListBindSourceAdapter.Create(AMasterProperty.GetRelationChildClassRef
                                                 ,''
                                                 ,AOwner
                                                 ,TList<TObject>.Create
                                                 ,False
                                                 ,False
                                                 );
  Result.SetMasterProperty(AMasterProperty);
end;

class function TioLiveBindingsFactory.ContainedObjectBindSourceAdapter(AOwner:TComponent; AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
begin
  Result := TioActiveObjectBindSourceAdapter.Create(AMasterProperty.GetRelationChildClassRef
                                                   ,''
                                                   ,AOwner
                                                   ,TObject.Create
                                                   ,False
                                                   ,False
                                                   );
  Result.SetMasterProperty(AMasterProperty);
end;

class function TioLiveBindingsFactory.DetailAdaptersContainer(AMasterAdapter:IioContainedBindSourceAdapter): IioDetailBindSourceAdaptersContainer;
begin
  Result := TioDetailAdaptersContainer.Create(AMasterAdapter);
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
