unit IDEActionModule;

interface

uses
  SysUtils, Classes, Dialogs, ImgList, Controls, ActnList, IDEController, IDEModule, Menus;

type
  TIDEActions = class(TDataModule)
    ActionList: TActionList;
    actNewUnit: TAction;
    actCloseUnitByTab: TAction;
    actSaveActive: TAction;
    actSaveActiveAs: TAction;
    actSaveAll: TAction;
    actSaveProjectAs: TAction;
    actNewProject: TAction;
    actCompile: TAction;
    actOpenProject: TAction;
    actAddExistingUnit: TAction;
    actProjectOptions: TAction;
    actPeekCompile: TAction;
    actRun: TAction;
    actStop: TAction;
    actExit: TAction;
    actPause: TAction;
    actStep: TAction;
    actStepOver: TAction;
    actStepUntilReturn: TAction;
    actCopy: TAction;
    actCut: TAction;
    actPaste: TAction;
    actUndo: TAction;
    actRedo: TAction;
    actFind: TAction;
    actReplace: TAction;
    procedure actNewUnitExecute(Sender: TObject);
    procedure actCloseUnitByTabExecute(Sender: TObject);
    procedure actSaveActiveExecute(Sender: TObject);
    procedure actSaveActiveAsExecute(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure actSaveProjectAsExecute(Sender: TObject);
    procedure actNewProjectExecute(Sender: TObject);
    procedure actCompileExecute(Sender: TObject);
    procedure actOpenProjectExecute(Sender: TObject);
    procedure actAddExistingUnitExecute(Sender: TObject);
    procedure actProjectOptionsExecute(Sender: TObject);
    procedure actPeekCompileExecute(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure actPauseExecute(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    procedure actRedoExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
  private
    FController: TIDEController;
    FIDEData: TIDEData;
    procedure SetIDEData(const Value: TIDEData);
    { Private declarations }
  public
    { Public declarations }
    property Controller: TIDEController read FController write FController;
    property IDEData: TIDEData read FIDEData write SetIDEData;
  end;

implementation

uses
  PascalUnit, ProjectOptionDialog, IDEPageFrame, IDEUnit;

{$R *.dfm}

{ TIDEData }

procedure TIDEActions.actAddExistingUnitExecute(Sender: TObject);
begin
  if FIDEData.OpenUnitDialog.Execute then
  begin
    FController.AddPage(ExtractFileName(FIDEData.OpenUnitDialog.FileName), FIDEData.OpenUnitDialog.FileName);
  end;
end;

procedure TIDEActions.actCloseUnitByTabExecute(Sender: TObject);
begin
  FController.ClosePage(FIDEData.TabPopUp.Tag);
end;

procedure TIDEActions.actCompileExecute(Sender: TObject);
begin
  actSaveAll.Execute();
  actCompile.Tag := Integer(False);
  if Boolean(actSaveAll.Tag) then
  begin
    FController.Compile();
    actCompile.Tag := Integer(True);
  end;
end;

procedure TIDEActions.actCopyExecute(Sender: TObject);
begin
  FController.Copy;
end;

procedure TIDEActions.actCutExecute(Sender: TObject);
begin
  FController.Cut;
end;

procedure TIDEActions.actExitExecute(Sender: TObject);
begin
  //Self.Close;
end;

procedure TIDEActions.actFindExecute(Sender: TObject);
begin
  FController.Search();
end;

procedure TIDEActions.actNewProjectExecute(Sender: TObject);
var
  LName: string;
begin
  if FIDEData.SaveProjectDialog.Execute then
  begin
    LName := ChangeFileExt(FIDEData.SaveProjectDialog.FileName, '.d16p');
    FController.CreateNewProject(ExtractFileName(LName), ExtractFilePath(LName));
  end;
end;

procedure TIDEActions.actNewUnitExecute(Sender: TObject);
begin
  FController.NewUnit();
end;

procedure TIDEActions.actOpenProjectExecute(Sender: TObject);
begin
  if FIDEData.OpenProjectDialog.Execute then
  begin
    FController.OpenProject(FIDEData.OpenProjectDialog.FileName);
  end;
end;

procedure TIDEActions.actPasteExecute(Sender: TObject);
begin
  FController.Paste;
end;

procedure TIDEActions.actPauseExecute(Sender: TObject);
begin
  FController.Pause;
  actRun.Enabled := True;
  actPause.Enabled := False;
end;

procedure TIDEActions.actPeekCompileExecute(Sender: TObject);
begin
  FController.PeekCompile();
end;

procedure TIDEActions.actProjectOptionsExecute(Sender: TObject);
var
  LDialog: TProjectOption;
begin
  LDialog := TProjectOption.Create(nil);
  LDialog.LoadFromProject(FController.Project);
  if LDialog.ShowModal = mrOk then
  begin
    LDialog.SaveToProject(FController.Project);
  end;
end;

procedure TIDEActions.actRedoExecute(Sender: TObject);
begin
  FController.Redo;
end;

procedure TIDEActions.actRunExecute(Sender: TObject);
begin
  if not FController.IsRunning then
  begin
    actCompile.Execute();
  end;
  if (FController.Errors = 0) and (FController.Project.Assemble) and Boolean(actCompile.Tag) then
  begin
    actCompile.Enabled := False;
    actRun.Enabled := False;
    actStop.Enabled := True;
    actPause.Enabled := True;
    FController.Run();
  end;
end;

procedure TIDEActions.actSaveActiveAsExecute(Sender: TObject);
var
  LPage: TIDEPage;
begin
  LPage := FController.GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    FIDEData.SaveUnitDialog.InitialDir := ExtractFilePath(LPage.IDEUnit.SavePath);
    if FIDEData.SaveUnitDialog.Execute() then
    begin
      LPage.IDEUnit.SavePath := ExtractFilePath(FIDEData.SaveUnitDialog.FileName);
      LPage.IDEUnit.Caption := ChangeFileExt(ExtractFileName(FIDEData.SaveUnitDialog.FileName), '');
      FController.SaveUnit(LPage.IDEUnit);
    end;
  end;
end;

procedure TIDEActions.actSaveActiveExecute(Sender: TObject);
var
  LPage: TIDEPage;
begin
  LPage := FController.GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    FController.SaveUnit(LPage.IDEUnit);
  end;
end;

procedure TIDEActions.actSaveAllExecute(Sender: TObject);
var
  LUnit: TIDEUnit;
begin
  actSaveAll.Tag := Integer(False);
  for LUnit in FController.Project.Units do
  begin
    if not FController.SaveUnit(LUnit) then
    begin
      Exit;
    end;
  end;
  if FController.SaveProject(FController.Project) then
  begin
    actSaveAll.Tag := Integer(True);
  end;
end;

procedure TIDEActions.actSaveProjectAsExecute(Sender: TObject);
begin
  FController.Project.ProjectPath := '';
  FController.SaveProject(FController.Project);
end;

procedure TIDEActions.actStopExecute(Sender: TObject);
begin
  FController.Stop();
  actCompile.Enabled := True;
  actRun.Enabled := True;
  actStop.Enabled := False;
  actPause.Enabled := False;
end;

procedure TIDEActions.actUndoExecute(Sender: TObject);
begin
  FController.Undo;
end;

procedure TIDEActions.DataModuleCreate(Sender: TObject);
begin
  actSaveAll.ShortCut := ShortCut(Ord('S'), [ssCtrl, ssShift]);
end;

procedure TIDEActions.SetIDEData(const Value: TIDEData);
begin
  FIDEData := Value;
  FIDEData.Close1.Action := actCloseUnitByTab;
  FIDEData.NewUnit1.Action := actNewUnit;
  FIDEData.AddUnit1.Action := actAddExistingUnit;
  FIDEData.Options2.Action := actProjectOptions;
end;

end.
