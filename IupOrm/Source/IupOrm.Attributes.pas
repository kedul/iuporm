unit IupOrm.Attributes;

interface

uses
  IupOrm.CommonTypes, ObjMapperAttributes;

type

  // Relation types
  TioRelationType = (ioRTNone, ioRTBelongsTo, ioRTHasMany, ioRTHasOne, ioRTEmbeddedHasMany, ioRTEmbeddedHasOne);

  // LazyLoad
  TioLoadType = (ioImmediateLoad = 0, ioLazyLoad);

  // Join types
  TioJoinType = (ioInner, ioCross, ioLeftOuter, ioRightOuter, ioFullOuter);

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
    FChildTypeName: String;
    FChildTypeAlias: String;
  public
    constructor Create(const AChildClassRef:TioClassRef); overload;
    constructor Create(const AChildTypeName:String; const AChildTypeAlias:String=''); overload;
    property ChildTypeName: String read FChildTypeName;
    property ChildTypeAlias: String read FChildTypeAlias;
  end;

  // Standard AttributeLabel
  ioMarker = class(TioCustomStringAttribute)
  end;

  // ---------------------------------------------------------------------------
  // END BASE ATTRIBUTES
  // ===========================================================================





  // ===========================================================================
  // START MVVM ATTRIBUTES
  // ---------------------------------------------------------------------------

     ioAction = class(TioCustomStringAttribute)
     end;

  // ---------------------------------------------------------------------------
  // END MVVM ATTRIBUTES
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

  // FieldName attribute
  ioLoadSQL = class(TioCustomStringAttribute)
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
    FLoadType: TioLoadType;
  public
    constructor Create(const AChildClassRef:TioClassRef; const AChildPropertyName:String; const ALoadType:TioLoadType=ioImmediateLoad); overload;
    constructor Create(const AChildTypeName, AChildTypeAlias, AChildPropertyName:String; const ALoadType:TioLoadType=ioImmediateLoad); overload;
    constructor Create(const AChildTypeName, AChildPropertyName:String; const ALoadType:TioLoadType=ioImmediateLoad); overload;
    property ChildPropertyName: String read FChildPropertyName;
    property LoadType: TioLoadType read FLoadType;
  end;

  // Relation BelongsTo attribute
  ioHasOne = class(ioHasMany)
  end;

  // ReadOnly attribute
  ioReadOnly = class(TioCustomAttribute)
  end;

  // WriteOnly attribute
  ioWriteOnly = class(TioCustomAttribute)
  end;

  // TypeAlias attribute
  ioTypeAlias = class(TioCustomStringAttribute)
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

  // ConnectionDefName attribute
  ioConnectionDefName = class(TioCustomStringAttribute)
  end;

  // ClassFromField
  ioClassFromField = class(TioCustomAttribute)
  end;

  // GroupBy
  ioGroupBy = class(TioCustomStringAttribute)
  end;

  // Join attribute
  ioJoin = class(TioCustomAttribute)
  strict private
    FJoinType: TioJoinType;
    FJoinClassRef: TioClassRef;
    FJoinCondition: String;
  public
    constructor Create(const AJoinType:TioJoinType; AJoinClassRef:TioClassRef; AJoinCondition:String='');
    property JoinType: TioJoinType read FJoinType;
    property JoinClassRef: TioClassRef read FJoinClassRef;
    property JoinCondition: String read FJoinCondition;
  end;

  // ---------------------------------------------------------------------------
  // SEND CLASS ATTRIBUTES
  // ===========================================================================




  // ===========================================================================
  // START EMBEDDED ATTRIBUTES
  // ---------------------------------------------------------------------------

  // EmbeddedHasMany attribute
  ioEmbeddedHasMany = class(TioCustomAttribute)

  end;

  // EmbeddedHasOne attribute
  ioEmbeddedHasOne = class(TioCustomAttribute)

  end;

  // EmbeddedSkip attribute
  ioEmbeddedSkip = class(DoNotSerializeAttribute)  // from DMVC ObjectsMappers

  end;

  // EmbeddedSkip attribute
  ioEmbeddedStreamable = class(StreamableAttribute)  // from DMVC ObjectsMappers

  end;

  // ===========================================================================
  // end EMBEDDED ATTRIBUTES
  // ---------------------------------------------------------------------------

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
  Create(AChildClassRef.ClassName, '');
end;

constructor TCustomRelationAttribute.Create(const AChildTypeName, AChildTypeAlias: String);
begin
  FChildTypeName := AChildTypeName;
  FChildTypeAlias := AChildTypeAlias;
end;

{ ioHasMany }

constructor ioHasMany.Create(const AChildClassRef: TioClassRef;
  const AChildPropertyName: String; const ALoadType:TioLoadType=ioImmediateLoad);
begin
  inherited Create(AChildClassRef);
  FChildPropertyName := AChildPropertyName;
  FLoadType := ALoadType;
end;


constructor ioHasMany.Create(const AChildTypeName, AChildTypeAlias, AChildPropertyName: String; const ALoadType: TioLoadType);
begin
  inherited Create(AChildTypeName, AChildTypeAlias);
  FChildPropertyName := AChildPropertyName;
  FLoadType := ALoadType;
end;

constructor ioHasMany.Create(const AChildTypeName, AChildPropertyName: String; const ALoadType: TioLoadType);
begin
  Self.Create(AChildTypeName, '', AChildPropertyName, ALoadType);
end;

{ ioJoin }

constructor ioJoin.Create(const AJoinType: TioJoinType;
  AJoinClassRef: TioClassRef; AJoinCondition: String);
begin
  inherited Create;
  FJoinType := AJoinType;
  FJoinClassRef := AJoinClassRef;
  FJoinCondition := AJoinCondition;
end;

end.
