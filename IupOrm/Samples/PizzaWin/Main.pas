unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, Data.Bind.Components, Data.Bind.ObjectScope, FMX.Edit,
  FMX.Objects, FMX.ListView;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    Image1: TImage;
    EditID: TEdit;
    EditName: TEdit;
    Button1: TButton;
    Button2: TButton;
    PrototypeBindSource1: TPrototypeBindSource;
    procedure PrototypeBindSource1CreateAdapter(Sender: TObject;
      var ABindSourceAdapter: TBindSourceAdapter);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  ModelU,
  IupOrm,
  IupOrm.DB.DBCreator.Factory;

{$R *.fmx}

procedure TForm1.PrototypeBindSource1CreateAdapter(Sender: TObject;
  var ABindSourceAdapter: TBindSourceAdapter);
begin
  TIupOrm.Init('PizzaWin');
  TioDBCreatorFactory.GetDBCreator.AutoCreateDatabase;
  ABindSourceAdapter := TIupOrm.Load<TPizza>.ToActiveListBindSourceAdapter(PrototypeBindSource1);
end;

end.
