unit IupOrm.MVVM.Factory;

interface

uses
  IupOrm.MVVM.Interfaces, IupOrm.LiveBindings.Interfaces;

type

  TioMVVMFactory = class
  public
    class function ViewData(ADataObj:TObject): IioViewData; overload;
    class function ViewData(ABindSourceAdapter:IioActiveBindSourceAdapter): IioViewData; overload;
  end;

implementation

uses
  IupOrm.MVVM.ViewModel.ViewData;

{ TioMVVMFactory }

class function TioMVVMFactory.ViewData(ADataObj: TObject): IioViewData;
begin
  Result := TioViewData.Create(ADataObj);
end;

class function TioMVVMFactory.ViewData(ABindSourceAdapter: IioActiveBindSourceAdapter): IioViewData;
begin
  Result := TioViewData.Create(ABindSourceAdapter);
end;

end.
