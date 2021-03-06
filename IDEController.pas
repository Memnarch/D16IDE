unit IDEController;

interface

uses
  Classes, Types, Windows, Forms, SysUtils, Generics.Collections, VirtualTrees, JvComCtrls, WatchViewForm, CPUViewForm, Project, CompilerDefines,
  Compiler, Emulator, IDEPageFrame, IDEModule,
  ProjectTreeController, CodeTreeController, IDEUnit, SynCompletionProposal, Debugger, LineMapping,
  RoutineMapping, CodeElement, LogTreeController, IDELayout, IDEControllerIntf,
  ProjectEvents, EventGroups, CurrentUnitEvents, PascalUnit, CompilerEvents, EVents;

type
  TControllerState = (csStopped, csRunning, csPaused);

  TStateChangeEvent = procedure(AState: TControllerState) of object;

  TIDEController = class(TInterfacedPersistent, IIDEController)
  private
    FLayout: TIDELayout;
    FProject: TProject;
    FID: Integer;
    FPeekCompiler: TCompiler;
    FLastPeek: TDateTime;
    FPageControl: TJvPageControl;
    FSynCompletionProposal: TSynCompletionProposal;
    FEmulator: TD16Emulator;
    FErrors: Cardinal;
    FDebugger: TDebugger;
    FIDEData: TIDEData;
    FOnChange: TStateChangeEvent;
  //EventData-Objects
    FEvent: TEventData;
    FProjectEvent: TProjectEvenetData;
    FCurrentUnitEvent: TCurrentUnitEventData;
    FCompilerMessageEvent: TCompilerMessageEventData;
  //events
    procedure UpdateAllMappings();
    procedure PageControlChange(Sender: TObject);
    function GetIsRunning: Boolean;
    procedure SetIDEData(const Value: TIDEData);
    procedure ResetAllDebugCursors();
    procedure HandleAddBreakPoint(AUnit: string; ALine: Integer);
    procedure HandleDeleteBreakPoint(AUnit: string; ALine: Integer);
    procedure HandleOnDebugStep(AMapping: TLineMapping; ARoutine: TRoutineMapping);
    procedure HandleOnRun();
    procedure HandleOnPause();
    procedure DoOnChange(AState: TControllerState);
    procedure BuildCompletionListForElements(ACompletion, AInsert: TStrings; AElements: TObjectList<TCodeElement>; AIgnoreDummyProcs: Boolean; ACaretY: Integer = -1);
  //event-triggers
    procedure ProjectChanged(AProject: TProject);
    procedure UnitCacheChanged(AUnit: TPascalUnit);
    procedure CompilerMessage(AMessage, AUnitName: string; ALine: Integer; ALevel: TMessageLevel);
    procedure CompileStart();
    procedure CompileFinished();
  public
    constructor Create(AOwner: TForm; APageControl: TJvPageControl; ACompletionProposal: TSynCompletionProposal); reintroduce;
    destructor Destroy(); override;

    function SaveUnit(AUnit: TIDEUnit): Boolean;
    function GetTabIndexBelowCursor(): Integer;
    function SaveProject(AProject: TProject): Boolean;
    procedure AddPage(ATitle: string; AFile: string = ''; AUnit: TIDEUnit = nil);
    function ClosePage(AIndex: Integer): Boolean;
    procedure CreateNewProject(ATitle: string; AProjectFolder: string);
    procedure ClearProjects();
    procedure OpenProject(AFile: string);
    procedure HandleCompileMessage(AMessage, AUnitName: string; ALine: Integer; ALevel: TMessageLevel);
    procedure HandleSynEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BuildCompletionLists(ACompletion, AInsert: TStrings);
    function FormatCompletPropString(ACategory, AIdentifier, AType: string): string;
    function GetActiveIDEPage(): TIDEPage;
    procedure HandleEmuMessage(AMessage: string);
    function IDEUnitIsOpen(AUnit: TIDEUnit): Boolean;
    function GetPageIndexForIdeUnit(AUnit: TIDEUnit): Integer;
    procedure FokusIDEPageByUnit(AUnit: TIDEUnit);
    procedure FokusIDEEdit(AUnitName: string; ADebugCursor: Integer = -1; AErrorCursor: Integer = -1);
    procedure NewUnit();
    procedure Compile();
    procedure PeekCompile();
    procedure Run();
    procedure Stop();
    procedure Pause();
    procedure Undo();
    procedure Redo();
    procedure Cut();
    procedure Copy();
    procedure Paste();
    procedure Search();
    procedure FindNext();
    procedure FindPrevious();
    procedure TraceInto();
    procedure StepOver();
    procedure RunUntilReturn();
    property Project: TProject read FProject;
    property Errors: Cardinal read FErrors;
    property IsRunning: Boolean read GetIsRunning;
    property IDEData: TIDEData read FIDEData write SetIDEData;
    property Layout: TIDELayout read FLayout;
    property OnChange: TStateChangeEvent read FOnChange write FOnChange;
  end;

