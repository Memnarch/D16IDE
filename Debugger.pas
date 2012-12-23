unit Debugger;

interface

uses
  Classes, Types, SysUtils, Generics.Collections, UnitMapping,LineMapping, BreakPoint, Emulator,
  EmuTypes, RoutineMapping;

type
  TStepEvent = procedure(AMapping: TLineMapping; ARoutine: TRoutineMapping) of object;
  TStepMode = (smNone, smTraceInto, smStepOver, smRunUntilReturn);

  TDebugger = class
  private
    FMappings: TObjectList<TUnitMapping>;
    FEmulator: TD16Emulator;
    FLastLine: Integer;
    FOnStep: TStepEvent;
    FMode : TStepMode;
    //original events
    FHookedRun: TEvent;
    FHookedPause: TEvent;
    FHookedStep: TEvent;
    FHookedCall: TEvent;
    FHookedReturn: TEvent;
    FHookedAlert: TAlertEvent;
    FCallLevel: Integer;
    FCurrentCallLevel: Integer;
    FCallStack: TStack<Word>;
    FRoutineMapping: TRoutineMapping;
    procedure ClearMappings();
    procedure HandleOnRun();
    procedure HandleOnPause();
    procedure HandleOnStep();
    procedure HandleCall();
    procedure HandleReturn();
    procedure HandleOnAlert(var APauseExecution: Boolean);
    procedure ValidateAllBreakpoints();
    procedure InjectAllBreakPoints();
    procedure DoOnStep(AMapping: TLineMapping; ARoutine: TRoutineMapping);
    function GetBreakPointByAddress(AAddress: Word): TBreakPoint;
    function GetLineMappingByAddress(AAddress: Word): TLineMapping;
    function GetRoutineMappingByAddress(AAddress: Word): TRoutineMapping;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Clear();
    procedure HookEmulator(AEmulator: TD16Emulator);
    procedure UnHookEmulator();
    procedure LoadMappingFromFile(AFile: string);
    procedure AddBreakPoint(AUnit: string; AUnitLine: Integer);
    procedure DeleteBreakPoint(AUnit: string; AUnitLine: Integer);
    procedure TraceInto();
    procedure StepOver();
    procedure RunUntilReturn();
    function GetUnitMapping(AUnit: string): TUnitMapping;
    function ReadWord(AAddress: Word): Word;
    function ReadRegister(AIndex: Byte): Word;
    property OnStep: TStepEvent read FOnStep write FOnStep;
  end;

implementation

uses
  VarMapping;

{ TDebugger }

procedure TDebugger.AddBreakPoint(AUnit: string; AUnitLine: Integer);
var
  LBreak: TBreakPoint;
begin
  LBreak := TBreakPoint.Create();
  try
    LBreak.UnitLine := AUnitLine;
    LBreak.Memory := -1;
    LBreak.State := bpsNormal;
    LBreak.D16UnitName := AUnit;
  finally
    GetUnitMapping(AUnit).BreakPoints.Add(LBreak);
  end;
end;

procedure TDebugger.Clear;
begin
  FMappings.Clear();
end;

procedure TDebugger.ClearMappings;
var
  LMapping: TUnitMapping;
begin
  for LMapping in FMappings do
  begin
    LMapping.Mapping.Clear;
  end;
end;

constructor TDebugger.Create;
begin
  FMappings := TObjectList<TUnitMapping>.Create();
  FCallStack := TStack<Word>.Create();
end;

procedure TDebugger.DeleteBreakPoint(AUnit: string; AUnitLine: Integer);
var
  LUnitMapping: TUnitMapping;
  i: Integer;
begin
  LUnitMapping := GetUnitMapping(AUnit);
  for i := LUnitMapping.BreakPoints.Count - 1 downto 0 do
  begin
    if LUnitMapping.BreakPoints.Items[i].UnitLine = AUnitLine then
    begin
      LUnitMapping.BreakPoints.Delete(i);
      Break;
    end;
  end;
end;

destructor TDebugger.Destroy;
begin
  FMappings.Free;
  FCallStack.Free;
  inherited;
end;

procedure TDebugger.DoOnStep(AMapping: TLineMapping; ARoutine: TRoutineMapping);
begin
  FMode := smNone;
  if Assigned(FOnStep) then
  begin
    FOnStep(AMapping, ARoutine);
  end;
end;

