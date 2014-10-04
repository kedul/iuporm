unit IupOrm.MVVM.ViewModel.ViewData;

interface

uses
  IupOrm.MVVM.ViewModel.Interfaces, IupOrm.LiveBindings.Interfaces;

type

  TioViewData = class(TInterfacedObject, IioViewData)
  private
    FDataObj: TObject;
    FBindSourceAdapter: IioActiveBindSourceAdapter;
  protected
  public
    function DataObj: TObject;
    procedure SetDataObj(ADataObj:TObject);
    function BindSourceAdapter: IioActiveBindSourceAdapter;
    procedure SetBindSourceAdapter(ABindSourceAdapter: IioActiveBindSourceAdapter);
  end;

implementation

uses
  Data.Bind.ObjectScope;

{ TViewData }

function TioViewData.BindSourceAdapter: IioActiveBindSourceAdapter;
begin
  Result := FBindSourceAdapter;
end;

function TioViewData.DataObj: TObject;
begin
  Result := FDataObj;
end;

procedure TioViewData.SetBindSourceAdapter(
  ABindSourceAdapter: IioActiveBindSourceAdapter);
begin
  FBindSourceAdapter := ABindSourceAdapter;
end;

procedure TioViewData.SetDataObj(ADataObj: TObject);
begin
  FDataObj := ADataObj;
end;

end.
