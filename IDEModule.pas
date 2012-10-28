unit IDEModule;

interface

uses
  SysUtils, Classes, Dialogs, ImgList, Controls, ActnList, Menus;

type
  TIDEData = class(TDataModule)
    TreeImages: TImageList;
    ToolBarImages: TImageList;
    SaveUnitDialog: TSaveDialog;
    SaveProjectDialog: TSaveDialog;
    OpenUnitDialog: TOpenDialog;
    OpenProjectDialog: TOpenDialog;
    TabPopUp: TPopupMenu;
    Close1: TMenuItem;
    ProjectPopup: TPopupMenu;
    NewUnit1: TMenuItem;
    AddUnit1: TMenuItem;
    Options2: TMenuItem;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  IDEData: TIDEData;

implementation

uses
  PascalUnit, ProjectOptionDialog, IDEPageFrame, IDEUnit;

{$R *.dfm}

{ TIDEData }

end.
