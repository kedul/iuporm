unit IupOrm.DB.ConnectionContainer;

interface

uses
  IupOrm.DB.Interfaces, System.Generics.Collections;

type

  TioInternalContainerType = TDictionary<TThreadID, IioConnection>;

  TioConnectionContainer = class
  strict private
    class var FContainer: TioInternalContainerType;
  strict protected
    class function GetCurrentThreadID: TThreadID;
  public
    class procedure CreateInternalContainer;
    class procedure FreeInternalContainer;
    class procedure AddConnection(AConnection:IioConnection);
    class procedure FreeConnection;
    class function GetConnection: IioConnection;
    class function ConnectionExist: Boolean;
  end;

  TioConnectionContainerRef = class of TioConnectionContainer;

implementation

uses
  System.Classes;

{ TioConnectionContainer }

class procedure TioConnectionContainer.AddConnection(AConnection: IioConnection);
begin
  FContainer.Add(Self.GetCurrentThreadID, AConnection);
end;

class function TioConnectionContainer.ConnectionExist: Boolean;
begin
  Result := FContainer.ContainsKey(Self.GetCurrentThreadID);
end;

class procedure TioConnectionContainer.CreateInternalContainer;
begin
  Self.FContainer := TioInternalContainerType.Create;
end;

class procedure TioConnectionContainer.FreeConnection;
begin
  FContainer.Remove(Self.GetCurrentThreadID);
end;

class procedure TioConnectionContainer.FreeInternalContainer;
begin
  Self.FContainer.Free;
end;

class function TioConnectionContainer.GetConnection: IioConnection;
begin
  Result := FContainer.Items[Self.GetCurrentThreadID];
end;

class function TioConnectionContainer.GetCurrentThreadID: TThreadID;
begin
  Result := System.Classes.TThread.CurrentThread.ThreadID;
end;

initialization

  TioConnectionContainer.CreateInternalContainer;

finalization

  TioConnectionContainer.FreeInternalContainer;

end.