implementation

uses
  DateUtils, IDETabSheet, DataType, VarDeclaration, ProcDeclaration,
  CompilerUtil, xmldom, XMLIntf, msxmldom, XMLDoc, ComCtrls, UnitTemplates, UnitMapping;

{ TIDEController }

procedure TIDEController.AddPage(ATitle, AFile: string; AUnit: TIDEUnit);
var
  LPage: TIDETabSheet;
  LUnit: TIDEUnit;
begin
  LPage := TIDETabSheet.Create(FPageControl, FPageControl);
  if Assigned(FIDEData) then
  begin
    LPage.IDEPage.IDEIcons := FIDEData.IDEImages;
  end;
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
  LPage.IDEPage.IDEEdit.OnAddBreakPoint := HandleAddBreakPoint;
  LPage.IDEPage.IDEEdit.OnDeleteBreakPoint := HandleDeleteBreakPoint;
  if not Assigned(AUnit)  then
  begin
    if AFile = '' then
    begin
      LUnit.Caption := ATitle;
    end
    else
    begin
      LUnit.FileName := AFile;
    end;
  end;

  if ((AFile <> '') or Assigned(AUnit)) and FileExists(LUnit.FileName)  then
  begin
    LUnit.Load();
  end;
  LUnit.ImageIndex := 1;
  if not Assigned(AUnit) then
  begin
    FProject.Units.Add(LUnit);
  end;
  LPage.IDEPage.IDEEdit.UpdateMapping(FDebugger.GetUnitMapping(LUnit.Caption));
  FokusIDEPageByUnit(LUnit);
end;

procedure TIDEController.BuildCompletionListForElements(ACompletion,
  AInsert: TStrings; AElements: TObjectList<TCodeElement>; AIgnoreDummyProcs: Boolean; ACaretY: Integer = -1);
var
  LElement, LParam: TCodeElement;
  LType, LCat, LIdentifier: string;
begin
  for LElement in AElements do
  begin
    LType := '';
    LCat := '';
    LIdentifier := LElement.Name;
    if LElement is TDataType then
    begin
      LCat := 'type';
    end
    else
    begin
      if LElement is TVarDeclaration then
      begin
        LCat := 'var';
        LType := ': ' + TVarDeclaration(LElement).DataType.Name;
      end
      else
      begin
        if (LElement is TProcDeclaration) and (not (TProcDeclaration(LElement).IsDummy and AIgnoreDummyProcs)) then
        begin
          if TProcDeclaration(LElement).IsFunction then
          begin
            LCat := 'function';
          end
          else
          begin
            LCat := 'procedure';
          end;
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
      end;
    end;
    if LCat <> '' then
    begin
      ACompletion.Add(FormatCompletPropString(LCat, LIdentifier, LType));
      AInsert.Add(LElement.Name);
      if LElement is TProcDeclaration then
      begin
        if (ACaretY >= TProcDeclaration(LElement).StartLine) and (ACaretY <= TProcDeclaration(LElement).EndLine) then
        begin
          for LParam in TProcDeclaration(LElement).Parameters do
          begin
            ACompletion.Add(FormatCompletPropString('param', LParam.Name, ': ' + TVarDeclaration(LParam).DataType.Name));
            AInsert.Add(LParam.Name);
          end;
          for LParam in TProcDeclaration(LElement).Locals do
          begin
            ACompletion.Add(FormatCompletPropString('var', LParam.Name, ': ' + TVarDeclaration(LParam).DataType.Name));
            AInsert.Add(LParam.Name);
          end;
        end;
      end;
    end;
  end;
end;

procedure TIDEController.BuildCompletionLists(ACompletion, AInsert: TStrings);
var
  LUnit, LActiveUnit: TPascalUnit;
  LUnitName: string;