function TDebugger.GetBreakPointByAddress(AAddress: Word): TBreakPoint;
var
  LUnitMap: TUnitMapping;
  LBreak: TBreakPoint;
begin
  Result := nil;
  for LUnitMap in FMappings do
  begin
    for LBreak in LUnitMap.BreakPoints do
    begin
      if LBreak.Memory = AAddress then
      begin
        Result := LBreak;
        Break;
      end;
    end;
  end;
end;

function TDebugger.GetLineMappingByAddress(AAddress: Word): TLineMapping;
var
  LUnitMap: TUnitMapping;
  LLine: TLineMapping;
begin
  Result := nil;
  for LUnitMap in FMappings do
  begin
    for LLine in LUnitMap.Mapping do
    begin
      if LLine.MemoryAddress = AAddress then
      begin
        Result := LLine;
        Break;
      end;
    end;
  end;
end;

function TDebugger.GetRoutineMappingByAddress(AAddress: Word): TRoutineMapping;
var
  LUnitMap: TUnitMapping;
  LLine: TLineMapping;
begin
  Result := nil;
  for LUnitMap in FMappings do
  begin
    for LLine in LUnitMap.Mapping do
    begin
      if (LLine.MemoryAddress = AAddress) and (LLine is TRoutineMapping) then
      begin
        Result := TRoutineMapping(LLine);
        Break;
      end;
    end;
  end;
end;

function TDebugger.GetUnitMapping(AUnit: string): TUnitMapping;
var
  LUnit: TUnitMapping;
begin
  Result := nil;
  for LUnit in FMappings do
  begin
    if SameText(LUnit.D16UnitName, AUnit) then
    begin
      Result := LUnit;
      Break;
    end;
  end;
  if not Assigned(Result) then
  begin
    Result := TUnitMapping.Create();
    FMappings.Add(Result);
    Result.D16UnitName := AUnit;
  end;
end;

procedure TDebugger.HandleCall;
begin
  if Assigned(FHookedCall) then
  begin
    FHookedCall();
  end;
  FCallStack.Push(FEmulator.Registers[CRegPC]);
  FRoutineMapping := GetRoutineMappingByAddress(FCallStack.Peek);
  Inc(FCallLevel);
end;

procedure TDebugger.HandleOnAlert(var APauseExecution: Boolean);
var
  LBreak: TBreakPoint;
begin
  if Assigned(FHookedAlert) then
  begin
    FHookedAlert(APauseExecution);
  end;
  LBreak := GetBreakPointByAddress(FEmulator.Registers[CRegPC]);
  if Assigned(LBreak) and (LBreak.UnitLine <> FLastLine) then
  begin
    APauseExecution := True;
  end;
end;

procedure TDebugger.HandleOnPause;
var
  LMapping: TLineMapping;
begin
  if Assigned(FHookedPause) then
  begin
    FHookedPause();
  end;
  FHookedStep := FEmulator.OnStep;
  FEmulator.OnStep := HandleOnStep;
  LMapping := GetLineMappingByAddress(FEmulator.Registers[CRegPC]);
  if Assigned(LMapping) then
  begin
    DoOnStep(LMapping, FRoutineMapping);
  end
  else
  begin
    TraceInto(); //we resume emulation until we find a fitting mapping spot
  end;
end;

procedure TDebugger.HandleOnRun;
begin
  if Assigned(FHookedRun) then
  begin
    FHookedRun();
  end;
  if (FMode <> smTraceInto) and (FMode <> smStepOver) then
  begin
    FEmulator.OnStep := nil;
  end;
  if FCallStack.Count > 0 then
  begin
    FRoutineMapping := GetRoutineMappingByAddress(FCallStack.Peek);
  end
  else
  begin
    FRoutineMapping := nil;
  end;
  FLastLine := -1;
end;

procedure TDebugger.HandleOnStep;
var
  LMapping: TLineMapping;
begin
  if (FMode = smStepOver) then
  begin
    if (FCallLevel > FCurrentCallLevel) then
    begin
      Exit;
    end;
  end;
  LMapping := GetLineMappingByAddress(FEmulator.Registers[CRegPC]);
  if Assigned(LMapping) and (LMapping.UnitLine <> FLastLine) then
  begin
    FLastLine := LMapping.UnitLine;
    FEmulator.Pause();
  end;
end;

