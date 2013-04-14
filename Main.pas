unit Main;

interface

uses
  Windows, Messages, UXTheme, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, Menus, ExtCtrls, SynEdit, ImgList, VirtualTrees,
  SynEditHighlighter, SynHighlighterPas, SynMemo, ActnList, JvExComCtrls,
  JvComCtrls, JvTabBar, JvExControls, JvPageList, JvTabBarXPPainter,
  JvComponentBase, Project,  IDEUnit, CompilerDefines, Compiler,
  PascalUnit, SynCompletionProposal, CPUViewForm, Emulator,
  WatchViewForm, IDETabSheet, IDEPageFrame, ProjectTreeController, CodeTreeController, IDEModule,
  IDEController, IDEActionModule, SynEditMiscClasses, SynEditSearch;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    tbRun: TToolBar;
    plLeft: TPanel;
    plRight: TPanel;
    SplitterLeft: TSplitter;
    SplitterRight: TSplitter;
    ProjectTree: TVirtualStringTree;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Edit1: TMenuItem;
    Search1: TMenuItem;
    Project1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    New1: TMenuItem;
    miNewUnit: TMenuItem;
    miNewProject: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    miSaveProjectAs: TMenuItem;
    miSaveAll: TMenuItem;
    miOpen: TMenuItem;
    miExit: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    miOptions: TMenuItem;
    PageControl: TJvPageControl;
    CodeTree: TVirtualStringTree;
    SynCompletionProposal: TSynCompletionProposal;
    btnRun: TToolButton;
    btnStop: TToolButton;
    miCompile: TMenuItem;
    miRun: TMenuItem;
    miStop: TMenuItem;
    ControlBar: TControlBar;
    btnPause: TToolButton;
    tbDebug: TToolBar;
    btnStep: TToolButton;
    btnStepOver: TToolButton;
    btnStepUntilReturn: TToolButton;
    tbFile: TToolBar;
    btnNewUnit: TToolButton;
    btnSave: TToolButton;
    btnSaveAll: TToolButton;
    tbEdit: TToolBar;
    btnCopy: TToolButton;
    btnCut: TToolButton;
    btnPaste: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    tbSearch: TToolBar;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    LogTree: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
    procedure ProjectTreeDblClick(Sender: TObject);
    procedure ProjectTreeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure CodeTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure CodeTreeDblClick(Sender: TObject);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var CurrentInput: string; var x, y: Integer;
      var CanExecute: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PageControlContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
    procedure LogTreeDblClick(Sender: TObject);
  private
    { Private declarations }
    FCpuView: TCPUView;
    FWatchView: TWatchView;
    FIDEData: TIDEData;
    FIDEActions: TIDEActions;
    FController: TIDEController;
    procedure BindActions();
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

var
  MainForm: TMainForm;

implementation

uses
 CompilerUtil, ProjectOptionDialog, DateUtils, CodeElement,
 VarDeclaration, ProcDeclaration, DataType, LogTreeController;

{$R *.dfm}

{ TForm1 }

procedure TMainForm.PageControlContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  LIndex: Integer;
begin
  LIndex := FController.GetTabIndexBelowCursor();
  if (htOnItem in PageControl.GetHitTestInfoAt(MousePos.X, MousePos.Y)) and (LIndex >= 0) then
  begin
    PageControl.PopupMenu := FIDEData.TabPopUp;
    PageControl.PopupMenu.Tag := LIndex;
  end
  else
  begin
    PageControl.PopupMenu := nil;
  end;
end;

procedure TMainForm.BindActions;
begin
//  //toolbar
//  //run
////  btnRun.Action := FIDEActions.actRun;
//  btnPause.Action := FIDEActions.actPause;
//  btnStop.Action := FIDEActions.actStop;
//  //Debug
//  btnStep.Action := FIDEActions.actStep;
//  btnStepOver.Action := FIDEActions.actStepOver;
//  btnStepUntilReturn.Action := FIDEActions.actStepUntilReturn;
//  //menubar
//  //file
//  miNewUnit.Action := FIDEActions.actNewUnit;
//  miNewProject.Action := FIDEActions.actNewProject;
//  miSave.Action := FIDEActions.actSaveActive;
//  miSaveAs.Action := FIDEActions.actSaveActiveAs;
//  miSaveProjectAs.Action := FIDEActions.actSaveProjectAs;
//  miSaveAll.Action := FIDEActions.actSaveAll;
//  miOpen.Action := FIDEActions.actOpenProject;
//  miExit.Action := FIDEActions.actExit;
//  //project
//  miCompile.Action := FIDEActions.actCompile;
//  miRun.Action := FIDEActions.actRun;
//  miStop.Action := FIDEActions.actStop;
//  miOptions.Action := FIDEActions.actProjectOptions;
end;

procedure TMainForm.CodeTreeDblClick(Sender: TObject);
var
  LNode: PVirtualNode;
  LPos: TPoint;
  LPage: TIDEPage;
