unit UnitMapping;

interface

uses
  Classes, Types, Generics.Collections, LineMapping;

type
  TUnitMapping = class
  private
    FD16UnitName: string;
    FMapping: TObjectList<TLineMapping>;

  public
    constructor Create();
    destructor Destroy(); override;
    property D16UnitName: string read FD16UnitName write FD16UnitName;
    property Mapping: TObjectList<TLineMapping> read FMapping;
  end;

implementation

{ TUnitMapping }

constructor TUnitMapping.Create;
begin
  FMapping := TObjectList<TLineMapping>.Create();
end;

destructor TUnitMapping.Destroy;
begin
  FMapping.Free;
  inherited;
end;

end.
