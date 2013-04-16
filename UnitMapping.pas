unit UnitMapping;

interface

uses
  Classes, Types, Generics.Collections, LineMapping, BreakPoint;

type
  TUnitMapping = class
  private
    FD16UnitName: string;
    FNullLine: TLineMapping;
    FMapping: TObjectList<TLineMapping>;
    FBreakPoints: TObjectList<TBreakPoint>;
  public
    constructor Create();
    destructor Destroy(); override;
    function GetLineMappingByUnitLine(ALine: Integer): TLineMapping;
    property D16UnitName: string read FD16UnitName write FD16UnitName;
    property Mapping: TObjectList<TLineMapping> read FMapping;
    property BreakPoints: TObjectList<TBreakPoint> read FBreakPoints;
  end;

implementation

{ TUnitMapping }

constructor TUnitMapping.Create;
begin
  FMapping := TObjectList<TLineMapping>.Create();
  FBreakPoints := TObjectList<TBreakPoint>.Create();
  FNullLine := TLineMapping.Create();
end;

destructor TUnitMapping.Destroy;
begin
  FMapping.Free;
  FBreakPoints.Free;
  FNullLine.Free;
  inherited;
end;

function TUnitMapping.GetLineMappingByUnitLine(ALine: Integer): TLineMapping;
var
  LLine: TLineMapping;
begin
  Result := FNullLine;
  for LLine in FMapping do
  begin
    if LLine.UnitLine = ALine then
    begin
      Result := LLine;
      Break;
    end;
  end;
end;

end.
