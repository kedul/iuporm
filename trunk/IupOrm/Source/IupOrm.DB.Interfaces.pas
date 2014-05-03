unit IupOrm.DB.Interfaces;

interface

uses
  IupOrm.Context.Properties.Interfaces,
  IupOrm.Context.Interfaces,
  IupOrm.Interfaces,
  System.Classes,
  System.Rtti, Data.DB, Data.SqlExpr;

type

  TioInternalSqlConnection = TSQLConnection;
  TioFields = TFields;

  TioCompareOperatorRef = class of TioCompareOperator;
  TioLogicRelationRef = class of TioLogicRelation;
  TioSqlDataConverterRef = class of TioSqlDataConverter;
  TioSqlGeneratorRef = class of TioSqlGenerator;

  // Interfaccia per il componente connection da fornire alla query per la
  //  connessione al database
  IioConnection = interface
    ['{FF5D54D7-7EBE-4E6E-830E-E091BA7AE929}']
    function GetConnection: TioInternalSqlConnection;
    function InTransaction: Boolean;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
  end;

  // Interfaccia per il componente Query, cioè del componente che si
  //  occuperà di eseguire il codice SQL o altro per caricare/modificare/eliminare
  //  il dato
  IioQuery = interface
    ['{E8CFB984-2572-4D6F-BC4B-A4454F1EEDAA}']
    procedure First;
    procedure Last;
    procedure Next;
    procedure Prior;
    function Eof: Boolean;
    function GetValue(AProperty:IioContextProperty): TValue;
    function GetValueByFieldNameAsVariant(AFieldName:String): Variant;
    procedure Open;
    procedure Close;
    function ExecSQL: Integer;
    function GetSQL: TStrings;
    function Fields: TioFields;
    function Connection: IioConnection;
    property SQL: TStrings read GetSQL;
  end;

  // Interfaccia per le classi che si occupano di convertire i dati in
  //  rappresentazioni degli stessi da inserire nel testo delle query,
  TioSqlDataConverter = class abstract
  public
    class function StringToSQL(AString:String): String; virtual; abstract;
    class function FloatToSQL(AFloat:Extended): String; virtual; abstract;
    class function TValueToSql(AValue:TValue): String; virtual; abstract;
  end;

  // INterfaccia per le classi che devono generare i vari tipi di query
  //  Select/Update/Insert/Delete
  TioSqlGenerator = class abstract
  public
    class function GenerateSqlSelectForObject(AContext:IioContext): IioQuery; virtual; abstract;
    class function GenerateSqlSelectForList(AContext:IioContext): IioQuery; virtual; abstract;
    class function GenerateSqlInsert(AContext:IioContext): IioQuery; virtual; abstract;
    class function GenerateSqlUpdate(AContext:IioContext): IioQuery; virtual; abstract;
    class function GenerateSqlDelete(AContext:IioContext): IioQuery; virtual; abstract;
  end;

  // Interfaccia per le classi che devono generare le LogicRelations
  TioLogicRelation = class abstract
    class function _And           : IioSqlItem; virtual; abstract;
    class function _Or            : IioSqlItem; virtual; abstract;
    class function _Not           : IioSqlItem; virtual; abstract;
    class function _OpenPar       : IioSqlItem; virtual; abstract;
    class function _ClosePar      : IioSqlItem; virtual; abstract;
  end;

  // Interfaccia per le classi che devono generare operatori di comparazione
  TioCompareOperator = class abstract
    class function _Equal: IioSqlItem; virtual; abstract;
    class function _Greater: IioSqlItem; virtual; abstract;
    class function _Lower: IioSqlItem; virtual; abstract;
    class function _GreaterOrEqual: IioSqlItem; virtual; abstract;
    class function _LowerOrEqual: IioSqlItem; virtual; abstract;
    class function _NotEqual: IioSqlItem; virtual; abstract;
    class function _Like: IioSqlItem; virtual; abstract;
    class function _IsNull: IioSqlItem; virtual; abstract;
    class function _IsNotNull: IioSqlItem; virtual; abstract;
  end;

implementation


end.
