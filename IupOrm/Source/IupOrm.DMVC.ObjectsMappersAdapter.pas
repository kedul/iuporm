unit IupOrm.DMVC.ObjectsMappersAdapter;

interface

uses
  IupOrm.DuckTyped.Interfaces;

type

  // DuckTypedStreamObject interface
  IWrappedObject = interface(IioDuckTypedStreamObject)
    ['{37EA7CB5-1673-4701-9585-E6BBB74E1E58}']
  end;

function WrapAsObject(const AObject: TObject): IWrappedObject;

implementation

uses
  IupOrm.DuckTyped.Factory, System.SysUtils;

function WrapAsObject(const AObject: TObject): IWrappedObject;
var
  AWrappedObj: TObject;
begin
  AWrappedObj := TioDuckTypedFactory.DuckTypedStreamObject(AObject) as TObject;
  Supports(AWrappedObj, IWrappedObject, Result);
end;


end.
