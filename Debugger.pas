unit Debugger;

interface

uses
  Classes, Types, SysUtils, Generics.Collections, UnitMapping, BreakPoint;

type
  TDebugger = class
  private
    FMappings: TObjectList<TUnitMapping>;
    procedure ClearMappings();
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Clear();
    procedure LoadMappingFromFile(AFile: string);
    procedure AddBreakPoint(AUnit: string; AUnitLine: Integer);
    procedure DeleteBreakPoint(AUnit: string; AUnitLine: Integer);
    function GetUnitMapping(AUnit: string): TUnitMapping;
  end;

implementation

uses
  LineMapping;

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
  inherited;
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
        LMapping := TLineMapping.Create();
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

end.
