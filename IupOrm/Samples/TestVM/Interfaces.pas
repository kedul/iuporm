unit Interfaces;

interface

uses
  Vcl.ActnList;

type

  IViewModel = interface
    ['{723FBC0C-35B8-400A-8A42-B9461AD9CAA3}']
    function GetCmdHello: TAction;
    property cmdHello:TAction read GetCmdHello;
  end;

implementation

end.
