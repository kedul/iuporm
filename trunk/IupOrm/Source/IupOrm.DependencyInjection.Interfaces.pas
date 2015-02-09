unit IupOrm.DependencyInjection.Interfaces;

interface

uses
  System.Rtti, IupOrm.MVVM.Interfaces, IupOrm.LiveBindings.PrototypeBindSource,
  IupOrm.LiveBindings.Interfaces;

type

  IioDependencyInjectionLocator = interface
    ['{51289FD7-AA55-43D9-BF5B-EDA5BF27D301}']
    function Exist: Boolean;
    function Get: TObject;
    function Alias(const AAlias:String): IioDependencyInjectionLocator;
    function ConstructorParams(const AParams: array of TValue): IioDependencyInjectionLocator;
    function ConstructorMethod(const AConstructorMethod: String): IioDependencyInjectionLocator;
    function ConstructorMarker(const AConstructorMarker: String): IioDependencyInjectionLocator;
    function ViewModel(const AViewModel:IioViewModel): IioDependencyInjectionLocator; overload;

    function ViewModel(const AInterfaceNameOrAlias, AModelClassName:String; const AWhere:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
    function ViewModel(const AInterfaceNameOrAlias:String; const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
    function ViewModel(const AInterfaceNameOrAlias:String; ABindSourceAdapter:IioActiveBindSourceAdapter; const AAlias:String=''): IioDependencyInjectionLocator; overload;
//    function ViewModel<T:IioViewModel>(const AModelClassName:String; const AWhere:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
//    function ViewModel<T:IioViewModel>(const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''; const AAlias:String=''): IioDependencyInjectionLocator; overload;
//    function ViewModel<T:IioViewModel>(const ABindSourceAdapter:IioActiveBindSourceAdapter; const AAlias:String=''): IioDependencyInjectionLocator; overload;
  end;

  IioDependencyInjectionLocator<TI: IInterface> = interface(IioDependencyInjectionLocator)
    ['{EA9F3CAD-B9A2-4607-8D80-881EF4C36EDE}']
    function Get: TI; overload;
    function Alias(const AAlias:String): IioDependencyInjectionLocator<TI>;
    function ConstructorParams(const AParams: array of TValue): IioDependencyInjectionLocator<TI>;
    function ConstructorMethod(const AConstructorMethod: String): IioDependencyInjectionLocator<TI>;
    function ConstructorMarker(const AConstructorMarker: String): IioDependencyInjectionLocator<TI>;
    function ViewModel(const AViewModel:IioViewModel): IioDependencyInjectionLocator<TI>; overload;

    function ViewModel(const AInterfaceNameOrAlias, AModelClassName:String; const AWhere:String=''; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
    function ViewModel(const AInterfaceNameOrAlias:String; const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
    function ViewModel(const AInterfaceNameOrAlias:String; ABindSourceAdapter:IioActiveBindSourceAdapter; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
//    function ViewModel<T:IioViewModel>(const AModelClassName:String; const AWhere:String=''; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
//    function ViewModel<T:IioViewModel>(const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
//    function ViewModel<T:IioViewModel>(const ABindSourceAdapter:IioActiveBindSourceAdapter; const AAlias:String=''): IioDependencyInjectionLocator<TI>; overload;
  end;

implementation

end.
