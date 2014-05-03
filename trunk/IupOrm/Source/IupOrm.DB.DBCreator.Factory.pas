unit IupOrm.DB.DBCreator.Factory;

interface

uses
  IupOrm.DB.DBCreator.Interfaces, System.Rtti, IupOrm.DB.Interfaces;

type

  TioDBCreatorFactory = class
  public
    class function GetField(AFieldName:String; AFieldType:String; AIsKeyField:Boolean; ARttiProperty:TRttiProperty; ASqlGenerator:IioDBCreatorSqlGenerator): IioDBCreatorField;
    class function GetTable(ATableName: String; AIsClassFromField:Boolean; ASqlGenerator:IioDBCreatorSqlGenerator): IioDBCreatorTable;
    class function GetDBCreator: IioDBCreator;
    class function GetSqlGenerator: IioDBCreatorSqlGenerator;
  end;

implementation

uses
  IupOrm.DB.DBCreator, IupOrm.DB.DBCreator.SqLite.SqlGenerator,
  IupOrm.DB.Factory;

{ TioDBCreatorFactory }

class function TioDBCreatorFactory.GetDBCreator: IioDBCreator;
begin
  Result := TioDBCreator.Create(Self.GetSqlGenerator);
end;

class function TioDBCreatorFactory.GetField(AFieldName: String; AFieldType: String;
  AIsKeyField: Boolean; ARttiProperty:TRttiProperty; ASqlGenerator:IioDBCreatorSqlGenerator): IioDBCreatorField;
begin
  Result := TioDBCreatorField.Create(AFieldName, AFieldType, AIsKeyField, ARttiProperty, ASqlGenerator);
end;

class function TioDBCreatorFactory.GetSqlGenerator: IioDBCreatorSqlGenerator;
begin
  Result := TioDBCreatorSqLiteSqlGenerator.Create(TioDbFactory.Query(nil));
end;

class function TioDBCreatorFactory.GetTable(
  ATableName: String; AIsClassFromField:Boolean; ASqlGenerator:IioDBCreatorSqlGenerator): IioDBCreatorTable;
begin
  Result := TioDBCreatorTable.Create(ATableName, AIsClassFromField, ASqlGenerator);
end;

end.
