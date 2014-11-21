unit IupOrm.DependencyInjection;

interface

uses
  IupOrm.CommonTypes, System.Generics.Collections, IupOrm.MVVM.Interfaces,
  System.SyncObjs, IupOrm.DependencyInjection.Interfaces, System.Rtti,
  IupOrm.LiveBindings.PrototypeBindSource, IupOrm.LiveBindings.Interfaces;

type

  // Container instance types
  TioDIContainerKey = String;
  TioDIContainerValue = record
    ClassRef: TioClassref;
  end;
  TioDIContainerInstance = TDictionary<TioDIContainerKey, TioDIContainerValue>;

  // Dependency Injection Container (and relative class reference)
  TioDependencyInjectionContainerRef = class of TioDependencyInjectionContainer;
  TioDependencyInjectionContainer = class abstract
  strict private
    class var FContainer: TioDIContainerInstance;
  public
    class procedure Build;
    class procedure CleanUp;
    class procedure Add(const AKey:TioDIContainerKey; const AValue:TioDIContainerValue);
    class function Exists(const AKey:TioDIContainerKey): Boolean; overload;
    class function Get(const AKey:TioDIContainerKey): TioDIContainerValue;
  end;

  // Shuttle class for ViewModel (for View creation)
  TioViewModelShuttle = class abstract
  strict private
    class var FViewModel: IioViewModel;
    class var FCriticalSection: TCriticalSection;
  public
    class procedure Build;
    class procedure CleanUp;
    class procedure Lock(AViewModel:IioViewModel);
    class procedure Unlock;
    class function Exist: Boolean;
    class function Get: IioViewModel;
  end;

  // Base class for Dependency Injection Register and Locator classes
  TioDependencyInjectionBase = class abstract(TInterfacedObject)
  strict protected
    class function Container: TioDependencyInjectionContainerRef;
    class function InterfaceNameToString<T:IInterface>: String;
    class function InterfaceGUIToString<T:IInterface>: String;
    class function ComposeKey(const AInterface:String; const AAlias: String): String; overload;
  end;

  // Register Class (NoRefCounter)
  TioDependencyInjectionRegister = class(TioDependencyInjectionBase)
  strict private
    FContainerValue: TioDIContainerValue;
    FInterfaceName: String;
    FAlias: String;
    function GetKey: TioDIContainerKey;
    function GetValue: TioDIContainerValue;
  public
    constructor Create(const AContainerValue:TioDIContainerValue);
    procedure Execute;
    function Implements(const AInterfaceName:String): TioDependencyInjectionRegister; overload;
    function Implements<T: IInterface>: TioDependencyInjectionRegister; overload;
    function Alias(const AAlias:String): TioDependencyInjectionRegister;
  end;

  // Service Locator Class
  TioDependencyInjectionLocator = class(TioDependencyInjectionBase, IioDependencyInjectionLocator)
  strict private
    FInterfaceName: String;
    FAlias: String;
    FConstructorMethod: String;
    FConstructorMarker: String;
    FConstructorParams: array of TValue;
    FViewModel: IioViewModel;
    function GetKey: TioDIContainerKey;
    function ViewModelExist: Boolean;
  public
    constructor Create(AInterfaceName:String); virtual;
    function Get: TObject; virtual;
    function Alias(const AAlias:String): IioDependencyInjectionLocator;
    function ConstructorParams(const AParams: array of TValue): IioDependencyInjectionLocator; virtual;
    function ConstructorMethod(const AConstructorMethod: String): IioDependencyInjectionLocator; virtual;
    function ConstructorMarker(const AConstructorMarker: String): IioDependencyInjectionLocator; virtual;
    function ViewModel(const AViewModel:IioViewModel): IioDependencyInjectionLocator; overload;

    function ViewModel(const AInterfaceNameOrAlias, AModelClassName:String; const AWhere:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
    function ViewModel(const AInterfaceNameOrAlias:String; const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
    function ViewModel(const AInterfaceNameOrAlias:String; ABindSourceAdapter:IioActiveBindSourceAdapter; const AAlias:String=''): IioDependencyInjectionLocator; overload;
  end;
  // Generic version of the Service Locator Class
  TioDependencyInjectionLocator<TI:IInterface> = class(TioDependencyInjectionLocator, IioDependencyInjectionLocator<TI>)
  public
    function Get: TI; overload;
    function Alias(const AAlias:String): IioDependencyInjectionLocator<TI>;
    function ConstructorParams(const AParams: array of TValue): IioDependencyInjectionLocator<TI>; overload;
    function ConstructorMethod(const AConstructorMethod: String): IioDependencyInjectionLocator<TI>; overload;
    function ConstructorMarker(const AConstructorMarker: String): IioDependencyInjectionLocator<TI>; overload;
    function ViewModel(const AViewModel:IioViewModel): IioDependencyInjectionLocator<TI>; overload;

    function ViewModel(const AInterfaceNameOrAlias, AModelClassName:String; const AWhere:String=''; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
    function ViewModel(const AInterfaceNameOrAlias:String; const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
    function ViewModel(const AInterfaceNameOrAlias:String; ABindSourceAdapter:IioActiveBindSourceAdapter; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
  end;

  // Main Dependency Injection Class (and relative class reference)
  TioDependencyInjectionRef = class of TioDependencyInjection;
  TioDependencyInjection = class(TioDependencyInjectionBase)
  public
    class function RegisterClass(const AClassRef:TioClassRef): TioDependencyInjectionRegister; overload;
    class function RegisterClass<T: class>: TioDependencyInjectionRegister; overload;
    class function Locate(const AInterfaceNameOrAlias:String): IioDependencyInjectionLocator; overload;
    class function Locate<T:IInterface>: IioDependencyInjectionLocator<T>; overload;

    class function LocateViewModel(const AInterfaceNameOrAlias, AModelClassName:String; const AWhere:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
    class function LocateViewModel(const AInterfaceNameOrAlias:String; const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
    class function LocateViewModel(const AInterfaceNameOrAlias:String; ABindSourceAdapter:IioActiveBindSourceAdapter; const AAlias:String=''): IioDependencyInjectionLocator; overload;
    class function LocateViewModel<T:IInterface>(const AModelClassName:String; const AWhere:String=''; const AAlias:String=''): IioDependencyInjectionLocator<T>; overload;
    class function LocateViewModel<T:IInterface>(const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
    class function LocateViewModel<T:IInterface>(const ABindSourceAdapter:IioActiveBindSourceAdapter; const AAlias:String=''): IioDependencyInjectionLocator; overload;
  end;

  // Dependency Injection Factory
  TioDependencyInjectionFactory = class abstract(TioDependencyInjectionBase)
  public
    class function GetRegister(const AContainerValue:TioDIContainerValue): TioDependencyInjectionRegister;
    class function GetLocator(const AInterfaceName:String): IioDependencyInjectionLocator; overload;
    class function GetLocator<TI:IInterface>: IioDependencyInjectionLocator<TI>; overload;
  end;

implementation

uses
  IupOrm, IupOrm.Exceptions, SysUtils, System.TypInfo, IupOrm.ObjectsForge.ObjectMaker;

{ TioDependencyInjectionBase }

class function TioDependencyInjectionBase.ComposeKey(const AInterface, AAlias: String): String;
begin
  if AAlias <> ''
    then Exit(AAlias)
    else Exit(AInterface);
end;

class function TioDependencyInjectionBase.Container: TioDependencyInjectionContainerRef;
begin
  Result := TioDependencyInjectionContainer;
end;

class function TioDependencyInjectionBase.InterfaceGUIToString<T>: String;
var
  pinfo: PTypeInfo;
  pdata: PTypeData;
begin
  pinfo := TypeInfo(T);
  if pinfo = nil then Exit(Self.ClassName + ': TypeInfo (GUI) not found!');
  pdata := GetTypeData(pinfo);
  Result := GUIDtoString(pdata.Guid);
end;

class function TioDependencyInjectionBase.InterfaceNameToString<T>: String;
var
  pinfo: PTypeInfo;
  AName: String;
begin
  pinfo := TypeInfo(T);
  if pinfo = nil then Exit(Self.ClassName + ': TypeInfo (name) not found!');
  Result := pinfo.NameFld.ToString;
//  Result := pinfo.Name;
end;

{ TioDependencyInjection }

class function TioDependencyInjection.Locate(const AInterfaceNameOrAlias: String): IioDependencyInjectionLocator;
begin
  Result := TioDependencyInjectionFactory.GetLocator(AInterfaceNameOrAlias);
end;

class function TioDependencyInjection.Locate<T>: IioDependencyInjectionLocator<T>;
begin
  Result := TioDependencyInjectionFactory.GetLocator<T>;
end;

class function TioDependencyInjection.LocateViewModel(const AInterfaceNameOrAlias, AModelClassName,
  AWhere, AAlias: String): IioDependencyInjectionLocator;
begin
  Result := Self.Locate(AInterfaceNameOrAlias)
                .Alias(AAlias)
                .ConstructorMarker('CreateByClassName')
                .ConstructorParams([AModelClassName, AWhere]);
end;

class function TioDependencyInjection.LocateViewModel(const AInterfaceNameOrAlias:String; const AMasterBindSource: TioMasterBindSource;
  const AMasterPropertyName, AAlias: String): IioDependencyInjectionLocator;
begin
  Result := Self.Locate(AInterfaceNameOrAlias)
                .Alias(AAlias)
                .ConstructorMarker('CreateByMasterBindSource')
                .ConstructorParams([TValue.From(AMasterBindSource), AMasterPropertyName]);
end;

class function TioDependencyInjection.LocateViewModel(const AInterfaceNameOrAlias: String;
  ABindSourceAdapter: IioActiveBindSourceAdapter; const AAlias:String): IioDependencyInjectionLocator;
begin
  Result := Self.Locate(AInterfaceNameOrAlias)
                .Alias(AAlias)
                .ConstructorMarker('CreateByBindSourceAdapter')
                .ConstructorParams([TValue.From(ABindSourceAdapter)]);
end;

class function TioDependencyInjection.LocateViewModel<T>(const AModelClassName, AWhere, AAlias: String): IioDependencyInjectionLocator<T>;
begin
  Result := Self.Locate<T>
                .Alias(AAlias)
                .ConstructorMarker('CreateByClassName')
                .ConstructorParams([AModelClassName, AWhere]);
end;

class function TioDependencyInjection.LocateViewModel<T>(const AMasterBindSource: TioMasterBindSource;
  const AMasterPropertyName, AAlias: String): IioDependencyInjectionLocator;
begin
  Result := Self.Locate<T>
                .Alias(AAlias)
                .ConstructorMarker('CreateByMasterBindSource')
                .ConstructorParams([TValue.From(AMasterBindSource), AMasterPropertyName]);
end;

class function TioDependencyInjection.LocateViewModel<T>(
  const ABindSourceAdapter: IioActiveBindSourceAdapter; const AAlias:String): IioDependencyInjectionLocator;
begin
  Result := Self.Locate<T>
                .Alias(AAlias)
                .ConstructorMarker('CreateByBindSourceAdapter')
                .ConstructorParams([TValue.From(ABindSourceAdapter)]);
end;

class function TioDependencyInjection.RegisterClass(const AClassRef: TioClassRef): TioDependencyInjectionRegister;
var
  ContainerValue: TioDIContainerValue;
begin
  ContainerValue.ClassRef := AClassRef;
  Result := TioDependencyInjectionFactory.GetRegister(ContainerValue);
end;

class function TioDependencyInjection.RegisterClass<T>: TioDependencyInjectionRegister;
var
  ContainerValue: TioDIContainerValue;
begin
  ContainerValue.ClassRef := T;
  Result := TioDependencyInjectionFactory.GetRegister(ContainerValue);
end;

{ TioDependencyInjectionRegister }

function TioDependencyInjectionRegister.Alias(const AAlias: String): TioDependencyInjectionRegister;
begin
  Self.FAlias := AAlias;
  Result := Self;
end;

constructor TioDependencyInjectionRegister.Create(const AContainerValue:TioDIContainerValue);
begin
  inherited Create;
  Self.FContainerValue := AContainerValue;
end;

procedure TioDependencyInjectionRegister.Execute;
begin
  Self.Container.Add(Self.GetKey, Self.GetValue);
  Self.Free;
end;

function TioDependencyInjectionRegister.GetKey: TioDIContainerKey;
begin
  Result := Self.ComposeKey(FInterfaceName, FAlias);
end;

function TioDependencyInjectionRegister.GetValue: TioDIContainerValue;
begin
  Result := Self.FContainerValue;
end;

function TioDependencyInjectionRegister.Implements(const AInterfaceName: String): TioDependencyInjectionRegister;
begin
  Self.FInterfaceName := AInterfaceName;
  Result := Self;
end;

function TioDependencyInjectionRegister.Implements<T>: TioDependencyInjectionRegister;
begin
  Result := Self.Implements(Self.InterfaceNameToString<T>);
end;

{ TioDependencyInjectionContainer }

class procedure TioDependencyInjectionContainer.Add(const AKey: TioDIContainerKey; const AValue: TioDIContainerValue);
begin
  if Self.Exists(AKey) then
    raise EIupOrmException.Create(Self.ClassName + ': Key already exist in the dependency injection cantainer!');
  Self.FContainer.Add(AKey, AValue);
end;

class procedure TioDependencyInjectionContainer.Build;
begin
  Self.FContainer := TioDIContainerInstance.Create;
end;

class procedure TioDependencyInjectionContainer.CleanUp;
begin
  Self.FContainer.Free;
end;

class function TioDependencyInjectionContainer.Exists(const AKey: TioDIContainerKey): Boolean;
begin
  Result := Self.FContainer.ContainsKey(AKey);
end;

class function TioDependencyInjectionContainer.Get(const AKey: TioDIContainerKey): TioDIContainerValue;
begin
  if not Self.Exists(AKey) then
    raise EIupOrmException.Create(Self.ClassName + ': Key not found!');
  Result := Self.FContainer.Items[AKey];
end;

{ TioViewModelShuttle }

class procedure TioViewModelShuttle.Build;
begin
  FCriticalSection := TCriticalSection.Create;
end;

class procedure TioViewModelShuttle.CleanUp;
begin
  FCriticalSection.Free;
end;

class function TioViewModelShuttle.Exist: Boolean;
begin
  Result := Assigned(Self.FViewModel);
end;

class function TioViewModelShuttle.Get: IioViewModel;
begin
  Result := Self.FViewModel;
end;

class procedure TioViewModelShuttle.Lock(AViewModel: IioViewModel);
begin
  Self.FCriticalSection.Acquire;
  try
    if Self.Exist then raise EIupOrmException.Create(Self.ClassName +  ': The shuttle should be empty but it is not!');
    if not Self.Exist then raise EIupOrmException.Create(Self.ClassName +  ': "AViewModel" param should not be empty!');
    Self.FViewModel  := AViewModel;
  except
    Self.FCriticalSection.Release;
  end;
end;

class procedure TioViewModelShuttle.Unlock;
begin
  Self.FViewModel := nil;
  Self.FCriticalSection.Release;
end;

{ TioDependencyInjectionLocator }

function TioDependencyInjectionLocator.Alias(const AAlias: String): IioDependencyInjectionLocator;
begin
  FAlias := AAlias;
  Result := Self;
end;

function TioDependencyInjectionLocator.ConstructorMarker(const AConstructorMarker: String): IioDependencyInjectionLocator;
begin
  FConstructorMarker := AConstructorMarker;
  Result := Self;
end;

function TioDependencyInjectionLocator.ConstructorMethod(const AConstructorMethod: String): IioDependencyInjectionLocator;
begin
  FConstructorMethod := AConstructorMethod;
  Result := Self;
end;

function TioDependencyInjectionLocator.ConstructorParams(const AParams: array of TValue): IioDependencyInjectionLocator;
var
  i: Integer;
begin
  // Solo così sembra andare bene
  SetLength(FConstructorParams, Length(AParams));
  for i := 0 to High(AParams) do FConstructorParams[i] := AParams[i];
  Result := Self;
end;

constructor TioDependencyInjectionLocator.Create(AInterfaceName: String);
begin
  inherited Create;
  FInterfaceName := AInterfaceName;
  FViewModel := nil;
end;

function TioDependencyInjectionLocator.Get: TObject;
var
  ContainerValue: TioDIContainerValue;
begin
  Result := nil;
  // Retrieve the Class Type Reference
  ContainerValue := Self.Container.Get(Self.GetKey);
  // if then ViewModel is present then Lock it (MVVM)
  if Self.ViewModelExist then TioViewModelShuttle.Lock(FViewModel);
  try
    // Object creation
    Result := TioObjectMaker.CreateObjectByClassRefEx(ContainerValue.ClassRef, FConstructorParams, FConstructorMarker, FConstructorMethod);
  finally
    // if the ViewModel is present then UnLock it (MVVM)
    if TioViewModelShuttle.Exist then TioViewModelShuttle.Unlock;
  end;
end;

function TioDependencyInjectionLocator.GetKey: TioDIContainerKey;
begin
  Result := Self.ComposeKey(FInterfaceName, FAlias);
end;

function TioDependencyInjectionLocator.ViewModel(const AViewModel: IioViewModel): IioDependencyInjectionLocator;
begin
  FViewModel := AViewModel;
  Result := Self;
end;

function TioDependencyInjectionLocator.ViewModel(const AInterfaceNameOrAlias, AModelClassName, AWhere,
  AAlias: String): IioDependencyInjectionLocator;
begin
  Result := Self.ViewModel(
    TiupOrm.DependencyInjection.LocateViewModel(AInterfaceNameOrAlias, AModelClassName, AWhere, AAlias).Get.ioAsInterface<IioViewModel>
    );
end;

function TioDependencyInjectionLocator.ViewModel(const AInterfaceNameOrAlias: String; const AMasterBindSource: TioMasterBindSource;
  const AMasterPropertyName, AAlias: String): IioDependencyInjectionLocator;
begin
  Result := Self.ViewModel(
    TiupOrm.DependencyInjection.LocateViewModel(AInterfaceNameOrAlias, AMasterBindSource, AMasterPropertyName, AAlias).Get.ioAsInterface<IioViewModel>
    );
end;

function TioDependencyInjectionLocator.ViewModel(const AInterfaceNameOrAlias: String;
  ABindSourceAdapter: IioActiveBindSourceAdapter; const AAlias: String): IioDependencyInjectionLocator;
begin
  Result := Self.ViewModel(
    TiupOrm.DependencyInjection.LocateViewModel(AInterfaceNameOrAlias, ABindSourceAdapter, AAlias).Get.ioAsInterface<IioViewModel>
    );
end;

function TioDependencyInjectionLocator.ViewModelExist: Boolean;
begin
  Result := Assigned(Self.FViewModel);
end;

{ TioDependencyInjectionFactory }

class function TioDependencyInjectionFactory.GetLocator(const AInterfaceName: String): IioDependencyInjectionLocator;
begin
  Result := TioDependencyInjectionLocator.Create(AInterfaceName);
end;

class function TioDependencyInjectionFactory.GetLocator<TI>: IioDependencyInjectionLocator<TI>;
begin
  Result := TioDependencyInjectionLocator<TI>.Create(Self.InterfaceNameToString<TI>);
end;

class function TioDependencyInjectionFactory.GetRegister(const AContainerValue:TioDIContainerValue): TioDependencyInjectionRegister;
begin
  Result := TioDependencyInjectionRegister.Create(AContainerValue);
end;

{ TioDependencyInjectionLocator<T> }

function TioDependencyInjectionLocator<TI>.Alias(const AAlias: String): IioDependencyInjectionLocator<TI>;
begin
  Result := Self;
  TioDependencyInjectionLocator(Self).Alias(AAlias);
end;

function TioDependencyInjectionLocator<TI>.ConstructorMarker(const AConstructorMarker: String): IioDependencyInjectionLocator<TI>;
begin
  Result := Self;
  TioDependencyInjectionLocator(Self).ConstructorMarker(AConstructorMarker);
end;

function TioDependencyInjectionLocator<TI>.ConstructorMethod(const AConstructorMethod: String): IioDependencyInjectionLocator<TI>;
begin
  Result := Self;
  TioDependencyInjectionLocator(Self).ConstructorMethod(AConstructorMethod);
end;

function TioDependencyInjectionLocator<TI>.ConstructorParams(const AParams: array of TValue): IioDependencyInjectionLocator<TI>;
begin
  Result := Self;
  TioDependencyInjectionLocator(Self).ConstructorParams(AParams);
end;

function TioDependencyInjectionLocator<TI>.Get: TI;
begin
  Result := inherited Get.ioAsInterface<TI>;
end;

function TioDependencyInjectionLocator<TI>.ViewModel(const AInterfaceNameOrAlias, AModelClassName, AWhere,
  AAlias: String): IioDependencyInjectionLocator<TI>;
begin
  Result := Self;
  TioDependencyInjectionLocator(Self).ViewModel(AInterfaceNameOrAlias, AModelClassName, AWhere, AAlias);
end;

function TioDependencyInjectionLocator<TI>.ViewModel(const AInterfaceNameOrAlias: String;
  const AMasterBindSource: TioMasterBindSource; const AMasterPropertyName, AAlias: String): IioDependencyInjectionLocator<TI>;
begin
  Result := Self;
  TioDependencyInjectionLocator(Self).ViewModel(AInterfaceNameOrAlias, AMasterBindSource, AMasterPropertyName, AAlias);
end;

function TioDependencyInjectionLocator<TI>.ViewModel(const AInterfaceNameOrAlias: String;
  ABindSourceAdapter: IioActiveBindSourceAdapter; const AAlias: String): IioDependencyInjectionLocator<TI>;
begin
  Result := Self;
  TioDependencyInjectionLocator(Self).ViewModel(AInterfaceNameOrAlias, ABindSourceAdapter, AAlias);
end;

function TioDependencyInjectionLocator<TI>.ViewModel(const AViewModel: IioViewModel): IioDependencyInjectionLocator<TI>;
begin
  Result := Self;
  TioDependencyInjectionLocator(Self).ViewModel(AViewModel);
end;


initialization
  TioDependencyInjectionContainer.Build;
  TioViewModelShuttle.Build;

finalization
  TioDependencyInjectionContainer.CleanUp;
  TioViewModelShuttle.CleanUp;

end.
