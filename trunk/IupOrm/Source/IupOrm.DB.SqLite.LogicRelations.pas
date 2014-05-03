unit IupOrm.DB.SqLite.LogicRelations;

interface

uses
  IupOrm.DB.Interfaces,
  IupOrm.Interfaces;

type
  TioLogicRelationSqLite = class(TioLogicRelation)
    class function _And: IioSqlItem; override;
    class function _Or: IioSqlItem; override;
    class function _Not: IioSqlItem; override;
    class function _OpenPar: IioSqlItem; override;
    class function _ClosePar: IioSqlItem; override;
  end;

implementation

uses
  IupOrm.SqlItems;

{ TioLrFactory }

class function TioLogicRelationSqLite._And: IioSqlItem;
begin
  Result := TioSqlItem.Create(' AND ');
end;

class function TioLogicRelationSqLite._ClosePar: IioSqlItem;
begin
  Result := TioSqlItem.Create(')');
end;

class function TioLogicRelationSqLite._Not: IioSqlItem;
begin
  Result := TioSqlItem.Create(' NOT ');
end;

class function TioLogicRelationSqLite._OpenPar: IioSqlItem;
begin
  Result := TioSqlItem.Create('(');
end;

class function TioLogicRelationSqLite._Or: IioSqlItem;
begin
  Result := TioSqlItem.Create(' OR ');
end;

end.
