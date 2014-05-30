unit Model;

interface

uses IupOrm.Attributes, System.Generics.Collections;

type

  [ioTable('Phones')]
  TPhoneNumber = class
  private
    FPhoneNumber: String;
    FPhoneType: String;
    FPersonID: Integer;
    FID: Integer;
  public
    constructor Create(NewPhoneType, NewPhoneNumber: String; NewPersonID: Integer; NewID: Integer = 0); overload;
    property ID: Integer read FID write FID;
    property PersonID:Integer read FPersonID write FPersonID;
    property PhoneType:String read FPhoneType write FPhoneType;
    property PhoneNumber:String read FPhoneNumber write FPhoneNumber;
  end;

  [ioTable('Persons')]
  [ioClassFromField]
  TPerson = class
  private
    FID: Integer;
    FLastName: String;
    FFirstName: String;
    FPhones: TObjectList<TPhoneNumber>;
    function GetFullName: String;
    function GetClassNameProp: String;
  public
    constructor Create(NewFirstName, NewLastName: String; NewID: Integer = 0); overload;
    destructor Destroy; override;
    [ioOID]                         // Not necessary if property is exactly named "ID" as in this case
    property ID:Integer read FID write FID;
    [ioField('FIRST_NAME')]         // Not necessary if property has the same name of the field
    property FirstName:String read FFirstName write FFirstName;
    [ioField('LAST_NAME')]          // Not necessary if property has the same name of the field
    property LastName:String read FLastName write FLastName;
    [ioHasMany(TPhoneNumber, 'PersonID')]
    property Phones:TObjectList<TPhoneNumber> read FPhones write FPhones;
    [ioSkip]
    property FullName:String read GetFullName;
    [ioSkip]
    property ClassNameProp:String read GetClassNameProp;
  end;

  [ioTable('Persons')]
  [ioClassFromField]
  TEmployee = class(TPerson)
  private
    FBranchOffice: String;
  public
    constructor Create(NewFirstName, NewLastName, NewBranchOffice: String; NewID: Integer = 0); overload;
    property BranchOffice:String read FBranchOffice write FBranchOffice;
  end;

  [ioTable('Persons')]
  [ioClassFromField]
  TCustomer = class(TPerson)
  private
    FFidelityCardCode: String;
  public
    constructor Create(NewFirstName, NewLastName, NewFidelityCardCode: String; NewID: Integer = 0); overload;
    property FidelityCardCode:String read FFidelityCardCode write FFidelityCardCode;
  end;

  [ioTable('Persons')]
  [ioClassFromField]
  TVipCustomer = class(TCustomer)
  private
    FVipCardCode: String;
  public
    constructor Create(NewFirstName, NewLastName, NewFidelityCardCode, NewVipCardCode: String; NewID: Integer = 0); overload;
    property VipCardCode:String read FVipCardCode write FVipCardCode;
  end;

implementation

uses
  System.SysUtils;

{ TPerson }

constructor TPerson.Create(NewFirstName, NewLastName: String; NewID: Integer);
begin
  inherited Create;
  FPhones := TObjectList<TPhoneNumber>.Create(True);
  FID := NewID;
  FFirstName := NewFirstName;
  FLastName := NewLastName;
end;

destructor TPerson.Destroy;
begin
  FPhones.Free;
  inherited;
end;

function TPerson.GetClassNameProp: String;
begin
  Result := Self.ClassName;
end;

function TPerson.GetFullName: String;
begin
 Result := (FirstName + ' ' + LastName).Trim;
end;

{ TEmployee }

constructor TEmployee.Create(NewFirstName, NewLastName, NewBranchOffice: String;
  NewID: Integer);
begin
  inherited Create(NewFirstName, NewLastName);
  FBranchOffice := NewBranchOffice;
end;

{ TCustomer }

constructor TCustomer.Create(NewFirstName, NewLastName,
  NewFidelityCardCode: String; NewID: Integer);
begin
  inherited Create(NewFirstName, NewLastName);
  FFidelityCardCode := NewFidelityCardCode;
end;

{ TVipCustomer }

constructor TVipCustomer.Create(NewFirstName, NewLastName,
  NewFidelityCardCode, NewVipCardCode: String; NewID: Integer);
begin
  inherited Create(NewFirstName, NewLastName, NewFidelityCardCode);
  FVipCardCode := NewVipCardCode;
end;

{ TPhoneNumbers }

constructor TPhoneNumber.Create(NewPhoneType, NewPhoneNumber: String;
  NewPersonID, NewID: Integer);
begin
  inherited Create;
  FPersonID := NewPersonID;
  FPhoneType := NewPhoneType;
  FPhoneNumber := NewPhoneNumber;
end;


end.
