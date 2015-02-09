unit IupOrm.DB.DBCreator.Factory;

interface

uses
  IupOrm.DB.DBCreator.Interfaces, System.Rtti, IupOrm.DB.Interfaces,
  IupOrm.Context.Properties.Interfaces;

type

  TioDBCreatorFactory = class
  public
    class function GetField(AFieldName:String; AIsKeyField:Boolean; AProperty:IioContextProperty; ASqlGenerator:IioDBCreatorSqlGenerator; AIsClassFromField:Boolean): IioDBCreatorField;
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

class function TioDBCreatorFactory.GetField(AFieldName: String; AIsKeyField: Boolean;
  AProperty:IioContextProperty; ASqlGenerator:IioDBCreatorSqlGenerator; AIsClassFromField:Boolean): IioDBCreatorField;
begin
  Result := TioDBCreatorField.Create(AFieldName, AIsKeyField, AProperty, ASqlGenerator, AIsClassFromField);
end;

class function TioDBCreatorFactory.GetSqlGenerator: IioDBCreatorSqlGenerator;
begin
  // NB: Query for BD Creation only for the default ConnectionDef
  Result := TioDBCreatorSqLiteSqlGenerator.Create(TioDbFactory.Query(''));
end;

class function TioDBCreatorFactory.GetTable(
  ATableName: String; AIsClassFromField:Boolean; ASqlGenerator:IioDBCreatorSqlGenerator): IioDBCreatorTable;
begin
  Result := TioDBCreatorTable.Create(ATableName, AIsClassFromField, ASqlGenerator);
end;

end.
