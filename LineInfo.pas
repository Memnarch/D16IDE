unit LineInfo;

interface

uses
  Classes, Types, LineMapping, BreakPoint;

type
  TLineState = (ltNone, ltModified, ltSaved);

  TLineInfo = class
  private
    FState: TLineState;
    FMapping: TLineMapping;
    FBreakPointState: TBreakPointState;
    function GetIsPossibleBreakPoint: Boolean;
  public
    constructor Create(AState: TLineState);
    destructor Destroy(); override;
    property State: TLineState read FState write FState;
    property Mapping: TLineMapping read FMapping;
    property IsPossibleBreakPoint: Boolean read GetIsPossibleBreakPoint;
    property BreakPointState: TBreakPointState read FBreakPointState write FBreakPointState;
  end;

implementation

uses
  VarMapping;

{ TLineInfo }

{ TLineInfo }

constructor TLineInfo.Create(AState: TLineState);
begin
  FState := AState;
  FMapping := TLineMapping.Create();
end;

destructor TLineInfo.Destroy;
begin
  FMapping.Free;
  inherited;
end;

function TLineInfo.GetIsPossibleBreakPoint: Boolean;
begin
  Result := FMapping.IsPossibleBreakPoint and (FMapping.MemoryAddress >= 0);
end;

end.