begin
  ACompletion.Clear;
  AInsert.Clear;
  LUnitName := ChangeFileExt(GetActiveIDEPage().IDEUnit.Caption, '');
  LActiveUnit :=  FPeekCompiler.Units.GetUnitByName(LUnitName);
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
    if LUnit = LActiveUnit then
    begin
      BuildCompletionListForElements(ACompletion, AInsert, LUnit.ImplementationSection, False, GetActiveIDEPage().IDEEdit.CaretY);
      BuildCompletionListForElements(ACompletion, AInsert, LUnit.SubElements, True);
    end
    else
    begin
      BuildCompletionListForElements(ACompletion, AInsert, LUnit.SubElements, False);
    end;
  end;
end;

procedure TIDEController.ClearProjects;
var
  i: Integer;
begin
  FDebugger.Clear();
  ProjectChanged(nil);
  if Assigned(FProject) then
  begin
    FProject.Units.Clear;
    for i := FPageControl.PageCount - 1 downto 0 do
    begin
      FPageControl.Pages[i].Free;
    end;
    FProject.Free;
  end;
end;

function TIDEController.ClosePage(AIndex: Integer): Boolean;
var
  LPage: TIDETabSheet;
begin
  Result := False;
  LPage := TIDETabSheet(FPageControl.Pages[AIndex]);
  if not SaveUnit(LPage.IDEPage.IDEUnit) then
  begin
    if LPage.IDEPage.IDEUnit = FProject.ProjectUnit then
    begin
      MessageBox(0, 'Can not close Projectsource without saving it for the first time!', 'Hint', MB_ICONASTERISK);
      Exit;
    end;
    if MessageBox(0, 'Close without saving?', 'Warning', MB_YESNO or MB_ICONWARNING) = IDNO then
    begin
      Exit;
    end;
  end;
  LPage.IDEPage.IDEUnit.SourceLink := nil;
  LPage.IDEPage.IDEUnit.OnRename := nil;
  LPage.Free;
  Result := True;
end;

procedure TIDEController.Compile;
var
  LFileName: string;
begin
  CompileStart();
  FErrors := 0;
  CompileFile(FProject.ProjectUnit.FileName, FProject.Optimize, FProject.Assemble,
    FProject.BuildModule, FProject.UseBigEndian, HandleCompileMessage);
  LFileName := ExtractFilePath(FProject.ProjectUnit.FileName) + '\mapping.txt';
  if FileExists(LFileName) then
  begin
    FDebugger.LoadMappingFromFile(LFileName);
    UpdateAllMappings();
  end;
  CompileFinished();
end;

procedure TIDEController.CompileFinished;
begin
  FEvent.EventID := evFinishCompiling;
  FLayout.CallEvent(egCompiler, FEvent);
end;

procedure TIDEController.CompilerMessage(AMessage, AUnitName: string;
  ALine: Integer; ALevel: TMessageLevel);
begin
  FCompilerMessageEvent.EventID := evCompilerMessage;
  FCompilerMessageEvent.Message := AMessage;
  FCompilerMessageEvent.D16UnitName := AUnitName;
  FCompilerMessageEvent.Line := ALine;
  FCompilerMessageEvent.Level := ALevel;
  FLayout.CallEvent(egCompiler, FCompilerMessageEvent);
end;

procedure TIDEController.CompileStart;
begin
  FEvent.EventID := evStartCompiling;
  FLayout.CallEvent(egCompiler, FEvent);
end;

procedure TIDEController.Copy;
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    LPage.IDEEdit.CopyToClipboard;
  end;
end;

constructor TIDEController.Create;
begin
  inherited Create();
  FLayout := TIDELayout.Create(AOwner);
  FPageControl := APageControl;
  FPageControl.OnChange := PageControlChange;
  FDebugger := TDebugger.Create();
  FPeekCompiler := TCompiler.Create();
  FPeekCompiler.PeekMode := True;
  FSynCompletionProposal := ACompletionProposal;
  //FLog := TLogTreeController.Create(ALogTree);
  FLastPeek := Now();
  FID := 1;
  //creating EventDataObjects
  FEvent := TEventData.Create();
  FProjectEvent := TProjectEvenetData.Create();
  FCurrentUnitEvent := TCurrentUnitEventData.Create();
  FCompilerMessageEvent := TCompilerMessageEventData.Create();
