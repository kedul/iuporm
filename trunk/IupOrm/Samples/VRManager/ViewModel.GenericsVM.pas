unit ViewModel.GenericsVM;

interface

uses ViewModel.Interfaces, ViewModel, Model.BaseClasses, Model.BaseListClasses,
  Service.Interfaces, Data.Bind.ObjectScope;

type

  // Base comune a tutti i ViewModel
  TViewModelGenericObject<T:TBaseClass, constructor> = class(TInterfacedObject, IViewModel)
  strict private
    FDataObjectID: Integer;
    FDataObject: T;
  strict protected
    FService: IServiceGeneric<T>;
    FLoadFuncRef: TVMLoadFuncRefObject;
  public
    constructor Create(AService:IServiceGeneric<T>); overload;
    constructor Create(AService:IServiceGeneric<T>; ADataObjectID:Integer); overload;
    constructor Create(AService:IServiceGeneric<T>; ADataObject:T); overload;
    constructor Create(AService:IServiceGeneric<T>; ALoadFuncRef:TVMLoadFuncRefObject); overload;
    procedure New; virtual;
    procedure Load; virtual;
    procedure Save; virtual;
    procedure Delete; virtual;
    function GetBindSourceAdapter(AOwner:TPrototypeBindSource): TBindSourceAdapter; virtual;
  end;

  // Base comune a tutti i ViewModel che espngo ObjectList
  TViewModelGenericList<T:TBaseClass, constructor> = class(TInterfacedObject, IViewModelList)
  strict private
    FDataObject: TBaseObjectList<T>;
    FBindSource: TBaseObjectBindSource;
  strict protected
    FService: IServiceGeneric<T>;
    FLoadFuncRef: TVMLoadFuncRefList;
    procedure onCreateBindSourceAdapterEvent(Sender: TObject; var ABindSourceAdapter: TBindSourceAdapter);
    function GetBindSourceAdapter(AOwner:TObject): TBindSourceAdapter;
  public
    constructor Create(AService:IServiceGeneric<T>); overload;
    constructor Create(AService:IServiceGeneric<T>; ADataObject:TBaseObjectList<T>); overload;
    constructor Create(AService:IServiceGeneric<T>; ALoadFuncRef:TVMLoadFuncRefList); overload;
    procedure New; virtual;
    procedure Load; virtual;
    procedure Save(AObj:TBaseClass); virtual;
    procedure Delete(AObj:TBaseClass); virtual;
    procedure SaveAll; virtual;
    procedure DeleteAll; virtual;
    procedure SetBindSource(ABindSource:TBaseObjectBindSource); virtual;
  end;

implementation

uses
  System.Generics.Collections, Model.Travel, System.Classes;

{ TViewModel }

function TViewModelGenericObject<T>.GetBindSourceAdapter(AOwner:TPrototypeBindSource): TBindSourceAdapter;
begin
  Result := nil;
  Result := TObjectBindSourceAdapter.Create(AOwner, TObject(FDataObject), TObject(FDataObject).ClassType);
end;

constructor TViewModelGenericObject<T>.Create(AService: IServiceGeneric<T>; ADataObjectID: Integer);
begin
  FDataObjectID := ADataObjectID;
  FService := AService;
  Self.New;
end;

constructor TViewModelGenericObject<T>.Create(AService: IServiceGeneric<T>; ADataObject: T);
begin
  FService := AService;
  FDataObject := ADataObject;
end;

constructor TViewModelGenericObject<T>.Create(AService: IServiceGeneric<T>;
  ALoadFuncRef: TVMLoadFuncRefObject);
begin
  FService := AService;
  FLoadFuncRef := ALoadFuncRef;
  Self.New;
end;

constructor TViewModelGenericObject<T>.Create(AService: IServiceGeneric<T>);
begin
  FService := AService;
  Self.New;
end;

