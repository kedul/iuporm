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
  AObj: TObject;
begin
  inherited;
  // DataObject creation if not already exists
  if not Assigned(AContext.DataObject) then
    AContext.DataObject := Self.CreateObjectByClassRef(AContext.GetClassRef);
  Result := AContext.DataObject;
  // ObjectStatus
  AContext.ObjectStatus := osClean;
  // Load properties values
  for CurrProp in AContext.GetProperties do
  begin
    // If the property is not ReadEnabled then skip it
    if not CurrProp.IsReadEnabled then Continue;
    case CurrProp.GetRelationType of
// ------------------------------ NO RELATION --------------------------------------------------------------------------------------
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
        // Next property
        Continue;
      end;
// ------------------------------ RELATION -----------------------------------------------------------------------------------------
      // Load the related object/s
      ioRTBelongsTo:        AObj := Self.LoadPropertyBelongsTo(AContext, AQuery, CurrProp);
      ioRTHasMany:          AObj := Self.LoadPropertyHasMany(AContext, AQuery, CurrProp);
      ioRTHasOne:           AObj := Self.LoadPropertyHasOne(AContext, AQuery, CurrProp);
      ioRTEmbeddedHasMany:  AObj := Self.LoadPropertyEmbeddedHasMany(AContext, AQuery, CurrProp);
      ioRTEmbeddedHasOne:   AObj := Self.LoadPropertyEmbeddedHasOne(AContext, AQuery, CurrProp);
    end;
    // If is an Interface property then adjust the RefCount to prevent an access violation
    if CurrProp.IsInterface then
      AObj.ioAsInterface<IInterface>._Release;  // Adjust the RefCount to prevent an access violation
    // Assign the related object/s to the property
    CurrProp.SetValue(Result,   AObj   );
// ---------------------------------------------------------------------------------------------------------------------------------
  end;
end;

end.

