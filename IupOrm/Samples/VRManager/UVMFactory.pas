unit UVMFactory;

interface

uses ViewModel.Interfaces;

type

  TVMFactory = class
  public
    class function VMTravelList: IVMTravelList;
  end;

implementation

uses UVMTravelList;

{ TVMFactory }

class function TVMFactory.VMTravelList: IVMTravelList;
begin
  Result := TVMTravelList.Create;
  Result.Get;
end;

end.
