unit Debugger;

interface

uses
  Classes, Types, SysUtils, Generics.Collections, UnitMapping;

type
  TDebugger = class
  private
    FMappings: TObjectList<TUnitMapping>;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure LoadMappingFromFile(AFile: string);
    function GetUnitMapping(AUnit: string): TUnitMapping;
  end;

implementation

uses
  LineMapping;

{ TDebugger }

constructor TDebugger.Create;
begin
  FMappings := TObjectList<TUnitMapping>.Create();
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
  FMappings.Clear();
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
