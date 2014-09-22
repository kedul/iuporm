unit IupOrm.LiveBindings.NaturalActiveObjectBindSourceAdapter;

interface

uses
  IupOrm.LiveBindings.ActiveObjectBindSourceAdapter,
  IupOrm.LiveBindings.Interfaces, System.Classes;

type

  TioNaturalActiveObjectBindSourceAdapter = class(TioActiveObjectBindSourceAdapter)
  strict private
    FSourceAdapter: IioNaturalBindSourceAdapterSource;
  strict protected
    procedure DoBeforeDelete; override;
    procedure DoAfterDelete; override;
  public
    constructor Create(AOwner:TComponent; ASourceAdapter:IioNaturalBindSourceAdapterSource); overload;
    procedure Notify(Sender:TObject; ANotification:IioBSANotification); override;
  end;

implementation

uses
  Data.Bind.ObjectScope;





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

procedure TioNaturalActiveObjectBindSourceAdapter.DoAfterDelete;
begin
  // Questo � un NaturalBindSourceAdapter quindi in realt� nella quasi totalit� dei casi
  //  sta esponendo ad una form anagrafica l'oggetto selezionato in un altro BindSourceAdapter
  //  (probabilmente un TioActiveListBindSourceAdapter) e questo, in caso di eliminazione
  //  dell'oggetto, causava il fatto che su quest'ultimo BSA sorgente (FSourceAdapter) in realt�
  //  l'oggetto non viene eliminato.
  //  Per risolvere questo problema senza obbligare l'utente a generare un gestore per l'evento OnNotify
  //  faccio eseguire il Delete alFSourceAdapter se presente (sempre).
  //  Questo per� causa una doppia notifica di eliminazione (su questo stesso BSA e sul FSourceAdapter) e
  //  per questo e sempre se � presente l'FSourceAdapter inibisco anche il DoAfterDelete (oltre quindi al DoBeforeDelete).
  // ---------------------------------------------------------------------------
  // NB: Nessun inherited perch� altrimenti cmq avrei una doppia notifica e
  //      addirittura anche una doppia query delete sul database
  //      per� in questo modo in pratica disabilito l'eventuale event handler
  //inherited;
end;

procedure TioNaturalActiveObjectBindSourceAdapter.DoBeforeDelete;
begin
  // Questo � un NaturalBindSourceAdapter quindi in realt� nella quasi totalit� dei casi
  //  sta esponendo ad una form anagrafica l'oggetto selezionato in un altro BindSourceAdapter
  //  (probabilmente un TioActiveListBindSourceAdapter) e questo, in caso di eliminazione
  //  dell'oggetto, causava il fatto che su quest'ultimo BSA sorgente (FSourceAdapter) in realt�
  //  l'oggetto non viene eliminato.
  //  Per risolvere questo problema senza obbligare l'utente a generare un gestore per l'evento OnNotify
  //  faccio eseguire il Delete alFSourceAdapter se presente (sempre).
  //  Questo per� causa una doppia notifica di eliminazione (su questo stesso BSA e sul FSourceAdapter) e
  //  per questo e sempre se � presente l'FSourceAdapter inibisco anche il DoAfterDelete (oltre quindi al DoBeforeDelete).
  // ---------------------------------------------------------------------------
  // NB: Nessun inherited perch� altrimenti cmq avrei una doppia notifica e
  //      addirittura anche una doppia query delete sul database
  //      per� in questo modo in pratica disabilito l'eventuale event handler
  //inherited;
  if Assigned(FSourceAdapter) then
     TBindSourceAdapter(FSourceAdapter).Delete;
end;

procedure TioNaturalActiveObjectBindSourceAdapter.Notify(Sender: TObject;
  ANotification: IioBSANotification);
begin
  inherited;
  if Assigned(FSourceAdapter)
    then FSourceAdapter.Notify(Self, ANotification);
end;

end.
