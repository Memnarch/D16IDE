unit IDEModule;

interface

uses
  SysUtils, Classes, Dialogs, ImgList, Controls, ActnList, Menus,
  SynEditMiscClasses, SynEditSearch, JvComponentBase, JvFindReplace;

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
    ToolBarDisabledImages: TImageList;
    dlgFindReplace: TJvFindReplace;
    IDEImages: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

uses
  PascalUnit, ProjectOptionDialog, IDEPageFrame, IDEUnit;

{$R *.dfm}

{ TIDEData }

end.
