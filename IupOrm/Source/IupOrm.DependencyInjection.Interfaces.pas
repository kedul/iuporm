unit IupOrm.DependencyInjection.Interfaces;

interface

uses
  System.Rtti, IupOrm.MVVM.Interfaces;

type

  IioDependencyInjectionLocator = interface
    ['{51289FD7-AA55-43D9-BF5B-EDA5BF27D301}']
    function Get: TObject;
    function ConstructorParams(const AParams: array of TValue): IioDependencyInjectionLocator;
    function ConstructorMethod(const AConstructorMethod: String): IioDependencyInjectionLocator;
    function ConstructorMarker(const AConstructorMarker: String): IioDependencyInjectionLocator;
    function ViewModel(AViewModel:IioViewModel): IioDependencyInjectionLocator;
  end;

  IioDependencyInjectionLocator<T: IInterface> = interface(IioDependencyInjectionLocator)
    ['{EA9F3CAD-B9A2-4607-8D80-881EF4C36EDE}']
    function Get: T; overload;
  end;

implementation

end.