end;

procedure TIDEController.CreateNewProject(ATitle, AProjectFolder: string);
begin
  ClearProjects();
  FProject := TProject.Create();
  FProject.ProjectPath := AProjectFolder;
  FProject.ProjectName := ChangeFileExt(ATitle,'.d16p');
  FPeekCompiler.Reset();
  AddPage(ChangeFileExt(FProject.ProjectName, ''), '', FProject.ProjectUnit);
  FProject.ProjectUnit.SourceLink.Text := CDefaultProgramUnit;
  FProject.ProjectUnit.Caption := ChangeFileExt(FProject.ProjectName, '');
  Inc(FID);
  PageControlChange(FPageControl);
  ProjectChanged(FProject);
end;

procedure TIDEController.Cut;
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    LPage.IDEEdit.CutToClipboard;
  end;
end;

destructor TIDEController.Destroy;
begin
  FDebugger.Free;
  FEvent.Free;
  FCurrentUnitEvent.Free;
  FProjectEvent.Free;
  FCompilerMessageEvent.Free;
  inherited;
end;

procedure TIDEController.DoOnChange(AState: TControllerState);
begin
  if Assigned(FOnChange) then
  begin
    FOnChange(AState);
  end;
end;

procedure TIDEController.FindNext;
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    LPage.FindNext();
  end;
end;

procedure TIDEController.FindPrevious;
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    LPage.FindPrevious();
  end;
end;

procedure TIDEController.FokusIDEEdit(AUnitName: string; ADebugCursor,
  AErrorCursor: Integer);
var
  LUnit: TIDEUnit;
begin
  LUnit := FProject.GetUnitByName(AUnitName);
  if Assigned(LUnit) then
  begin
    if LUnit.IsOpen then
    begin
      FokusIDEPageByUnit(LUnit);
    end
    else
    begin
      AddPage(LUnit.Caption, '', LUnit);
    end;
    GetActiveIDEPage().IDEEdit.DebugCursor := ADebugCursor;
    GetActiveIDEPage().IDEEdit.ErrorCursor := AErrorCursor;
  end;
end;

procedure TIDEController.FokusIDEPageByUnit(AUnit: TIDEUnit);
var
  i: Integer;
begin
  for i := 0 to FPageControl.PageCount - 1 do
  begin
    if AUnit = TIDETabSheet(FPageControl.Pages[i]).IDEPage.IDEUnit then
    begin
      FPageControl.ActivePageIndex := i;
      PageControlChange(FPageControl);
      Break;
    end;
  end;
end;

function TIDEController.FormatCompletPropString(ACategory, AIdentifier,
  AType: string): string;
begin
  Result := '\color{clNavy}' + ACategory + '\column{}\color{clBlack}\Style{+B}' + AIdentifier + '\Style{-B}' + AType;
end;

function TIDEController.GetActiveIDEPage: TIDEPage;
var
  LIDETab: TIDETabSheet;
begin
  Result := nil;
  LIDETab := TIDETabSheet(FPageControl.ActivePage);
  if Assigned(LIDETab) then
  begin
    Result := LIDETab.IDEPage;
  end;
end;

function TIDEController.GetIsRunning: Boolean;
begin
  Result := Assigned(FEmulator);
end;

function TIDEController.GetPageIndexForIdeUnit(AUnit: TIDEUnit): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FPageControl.PageCount - 1 do
  begin
    if AUnit = TIDETabSheet(FPageControl.Pages[i]).IDEPage.IDEUnit then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TIDEController.GetTabIndexBelowCursor: Integer;
var
  i: Integer;
  LPos: TPoint;
begin
  Result := -1;
  if FPageControl.PageCount <= 1 then
  begin
    Exit;
  end;
  GetCursorPos(LPos);
  LPos := FPageControl.ScreenToClient(LPos);
  for i := 0 to FPageControl.PageCount - 1 do
  begin
    if (LPos.X >= FPageControl.TabRect(i).Left) and (LPos.X <= FPageControl.TabRect(i).Right) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TIDEController.HandleAddBreakPoint(AUnit: string; ALine: Integer);
begin
  FDebugger.AddBreakPoint(AUnit, ALine);
end;

procedure TIDEController.HandleCompileMessage(AMessage, AUnitName: string;
  ALine: Integer; ALevel: TMessageLevel);
