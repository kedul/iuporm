unit IupOrm.LazyLoad.Interfaces;

interface

uses
  IupOrm.CommonTypes;

type

  IioLazyLoadable = interface
    ['{3DB9E89C-2010-400A-8EA8-89D12C98218B}']
    procedure SetRelationInfo(const ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName:String; const ARelationChildID:Integer);
    function GetInternalObject: TObject;
  end;

  IioLazyLoader<T:class,constructor> = interface
    ['{CBF57EB9-CD85-412D-97EA-C9F46943B1B8}']
    function GetInternalObj: T;
    procedure SetRelationInfo(const ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName:String; const ARelationChildID:Integer);
    // OwnsObject property
    procedure SetOwnsObjects(Value: Boolean);
    function GetOwnsObjects: Boolean;
    property OwnsObjects:Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

implementation

end.
