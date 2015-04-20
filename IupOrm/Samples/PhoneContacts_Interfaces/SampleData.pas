unit SampleData;

interface

type

  TSampleData = class
  public
    class procedure CheckForSampleDataCreation;
    class procedure CreateSampleData;
  end;

implementation

uses
  Model, IupOrm, System.Generics.Collections, FMX.Dialogs, System.UITypes,
  AnotherModel, Interfaces;

{ TSampleData }

class procedure TSampleData.CheckForSampleDataCreation;
var
  AList: TObjectList<TPerson>;
begin
  AList := TIupOrm.Load<TPerson>.ToList<TObjectList<TPerson>>;
  try
    if AList.Count = 0
      then Self.CreateSampleData;
  finally
    AList.Free;
  end;
end;

class procedure TSampleData.CreateSampleData;
var
  NewPerson: IPerson;
begin
  // TPerson
  NewPerson := TPerson.Create('Maurizio', 'Del Magno');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '0541/112233', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '329/11223344', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Office', '0541/234687', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);

  NewPerson := TPerson.Create('Andrea', 'Costa');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '0541/445566', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '329/11255355', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);

  NewPerson := TPerson.Create('Luca', 'Coccia');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '0541/734573457', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '345/12662346', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Office', '0541/1112223', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);


  // TCustomer
  NewPerson := TCustomer.Create('Mario', 'Rossi', 'FC0001');
  TIupOrm.Persist(NewPerson);

  NewPerson := TCustomer.Create('Giuseppe', 'Verdi', 'FC0002');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '051/9234763764', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '335/993356567', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);

  NewPerson := TCustomer.Create('Francesco', 'Baracca', 'FC0003');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '051/4235552', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '335/23523555', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);


  // TVipCustomer
  NewPerson := TVipCustomer.Create('Omar', 'Bossoni', 'FC0004', 'VipCard0001');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '051/2432348', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '335/6345457', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);

  NewPerson := TVipCustomer.Create('Thomas', 'Ranzetti', 'FC0005', 'VipCard0002');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '051/34563456', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '335/1346476', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);

  NewPerson := TVipCustomer.Create('Paolo', 'Filippini', 'FC0006', 'VipCard0003');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '0721/423424624', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '340/423462346', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);


  // TEmployee
  NewPerson := TEmployee.Create('Daniele', 'Teti', 'Roma');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '06/12363466', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '328/2342529879', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);

  NewPerson := TEmployee.Create('Daniele', 'Daqua', 'Roma');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '06/998867653', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '328/838768723', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);

  NewPerson := TEmployee.Create('Fabrizio', 'Bitti', 'Dubai');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '06/4634734', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '328/2323555', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);


  // TAnotherPerson
  NewPerson := TAnotherPerson.Create('Maurizio', 'Another Magno');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '11/111111', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '22/222222', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);

  NewPerson := TAnotherPerson.Create('Daniele', 'Another Daqua');
  NewPerson.Phones.Add(   TPhoneNumber.Create('Home', '06/998867653', NewPerson.ID)   );
  NewPerson.Phones.Add(   TPhoneNumber.Create('Mobile', '328/838768723', NewPerson.ID)   );
  TIupOrm.Persist(NewPerson);
end;

end.