procedure TDebugger.HandleReturn;
begin
  if Assigned(FHookedReturn) then
  begin
    FHookedReturn();
  end;
  Dec(FCallLevel);
  FCallStack.Pop;
  if FCallStack.Count > 0 then
  begin
    FRoutineMapping := GetRoutineMappingByAddress(FCallStack.Peek);
  end
  else
  begin
    FRoutineMapping := nil;
  end;
  if (FMode = smRunUntilReturn) then
  begin
    FEmulator.Pause();
  end;
end;

procedure TDebugger.HookEmulator(AEmulator: TD16Emulator);
begin
  FEmulator := AEmulator;
  FHookedRun := FEmulator.OnRun;
  FHookedPause := FEmulator.OnPause;
  FHookedCall := FEmulator.OnCall;
  FHookedReturn := FEmulator.OnReturn;
  FHookedAlert := FEmulator.OnAlert;
  FEmulator.OnPause := HandleOnPause;
  FEmulator.OnRun := HandleOnRun;
  FEmulator.OnAlert := HandleOnAlert;
  FEmulator.OnCall := HandleCall;
  FEmulator.OnReturn := HandleReturn;
  FCallLevel := 0;
  InjectAllBreakPoints();
end;

procedure TDebugger.InjectAllBreakPoints;
var
  LBreak: TBreakPoint;
  LUnitMap: TUnitMapping;
begin
  ValidateAllBreakpoints();
  for LUnitMap in FMappings do
  begin
    for LBreak in LUnitMap.BreakPoints do
    begin
      if LBreak.Memory > -1 then
      begin
        FEmulator.SetAlertPoint(LBreak.Memory, True);
      end;
    end;
  end;
end;

procedure TDebugger.LoadMappingFromFile(AFile: string);
var
  LFile: TStringList;
  LUnit: TUnitMapping;
  LMapping: TLineMapping;
  LLine: string;
begin
  ClearMappings();
  LFile := TStringList.Create();
  try
    LFile.LoadFromFile(AFile);
    for LLine in LFile do
    begin
      try
        if Pos('%', LLine) > 1  then
        begin
          LMapping := TRoutineMapping.Create();
        end
        else
        begin
          if Pos('#', LLine) > 1 then
          begin
            LMapping := TVarMapping.Create();
          end
          else
          begin
            LMapping := TLineMapping.Create();
          end;
        end;
        LMapping.ReadFromLine(LLine);
      finally
        LUnit := GetUnitMapping(LMapping.D16UnitName);
        LUnit.Mapping.Add(LMapping);
      end;
    end;
  finally
    LFile.Free;
  end;
end;

function TDebugger.ReadRegister(AIndex: Byte): Word;
begin
  Result := FEmulator.Registers[AIndex];
end;

function TDebugger.ReadWord(AAddress: Word): Word;
begin
  Result := FEmulator.Ram[AAddress];
end;

procedure TDebugger.RunUntilReturn;
begin
  FMode := smRunUntilReturn;
  FEmulator.Run;
end;

procedure TDebugger.StepOver;
begin
  FMode := smStepOver;
  FCurrentCallLevel := FCallLevel;
  FEmulator.Run;
end;

procedure TDebugger.TraceInto;
begin
  FMode := smTraceInto;
  FEmulator.Run();
end;

procedure TDebugger.UnHookEmulator;
begin
  FEmulator.OnPause := FHookedPause;
  FEmulator.OnRun := FHookedRun;
  FEmulator.OnAlert := FHookedAlert;
  FEmulator.OnCall := FHookedCall;
  FEmulator.OnReturn := FHookedReturn;
  FEmulator := nil;
end;

procedure TDebugger.ValidateAllBreakpoints;
var
  LUnitMap: TUnitMapping;
  LLine: TLineMapping;
  LBreak: TBreakPoint;
begin
  for LUnitMap in FMappings do
  begin
    for LBreak in LUnitMap.BreakPoints do
    begin
      LBreak.Memory := -1;
      LLine := LUnitMap.GetLineMappingByUnitLine(LBreak.UnitLine);
      if Assigned(LLine) then
      begin
        LBreak.Memory := LLine.MemoryAddress;
      end;
      if LBreak.Memory > -1 then
      begin
        LBreak.State := bpsAccepted;
      end
      else
      begin
        LBreak.State := bpsDenied;
      end;
    end;
  end;
end;

end.