procedure TViewModelGenericObject<T>.Delete;
begin
  FService.DeleteByID(FDataObject.ID);
end;

procedure TViewModelGenericObject<T>.Load;
begin
  // Se è stato specificato un Anonomous Method per il caricamento
  //  del DataObject lo usa altrimenti usa il IService.
  if Assigned(FLoadFuncRef) then
  begin
    FDataObject := T(FLoadFuncRef);
    Exit;
  end;
  FDataObject := FService.GetByID(FDataObjectID) as T;
end;

procedure TViewModelGenericObject<T>.New;
begin
  FDataObject := T.Create;
end;

procedure TViewModelGenericObject<T>.Save;
begin
  FService.Update(FDataObject);
end;

{ TViewModelList }

constructor TViewModelGenericList<T>.Create(AService: IServiceGeneric<T>;
  ADataObject: TBaseObjectList<T>);
begin
  FService := AService;
  FDataObject := ADataObject;
end;

constructor TViewModelGenericList<T>.Create(AService: IServiceGeneric<T>;
  ALoadFuncRef: TVMLoadFuncRefList);
begin
  FService := AService;
  FLoadFuncRef := ALoadFuncRef;
  Self.New;
end;

constructor TViewModelGenericList<T>.Create(AService: IServiceGeneric<T>);
begin
  FService := AService;
  Self.New;
end;

procedure TViewModelGenericList<T>.Delete(AObj:TBaseClass);
begin
  FService.DeleteByID(AObj.ID);
end;

procedure TViewModelGenericList<T>.DeleteAll;
var
  CurrObj: T;
begin
  for CurrObj in FDataObject do FService.DeleteByID(CurrObj.ID);
end;

function TViewModelGenericList<T>.GetBindSourceAdapter(
  AOwner: TObject): TBindSourceAdapter;
begin
  Result := nil;
  Result := TListBindSourceAdapter.Create((AOwner as TComponent), TObjectList<TObject>(FDataObject), FDataObject.GetGenericTypeRef);
end;

procedure TViewModelGenericList<T>.Load;
begin
  if Assigned(FBindSource) then FBindSource.Active := False;
  // Se è stato specificato un Anonomous Method per il caricamento
  //  del DataObject lo usa altrimenti usa il IService.
  if Assigned(FLoadFuncRef) then
  begin
    FDataObject := TBaseObjectList<T>(FLoadFuncRef);
    Exit;
  end;
//  FDataObject := TBaseObjectList<T>(FService.GetAll);
  FDataObject := FService.GetAll;
{
  if Assigned(FBindSource) then
  begin
    (FBindSource.InternalAdapter as TListBindSourceAdapter<T>).SetList(FDataObject);
  end;
}
  if Assigned(FBindSource) then FBindSource.Active := True;

end;

procedure TViewModelGenericList<T>.New;
begin
  FDataObject := TBaseObjectList<T>.Create(True);
//  FDataObject.Add(TTravel.Create(999, '***'));
//  FDataObject := TBaseObjectList<T>(FService.GetAll);


end;

procedure TViewModelGenericList<T>.onCreateBindSourceAdapterEvent(Sender: TObject;
  var ABindSourceAdapter: TBindSourceAdapter);
begin
  ABindSourceAdapter := Self.GetBindSourceAdapter(Sender);
end;

procedure TViewModelGenericList<T>.Save(AObj: TBaseClass);
begin
  FService.Update(AObj);
end;

procedure TViewModelGenericList<T>.SaveAll;
var
  CurrObj: T;
begin
  for CurrObj in FDataObject do FService.Update(CurrObj);
end;

procedure TViewModelGenericList<T>.SetBindSource(
  ABindSource: TBaseObjectBindSource);
begin
  FBindSource := ABindSource;
  FBindSource.Active := False;
  FBindSource.OnCreateAdapter := onCreateBindSourceAdapterEvent;
  FBindSource.Active := True;
end;

end.
