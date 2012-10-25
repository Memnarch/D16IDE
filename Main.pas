unit Main;

interface

uses
  Windows, Messages, UXTheme, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, Menus, ExtCtrls, SynEdit, ImgList, VirtualTrees,
  SynEditHighlighter, SynHighlighterPas, SynMemo, ActnList, JvExComCtrls,
  JvComCtrls, JvTabBar, JvExControls, JvPageList, JvTabBarXPPainter,
  JvComponentBase, xmldom, XMLIntf, msxmldom, XMLDoc, Project,  IDEUnit, CompilerDefines, Compiler,
  PascalUnit, SynCompletionProposal, CPUViewForm, Emulator, SiAuto, SmartInspect,
  WatchViewForm, IDETabSheet, IDEPageFrame, ProjectTreeController;

type
  TCodeNodeData = record
    Caption: string;
    Line: Integer;
  end;

  PCodeNodeData = ^TCodeNodeData;

  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    ToolBar1: TToolBar;
    plLeft: TPanel;
    plRight: TPanel;
    SplitterLeft: TSplitter;
    SplitterRight: TSplitter;
    TreeImages: TImageList;
    ProjectTree: TVirtualStringTree;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Log: TSynMemo;
    btnCompile: TToolButton;
    ToolBarImages: TImageList;
    Edit1: TMenuItem;
    Search1: TMenuItem;
    Project1: TMenuItem;
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
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    Options1: TMenuItem;
    PageControl: TJvPageControl;
    ActionList: TActionList;
    actNewUnit: TAction;
    TabPopUp: TPopupMenu;
    Close1: TMenuItem;
    actCloseUnitByTab: TAction;
    OpenUnitDialog: TOpenDialog;
    SaveUnitDialog: TSaveDialog;
    actSaveActive: TAction;
    actSaveActiveAs: TAction;
    actSaveAll: TAction;
    actSaveProjectAs: TAction;
    SaveProjectDialog: TSaveDialog;
    actNewProject: TAction;
    actCompile: TAction;
    actOpenProject: TAction;
    OpenProjectDialog: TOpenDialog;
    ProjectPopup: TPopupMenu;
    NewUnit1: TMenuItem;
    AddUnit1: TMenuItem;
    actAddExistingUnit: TAction;
    actProjectOptions: TAction;
    Options2: TMenuItem;
    CodeTree: TVirtualStringTree;
    actPeekCompile: TAction;
    SynCompletionProposal: TSynCompletionProposal;
    btnRun: TToolButton;
    actRun: TAction;
    actStop: TAction;
    ToolButton1: TToolButton;
    Compile1: TMenuItem;
    Run1: TMenuItem;
    Stop1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure actNewUnitExecute(Sender: TObject);
    procedure PageControlContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure actCloseUnitByTabExecute(Sender: TObject);
    procedure ProjectTreeDblClick(Sender: TObject);
    procedure actSaveActiveExecute(Sender: TObject);
    procedure actSaveActiveAsExecute(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure actSaveProjectAsExecute(Sender: TObject);
    procedure actNewProjectExecute(Sender: TObject);
    procedure actCompileExecute(Sender: TObject);
    procedure actOpenProjectExecute(Sender: TObject);
    procedure ProjectTreeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure actAddExistingUnitExecute(Sender: TObject);
    procedure actProjectOptionsExecute(Sender: TObject);
    procedure CodeTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure CodeTreeDblClick(Sender: TObject);
    procedure actPeekCompileExecute(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var CurrentInput: string; var x, y: Integer;
      var CanExecute: Boolean);
    procedure actRunExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FProject: TProject;
    FID: Integer;
    FPeekCompiler: TCompiler;
    FLastPeek: TDateTime;
    FCpuView: TCPUView;
    FWatchView: TWatchView;
    FEmulator: TD16Emulator;
    FProjectTreeController: TProjectTreeController;
    FErrors: Cardinal;
    function SaveUnit(AUnit: TIDEUnit): Boolean;
    function GetTabIndexBelowCursor(): Integer;
    function SaveProject(AProject: TProject): Boolean;
    procedure AddPage(ATitle: string; AFile: string = ''; AUnit: TIDEUnit = nil);
    procedure ClosePage(AIndex: Integer);
    procedure CreateNewProject(ATitle: string; AProjectFolder: string);
    procedure ClearProjects();
    procedure OpenProject(AFile: string);
    procedure HandleCompileMessage(AMessage, AUnitName: string; ALine: Integer; ALevel: TMessageLevel);
    procedure HandleSynEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BuildCodeTreeFromUnit(AUnit: TPascalUnit);
    procedure BuildCompletionLists(ACompletion, AInsert: TStrings);
    function FormatCompletPropString(ACategory, AIdentifier, AType: string): string;
    function GetActiveIDEPage(): TIDEPage;
    procedure HandleCPUViewClose(Sender: TObject; var Action: TCloseAction);
    procedure HandleEmuMessage(AMessage: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

var
  MainForm: TMainForm;

implementation

uses
 CompilerUtil, ProjectOptionDialog, CodeElement, VarDeclaration, ProcDeclaration, DateUtils, DataType;

{$R *.dfm}

{ TForm1 }

procedure TMainForm.actAddExistingUnitExecute(Sender: TObject);
begin
  if OpenUnitDialog.Execute then
  begin
    AddPage(ExtractFileName(OpenUnitDialog.FileName), OpenUnitDialog.FileName);
  end;
end;

procedure TMainForm.actCloseUnitByTabExecute(Sender: TObject);
begin
  ClosePage(TabPopUp.Tag);
end;

procedure TMainForm.actCompileExecute(Sender: TObject);
begin
  actSaveAll.Execute();
  Log.Clear;
  FErrors := 0;
  CompileFile(FProject.Units.Items[0].FileName, FProject.Optimize, FProject.Assemble,
    FProject.BuildModule, FProject.UseBigEndian, HandleCompileMessage);
end;

procedure TMainForm.actNewProjectExecute(Sender: TObject);
var
  LName: string;
begin
  if SaveProjectDialog.Execute then
  begin
    LName := ChangeFileExt(SaveProjectDialog.FileName, '.d16p');
    CreateNewProject(ExtractFileName(LName), ExtractFilePath(LName));
  end;
end;

procedure TMainForm.actNewUnitExecute(Sender: TObject);
begin
  AddPage('Unit' + IntToStr(FID));
  Inc(FID);
end;

procedure TMainForm.actOpenProjectExecute(Sender: TObject);
begin
  if OpenProjectDialog.Execute then
  begin
    OpenProject(OpenProjectDialog.FileName);
  end;
end;

procedure TMainForm.actPeekCompileExecute(Sender: TObject);
var
  LUnit: TPascalUnit;
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    if FPeekCompiler.PeekCompile(LPage.IDEEdit.Text, LPage.IDEUnit.Caption, LUnit) then
    begin
      BuildCodeTreeFromUnit(LUnit);
    end;
  end;
end;

procedure TMainForm.actProjectOptionsExecute(Sender: TObject);
var
  LDialog: TProjectOption;
begin
  LDialog := TProjectOption.Create(nil);
  LDialog.LoadFromProject(FProject);
  if LDialog.ShowModal = mrOk then
  begin
    LDialog.SaveToProject(FProject);
  end;
end;

procedure TMainForm.actRunExecute(Sender: TObject);
begin
  actCompile.Execute();
  if (FErrors = 0) and (FProject.Assemble) then
  begin
    actCompile.Enabled := False;
    actRun.Enabled := False;
    actStop.Enabled := True;
    FCPUView.LoadASMFromFile(ChangeFileExt(FProject.Units.Items[0].FileName, '.asm'));
    FCPUView.Show;
    FWatchView.Show;
    Log.Clear;
    FEmulator := TD16Emulator.Create();
    FEmulator.OnMessage := HandleEmuMessage;
    FCpuView.SetEmulator(FEmulator);
    FWatchView.SetEmulator(FEmulator);
    Log.Lines.Add('Running: ' + ExtractFileName(ChangeFileExt(FProject.Units.Items[0].FileName, '.d16')));
    FEmulator.LoadFromFile(ChangeFileExt(FProject.Units.Items[0].FileName, '.d16'), FProject.UseBigEndian);
    FEmulator.Run();
  end;
end;

procedure TMainForm.actSaveActiveAsExecute(Sender: TObject);
//var
//  LNode: PVirtualNode;
//  LData: PNodeData;
begin
//  LNode := GetTreeNodeBySynEdit(GetActiveSynEdit);
//  LData := ProjectTree.GetNodeData(LNode);
//  SaveUnitDialog.InitialDir := ExtractFilePath(TIDEUnit(LData.Item).SavePath);
//  if SaveUnitDialog.Execute() then
//  begin
//    TIdeUnit(LData.Item).SavePath := ExtractFilePath(SaveUnitDialog.FileName);
//    TIdeUnit(LData.Item).Caption := ChangeFileExt(ExtractFileName(SaveUnitDialog.FileName), '');
//    SaveUnit(TIdeUnit(LData.Item));
//  end;
end;

procedure TMainForm.actSaveActiveExecute(Sender: TObject);
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    SaveUnit(LPage.IDEUnit);
  end;
end;

procedure TMainForm.actSaveAllExecute(Sender: TObject);
var
  LUnit: TIDEUnit;
begin
  for LUnit in FProject.Units do
  begin
    SaveUnit(LUnit);
  end;
  if SaveProject(FProject) then
  begin
    actSaveAll.Tag := Integer(True);
  end;
end;

procedure TMainForm.actSaveProjectAsExecute(Sender: TObject);
begin
  FProject.ProjectPath := '';
  SaveProject(FProject);
end;

procedure TMainForm.actStopExecute(Sender: TObject);
begin
  if Assigned(FEmulator) then
  begin
    FEmulator.Stop;
    FEmulator.Terminate;
    WaitForSingleObject(FEmulator.Handle, 5000);
    FEmulator.Free;
    FEmulator := nil;
  end;
  actCompile.Enabled := True;
  actRun.Enabled := True;
  actStop.Enabled := False;
  FCPUView.Hide;
  FWatchView.Hide;
end;

procedure TMainForm.AddPage(ATitle: string; AFile: string = ''; AUnit: TIDEUnit = nil);
var
  LPage: TIDETabSheet;
  LUnit: TIDEUnit;
begin
  LPage := TIDETabSheet.Create(Self, PageControl);

  if Assigned(AUnit) then
  begin
    LUnit := AUnit;
  end
  else
  begin
    LUnit := TIDEUnit.Create();
  end;
  LPage.IDEPage.IDEUnit := LUnit;
  LPage.IDEPage.IDEEdit.OnKeyDown := HandleSynEditKeyDown;
  LUnit.Caption := ATitle;
  LUnit.ImageIndex := 1;
  FProject.Units.Add(LUnit);
end;

procedure TMainForm.BuildCodeTreeFromUnit(AUnit: TPascalUnit);
var
  LUses, LProcedures, LVars, LTypes, LNode: PVirtualNode;
  LElement: TCodeElement;
  LName: string;
  LPreFix: string;
begin
  CodeTree.BeginUpdate;
  CodeTree.Clear;
  LUses := CodeTree.AddChild(nil);
  PCodeNodeData(CodeTree.GetNodeData(LUses)).Caption := 'Uses';
  PCodeNodeData(CodeTree.GetNodeData(LUses)).Line := -1;
  LVars := CodeTree.AddChild(nil);
  LTypes := CodeTree.AddChild(nil);
  PCodeNodeData(CodeTree.GetNodeData(LTypes)).Caption := 'Types';
  PCodeNodeData(CodeTree.GetNodeData(LTypes)).Line := -1;
  PCodeNodeData(CodeTree.GetNodeData(LVars)).Caption := 'Vars';
  PCodeNodeData(CodeTree.GetNodeData(LVars)).Line := -1;
  LProcedures := CodeTree.AddChild(nil);
  PCodeNodeData(CodeTree.GetNodeData(LProcedures)).Caption := 'Procedures';
  PCodeNodeData(CodeTree.GetNodeData(LProcedures)).Line := -1;
  for LName in AUnit.UsedUnits do
  begin
      LNode := CodeTree.AddChild(LUses);
      PCodeNodeData(CodeTree.GetNodeData(LNode)).Caption := LName;
  end;
  for LElement in AUnit.SubElements do
  begin
    LNode := nil;
    if LElement is TVarDeclaration then
    begin
      LNode := CodeTree.AddChild(LVars);
      PCodeNodeData(CodeTree.GetNodeData(LNode)).Caption := LElement.Name + ': ' + TVarDeclaration(LElement).DataType.Name;
    end;
    if LElement is TProcDeclaration then
    begin
      LNode := CodeTree.AddChild(LProcedures);
      PCodeNodeData(CodeTree.GetNodeData(LNode)).Caption := LElement.Name;
    end;
    if (LElement is TDataType) and (TDataType(LElement) <> TDataType(LElement).BaseType) then
    begin
      LNode := CodeTree.AddChild(LTypes);
      LPreFix := '';
      if TDataType(LElement).RawType = rtPointer then
      begin
        LPreFix := '^';
      end;
      if TDataType(LElement).RawType = rtArray then
      begin
        LPreFix := 'array of ';
      end;
      PCodeNodeData(CodeTree.GetNodeData(LNode)).Caption := LElement.Name + ': ' + LPreFix + TDataType(LElement).BaseType.Name;
    end;
    if Assigned(LNode) then
    begin
      PCodeNodeData(CodeTree.GetNodeData(LNode)).Line := LElement.Line;
    end;
  end;
  CodeTree.FullExpand(nil);
  CodeTree.EndUpdate;
end;

procedure TMainForm.BuildCompletionLists(ACompletion, AInsert: TStrings);
var
  LUnit, LActiveUnit: TPascalUnit;
  LElement, LParam: TCodeElement;
  LType, LCat, LIdentifier: string;
  LUnitName: string;
begin
  ACompletion.Clear;
  AInsert.Clear;
  LUnitName := ChangeFileExt(GetActiveIDEPage().IDEUnit.Caption, '');
  LActiveUnit :=  FPeekCompiler.GetUnitByName(LUnitName);
  if not Assigned(LActiveUnit) then
  begin
    Exit;
  end;
  for LUnit in FPeekCompiler.Units do
  begin
    if (not SameText(LUnit.Name, LActiveUnit.Name)) and (LActiveUnit.UsedUnits.IndexOf(LUnit.Name) < 0) then
    begin
      Continue;
    end;
    for LElement in LUnit.SubElements do
    begin
      LType := '';
      LIdentifier := LElement.Name;
      if LElement is TDataType then
      begin
        LCat := 'type';
      end;
      if LElement is TVarDeclaration then
      begin
        LCat := 'var';
        LType := ': ' + TVarDeclaration(LElement).DataType.Name;
      end;
      if LElement is TProcDeclaration then
      begin
        LCat := 'proc';
        LType :=  '(';
        for LParam in TProcDeclaration(LElement).Parameters do
        begin
          if Length(LType) > 1 then
          begin
            LType := LType + '; ';
          end;
          LType := LType + LParam.Name + ': ' + TVarDeclaration(LParam).DataType.Name;
        end;
        LType := LType + ')';
        if TProcDeclaration(LElement).IsFunction then
        begin
          LType := LType + ': ' + TProcDeclaration(LElement).ResultType.Name;
        end;
      end;
      ACompletion.Add(FormatCompletPropString(LCat, LIdentifier, LType));
      AInsert.Add(LElement.Name);
    end;
  end;
end;

procedure TMainForm.ClearProjects;
var
  i: Integer;
begin
  FProjectTreeController.Project := nil;
  if Assigned(FProject) then
  begin
    FProject.Units.Clear;
    for i := PageControl.PageCount - 1 downto 0 do
    begin
      PageControl.Pages[i].Free;
    end;
    FProject.Free;
  end;
end;

procedure TMainForm.ClosePage(AIndex: Integer);
//var
//  LNode: PVirtualNode;
//  LEdit: TSynEdit;
//  LPage: TTabSheet;
//  LData: PNodeData;
begin
//  LPage := PageControl.Pages[AIndex];
//  LEdit := TSynEdit(LPage.FindChildControl('SynEdit'));
//  LNode := GetTreeNodeBySynEdit(LEdit);
//  if Assigned(LNode) then
//  begin
//    LData := ProjectTree.GetNodeData(LNode);
//    SaveUnit(TIdeUnit(LData.Item));
//    LPage.Free;
//  end;
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
      LPage := GetActiveIDEPage();
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
  FPeekCompiler := TCompiler.Create();
  FPeekCompiler.PeekMode := True;
  FCpuView := TCPUView.Create(Self);
  FCpuView.Parent := Self;
  FCPuView.Align := alRight;
  FCPUView.OnClose := HandleCPUViewClose;
  FWatchView := TWatchView.Create(Self);
  FWatchView.Parent := plLeft;
  FWatchView.Align := alBottom;
  FWatchView.ValueListEditor1.InsertRow('LTest', '0', True);
  CodeTree.NodeDataSize := SizeOf(TCodeNodeData);
  FProjectTreeController := TProjectTreeController.Create(ProjectTree);
  FLastPeek := Now();
end;

procedure TMainForm.CreateNewProject(ATitle, AProjectFolder: string);
begin
  ClearProjects();
  FProject := TProject.Create();
  FProject.ProjectPath := AProjectFolder;
  FProject.ProjectName := ChangeFileExt(ATitle,'.d16p');
  FPeekCompiler.Reset();
  AddPage('Unit' + IntToSTr(FID));
  Inc(FID);
  PageControlChange(PageControl);
  FProjectTreeController.Project := FProject;
end;

destructor TMainForm.Destroy;
begin
  FPeekCompiler.Free;
  inherited;
end;

function TMainForm.FormatCompletPropString(ACategory, AIdentifier,
  AType: string): string;
begin
  Result := '\color{clNavy}' + ACategory + '\column{}\color{clBlack}\Style{+B}' + AIdentifier + '\Style{-B}' + AType;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FEmulator) then
  begin
    CanClose := False;
    ShowMessage('Please stop the running emulation before closing the IDE')
  end
  else
  begin
    actSaveAll.Execute();
    CanClose := Boolean(actSaveAll.Tag);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ProjectTree.NodeDataSize := SizeOf(Cardinal);
  FID := 1;
  CreateNewProject('Project1', '');
  actSaveAll.ShortCut := ShortCut(Ord('S'), [ssCtrl, ssShift]);
end;

function TMainForm.GetActiveIDEPage: TIDEPage;
var
  i: Integer;
  LIDETab: TIDETabSheet;
begin
  Result := nil;
  LIDETab := TIDETabSheet(PageControl.ActivePage);
  if Assigned(LIDETab) then
  begin
    Result := LIDETab.IDEPage;
  end;
end;

function TMainForm.GetTabIndexBelowCursor: Integer;
var
  i: Integer;
  LPos: TPoint;
begin
  Result := -1;
  if PageControl.PageCount <= 1 then
  begin
    Exit;
  end;
  GetCursorPos(LPos);
  LPos := PageControl.ScreenToClient(LPos);
  for i := 0 to PageControl.PageCount - 1 do
  begin
    if (LPos.X >= PageControl.TabRect(i).Left) and (LPos.X <= PageControl.TabRect(i).Right) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TMainForm.HandleCompileMessage(AMessage, AUnitName: string;
  ALine: Integer; ALevel: TMessageLevel);
begin
  if ALevel = mlNone then
  begin
    Log.Lines.Add(AMessage);
  end
  else
  begin
    Log.Lines.Add('Error in ' + AUnitName + ' line ' + IntToSTr(ALine) + ': ' + AMessage);
    Inc(FErrors);
  end;
  Log.Refresh;
end;

procedure TMainForm.HandleCPUViewClose(Sender: TObject; var Action: TCloseAction);
begin
  ACtion := caHide;
  actStop.Execute();
end;

procedure TMainForm.HandleEmuMessage(AMessage: string);
begin
  Log.Lines.Add('Emulator: ' + AMessage);
end;

procedure TMainForm.OpenProject(AFile: string);
var
  LDoc: IXMLDocument;
  LNode, LRoot: IXMLNode;
  i: Integer;
  LPath: string;
  LPage: TIDEPage;
begin
  ClearProjects();
  LDoc := TXMLDocument.Create(nil);
  LDoc.Active := True;
  LDoc.LoadFromFile(AFile);
  LRoot := LDoc.ChildNodes.First;
  FProject := TProject.Create();
  FProject.ProjectName := ChangeFileExt(LRoot.Attributes['Name'], '.d16p');
  FProject.ProjectPath := ExtractFilePath(AFile);
  FPeekCompiler.Reset();
  FPeekCompiler.SearchPath.Add(FProject.ProjectPath);
  for i := 0 to LRoot.ChildNodes.Count - 1 do
  begin
    LNode := LRoot.ChildNodes.Nodes[i];
    LPath := LNode.Attributes['Path'];
    AddPage(ExtractFileName(LPath), LPath);
  end;
  FProjectTreeController.Project := FProject;
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    SynCompletionProposal.Editor := LPage.IDEEdit;
  end;
end;

procedure TMainForm.PageControlChange(Sender: TObject);
var
  LPage: TIDEPage;
begin
  actPeekCompile.Execute();
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    SynCompletionProposal.Editor := LPage.IDEEdit;
  end;
end;

procedure TMainForm.PageControlContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  LIndex: Integer;
begin
  LIndex := GetTabIndexBelowCursor();
  if (htOnItem in PageControl.GetHitTestInfoAt(MousePos.X, MousePos.Y)) and (LIndex >= 0) then
  begin
    PageControl.PopupMenu := TabPopUp;
    PageControl.PopupMenu.Tag := LIndex;
  end
  else
  begin
    PageControl.PopupMenu := nil;
  end;
end;

procedure TMainForm.ProjectTreeContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  if ProjectTree.GetNodeAt(MousePos.X, MousePos.Y) = ProjectTree.GetFirst() then
  begin
    ProjectTree.PopupMenu := ProjectPopup;
  end
  else
  begin
    ProjectTree.PopupMenu := nil;
  end;
end;

procedure TMainForm.ProjectTreeDblClick(Sender: TObject);
var
  LPos: TPoint;
//  LNode: PVirtualNode;
//  LData: PNodeData;
begin
  GetCursorPos(LPos);
//  LPos := ProjectTree.ScreenToClient(LPos);
//  LNode := ProjectTree.GetNodeAt(LPos.X, LPos.Y);
//  if Assigned(LNode) then
//  begin
//    if LNode = ProjectTree.GetFirst() then
//    begin
//      Exit;
//    end;
//    LData := ProjectTree.GetNodeData(LNode);
//    if Assigned(LData) then
//    begin
//      if not TIdeUnit(LData.Item).IsOpen then
//      begin
//        AddPage(TIdeUnit(LData.Item).Caption, TIdeUnit(LData.Item).SavePath, TIdeUnit(LData.Item));
//      end;
//      PageControl.ActivePageIndex := GetTabIndexBySynEdit(TIdeUnit(LData.Item).SynEdit);
//    end;
//  end;
end;


function TMainForm.SaveProject(AProject: TProject): Boolean;
begin
  Result := False;
  if (AProject.ProjectPath = '') or (AProject.ProjectName = '') then
  begin
    SaveProjectDialog.Title := 'Save ' +  AProject.ProjectName + ' as';
    if SaveProjectDialog.Execute then
    begin
      AProject.ProjectPath := ExtractFilePath(SaveProjectDialog.FileName);
      AProject.ProjectName := ChangeFileExt(ExtractFileName(SaveProjectDialog.FileName), '.d16p');
    end
    else
    begin
      Exit;
    end;
  end;
  AProject.SaveToFile(AProject.ProjectPath + '\' + AProject.ProjectName);
  Result := True;
end;

function TMainForm.SaveUnit(AUnit: TIDEUnit): Boolean;
var
  LOldUnitName: string;
begin
  Result := False;
  LOldUnitName := AUnit.Caption;
  if AUnit.SavePath = '' then
  begin
    SaveUnitDialog.Title := 'Save ' + AUnit.Caption + ' as';
    if SaveUnitDialog.Execute() then
    begin
      AUnit.SavePath := ExtractFilePath(SaveUnitDialog.FileName);
      AUnit.Caption := ChangeFileExt(ExtractFileName(SaveUnitDialog.FileName), '');
    end
    else
    begin
      Exit;
    end;
  end;
  AUnit.Save();
  Result := True;
end;

procedure TMainForm.SynCompletionProposalExecute(Kind: SynCompletionType;
  Sender: TObject; var CurrentInput: string; var x, y: Integer;
  var CanExecute: Boolean);
begin
  BuildCompletionLists(SynCompletionProposal.ItemList, SynCompletionProposal.InsertList);
  SynCompletionProposal.NbLinesInWindow := 8;
end;

procedure TMainForm.HandleSynEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if MilliSecondsBetween(FLastPeek, Now()) > 500 then
  begin
    actPeekCompile.Execute();
    FLastPeek := Now();
  end;
end;

initialization

Si.Enabled := True;

end.
