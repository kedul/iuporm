unit IupOrm.MVVM.Factory;

interface

uses
  IupOrm.MVVM.Interfaces, IupOrm.LiveBindings.Interfaces,
  IupOrm.LiveBindings.PrototypeBindSource;

type

  TioMVVMFactory = class
  public
    class function ViewData(const ADataObj:TObject; const AViewDataType:TioViewDataType): IioViewData; overload;
    class function ViewData(const ADataIntf:IInterface; const AViewDataType:TioViewDataType): IioViewData; overload;
    class function ViewData(const ABindSourceAdapter:IioActiveBindSourceAdapter): IioViewData; overload;
    class function ViewData(const ATypeName, ATypeAlias, AWhere: String; const AViewDataType:TioViewDataType; const AAutoLoadData:Boolean=True): IioViewData; overload;
    class function ViewData(const AMasterBindSource:TioMasterBindSource; const AMasterPropertyName:String=''): IioViewData; overload;
  end;

implementation

uses
  IupOrm.MVVM.ViewModel.ViewData;

{ TioMVVMFactory }

class function TioMVVMFactory.ViewData(const ADataIntf: IInterface; const AViewDataType: TioViewDataType): IioViewData;
begin
  Result := TioViewData.Create(ADataIntf, AViewDataType);
end;

class function TioMVVMFactory.ViewData(const ADataObj: TObject; const AViewDataType: TioViewDataType): IioViewData;
begin
  Result := TioViewData.Create(ADataObj, AViewDataType);
end;

class function TioMVVMFactory.ViewData(const ABindSourceAdapter: IioActiveBindSourceAdapter): IioViewData;
begin
  Result := TioViewData.Create(ABindSourceAdapter);
end;

class function TioMVVMFactory.ViewData(const AMasterBindSource: TioMasterBindSource;
  const AMasterPropertyName: String): IioViewData;
begin
  Result := TioViewData.Create(AMasterBindSource, AMasterPropertyName);
end;

class function TioMVVMFactory.ViewData(const ATypeName, ATypeAlias, AWhere: String; const AViewDataType: TioViewDataType;
  const AAutoLoadData: Boolean): IioViewData;
begin
  Result := TioViewData.Create(ATypeName, ATypeAlias, AWhere, AViewDataType, AAutoLoadData);
end;

end.
