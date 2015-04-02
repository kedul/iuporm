unit Model.BaseListClasses;

interface

uses
  System.Generics.Collections,
  Model.BaseClasses,
  Model.CostType,
  Model.Cost,
  Model.Travel;

type

  // Class Reference
  TBaseClassRef = class of TObject;

  // Classe base per liste di oggetti all'interno del programma
  //  creato per avere un antenato comune a tutte le ObjetcList
  //  all'interno del programma dove eventualmente inserire
  //  funzionalità che devono poi essere ereditate da tutte le
  //  sue derivate
  TBaseObjectList<T:TBaseClass, constructor> = class(TObjectList<T>)
    // Function che ritorna il tipo di T
    function GetGenericTypeRef: TBaseClassRef;
  end;


  // Classe per una lista di oggetti base
  TBaseList = class(TBaseObjectList<TBaseClass>)
  end;


  // Classe per una lista di CostType
  TCostTypeList = class(TBaseObjectList<TCostType>)
  end;

  // Classe per una lista di Cost
  TCostList = class(TBaseObjectList<TCostGeneric>)
  end;

  // Classe per una lista di Cost
  TTravelList = class(TBaseObjectList<TTravel>)
  end;

implementation

{ TBaseObjectList<T> }

function TBaseObjectList<T>.GetGenericTypeRef: TBaseClassRef;
begin
  Result := T;
end;

end.
