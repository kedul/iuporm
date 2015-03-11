unit IupOrm.Rtti.Utilities;

interface

uses
  IupOrm.CommonTypes, System.Rtti;

type

  TioRttiUtilities = class
  public
    class function IsAnInterface<T>: Boolean;
    class function GenericToString<T>: String;
    class function GenericInterfaceToGUI<T:IInterface>: String;
    class function ClassRefToRttiType(AClassRef:TioClassRef): TRttiInstanceType;
    class function CastObjectToGeneric<T>(AObj:TObject): T;
  end;

implementation

uses
  System.TypInfo, System.SysUtils, IupOrm.RttiContext.Factory;

{ TioRttiUtilities }

class function TioRttiUtilities.CastObjectToGeneric<T>(AObj: TObject): T;
begin
  Result := TValue.From<TObject>(AObj).AsType<T>;
end;

class function TioRttiUtilities.ClassRefToRttiType(AClassRef: TioClassRef): TRttiInstanceType;
begin
  Result := TioRttiContextFactory.RttiContext.GetType(AClassref).AsInstance;
end;

class function TioRttiUtilities.GenericInterfaceToGUI<T>: String;
begin
  Result := GUIDToString(   GetTypeData(   PTypeInfo(TypeInfo(T))   ).Guid   );

  // ----------------------------------------------------------------------------------
  // Old code
  // ----------------------------------------------------------------------------------
//  pinfo := TypeInfo(T);
//  if pinfo = nil then Exit(Self.ClassName + ': TypeInfo (GUI) not found!');
//  pdata := GetTypeData(pinfo);
//  Result := GUIDtoString(pdata.Guid);
  // ----------------------------------------------------------------------------------
end;

class function TioRttiUtilities.GenericToString<T>: String;
begin
  Result := PTypeInfo(TypeInfo(T)).Name;

  // ----------------------------------------------------------------------------------
  // Old code
  // ----------------------------------------------------------------------------------
//  pinfo := TypeInfo(T);
//  if pinfo = nil then Exit(Self.ClassName + ': TypeInfo (name) not found!');
//  Result := pinfo.NameFld.ToString;
////  Result := pinfo.Name;
  // ----------------------------------------------------------------------------------
end;

class function TioRttiUtilities.IsAnInterface<T>: Boolean;
begin
  // Result is True if T si an interface
//  Result := (   TioRttiContextFactory.RttiContext.GetType(TypeInfo(T)) is TRttiInterfaceType   );
  Result := PTypeInfo(TypeInfo(T)).Kind = tkInterface;
end;

end.
