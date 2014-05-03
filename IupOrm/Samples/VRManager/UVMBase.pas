unit UVMBase;

interface

uses
  ViewModel.Interfaces;

type

  TVMBase = class(TInterfacedObject, IVMBase)
  public
    procedure New; virtual;
    procedure Get; virtual;
    procedure Post; virtual;
    procedure Delete; virtual;
  end;

implementation

uses
  FMX.Dialogs;

{ TVMBase }

procedure TVMBase.Delete;
begin
  ShowMessage('TVMBase.Delete: Funzionalit� non implementata.');
end;

procedure TVMBase.Get;
begin
  ShowMessage('TVMBase.Get: Funzionalit� non implementata.');
end;

procedure TVMBase.New;
begin
  ShowMessage('TVMBase.New: Funzionalit� non implementata.');
end;

procedure TVMBase.Post;
begin
  ShowMessage('TVMBase.Post: Funzionalit� non implementata.');
end;

end.
