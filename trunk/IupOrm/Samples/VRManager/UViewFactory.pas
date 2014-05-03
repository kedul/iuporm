unit UViewFactory;

interface

uses View.TravelListFrame, System.Classes, FMX.Types;

type

  TViewFactory = class
  public
    class function ViewTravelListFrame(AOwner: TFmxObject): TViewTravelListFrame;
  end;

implementation

uses FMX.Forms, ViewModel;

{ TViewFactory }

class function TViewFactory.ViewTravelListFrame(AOwner: TFmxObject): TViewTravelListFrame;
begin
  Result := TViewTravelListFrame.Create(AOwner, TViewModelFactory.TravelListViewModel);
  Result.Parent := AOwner;
end;

end.
