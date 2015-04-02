unit AnotherModel;

interface

uses
  Interfaces, IupOrm.Containers.Interfaces, IupOrm.Attributes;

type

  [ioTable('Persons')]
  [ioClassFromField]
  TAnotherPerson = class(TInterfacedObject, IPerson)
  private
    FID: Integer;
    FLastName: String;
    FFirstName: String;
    FPhones: IioList<IPhoneNumber>;
  protected
    procedure SetID(AValue:Integer);
    function GetID: Integer;
    procedure SetFirstName(AValue:String);
    function GetFirstName: String;
    procedure SetLastName(AValue:String);
    function GetLastName: String;
    procedure SetPhones(AValue:IioList<IPhoneNumber>);
    function GetPhones: IioList<IPhoneNumber>;
    function GetFullName: String;
    function GetClassNameProp: String;
  public
    constructor Create; overload;
    constructor Create(NewFirstName, NewLastName: String; NewID: Integer = 0); overload;
    destructor Destroy; override;
    [ioOID]                         // Not necessary if property is exactly named "ID" as in this case
    property ID:Integer read GetID write SetID;
    [ioField('FIRST_NAME')]         // Not necessary if property has the same name of the field
    property FirstName:String read GetFirstName write SetFirstName;
    [ioField('LAST_NAME')]          // Not necessary if property has the same name of the field
    property LastName:String read GetLastName write SetLastName;
    [ioHasMany('IPhoneNumber', 'PersonID', ioLazyLoad)]
    property Phones:IioList<IPhoneNumber> read GetPhones write SetPhones;
    [ioSkip]
    property FullName:String read GetFullName;
    [ioSkip]
    property ClassNameProp:String read GetClassNameProp;
  end;


implementation

uses
  IupOrm, SysUtils;

{ TAnotherPerson }

constructor TAnotherPerson.Create;
begin
  inherited;
  FPhones := TIupOrm.DependencyInjection.Locate<IioList<Interfaces.IPhoneNumber>>.Get;
end;

constructor TAnotherPerson.Create(NewFirstName, NewLastName: String; NewID: Integer);
begin
  inherited Create;
//  FPhones := TIupOrm.DependencyInjection.Locate<IioList<Interfaces.IPhoneNumber>>.Get;
  FID := NewID;
  FFirstName := NewFirstName;
  FLastName := NewLastName;
end;

destructor TAnotherPerson.Destroy;
begin
//  if Assigned(FPhones) then FPhones.Free;
  inherited;
end;

function TAnotherPerson.GetClassNameProp: String;
begin
  Result := Self.ClassName + ' (Another)';
end;

function TAnotherPerson.GetFirstName: String;
begin
  Result := FFirstName;
end;

function TAnotherPerson.GetFullName: String;
begin
 Result := (LastName + ' ' + FirstName).Trim;
end;

function TAnotherPerson.GetID: Integer;
begin
  Result := FID;
end;

function TAnotherPerson.GetLastName: String;
begin
  Result := FLastName;
end;

function TAnotherPerson.GetPhones: IioList<IPhoneNumber>;
begin
  Result := FPhones;
end;

procedure TAnotherPerson.SetFirstName(AValue: String);
begin
  FFirstName := AValue;
end;

procedure TAnotherPerson.SetID(AValue: Integer);
begin
  FID := AValue;
end;

procedure TAnotherPerson.SetLastName(AValue: String);
begin
  FLastName := AValue;
end;

procedure TAnotherPerson.SetPhones(AValue: IioList<IPhoneNumber>);
begin
  FPhones := AValue;
end;

end.
