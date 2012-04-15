unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, Menus, ExtCtrls, SynEdit, ImgList, VirtualTrees,
  SynEditHighlighter, SynHighlighterPas, SynMemo, ActnList;

type
  TNodeData = record
    Caption: string;
    ImageIndex: Integer;
    SynEdit: TSynEdit;
  end;

  PNodeData = ^TNodeData;

  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    ToolBar1: TToolBar;
    plLeft: TPanel;
    plRight: TPanel;
    PageControl: TPageControl;
    SplitterLeft: TSplitter;
    SplitterRight: TSplitter;
    TreeImages: TImageList;
    ProjectTree: TVirtualStringTree;
    SynPasSyn: TSynPasSyn;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Log: TSynMemo;
    btnCompile: TToolButton;
    ToolBarImages: TImageList;
    Edit1: TMenuItem;
    Search1: TMenuItem;
    Project1: TMenuItem;
    Run1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    New1: TMenuItem;
    Unit1: TMenuItem;
    Project2: TMenuItem;
    Save1: TMenuItem;
    Saveas1: TMenuItem;
    SaveProjectas1: TMenuItem;
    Saveall1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    ActionList: TActionList;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    Options1: TMenuItem;
    Compile1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ProjectTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure ProjectTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
  private
    { Private declarations }
    procedure AddPage(ATitle: string);
    procedure CreateNewProject(ATitle: string);
    procedure ClearProjects();
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TForm1 }

procedure TMainForm.AddPage(ATitle: string);
var
  LPage: TTabSheet;
  LEdit: TSynEdit;
  LNode: PVirtualNode;
  LData: PNodeData;
begin
  LPage := TTabSheet.Create(Self);
  LPage.PageControl := PageControl;
  LPage.Caption := ATitle;
  LEdit := TSynEdit.Create(LPage);
  LEdit.Parent := LPage;
  LEdit.Align := alClient;
  LEdit.Gutter.ShowLineNumbers := True;
  LEdit.Highlighter := SynPasSyn;
  LEdit.Lines.Text := 'unit ' + ATitle + ';' + sLineBreak + sLineBreak + sLineBreak + sLineBreak + sLineBreak + sLineBreak + 'end.';
  LNode := ProjectTree.AddChild(ProjectTree.GetFirst());
  LData := ProjectTree.GetNodeData(LNode);
  LData.Caption := ATitle + '.pas';
  LData.ImageIndex := 1;
  LData.SynEdit := LEdit;
end;

procedure TMainForm.ClearProjects;
begin
  ProjectTree.Clear;
end;

procedure TMainForm.CreateNewProject(ATitle: string);
var
  LNode: PVirtualNode;
  LData: PNodeData;
begin
  LNode := ProjectTree.AddChild(nil);
  LData := ProjectTree.GetNodeData(LNode);
  LData.Caption := ATitle + '.d16';
  LData.ImageIndex := 0;
  LData.SynEdit := nil;
  AddPage('Unit1');
  ProjectTree.Expanded[LNode] := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ProjectTree.NodeDataSize := SizeOf(TNodeData);
  CreateNewProject('Project1');
end;

procedure TMainForm.ProjectTreeGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  ImageIndex := PNodeData(Sender.GetNodeData(Node)).ImageIndex;
end;

procedure TMainForm.ProjectTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  CellText := PNodeData(Sender.GetNodeData(Node)).Caption;
end;

end.