begin
  GetCursorPos(LPos);
  LPos := CodeTree.ScreenToClient(LPos);
  LNode := CodeTree.GetNodeAt(LPos.X, LPos.Y);
  if Assigned(LNode) then
  begin
    if PCodeNodeData(CodeTree.GetNodeData(LNode)).Line >= 0 then
    begin
      LPage := FController.GetActiveIDEPage();
      if Assigned(LPage) then
      begin
        LPage.IDEEdit.SetFocus;
        LPAge.IDEEdit.CaretY := PCodeNodeData(CodeTree.GetNodeData(LNode)).Line;
      end;
    end;
  end;
end;

procedure TMainForm.CodeTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  CellText := PCodeNodeData(Sender.GetNodeData(Node)).Caption;
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FCpuView := TCPUView.Create(Self);
  FCpuView.Parent := Self;
  FCPuView.Align := alRight;
  FWatchView := TWatchView.Create(Self);
  FWatchView.Parent := plLeft;
  FWatchView.Align := alBottom;
  FIDEData := TIDEData.Create(Self);
  FIDEActions := TIDEActions.Create(Self);
  FController := TIDEController.Create(Self, PageControl, ProjectTree, CodeTree, FCPUView, FWatchView,
    LogTree, SynCompletionProposal);
  FIDEActions.Controller := FController;
  FIDEActions.IDEData := FIDEData;
  FController.IDEData := FIDEData;
  BindActions();
end;

destructor TMainForm.Destroy;
begin
  inherited;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FController.IsRunning then
  begin
    FController.Stop();
  end;
  FIDEActions.actSaveAll.Execute();
  CanClose := Boolean(FIDEActions.actSaveAll.Tag);
  if not CanClose then
  begin
    if MessageDlg('There are unsaved changes. Exit without saving?', TMsgDlgType.mtWarning,
      [mbYes, mbNo], 0) = mrYes then
    begin
      CanClose := True;
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ProjectTree.NodeDataSize := SizeOf(Cardinal);
  FController.CreateNewProject('Project1', '');
end;

procedure TMainForm.LogTreeDblClick(Sender: TObject);
var
  LPos: TPoint;
  LNode: PVirtualNode;
  LData: PLogEntry;
begin
  if GetCursorPos(LPos) then
  begin
    LPos := LogTree.ScreenToClient(LPos);
    LNode := LogTree.GetNodeAt(LPos.X, LPos.Y);
    if Assigned(LNode) then
    begin
      LData := LogTree.GetNodeData(LNode);
      if Assigned(LData) then
      begin
        if LData.Line > -1 then
        begin
          FController.FokusIDEEdit(LData.UnitName, -1, LData.Line);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.ProjectTreeContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  LNode: PVirtualNode;
begin
  LNode := ProjectTree.GetNodeAt(MousePos.X, MousePos.Y);
  if LNode = ProjectTree.GetFirst() then
  begin
    ProjectTree.PopupMenu := FIDEData.ProjectPopup;
  end
  else
  begin
    if Assigned(LNode) then
    begin
      ProjectTree.PopupMenu := FIDEData.ProjectPopUp;//for now we use the same popup, will be changed later
    end
    else
    begin
      ProjectTree.PopupMenu := nil;
    end;
  end;
end;

procedure TMainForm.ProjectTreeDblClick(Sender: TObject);
var
  LPos: TPoint;
  LNode: PVirtualNode;
  LData: PProjectNodeData;
  LUnit: TIDEUnit;
begin
  LUnit := nil;
  GetCursorPos(LPos);
  LPos := ProjectTree.ScreenToClient(LPos);
  LNode := ProjectTree.GetNodeAt(LPos.X, LPos.Y);
  if Assigned(LNode) then
  begin
    if LNode = ProjectTree.GetFirst() then
    begin
      LData := ProjectTree.GetNodeData(LNode);
      if Assigned(LData) then
      begin
        LUnit := TProject(LData.Item).ProjectUnit;
      end;
    end
    else
    begin
      LData := ProjectTree.GetNodeData(LNode);
      if Assigned(LData) then
      begin
        LUnit := TIDEUnit(LData.Item);
      end;
    end;

    if Assigned(LUnit) then
    begin
      if not FController.IDEUnitIsOpen(LUnit) then
      begin
        FController.AddPage(LUnit.Caption, '', LUnit);
      end;
        FController.FokusIDEPageByUnit(LUnit);
    end;
  end;
end;

procedure TMainForm.SynCompletionProposalExecute(Kind: SynCompletionType;
  Sender: TObject; var CurrentInput: string; var x, y: Integer;
  var CanExecute: Boolean);
begin
  FController.BuildCompletionLists(SynCompletionProposal.ItemList, SynCompletionProposal.InsertList);
  SynCompletionProposal.NbLinesInWindow := 8;
end;

initialization

//Si.Enabled := True;

end.
