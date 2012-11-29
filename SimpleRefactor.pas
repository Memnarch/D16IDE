unit SimpleRefactor;

interface

uses
  Classes, Types, SysUtils, SynEdit;

type
  TSimpleRefactor = class
  private
    FEdit: TSynEdit;
  public
    constructor Create(AEdit: TSynEdit);
    procedure RenameHeader(AName: string);
    procedure CompleteBlocks();
  end;

implementation

uses
  StrUtils, Lexer, Token;

{ TSimpleRefactor }

procedure TSimpleRefactor.CompleteBlocks;
var
  LLexer: TLexer;
  LToken, LOpenToken: TToken;
  LOpen, LClose, LIdent: Integer;
  LText: string;
begin
  LOpen := 0;
  LClose := 0;
  LOpenToken := nil;
  LLexer := TLexer.Create();
  try
    LLexer.LoadFromString(FEdit.Text);
    while not LLexer.EOF do
    begin
      LToken := LLexer.GetToken();
      if LToken.IsType(ttReserved) then
      begin
        if AnsiIndexText(LToken.Content, ['unit', 'asm', 'begin']) > -1 then
        begin
          Inc(LOpen);
          if LToken.FoundInLine < FEdit.CaretY then
          begin
            LOpenToken := LToken;
          end;
        end
        else
        begin
          if SameText(LToken.Content, 'end') then
          begin
            Inc(LClose);
          end;
        end;
      end;
    end;
    if (LOpen > LClose) and (FEdit.CaretY > 0) and Assigned(LOpenToken) then
    begin
      FEdit.LInes.Strings[FEdit.CaretY-1] := FEdit.Lines.Strings[FEdit.CaretY-1] + #9; //jump into nextline with increased ident
      FEdit.CaretX := FEdit.CaretX + 1;
      LText := FEdit.Lines.Strings[LOpenToken.FoundInLine];
      LIdent := (Length(LText) - Length(TrimLeft(LText))) - 1;
      FEdit.Lines.Insert(FEdit.CaretY, StringOfChar(' ', LIdent) + 'end;');
    end;
  finally
    LLexer.Free;
  end;
end;

constructor TSimpleRefactor.Create(AEdit: TSynEdit);
begin
  FEdit := AEdit;
end;

procedure TSimpleRefactor.RenameHeader(AName: string);
var
  i, LPos: Integer;
  LEnd: string;
begin
  for i := 0 to FEdit.Lines.Count - 1 do
  begin
    if StartsText('unit ', Trim(FEdit.Lines.Strings[i]))
      or StartsText('program ', Trim(FEdit.Lines.Strings[i]))
    then
    begin
      LPos := Pos(';', FEdit.Lines.Strings[i]);
      if LPos > 0 then
      begin
        LEnd := copy(FEdit.Lines.Strings[i], LPos + 1, Length(FEdit.Lines.Strings[i]));
      end;
      if StartsText('unit ', Trim(FEdit.Lines.Strings[i])) then
      begin
        FEdit.Lines.Strings[i] := 'unit ' + AName + ';' + LEnd;
      end
      else
      begin
        FEdit.Lines.Strings[i] := 'program ' + AName + ';' + LEnd;
      end;
      Break;
    end;
  end;
end;

end.
