unit IupOrm.DB.SqLite.CompareOperators;

interface

uses
  IupOrm.DB.Interfaces,
  IupOrm.Interfaces;

type
  TioCompareOperatorSqLite = class(TioCompareOperator)
    class function _Equal: IioSqlItem; override;
    class function _Greater: IioSqlItem; override;
    class function _Lower: IioSqlItem; override;
    class function _GreaterOrEqual: IioSqlItem; override;
    class function _LowerOrEqual: IioSqlItem; override;
    class function _NotEqual: IioSqlItem; override;
    class function _Like: IioSqlItem; override;
    class function _IsNull: IioSqlItem; override;
    class function _IsNotNull: IioSqlItem; override;
  end;

implementation

uses
  IupOrm.SqlItems;


class function TioCompareOperatorSqLite._Equal: IioSqlItem;
begin
  Result := TioSqlItem.Create(' = ');
end;

class function TioCompareOperatorSqLite._GreaterOrEqual: IioSqlItem;
begin
  Result := TioSqlItem.Create(' >= ');
end;

class function TioCompareOperatorSqLite._Greater: IioSqlItem;
begin
  Result := TioSqlItem.Create(' > ');
end;

class function TioCompareOperatorSqLite._IsNotNull: IioSqlItem;
begin
  Result := TioSqlItem.Create(' IS NOT NULL ');
end;

class function TioCompareOperatorSqLite._IsNull: IioSqlItem;
begin
  Result := TioSqlItem.Create(' IS NULL ');
end;

class function TioCompareOperatorSqLite._Like: IioSqlItem;
begin
  Result := TioSqlItem.Create(' LIKE ');
end;

class function TioCompareOperatorSqLite._LowerOrEqual: IioSqlItem;
begin
  Result := TioSqlItem.Create(' <= ');
end;

class function TioCompareOperatorSqLite._Lower: IioSqlItem;
begin
  Result := TioSqlItem.Create(' < ');
end;

class function TioCompareOperatorSqLite._NotEqual: IioSqlItem;
begin
  Result := TioSqlItem.Create(' <> ');
end;

end.
