unit LineInfo;

interface

uses
  Classes, Types;

type
  TLineState = (ltNone, ltModified, ltSaved);

  TLineInfo = class
  private
    FState: TLineState;
  public
    constructor Create(AState: TLineState);
    property State: TLineState read FState write FState;
  end;

implementation

{ TLineInfo }

{ TLineInfo }

constructor TLineInfo.Create(AState: TLineState);
begin
  FState := AState;
end;

end.
