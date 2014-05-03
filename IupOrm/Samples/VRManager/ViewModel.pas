unit ViewModel;

interface

uses ViewModel.Interfaces, Model.BaseClasses, Model.BaseListClasses, Model.Travel;

type

  // Riferimento a un anonimous method per la creazione dei DataObject
  TVMLoadFuncRefObject = reference to function: TBaseClass;
  TVMLoadFuncRefList = reference to function: TBaseObjectList<TBaseClass>;

  // Factory per la creazione dei ViewModels
  TViewModelFactory = class
  public
    // TTravel
    class function TravelViewModel: IViewModel; overload;
    class function TravelViewModel(ADataObjectID:Integer): IViewModel; overload;
    class function TravelViewModel(ADataObject:TTravel): IViewModel; overload;
    class function TravelViewModel(ALoadFuncRef: TVMLoadFuncRefObject): IViewModel; overload;
    // TTravelList
    class function TravelListViewModel: IViewModelList; overload;
    class function TravelListViewModel(ADataObject:TTravelList): IViewModelList; overload;
    class function TravelListViewModel(ALoadFuncRef: TVMLoadFuncRefList): IViewModelList; overload;
  end;

implementation

uses ViewModel.GenericsVM, Service;

{ TViewModelFactory }

class function TViewModelFactory.TravelViewModel(ADataObjectID: Integer): IViewModel;
begin
//  Result := TViewModelGenericObject<TTravel>.Create(TServiceFactory<TTravel>.Travel, ADataObjectID);
end;

class function TViewModelFactory.TravelViewModel(
  ADataObject: TTravel): IViewModel;
begin
//  Result := TViewModelGenericObject<TTravel>.Create(TServiceFactory<TTravel>.Travel, ADataObject);
end;

class function TViewModelFactory.TravelListViewModel(
  ADataObject: TTravelList): IViewModelList;
begin
//  Result := TViewModelGenericList<TTravel>.Create(TServiceFactory<TTravel>.Travel, ADataObject);
end;

class function TViewModelFactory.TravelListViewModel(
  ALoadFuncRef: TVMLoadFuncRefList): IViewModelList;
begin
//  Result := TViewModelGenericList<TTravel>.Create(TServiceFactory<TTravel>.Travel, ALoadFuncRef);
end;

class function TViewModelFactory.TravelListViewModel: IViewModelList;
begin
//  Result := TViewModelGenericList<TTravel>.Create(TServiceFactory<TTravel>.Travel);
end;

class function TViewModelFactory.TravelViewModel(
  ALoadFuncRef: TVMLoadFuncRefObject): IViewModel;
begin
//  Result := TViewModelGenericObject<TTravel>.Create(TServiceFactory<TTravel>.Travel, ALoadFuncRef);
end;

class function TViewModelFactory.TravelViewModel: IViewModel;
begin
//  Result := TViewModelGenericObject<TTravel>.Create(TServiceFactory<TTravel>.Travel);
end;

end.
