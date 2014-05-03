unit IupOrm.Attributes;

interface

uses
  IupOrm.CommonTypes;

type

  // Relation types
  TioRelationType = (ioRTNone, ioRTBelongsTo, ioRTHasMany, ioRTHasOne);

  // ===========================================================================
  // START BASE ATTRIBUTES
  // ---------------------------------------------------------------------------

  // Base simple attribute
  TioCustomAttribute = class(TCustomAttribute)
  end;

  // Base String attribute
  TioCustomStringAttribute = class(TCustomAttribute)
  strict private
    FValue: String;
  public
    constructor Create(const AValue:String);
    property Value:String read FValue;
  end;

  // Base class for relation attribute
  TCustomRelationAttribute = class(TioCustomAttribute)
  strict private
    FChildClassRef: TioClassRef;
  public
    constructor Create(const AChildClassRef:TioClassRef);
    property ChildClassRef: TioClassRef read FChildClassRef;
  end;

  // ---------------------------------------------------------------------------
  // END BASE ATTRIBUTES
  // ===========================================================================




  // ===========================================================================
  // START PROPERTY ATTRIBUTES
  // ---------------------------------------------------------------------------
  // Transient attribute
  ioSkip = class(TioCustomAttribute)
  end;

  // ID attribute
  ioOID = class(TioCustomAttribute)
  end;

  // FieldName attribute
  ioField = class(TioCustomStringAttribute)
  end;

  // FieldType attribute
  ioFieldType = class(TioCustomStringAttribute)
  end;

  // Relation BelongsTo attribute
  ioBelongsTo = class(TCustomRelationAttribute)
  end;

  // Relation HasMany attribute
  ioHasMany = class(TCustomRelationAttribute)
  strict private
    FChildPropertyName: String;
  public
    constructor Create(const AChildClassRef:TioClassRef; AChildPropertyName:String);
    property ChildPropertyName: String read FChildPropertyName;
  end;

  // Relation BelongsTo attribute
  ioHasOne = class(ioHasMany)
  end;

  // ---------------------------------------------------------------------------
  // END PROPERTY ATTRIBUTES
  // ===========================================================================




  // ===========================================================================
  // START CLASS ATTRIBUTES
  // ---------------------------------------------------------------------------

  // Table attribute
  ioTable = class(TioCustomStringAttribute)
  end;

  // ClassFromField
  ioClassFromField = class(TioCustomAttribute)
  end;

  // ---------------------------------------------------------------------------
  // SEND CLASS ATTRIBUTES
  // ===========================================================================


implementation

{ TioStringAttribute }

constructor TioCustomStringAttribute.Create(const AValue: String);
begin
  FValue := AValue;
end;

{ ioSkip }

{ TCustomRelationAttribute }

constructor TCustomRelationAttribute.Create(const AChildClassRef: TioClassRef);
begin
  FChildClassRef := AChildClassRef;
end;

{ ioHasMany }

constructor ioHasMany.Create(const AChildClassRef: TioClassRef;
  AChildPropertyName: String);
begin
  inherited Create(AChildClassRef);
  FChildPropertyName := AChildPropertyName;
end;


end.
