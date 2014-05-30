unit IupOrm.LiveBindings.Factory;

interface

uses
  IupOrm.LiveBindings.Interfaces, IupOrm.CommonTypes, System.Classes,
  System.Generics.Collections, IupOrm.Context.Properties.Interfaces;

type

  TioLiveBindingsFactory = class
  public
    class function DetailAdaptersContainer: IioDetailBindSourceAdaptersContainer;
    class function ContainedListBindSourceAdapter(AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
    class function ContainedObjectBindSourceAdapter(AMasterProperty:IioContextProperty): IioContainedBindSourceAdapter;
  end;

implementation

uses
  IupOrm.LiveBindings.DetailAdaptersContainer,
  IupOrm.LiveBindings.ActiveListBindSourceAdapter,
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter;

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

class function TioLiveBindingsFactory.DetailAdaptersContainer: IioDetailBindSourceAdaptersContainer;
begin
  Result := TioDetailAdaptersContainer.Create;
end;






end.
