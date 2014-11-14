unit IupOrm.MVVM.ViewModelBase;

interface

uses
  System.SysUtils, System.Classes,
  IupOrm.LiveBindings.Interfaces, IupOrm.MVVM.Interfaces, System.Rtti,
  IupOrm.Attributes;

type
  TioViewModelBase = class(TDataModule, IioViewModel)
  private
    { Private declarations }
    FViewData: IioViewData;
  protected
// ---------------- Start: section added for IInterface support ---------------
{$IFNDEF AUTOREFCOUNT}
    [Volatile] FRefCount: Integer;
{$ENDIF}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
// ---------------- End: section added for IInterface support ---------------
  public
    { Public declarations }
    constructor Create(ADataObj:TObject); overload;
    [ioMarker('ThisIsCalledByIOPrototypeBindSource')]
    constructor Create(ABindSourceAdapter:IioActiveBindSourceAdapter); overload;
    function ViewData: IioViewData;
    function GetActionByName(AActionName: String): TBasicAction;
    procedure BindActions(const AView:IioView);
    procedure BindAction(const AType:TRttiType; const AView:IioView; const AComponentName, AActionName: String);
// ---------------- Start: section added for IInterface support ---------------
{$IFNDEF AUTOREFCOUNT}
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property RefCount: Integer read FRefCount;
{$ENDIF}
// ---------------- End: section added for IInterface support ---------------
  end;
// ---------------- Start: section added for IInterface support ---------------
  {$IFNDEF SYSTEM_HPP_DEFINES_OBJECTS}
//  {$NODEFINE TInterfacedObject}         { defined in systobj.h }
  {$ENDIF}
// ---------------- End: section added for IInterface support ---------------


implementation

uses IupOrm.MVVM.Factory, IupOrm.Exceptions, IupOrm.RttiContext.Factory;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TioViewModel }







{$IFNDEF AUTOREFCOUNT}

function TioViewModelBase.GetActionByName(AActionName: String): TBasicAction;
var
  AObj: TObject;
begin
  // Init
  Result := nil;
  if AActionName.Trim = '' then raise EIupOrmException.Create(Self.ClassName + ': invalid action name!');
  // Find the action
  AObj := Self.FindComponent(AActionName);
  // If found then return the action itself
  if Assigned(AObj) and (AObj is TBasicAction) then
    Exit(AObj as TBasicAction);
  // Else raise an exception
  raise EIupOrmException.Create(Self.ClassName + ': action not found!');
end;

procedure TioViewModelBase.AfterConstruction;
begin
// Release the constructor's implicit refcount
  AtomicDecrement(FRefCount);
end;

procedure TioViewModelBase.BeforeDestruction;
begin
  if RefCount <> 0 then
    Error(reInvalidPtr);
end;

procedure TioViewModelBase.BindAction(const AType:TRttiType; const AView:IioView; const AComponentName, AActionName: String);
var
  AObj: TObject;
  AProp: TRttiProperty;
  AAction: TBasicAction;
  AValue: TValue;
begin
  // Get RttiProperty
  AProp := AType.GetProperty('Action');
  if not Assigned(AProp) then EIupOrmException.Create(Self.ClassName + ': RttiProperty not found!');
  // Get the object
  AObj := AView.FindComponent(AComponentName);
  if not Assigned(AObj) then EIupOrmException.Create(Self.ClassName + ': View component not found!');
  // Get action
  AAction := Self.GetActionByName(AActionName);
  if not Assigned(AAction) then EIupOrmException.Create(Self.ClassName + ': Action not found!');
  // Set the action property of the object
  AValue := TValue.From<TBasicAction>(AAction);
  AProp.SetValue(AObj, AValue);
end;

procedure TioViewModelBase.BindActions(const AView: IioView);
var
  Typ: TRttiType;
  Fld: TRttiField;
  Attr: TCustomAttribute;
begin
  // Retrieve the RttiType of the view
  Typ := TioRttiContextFactory.RttiContext.GetType((AView as TObject).ClassType);
  for Fld in Typ.GetFields do
    for Attr in Fld.GetAttributes do
      if Attr is ioAction then
        Self.BindAction(Fld.FieldType, AView, Fld.Name, ioAction(Attr).Value);
end;

constructor TioViewModelBase.Create(ADataObj: TObject);
begin
  inherited Create(nil);
  FViewData := TioMVVMFactory.ViewData(ADataObj);
end;

constructor TioViewModelBase.Create(ABindSourceAdapter: IioActiveBindSourceAdapter);
begin
  inherited Create(nil);
  FViewData := TioMVVMFactory.ViewData(ABindSourceAdapter);
end;

class function TioViewModelBase.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TioViewModelBase(Result).FRefCount := 1;
end;

{$ENDIF AUTOREFCOUNT}








function TioViewModelBase.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TioViewModelBase.ViewData: IioViewData;
begin
  Result := FViewData;
end;

function TioViewModelBase._AddRef: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicIncrement(FRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function TioViewModelBase._Release: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
    Destroy;
{$ELSE}
  Result := __ObjRelease;
{$ENDIF}
end;

end.
