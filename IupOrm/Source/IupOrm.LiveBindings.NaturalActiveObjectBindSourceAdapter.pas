unit IupOrm.LiveBindings.NaturalActiveObjectBindSourceAdapter;

interface

uses
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter,
  IupOrm.LiveBindings.Interfaces, System.Classes;

type

  TioNaturalActiveObjectBindSourceAdapter = class(TioActiveObjectBindSourceAdapter)
  strict private
    FSourceAdapter: IioNaturalBindSourceAdapterSource;
  public
    constructor Create(AOwner:TComponent; ASourceAdapter:IioNaturalBindSourceAdapterSource); overload;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification); override;
  end;

implementation

{ TioNaturalActiveObjectBindSourceAdapter }

constructor TioNaturalActiveObjectBindSourceAdapter.Create(AOwner:TComponent;
  ASourceAdapter:IioNaturalBindSourceAdapterSource);
begin
  inherited Create(
                   ASourceAdapter.GetCurrent.ClassType,
                   '',
                   AOwner,
                   ASourceAdapter.GetCurrent,
                   False,
                   ASourceAdapter.UseObjStatus,
                   False
                  );
  FSourceAdapter := ASourceAdapter;
end;

procedure TioNaturalActiveObjectBindSourceAdapter.Notify(Sender: TObject;
  ANotification: IioBSANotification);
begin
  inherited;
  if Assigned(FSourceAdapter)
    then FSourceAdapter.Notify(Self, ANotification);
end;

end.
