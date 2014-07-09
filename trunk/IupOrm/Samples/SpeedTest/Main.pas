unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, System.Generics.Collections, Model;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure UserMsg(AMsg:String);
    function GeneraLista: TObjectList<TArticolo>;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses
  IupOrm, IupOrm.DB.Interfaces,
  Data.SqlExpr, IupOrm.DB.Factory, FireDAC.Comp.Client;

{$R *.fmx}

procedure TForm2.Button1Click(Sender: TObject);
var
  AArtList: TObjectList<TArticolo>;
begin
  UserMsg('Generating list');
  AArtList := Self.GeneraLista;
  UserMsg('Persisting');
  TIupOrm.PersistCollection(AArtList);
  UserMsg('Persisted');
  AArtList.Free;
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  AConnection: IioConnection;
  AQuery: TFDQuery;
  AArtList: TObjectList<TArticolo>;
  AArticolo: TArticolo;
  I: Integer;
begin
  I := 0;
  AConnection := TioDBFactory.Connection;
  AQuery := TFDQuery.Create(Self);
  AQuery.Connection := AConnection.GetConnection;
  UserMsg('Generating list');
  AArtList := Self.GeneraLista;
  AConnection.StartTransaction;
  for AArticolo in AArtList do
  begin
    inc(I);
    AQuery.SQL.Clear;
    AQuery.SQL.Add('insert into articoli (ID, Descrizione) values ');
    AQuery.SQL.Add('(' + I.ToString + ', ' + AArticolo.Descrizione.QuotedString + ')');
    AQuery.ExecSQL;
  end;
  AConnection.Commit;
  AArtList.Free;
end;

function TForm2.GeneraLista: TObjectList<TArticolo>;
var
  I: Integer;
begin
  Result := TObjectList<TArticolo>.Create;
  for I := 1 to Edit1.Text.ToInteger do
  begin
    Result.Add(TArticolo.Create(0, 'Articolo ' + I.ToString));
  end;
end;

procedure TForm2.UserMsg(AMsg: String);
begin
  Label1.BeginUpdate;
  try
    Label1.Text := AMsg;
  finally
    Label1.EndUpdate;
  end;
end;

end.
