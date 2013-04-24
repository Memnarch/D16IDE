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
  IDEController, IDEActionModule, SynEditMiscClasses, SynEditSearch, CodeTreeView, ProjectViewForm,
  MessageViewForm, StdCtrls;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    tbRun: TToolBar;
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
    btnCheckUpdates: TMenuItem;
    btnView: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var CurrentInput: string; var x, y: Integer;
      var CanExecute: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PageControlContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    FIDEData: TIDEData;
    FIDEActions: TIDEActions;
    FController: TIDEController;
    FCodeView: TCodeView;
    FProjectView: TProjectView;
    FMessageView: TMessageView;
    FCPUView: TCPUView;
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
 VarDeclaration, ProcDeclaration, DataType, LogTreeController, EventGroups,
 MenuFormItem;

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

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
//  FCpuView := TCPUView.Create(Self);
//  FCpuView.Parent := Self;
//  FCPuView.Align := alRight;
//  FWatchView := TWatchView.Create(Self);
//  FWatchView.Parent := plLeft;
//  FWatchView.Align := alBottom;
  FCodeView := TCodeView.Create(Self);
  FProjectView := TProjectView.Create(Self);
  FMessageView := TMessageView.Create(Self);
  FCPUView := TCPUView.Create(Self);
  FIDEData := TIDEData.Create(Self);
  FIDEActions := TIDEActions.Create(Self);
  FController := TIDEController.Create(Self, PageControl, SynCompletionProposal);
  FIDEActions.Controller := FController;
  FIDEActions.IDEData := FIDEData;
  FController.IDEData := FIDEData;
  FController.Layout.RegisterView(FCodeView, [egCurrentUnit]);
  FController.Layout.RegisterView(FProjectView, [egProject]);
  FController.Layout.RegisterView(FMessageView, [egCompiler, egEmulator]);
  FController.Layout.RegisterView(FCPUView, [egDebugger]);
  BindActions();
  FProjectView.IDEData := FIDEData;
  FProjectView.IDEActions := FIDEActions;
  FCodeView.IDEData := FIDEData;
  FMessageView.IDEData := FIDEData;
  FCodeView.Controller := FController;
  FProjectView.Controller := FController;
  FMessageView.Controller := FController;
  FCPUView.Controller := FController;

  btnView.Add(TMenuFormItem.Create(btnView, FCodeView));
  btnView.Add(TMenuFormItem.Create(btnView, FMessageView));
  btnView.Add(TMenuFormItem.Create(btnView, FProjectView));
  btnView.Add(TMenuFormItem.Create(btnView, FCPUView));
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
  if FIDEActions.DontAskForSavingOnExit then
  begin
    CanClose := True;
  end
  else
  begin
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
  FController.Layout.Save('Default');
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FController.Layout.Load('Default');
  FController.CreateNewProject('Project1', '');
end;

procedure TMainForm.SynCompletionProposalExecute(Kind: SynCompletionType;
  Sender: TObject; var CurrentInput: string; var x, y: Integer;
  var CanExecute: Boolean);
begin
  FController.BuildCompletionLists(SynCompletionProposal.ItemList, SynCompletionProposal.InsertList);
  SynCompletionProposal.NbLinesInWindow := 8;
end;

end.
