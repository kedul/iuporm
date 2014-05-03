unit IupOrm.Where.Interfaces;

interface

uses
  System.Rtti;

type

  // Where conditions interface ONY FOR EXTERNAL USE
  IioWhere = interface
    ['{B8266EBC-93F9-44BD-81E9-B25D37379920}']
    // ------ Conditions
    function ByOID(AOID:Integer): IioWhere;
    function Add(ATextCondition:String): IioWhere;
    // ------ Logic relations
    function _And: IioWhere; overload;
    function _Or: IioWhere; overload;
    function _Not: IioWhere; overload;
    function _OpenPar: IioWhere; overload;
    function _ClosePar: IioWhere; overload;
    // ------ Logic relations with TextCondition
    function _And(ATextCondition:String): IioWhere; overload;
    function _Or(ATextCondition:String): IioWhere; overload;
    function _Not(ATextCondition:String): IioWhere; overload;
    function _OpenPar(ATextCondition:String): IioWhere; overload;
    function _ClosePar(ATextCondition:String): IioWhere; overload;
    // ------ Compare operators
    function _Equal: IioWhere;
    function _Greater: IioWhere;
    function _Lower: IioWhere;
    function _GreaterOrEqual: IioWhere;
    function _LowerOrEqual: IioWhere;
    function _NotEqual: IioWhere;
    function _Like: IioWhere;
    function _IsNull: IioWhere;
    function _IsNotNull: IioWhere;
    // ------ Compare operators with TValue
    function _EqualTo(AValue:TValue): IioWhere;
    function _GreaterThan(AValue:TValue): IioWhere;
    function _LowerThan(AValue:TValue): IioWhere;
    function _GreaterOrEqualThan(AValue:TValue): IioWhere;
    function _LowerOrEqualThan(AValue:TValue): IioWhere;
    function _NotEqualTo(AValue:TValue): IioWhere;
    function _LikeTo(AValue:TValue): IioWhere;
    // ------
    function _Where: IioWhere; overload;
    function _Where(ATextCondition:String): IioWhere; overload;
    function _Property(APropertyName:String): IioWhere;
    function _PropertyOID: IioWhere;
    function _Value(AValue:TValue): IioWhere;
  end;

implementation

end.
