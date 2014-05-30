unit IupOrm.Helpers.ObjectHelperTools;

interface

uses
  IupOrm.Helpers.ObjectHelperTools.Interfaces;

type

  TioObjectHelperTools = class(TInterfacedObject, IioObjectHelperTools)
  strict private
    FObj: TObject;
  public
    constructor Create(AObj: TObject);
    procedure Persist;
    procedure Delete;
  end;

implementation

uses
  IupOrm;

{ TioObjectHelperTools }

constructor TioObjectHelperTools.Create(AObj: TObject);
begin
  FObj := AObj;
end;

procedure TioObjectHelperTools.Delete;
begin
  TIupOrm.Delete(FObj);
end;

procedure TioObjectHelperTools.Persist;
begin
  TIupOrm.Persist(FObj);
end;

end.