begin
  CompilerMessage(AMessage, AUnitName, ALine, ALevel);
  if not (ALevel in [mlNone, mlWarning]) then
  begin
    Inc(FErrors);
  end;
end;

procedure TIDEController.HandleDeleteBreakPoint(AUnit: string; ALine: Integer);
begin
  FDebugger.DeleteBreakPoint(AUnit, ALine);
end;

procedure TIDEController.HandleEmuMessage(AMessage: string);
begin
//  FLog.Add('Emulator: ' + AMessage, '', -1, mlNone);
end;

procedure TIDEController.HandleOnDebugStep(AMapping: TLineMapping; ARoutine: TRoutineMapping);
begin
  FokusIDEEdit(AMapping.D16UnitName, AMapping.UnitLine);
//  FWatchView.UpdateData(ARoutine);
//  FCpuView.UpdateData();
end;

procedure TIDEController.HandleOnPause;
begin
  DoOnChange(csPaused);
end;

procedure TIDEController.HandleOnRun;
begin
  ResetAllDebugCursors();
end;

procedure TIDEController.HandleSynEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if MilliSecondsBetween(FLastPeek, Now()) > 500 then
  begin
    PeekCompile();
    FLastPeek := Now();
  end;
end;

function TIDEController.IDEUnitIsOpen(AUnit: TIDEUnit): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FPageControl.PageCount - 1 do
  begin
    if TIDETabSheet(FPageControl.Pages[i]).IDEPage.IDEUnit = AUnit then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TIDEController.NewUnit;
begin
  AddPage('Unit' + IntToStr(FID));
  Inc(FID);
end;

procedure TIDEController.OpenProject(AFile: string);
var
  LPage: TIDEPage;
begin
  ClearProjects();
  FProject := TProject.Create();
  FProject.LoadFromFile(AFile);
  FPeekCompiler.Reset();
  FPeekCompiler.SearchPath.Add(FProject.ProjectPath);
  ProjectChanged(FProject);
  AddPage(FProject.ProjectUnit.Caption, '', FProject.ProjectUnit);
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    FSynCompletionProposal.Editor := LPage.IDEEdit;
  end;
end;

procedure TIDEController.PageControlChange(Sender: TObject);
var
  LPage: TIDEPage;
begin
  PeekCompile();
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    FSynCompletionProposal.Editor := LPage.IDEEdit;
  end;
end;

procedure TIDEController.Paste;
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    LPage.IDEEdit.PasteFromClipboard;
  end;
end;

procedure TIDEController.Pause;
begin
  if IsRunning then
  begin
    FEmulator.Pause();
  end;
end;

procedure TIDEController.PeekCompile;
var
  LUnit: TPascalUnit;
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    if FPeekCompiler.PeekCompile(LPage.IDEEdit.Text, LPage.IDEUnit.Caption, LPage.IDEUnit = FProject.ProjectUnit, LUnit) then
    begin
      UnitCacheChanged(LUnit);
    end;
  end;
end;

procedure TIDEController.ProjectChanged(AProject: TProject);
begin
  FProjectEvent.EventID := evProjectChanged;
  FProjectEvent.Project := AProject;
  FLayout.CallEvent(egProject, FProjectEvent);
end;

procedure TIDEController.Redo;
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    LPage.IDEEdit.Redo;
  end;
end;

procedure TIDEController.ResetAllDebugCursors;
var
  LTab: TIDETabSheet;
  i: Integer;
begin
  for i := 0 to FPageControl.PageCount - 1 do
  begin
    LTab := TIDETabSheet(FPageControl.Pages[i]);
    LTab.IDEPage.IDEEdit.DebugCursor := -1;
  end;
end;

procedure TIDEController.Run;
begin
  if not IsRunning then
  begin
//    FCPUView.LoadASMFromFile(ChangeFileExt(FProject.ProjectUnit.FileName, '.asm'));
//    FCPUView.Show;
//    FWatchView.Show;
//    FLog.Clear;
    FEmulator := TD16Emulator.Create();
    FEmulator.OnMessage := HandleEmuMessage;
    FEmulator.OnRun := HandleOnRun;
    FEmulator.OnPause := HandleOnPause;
