unit Main;

interface

uses
  Windows, Messages, UXTheme, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, Menus, ExtCtrls, SynEdit, ImgList, VirtualTrees,
  SynEditHighlighter, SynHighlighterPas, SynMemo, ActnList, JvExComCtrls,
  JvComCtrls, JvTabBar, JvExControls, JvPageList, JvTabBarXPPainter,
  JvComponentBase, xmldom, XMLIntf, msxmldom, XMLDoc, Project,  IDEUnit, CompilerDefines;

type
  TNodeData = record
    Item: TObject;
  end;

  PNodeData = ^TNodeData;

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
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    Options1: TMenuItem;
    Compile1: TMenuItem;
    PageControl: TJvPageControl;
    JvModernTabBarPainter1: TJvModernTabBarPainter;
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
    procedure FormCreate(Sender: TObject);
    procedure ProjectTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure ProjectTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actProjectOptionsExecute(Sender: TObject);
  private
    { Private declarations }
    FProject: TProject;
    FID: Integer;
    procedure SaveUnit(AUnit: TIDEUnit);
    function GetTabIndexBelowCursor(): Integer;
    function GetTabIndexBySynEdit(AEdit: TSynEdit): Integer;
    function GetTreeNodeBySynEdit(AEdit: TSynEdit): PVirtualNode;
    function GetTreeNodeByUnit(AUnit: TIDEUnit): PVirtualNode;
    function GetActiveSynEdit(): TSynEdit;
    procedure SaveProject(AFile: string);
    procedure ChangeUnitHeader(AEdit: TSynEdit; AOld, ANew: string);
    procedure AddPage(ATitle: string; AFile: string = ''; AUnit: TIDEUnit = nil);
    procedure ClosePage(AIndex: Integer);
    procedure CreateNewProject(ATitle: string; AProjectFolder: string);
    procedure ClearProjects();
    procedure OpenProject(AFile: string);
    procedure HandleCompileMessage(AMessage, AUnitName: string; ALine: Integer; ALevel: TMessageLevel);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  CompilerUtil, ProjectOptionDialog;

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
  CompileFile(FProject.Units.Items[0].SavePath, FProject.Optimize, FProject.Assemble,
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

procedure TMainForm.actSaveActiveAsExecute(Sender: TObject);
var
  LNode: PVirtualNode;
  LData: PNodeData;
begin
  LNode := GetTreeNodeBySynEdit(GetActiveSynEdit);
  LData := ProjectTree.GetNodeData(LNode);
  SaveUnitDialog.InitialDir := ExtractFilePath(TIDEUnit(LData.Item).SavePath);
  if SaveUnitDialog.Execute() then
  begin
    TIdeUnit(LData.Item).SavePath := SaveUnitDialog.FileName;
    SaveUnit(TIdeUnit(LData.Item));
  end;
end;

procedure TMainForm.actSaveActiveExecute(Sender: TObject);
var
  LNode: PVirtualNode;
  LData: PNodeData;
begin
  LNode := GetTreeNodeBySynEdit(GetActiveSynEdit());
  LData := ProjectTree.GetNodeData(LNode);
  SaveUnit(TIDEUnit(LData.Item));
end;

procedure TMainForm.actSaveAllExecute(Sender: TObject);
var
  i: Integer;
  LNode: PVirtualNode;
begin
  for i := 0 to PageControl.PageCount - 1 do
  begin
    LNode := GetTreeNodeBySynEdit(TSynEdit(PageControl.Pages[i].FindChildControl('SynEdit')));
    SaveUnit(TIDEUnit(PNodeData(ProjectTree.GetNodeData(LNode)).Item));
  end;
  SaveProject(FProject.ProjectPath + '\' + FProject.ProjectName);
end;

procedure TMainForm.actSaveProjectAsExecute(Sender: TObject);
begin
  if SaveProjectDialog.Execute then
  begin
    SaveProject(ChangeFileExt(SaveProjectDialog.FileName, '.d16p'));
  end;
end;

procedure TMainForm.AddPage(ATitle: string; AFile: string = ''; AUnit: TIDEUnit = nil);
var
  LPage: TTabSheet;
  LUnit: TIDEUnit;
  LNode: PVirtualNode;
begin
  LPage := TTabSheet.Create(Self);
  LPage.PageControl := PageControl;
  LPage.Caption := ChangeFileExt(ATitle, '');

  if Assigned(AUnit) then
  begin
    LUnit := AUnit;
  end
  else
  begin
    LUnit := TIDEUnit.Create();
  end;
  LUnit.Caption := ATitle;
  if SameText(ExtractFileExt(LUnit.Caption), '') then
  begin
    LUnit.Caption := LUnit.Caption + '.pas';
  end;
  LUnit.SavePath := FProject.ProjectPath + '\' + LUnit.Caption;
  LUnit.ImageIndex := 1;
  LUnit.Open;
  LUnit.SynEdit.Highlighter := SynPasSyn;
  LUnit.SynEdit.Lines.Text := 'unit ' + ATitle + ';' + sLineBreak + sLineBreak + sLineBreak + sLineBreak + sLineBreak + sLineBreak + 'end.';
  LUnit.SynEdit.Parent := LPage;
  LUnit.SynEdit.Align := alClient;
  LNode := GetTreeNodeByUnit(LUnit);
  if not Assigned(LNode) then
  begin
    LNode := ProjectTree.AddChild(ProjectTree.GetFirst());
  end;
  PNodeData(ProjectTree.GetNodeData(LNode)).Item := LUnit;
  FProject.Units.Add(LUnit);
  if AFile <> '' then
  begin
    LUnit.SynEdit.Lines.LoadFromFile(AFile);
  end;
  SaveUnit(LUnit);
end;

procedure TMainForm.ChangeUnitHeader(AEdit: TSynEdit; AOld, ANew: string);
begin
  AEdit.Text := StringReplace(AEdit.Text, 'unit ' + AOld + ';', 'unit ' + ANew + ';', [rfIgnoreCase]);
end;

procedure TMainForm.ClearProjects;
var
  i: Integer;
begin
  ProjectTree.Clear;
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
var
  LNode: PVirtualNode;
  LEdit: TSynEdit;
  LPage: TTabSheet;
  LData: PNodeData;
begin
  LPage := PageControl.Pages[AIndex];
  LEdit := TSynEdit(LPage.FindChildControl('SynEdit'));
  LNode := GetTreeNodeBySynEdit(LEdit);
  if Assigned(LNode) then
  begin
    LData := ProjectTree.GetNodeData(LNode);
    SaveUnit(TIdeUnit(LData.Item));
    TIdeUnit(LData.Item).Close;
    LPage.Free;
  end;
end;

procedure TMainForm.CreateNewProject(ATitle, AProjectFolder: string);
var
  LNode: PVirtualNode;
  LData: PNodeData;
begin
  ClearProjects();
  FProject := TProject.Create();
  LNode := ProjectTree.AddChild(nil);
  FProject.ProjectPath := AProjectFolder;
  FProject.ProjectName := ChangeFileExt(ATitle,'.d16p');
  LData := ProjectTree.GetNodeData(LNode);
  LData.Item := FProject;
  AddPage('Unit' + IntToSTr(FID));
  Inc(FID);
  ProjectTree.Expanded[LNode] := True;
  SaveProject(FProject.ProjectPath + '\' + FProject.ProjectName);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  actSaveAll.Execute;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ProjectTree.NodeDataSize := SizeOf(Cardinal);
  FID := 1;
  CreateNewProject('Project1', 'E:\TestIDEProject\');
  actSaveAll.ShortCut := ShortCut(Ord('S'), [ssCtrl, ssShift]);
end;

function TMainForm.GetActiveSynEdit: TSynEdit;
begin
  Result := TSynEdit(PageControl.Pages[PageControl.ActivePageIndex].FindChildControl('SynEdit'));
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

function TMainForm.GetTabIndexBySynEdit(AEdit: TSynEdit): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to PageControl.PageCount - 1 do
  begin
    if PageControl.Pages[i].FindChildControl('SynEdit') = AEdit then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TMainForm.GetTreeNodeBySynEdit(AEdit: TSynEdit): PVirtualNode;
var
  LNode: PVirtualNode;
  LData: PNodeData;
begin
  Result := nil;
  LNode := ProjectTree.GetFirstChild(ProjectTree.GetFirst());
  while Assigned(LNode) do
  begin
    LData := ProjectTree.GetNodeData(LNode);
    if AEdit = TIdeUnit(LData.Item).SynEdit then
    begin
      Result := LNode;
      Break;
    end;
    LNode := ProjectTree.GetNextSibling(LNode);
  end;
end;

function TMainForm.GetTreeNodeByUnit(AUnit: TIDEUnit): PVirtualNode;
var
  LNode: PVirtualNode;
begin
  Result := nil;
  LNode := ProjectTree.GetFirstChild(ProjectTree.GetFirst());
  while Assigned(LNode) do
  begin
    if TIdeUnit(PNodeData(ProjectTree.GetNodeData(LNode)).Item) = AUNit then
    begin
      Result := LNode;
      Break;
    end;
    LNode := ProjectTree.GetNextSibling(LNode);
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
  end;
  Log.Refresh;
end;

procedure TMainForm.OpenProject(AFile: string);
var
  LDoc: IXMLDocument;
  LNode, LRoot: IXMLNode;
  i: Integer;
  LPath: string;
  LPNode: PVirtualNode;
begin
  ClearProjects();
  LDoc := TXMLDocument.Create(nil);
  LDoc.Active := True;
  LDoc.LoadFromFile(AFile);
  LRoot := LDoc.ChildNodes.First;
  FProject := TProject.Create();
  FProject.ProjectName := ChangeFileExt(LRoot.Attributes['Name'], '.d16p');
  FProject.ProjectPath := ExtractFilePath(AFile);
  LPNode := ProjectTree.AddChild(nil);
  PNodeData(ProjectTree.GetNodeData(LPNode)).Item := FProject;
  for i := 0 to LRoot.ChildNodes.Count - 1 do
  begin
    LNode := LRoot.ChildNodes.Nodes[i];
    LPath := LNode.Attributes['Path'];
    AddPage(ExtractFileName(LPath), LPath);
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
  LNode: PVirtualNode;
  LData: PNodeData;
begin
  GetCursorPos(LPos);
  LPos := ProjectTree.ScreenToClient(LPos);
  LNode := ProjectTree.GetNodeAt(LPos.X, LPos.Y);
  if Assigned(LNode) then
  begin
    if LNode = ProjectTree.GetFirst() then
    begin
      Exit;
    end;
    LData := ProjectTree.GetNodeData(LNode);
    if Assigned(LData) then
    begin
      if not TIdeUnit(LData.Item).IsOpen then
      begin
        AddPage(TIdeUnit(LData.Item).Caption, TIdeUnit(LData.Item).SavePath, TIdeUnit(LData.Item));
      end;
      PageControl.ActivePageIndex := GetTabIndexBySynEdit(TIdeUnit(LData.Item).SynEdit);
    end;
  end;
end;

procedure TMainForm.ProjectTreeGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
//  ImageIndex := PNodeData(Sender.GetNodeData(Node)).ImageIndex;
end;

procedure TMainForm.ProjectTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  LUnit: TIdeUnit;
begin
  if Node = ProjectTree.GetFirst() then
  begin
    CellText := FProject.ProjectName;
  end
  else
  begin
    LUnit := TIdeUnit(PNodeData(ProjectTree.GetNodeData(Node)).Item);
    if Assigned(LUnit) then
    begin
      CellText := LUnit.Caption;
    end;
  end;
end;

procedure TMainForm.SaveProject(AFile: string);
var
  LDoc: IXMLDocument;
  LRootNode, LSubNode: iXMLNode;
  LNode: PVirtualNode;
  LData: PNodeData;
begin
  LDoc := TXMLDocument.Create(nil);
  LDoc.Active := True;
  LRootNode := LDoc.AddChild('Project');
  LRootNode.Attributes['Name'] := ChangeFileExt(ExtractFileName(AFile), '');
  LNode := ProjectTree.GetFirstChild(ProjectTree.GetFirst());
  while Assigned(LNode) do
  begin
    LData := ProjectTree.GetNodeData(LNode);
    LSubNode := LRootNode.AddChild('Unit');
    LSubNode.Attributes['Path'] := TIDEUnit(LData.Item).SavePath;
    LNode := ProjectTree.GetNextSibling(LNode);
  end;
  LDoc.SaveToFile(AFile);
end;

procedure TMainForm.SaveUnit(AUnit: TIDEUnit);
begin
  if AUnit.SavePath = '' then
  begin
    if SaveUnitDialog.Execute() then
    begin
      AUnit.SavePath := SaveUnitDialog.FileName;
      if SameText(ExtractFileExt(AUnit.SavePath), '') then
      begin
        AUnit.SavePath := AUnit.SavePath + '.pas';
      end;
      AUnit.Caption := ExtractFileName(AUnit.SavePath);
    end
    else
    begin
      Exit;
    end;
  end;
  if SameText(ExtractFileExt(AUnit.SavePath), '') then
  begin
    AUnit.SavePath := AUnit.SavePath + '.pas';
  end;
  ChangeUnitHeader(AUnit.SynEdit, ChangeFileExt(AUnit.Caption, ''), ChangeFileExt(ExtractFileName(AUnit.SavePath),''));
  AUnit.Caption := ExtractFileName(AUnit.SavePath);
  AUnit.SaveToFile(AUnit.SavePath);
end;

end.
