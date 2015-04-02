unit IupOrm.CommonTypes;

interface

uses
  System.Rtti, System.Generics.Collections;

const
  IO_CLASSFROMFIELD_FIELDNAME = 'ClassInfo';
  IO_CONNECTIONDEF_DEFAULTNAME = 'NO_NAME';
  IO_INTEGER_NULL_VALUE = 0;

type

  // Object Status
  TIupOrmObjectStatus = (osDirty = 0, osClean, osDeleted);

  // Common ClassRef
  TioClassRef = class of TObject;

  // Common interface getting the underlying object implementing the interface
  IioGetObject = interface
    ['{2CCE4A16-03B4-4CD1-BED8-B88AB87CC0B3}']
    function GetObject: TObject;
    function GetInternalList: TList<IInterface>;
  end;

implementation

end.
