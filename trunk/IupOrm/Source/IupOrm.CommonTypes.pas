unit IupOrm.CommonTypes;

interface

uses
  System.Rtti;

const
  IO_CLASSFROMFIELD_FIELDNAME = 'ClassInfo';

type

  // Object Status
  TIupOrmObjectStatus = (osDirty = 0, osClean, osDeleted);

  // Common ClassRef
  TioClassRef = class of TObject;

implementation

end.
