unit IupOrm.RttiContext.Factory;

interface

uses
  System.Rtti;

type

  TioRttiContextFactory = class
  public
    class function RttiContext: TRttiContext;
  end;

implementation

var ARttiContext: TRttiContext;

{ TioRttiContextFactory }

class function TioRttiContextFactory.RttiContext: TRttiContext;
begin
  Result := ARttiContext;
end;

initialization
  // Create the unique global instance of RttiContext
  ARttiContext := TRttiContext.Create;

finalization
  // GlobalRttiContext cleanup
  ARttiContext.Free;
end.
