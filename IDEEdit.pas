unit IDEEdit;

interface

uses
  Classes, Types, Controls, SysUtils, SynEdit, SimpleRefactor, SynEditTextBuffer, Generics.Collections, LineInfo,
  UnitMapping;

type
  TIDEEdit = class(TSynEdit)
  private
    FRefactor: TSimpleRefactor;
    FBuffer: TSynEditStringList;
    FLineDeleted: TStringListChangeEvent;
    FLineInserted: TStringListChangeEvent;
    FLinePutt: TStringListChangeEvent;
    FLineInfo: TObjectList<TLineInfo>;
    procedure InternalKeyPress(Sender: TObject; var Key: Char);
    procedure HandleLineDelete(Sender: TObject; Index, Count: Integer);
    procedure HandleLineInserted(Sender: TObject; Index, Count: Integer);
    procedure HandleLinePutt(Sender: TObject; Index, Count: Integer);
    procedure InterceptBuffer();
    procedure HandleGutterClick(Sender: TObject; Button: TMouseButton;
    X, Y, Line: Integer; Mark: TSynEditMark);
    procedure HandleGutterPaint(Sender: TObject; aLine, X, Y: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure SaveToFile(AFile: string);
    procedure LoadFromFile(AFile: string);
    procedure MarkAllLines(AState: TLineState);
    procedure ClearMappings();
    procedure UpdateMapping(AMapping: TUnitMapping);
    property Refactor: TSimpleRefactor read FRefactor;
  end;

implementation

uses
  SynHighlighterPas, SynEditSearch, Graphics, LineMapping;

{ TIDEEdit }

procedure TIDEEdit.ClearMappings;
var
  LInfo: TLineInfo;
begin
  for LInfo in FLineInfo do
  begin
    LInfo.Mapping.Clear();
  end;
end;

constructor TIDEEdit.Create(AOwner: TComponent);
begin
  inherited;
  FLineInfo := TObjectList<TLineInfo>.Create();
  InterceptBuffer();
  FRefactor := TSimpleRefactor.Create(Self);
  Highlighter := TSynPasSyn.Create(Self);
  TSynPasSyn(Highlighter).AsmAttri.Foreground := clBlack;
  TSynPasSyn(Highlighter).KeyAttri.Foreground := clNavy;
  TSynPasSyn(Highlighter).CommentAttri.Foreground := clGreen;
  Name := 'IDEEdit';
  Gutter.ShowLineNumbers := True;
  WantTabs := True;
  TabWidth := 2;
  Options := Options - [eoSmartTabs];
  DoubleBuffered := True;
  SearchEngine := TSynEditSearch.Create(Self);
  OnKeyPress := InternalKeyPress;
  OnGutterPaint := HandleGutterPaint;
  OnGutterClick := HandleGutterClick;
end;

destructor TIDEEdit.Destroy;
begin
  FRefactor.Free;
  FLineInfo.Free;
  inherited;
end;

procedure TIDEEdit.HandleGutterClick(Sender: TObject; Button: TMouseButton; X,
  Y, Line: Integer; Mark: TSynEditMark);
begin

end;

procedure TIDEEdit.HandleGutterPaint(Sender: TObject; aLine, X, Y: Integer);
var
  LColor: TColor;
begin
  if (FLineInfo.Count > 0) then
  begin
    if (FLineInfo.Items[ALine-1].IsPossibleBreakPoint) and Assigned(BookMarkOptions.BookmarkImages) then
    begin
      BookMarkOptions.BookmarkImages.Draw(Canvas, X, Y, 0);
    end;
    if FLineInfo.Items[ALine-1].State = ltNone then Exit;
    
    if FLineInfo.Items[ALine-1].State = ltModified then
    begin
      LColor := clYellow;
    end
    else
    begin
      LColor := clGreen;
    end;
    Canvas.Brush.Color := LColor;
    Canvas.Pen.Color := LColor;
    Canvas.Rectangle(x + 20, y, x+25, y+17);
  end;
end;

procedure TIDEEdit.HandleLineDelete(Sender: TObject; Index, Count: Integer);
var
  I: Integer;
begin
  if Assigned(FLineDeleted) then
  begin
    FLineDeleted(Sender, Index, Count);
  end;

  for i := Index + (Count-1) downto Index do
  begin
    FLineInfo.Delete(i);
  end;
end;

procedure TIDEEdit.HandleLineInserted(Sender: TObject; Index, Count: Integer);
var
  i: Integer;
begin
  if Assigned(FLineInserted) then
  begin
    FLineInserted(Sender, Index, Count);
  end;

  for i := Index to  Index + (Count-1) do
  begin
    FLineInfo.Insert(Index, TLineInfo.Create(ltModified));
  end;
end;

procedure TIDEEdit.HandleLinePutt(Sender: TObject; Index, Count: Integer);
var
  i: Integer;
begin
  if Assigned(FLinePutt) then
  begin
    FLinePutt(Sender, Index, Count);
  end;

  for i := Index to Index + (Count-1) do
  begin
    FLineInfo.Items[i].State := ltModified;
  end;
end;

procedure TIDEEdit.InterceptBuffer;
begin
  FBuffer :=  Lines as TSynEditStringList;
  FLineDeleted := FBuffer.OnDeleted;
  FLineInserted := FBuffer.OnInserted;
  FLinePutt := FBuffer.OnPutted;
  FBuffer.OnDeleted := HandleLineDelete;
  FBuffer.OnInserted := HandleLineInserted;
  FBuffer.OnPutted := HandleLinePutt;
end;

procedure TIDEEdit.InternalKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    FRefactor.CompleteBlocks();
  end;
end;

procedure TIDEEdit.LoadFromFile(AFile: string);
begin
  Lines.LoadFromFile(AFile);
  MarkAllLines(ltNone);
end;

procedure TIDEEdit.MarkAllLines(AState: TLineState);
var
  i: Integer;
begin
  for i := 0 to FLineInfo.Count - 1 do
  begin
    if (FLineInfo.Items[i].State <> ltNone) or (AState = ltNone) then
    begin
      FLineInfo.Items[i].State := AState;
    end;
  end;
  Repaint();
end;

procedure TIDEEdit.SaveToFile(AFile: string);
begin
  Lines.SaveToFile(AFile);
  MarkAllLines(ltSaved);
end;

procedure TIDEEdit.UpdateMapping(AMapping: TUnitMapping);
var
  LMapping: TLineMapping;
begin
  ClearMappings();
  for LMapping in AMapping.Mapping do
  begin
    if (LMapping.UnitLine > 0) and (LMapping.UnitLine <= FLineInfo.Count) then
    begin
      FLineInfo.Items[LMapping.UnitLine - 1].Mapping.Assign(LMapping);
    end;
  end;
end;

end.
