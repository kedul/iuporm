unit IupOrm.Context.Container;

interface

uses
  System.Generics.Collections, IupOrm.Context.Interfaces, System.Rtti;

type

  // Class for external access to the ContextContainer
  TioContextContainer = class
  public
    class function GetContext(AClassName:String): IioContext;
    class procedure AddContext(AContext:IioContext);
  end;

implementation

// Real ContextContainer instance
type TioContextContainerInstance = TDictionary<String, IioContext>;
var
  ioContextContainerInstance: TioContextContainerInstance;
  ioRttiContextInstance: TRttiContext;

{ TioContextContainer }

class procedure TioContextContainer.AddContext(AContext: IioContext);
begin
  ioContextContainerInstance.Add(AContext.GetClassRef.ClassName, AContext);
end;

class function TioContextContainer.GetContext(AClassName: String): IioContext;
begin
  Result := nil;
  if ioContextContainerInstance.ContainsKey(AClassName)
    then Result := ioContextContainerInstance.Items[AClassName];
end;

initialization
  ioContextContainerInstance := TioContextContainerInstance.Create;

finalization
  ioContextContainerInstance.Free;

end.
