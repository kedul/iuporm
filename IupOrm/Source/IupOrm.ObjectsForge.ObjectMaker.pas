unit IupOrm.ObjectsForge.ObjectMaker;

interface

uses
  IupOrm.ObjectsForge.Interfaces,
  IupOrm.Context.Interfaces,
  IupOrm.DB.Interfaces;

type

  // Standard Object Maker
  TioObjectMaker = class(TioObjectMakerIntf)
  public
    class function MakeObject(AContext:IioContext; AQuery:IioQuery): TObject; override;
  end;

implementation

uses
  IupOrm.Context.Properties.Interfaces, System.Rtti, IupOrm.Attributes, IupOrm,
  IupOrm.CommonTypes;

{ TObjectMaker }

class function TioObjectMaker.MakeObject(AContext: IioContext; AQuery: IioQuery): TObject;
var
  CurrProp: IioContextProperty;
  AList: TObject;
  AValue: TValue;
begin
  inherited;
  // DataObject creation
  Result := AContext.GetClassRef.Create;
  AContext.DataObject := Result;
  // ObjectStatus
  AContext.ObjectStatus := osClean;
  // Load properties values
  for CurrProp in AContext.GetProperties do
  begin
    // If the property is not ReadEnabled then skip it
    if not CurrProp.IsReadEnabled then Continue;
    case CurrProp.GetRelationType of
      // If RelationType = ioRTNone then load normal property value
      ioRTNone: CurrProp.SetValue(Result, AQuery.GetValue(CurrProp));
      // else if RelationType = BelongsTo then load object and assign it to the property
      ioRTBelongsTo: CurrProp.SetValue(Result,   TIupOrm.Load(CurrProp.GetRelationChildClassRef).ByOID(AQuery.GetValue(CurrProp).AsInteger).ToObject as CurrProp.GetRelationChildClassRef   );
      // else if RelationType = ioRTHasMany then load objects and assign it to the property  (list)
      ioRTHasMany: CurrProp.SetValue(Result,   Self.LoadPropertyHasMany(AContext, AQuery, CurrProp)   );
      // else if RelationType = ioRTHasOne then load object and assign it to the property
      ioRTHasOne: CurrProp.SetValue(Result,   Self.LoadPropertyHasOne(AContext, AQuery, CurrProp)   );
    end;
  end;
end;

end.