//    FCpuView.SetEmulator(FEmulator);
//    FLog.Add('Running: ' + ExtractFileName(ChangeFileExt(FProject.ProjectUnit.FileName, '.d16')));
    FEmulator.LoadFromFile(ChangeFileExt(FProject.ProjectUnit.FileName, '.d16'), FProject.UseBigEndian);
    FDebugger.OnStep := HandleOnDebugStep;
    FDebugger.HookEmulator(FEmulator);
  end;
  DoOnChange(csRunning);
  FEmulator.Run();
end;

procedure TIDEController.RunUntilReturn;
begin
  FDebugger.RunUntilReturn();
end;

function TIDEController.SaveProject(AProject: TProject): Boolean;
begin
  Result := False;
  if (AProject.ProjectPath = '') or (AProject.ProjectName = '') then
  begin
    FIDEData.SaveProjectDialog.Title := 'Save ' +  AProject.ProjectName + ' as';
    if FIDEData.SaveProjectDialog.Execute then
    begin
      AProject.ProjectPath := ExtractFilePath(IDEData.SaveProjectDialog.FileName);
      AProject.ProjectName := ChangeFileExt(ExtractFileName(IDEData.SaveProjectDialog.FileName), '.d16p');
    end
    else
    begin
      Exit;
    end;
  end;
  AProject.SaveToFile(AProject.ProjectPath + '\' + AProject.ProjectName);
  Result := True;
end;

function TIDEController.SaveUnit(AUnit: TIDEUnit): Boolean;
var
  LOldUnitName: string;
begin
  Result := False;
  if AUnit = FProject.ProjectUnit then
  begin
    Result := SaveProject(FProject);
    Exit;
  end;
  LOldUnitName := AUnit.Caption;
  if AUnit.SavePath = '' then
  begin
    IDEData.SaveUnitDialog.Title := 'Save ' + AUnit.Caption + ' as';
    if IDEData.SaveUnitDialog.Execute() then
    begin
      AUnit.SavePath := ExtractFilePath(IDEData.SaveUnitDialog.FileName);
      AUnit.Caption := ChangeFileExt(ExtractFileName(IDEData.SaveUnitDialog.FileName), '');
    end
    else
    begin
      Exit;
    end;
  end;
  AUnit.Save();
  Result := True;
end;

procedure TIDEController.Search;
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    LPage.ShowSearch();
  end;
end;

procedure TIDEController.SetIDEData(const Value: TIDEData);
begin
  FIDEData := Value;
//  FProjectTreeController.Images := FIDEData.TreeImages;
//  FCodeTreeController.Images := FIDEData.CodeTreeImages;
//  FLog.Images := FIDEData.LogImages;
end;

procedure TIDEController.StepOver;
begin
  FDebugger.StepOver();
end;

procedure TIDEController.Stop;
begin
  if Assigned(FEmulator) then
  begin
    FDebugger.UnHookEmulator();
    FDebugger.OnStep := nil;
    FEmulator.Stop();//emulator terminates on stop
    Application.ProcessMessages();
    WaitForSingleObject(FEmulator.Handle, 5000);
    FEmulator.Free;
    FEmulator := nil;
  end;
//  FCPUView.Hide;
//  FWatchView.Hide;
  ResetAllDebugCursors();
  DoOnChange(csStopped);
end;

procedure TIDEController.TraceInto;
begin
  FDebugger.TraceInto();
end;

procedure TIDEController.Undo;
var
  LPage: TIDEPage;
begin
  LPage := GetActiveIDEPage();
  if Assigned(LPage) then
  begin
    LPage.IDEEdit.Undo();
  end;
end;

procedure TIDEController.UnitCacheChanged(AUnit: TPascalUnit);
begin
  FCurrentUnitEvent.EventID := evCurrentUnitCacheChanged;
  FCurrentUnitEvent.UnitCache := AUnit;
  FLayout.CallEvent(egCurrentUnit, FCurrentUnitEvent);
end;

procedure TIDEController.UpdateAllMappings;
var
  LTab: TIDETabSheet;
  i: Integer;
begin
  for i := 0 to FPageControl.PageCount - 1 do
  begin
    LTab := TIDETabSheet(FPageControl.Pages[i]);
    LTab.IDEPage.IDEEdit.UpdateMapping(FDebugger.GetUnitMapping(LTab.IDEPage.IDEUnit.Caption));
    LTab.IDEPage.IDEEdit.Repaint();
  end;
end;

end.

