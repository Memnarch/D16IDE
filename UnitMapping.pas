unit UnitMapping;

interface

uses
  Classes, Types, Generics.Collections, LineMapping, BreakPoint;

type
  TUnitMapping = class
  private
    FD16UnitName: string;
    FMapping: TObjectList<TLineMapping>;
    FBreakPoints: TObjectList<TBreakPoint>;
  public
    constructor Create();
    destructor Destroy(); override;
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
end;

destructor TUnitMapping.Destroy;
begin
  FMapping.Free;
  FBreakPoints.Free;
  inherited;
end;

end.
