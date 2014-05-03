unit IupOrm.ObjectsForge.ObjectMakerClassFromField;

interface

uses
  IupOrm.ObjectsForge.Interfaces,
  IupOrm.Context.Interfaces,
  IupOrm.DB.Interfaces;

type

  // Standard Object Maker
  TioObjectMakerClassFromField = class(TioObjectMakerIntf)
  public
    class function MakeObject(AContext:IioContext; AQuery:IioQuery): TObject; override;
  end;

implementation

uses
  System.Rtti, IupOrm.Exceptions, IupOrm, System.SysUtils,
  IupOrm.RttiContext.Factory;

{ TioObjectMakerClassFromField }

class function TioObjectMakerClassFromField.MakeObject(AContext: IioContext;
  AQuery: IioQuery): TObject;
var
  Ctx: TRttiContext;
  Typ: TRttiInstanceType;
  AClassName: String;
begin
  // Get full qualified class name
  AClassName := AQuery.GetValueByFieldNameAsVariant(AContext.ClassFromField.GetSqlFieldName);
  AClassName := AContext.ClassFromField.QualifiedClassNameFromClassInfoFieldValue(AClassName);
  // Get rtti class type for classref
  Ctx := TioRttiContextFactory.RttiContext;
  Typ := Ctx.FindType(AClassName) as TRttiInstanceType;
  if not Assigned(Typ) then EIupOrmException.Create(Self.ClassName + ': RttiType not found (' + AClassName + ')');
  // Load object
  Result := TIupOrm.Load(Typ.MetaclassType).ByOID(AQuery.GetValue(AContext.GetProperties.GetIdProperty).AsInteger)
                                           .DisableClassFromField
                                           .ToObject;
end;

end.
