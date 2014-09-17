unit IupOrm.LiveBindings.Notification;

interface

uses
  IupOrm.LiveBindings.Interfaces;

type

  TioBSANotificationEvent = procedure(Sender:TObject; const ANotification:IioBSANotification) of object;

  TioBSANotification = class(TInterfacedObject, IioBSANotification)
  strict protected
    FSender: TObject;
    FSubject: TObject;
    FNotificationType: TioBSANotificationType;
  public
    constructor Create(ASender:TObject; ASubject:TObject; ANotificationType:TioBSANotificationType); overload;
    function Sender: TObject;
    function Subject: TObject;
    function NotificationType: TioBSANotificationType;
  end;

implementation

{ TioBSANotification }

constructor TioBSANotification.Create(ASender, ASubject: TObject;
  ANotificationType: TioBSANotificationType);
begin
  inherited Create;
  Self.FSender := ASender;
  Self.FSubject := ASubject;
  Self.FNotificationType := ANotificationType;
end;

function TioBSANotification.NotificationType: TioBSANotificationType;
begin
  Result := Self.FNotificationType;
end;

function TioBSANotification.Sender: TObject;
begin
  Result := Self.FSender;
end;

function TioBSANotification.Subject: TObject;
begin
  Result := Self.FSubject;
end;

end.
