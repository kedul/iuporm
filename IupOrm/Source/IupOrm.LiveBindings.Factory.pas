unit IupOrm.LiveBindings.Factory;

interface

uses
  IupOrm.LiveBindings.Interfaces, IupOrm.CommonTypes, System.Classes,
  System.Generics.Collections, IupOrm.Context.Properties.Interfaces;

type

  TioLiveBindingsFactory = class
  public
    class function DetailAdaptersContainer(AMasterAdapter:IioContainedBindSourceAdapter): IioDetailBindSourceAdaptersContainer;
    class function ContainedListBindSourceAdapter(AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
    class function ContainedObjectBindSourceAdapter(AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
    class function Notification(ASender:TObject; ASubject:TObject; ANotificationType:TioBSANotificationType): IioBSANotification;
  end;

implementation

uses
  IupOrm.LiveBindings.DetailAdaptersContainer,
  IupOrm.LiveBindings.ActiveListBindSourceAdapter,
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter,
  IupOrm.LiveBindings.Notification;

{ TioLiveBindingsFactory }

class function TioLiveBindingsFactory.ContainedListBindSourceAdapter(AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
begin
  Result := TioActiveListBindSourceAdapter.Create(AMasterProperty.GetRelationChildClassRef
                                                 ,''
                                                 ,nil
                                                 ,TList<TObject>.Create
                                                 ,False
                                                 ,False
                                                 );
  Result.SetMasterProperty(AMasterProperty);
end;

class function TioLiveBindingsFactory.ContainedObjectBindSourceAdapter(AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
begin
  Result := TioActiveObjectBindSourceAdapter.Create(AMasterProperty.GetRelationChildClassRef
                                                   ,''
                                                   ,nil
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






class function TioLiveBindingsFactory.Notification(ASender, ASubject: TObject;
  ANotificationType: TioBSANotificationType): IioBSANotification;
begin
  Result := TioBSANotification.Create(ASender, ASubject, ANotificationType);
end;

end.
