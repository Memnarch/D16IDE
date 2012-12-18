unit BreakPoint;

interface

uses
  Classes, Types;

type
  TBreakPointState = (bpsNone, bpsNormal, bpsAccepted, bpsDenied, bpsDisabled);

  TBreakPoint = class
  private
    FMemory: Integer;
    FState: TBreakPointState;
    FUnitLine: Integer;
  public
    property UnitLine: Integer read FUnitLine write FUnitLine;
    property Memory: Integer read FMemory write FMemory;
    property State: TBreakPointState read FState write FState;
  end;

implementation

end.
