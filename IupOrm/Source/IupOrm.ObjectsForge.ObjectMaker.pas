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
  Result := Self.CreateObjectByClassRef(AContext.GetClassRef);
  AContext.DataObject := Result;
  // ObjectStatus
  AContext.ObjectStatus := osClean;
  // Load properties values
  for CurrProp in AContext.GetProperties do
  begin
    // If the property is not ReadEnabled then skip it
    if not CurrProp.IsReadEnabled then Continue;
    case CurrProp.GetRelationType of
      // If RelationType = ioRTNone then load normal property value (No relation)
      ioRTNone: begin
        // If it isn't related to a blob field then load as normal value
        if not CurrProp.IsBlob then
          CurrProp.SetValue(Result, AQuery.GetValue(CurrProp))
        // If it's related to a blob field and it is of TStream or descendant the load as stream
        else if CurrProp.IsStream then
          Self.LoadPropertyStream(AContext, AQuery, CurrProp)
        // If it's related to a blob field and it is a "streamable object" (has LoadFromStream and SaveToStream methods)
        else
          CurrProp.SetValue(Result, Self.LoadPropertyStreamable(AContext, AQuery, CurrProp));
      end;
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

