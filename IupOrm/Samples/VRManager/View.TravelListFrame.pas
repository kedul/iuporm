unit View.TravelListFrame;

interface

uses FMX.ListView.Types, Data.Bind.GenData, Data.Bind.Components,
  Data.Bind.ObjectScope, System.Classes, FMX.Types, FMX.Controls, FMX.ListView,
  FMX.Forms, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, FMX.StdCtrls,
  ViewModel.Interfaces;

type
  TViewTravelListFrame = class(TFrame)
    TravelsListView: TListView;
    PBSTravels: TPrototypeBindSource;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  strict private
    FViewModel: IViewModelList;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner:TComponent; AViewModel:IViewModelList); overload;
  end;

implementation

uses UVMFactory, Model.BaseClasses, System.Generics.Collections;

{$R *.fmx}

procedure TViewTravelListFrame.Button1Click(Sender: TObject);
begin
//  PBSTravels.Active := False;
  FViewModel.Load;


//  (PBSTravels.InternalAdapter as TListBindSourceAdapter<TBaseClass>).SetList(FViewModel.Load);


//  PBSTravels.Active := True;
end;

constructor TViewTravelListFrame.Create(AOwner: TComponent;
  AViewModel: IViewModelList);
begin
  // NB: Prima assegna il ViewModel altrimenti fallisce la creazione
  //      del BindSourceAdapter
  inherited Create(AOwner);
  FViewModel := AViewModel;
  FViewModel.SetBindSource(PBSTravels);
end;

end.
