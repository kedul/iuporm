unit UVMTravelList;

interface

uses ViewModel.Interfaces, UVMBase, Model.BaseListClasses, Data.Bind.ObjectScope;

type
  TVMTravelList = class(TVMBase, IVMTravelList)
  strict private
    FDataObject: TTravelList;
  strict protected
    function GetDataObject: TTravelList;
  public
    destructor Destroy; override;
    procedure Get;
    function GetDataObjectBindSourceAdapter(AOwner:TPrototypeBindSource): TBindSourceAdapter;
    property DataObject: TTravelList read GetDataObject;
  end;


implementation

uses Service, System.Generics.Collections;

{ TVMTravelList }

destructor TVMTravelList.Destroy;
begin
  if Assigned(FDataObject) then FDataObject.Free;
  inherited;
end;

procedure TVMTravelList.Get;
begin
//  FDataObject := TServiceFactory.Travel.GetAll;
end;

function TVMTravelList.GetDataObject: TTravelList;
begin
  Result := FDataObject;
end;

function TVMTravelList.GetDataObjectBindSourceAdapter(AOwner:TPrototypeBindSource): TBindSourceAdapter;
begin
  Result := nil;
  Result := TListBindSourceAdapter.Create(AOwner, TObjectList<TObject>(FDataObject), FDataObject.GetGenericTypeRef);
end;

end.
