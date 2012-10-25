unit SimpleRefactor;

interface

uses
  Classes, Types, SysUtils;

type
  TSimpleRefactor = class
  private
    FSourceLink: TStrings;
  public
    constructor Create(ASourceLink: TStrings);
    procedure RenameHeader(AName: string);
  end;

implementation

uses
  StrUtils;

{ TSimpleRefactor }

constructor TSimpleRefactor.Create(ASourceLink: TStrings);
begin
  FSourceLink := ASourceLink;
end;

procedure TSimpleRefactor.RenameHeader(AName: string);
var
  i, LPos: Integer;
  LEnd: string;
begin
  for i := 0 to FSourceLink.Count - 1 do
  begin
    if StartsText('unit ', Trim(FSourceLink.Strings[i])) then
    begin
      LPos := Pos(';', FSourceLink.Strings[i]);
      if LPos > 0 then
      begin
        LEnd := copy(FSourceLink.Strings[i], LPos + 1, Length(FSourceLink.Strings[i]));
      end;
      FSourceLink.Strings[i] := 'unit ' + AName + ';' + LEnd;
      Break;
    end;
  end;
end;

end.
