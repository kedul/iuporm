unit IupOrm.MVVM.ViewModel.ViewData;

interface

uses
  IupOrm.MVVM.Interfaces, IupOrm.LiveBindings.Interfaces,
  Data.Bind.ObjectScope;

type

  TioViewData = class(TInterfacedObject, IioViewData)
  private
    FDataObj: TObject;
    FBindSourceAdapter: IioActiveBindSourceAdapter;
  protected
  public
    function DataObj: TObject;
    function BindSourceAdapter: TBindSourceAdapter;
    constructor Create(ADataObj:TObject); overload;
    constructor Create(ABindSourceAdapter:IioActiveBindSourceAdapter); overload;
  end;

implementation

uses
  IupOrm.LiveBindings.ActiveListBindSourceAdapter, System.Generics.Collections,
  IupOrm.Context.Container;

{ TViewData }

function TioViewData.BindSourceAdapter: TBindSourceAdapter;
begin
  Result := FBindSourceAdapter as TBindSourceAdapter;
end;

constructor TioViewData.Create(ADataObj: TObject);
begin
  inherited Create;
  // Check if not assigned
  if not assigned(ADataObj) then
  begin
    Self.FDataObj := nil;
    FBindSourceAdapter := nil;
    Exit;
  end;
  // Assign the DataObject
  Self.FDataObj := ADataObj;
  // Create the BindSourceAdapter
  FBindSourceAdapter := TioActiveListBindSourceAdapter.Create(
                                                    Self.FDataObj.ClassType  // DataObject class reference
                                                  , ''  // where sql
                                                  , nil  // Owner
                                                  , TObjectList<TObject>.Create    // Create an empty list for adapter creation only
                                                  , False  // AutoLoadData := False (the object is already loaded)
                                                  , TioMapContainer.GetMap(Self.FDataObj.ClassName).ObjStatusExist  // Use ObjStatus async persist
                                                  , False  // OwnsObject
                                                 );
end;

constructor TioViewData.Create(ABindSourceAdapter: IioActiveBindSourceAdapter);
begin
  // Check if not assigned
  if not assigned(ABindSourceAdapter) then
  begin
    Self.FDataObj := nil;
    FBindSourceAdapter := nil;
    Exit;
  end;
  // Assign the BindSourceAdapter
  Self.FBindSourceAdapter := ABindSourceAdapter;
  // Retrieve the DataObject from the BindSourceAdapter
  Self.FDataObj := Self.FBindSourceAdapter.GetDataObject;
end;

function TioViewData.DataObj: TObject;
begin
  Result := FDataObj;
end;

end.
