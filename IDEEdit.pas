unit IDEEdit;

interface

uses
  Classes, Types, Controls, Graphics, SysUtils, SynEdit, SimpleRefactor, SynEditTextBuffer, Generics.Collections, LineInfo,
  UnitMapping, LineMapping;

type
  TBreakPointEvent = procedure(AUnit: string; ALine: Integer) of object;

  TIDEEdit = class(TSynEdit)
  private
    FRefactor: TSimpleRefactor;
    FBuffer: TSynEditStringList;
    FLineDeleted: TStringListChangeEvent;
    FLineInserted: TStringListChangeEvent;
    FLinePutt: TStringListChangeEvent;
    FLineInfo: TObjectList<TLineInfo>;
    FOnAddBreakPoint: TBreakPointEvent;
    FOnDeleteBreakPoint: TBreakPointEvent;
    FD16UnitName: string;
    FBreakPointColor: TColor;
    FDebugCursor: Integer;
    FDebugCursorColor: TColor;
    procedure InternalKeyPress(Sender: TObject; var Key: Char);
    procedure HandleLineDelete(Sender: TObject; Index, Count: Integer);
    procedure HandleLineInserted(Sender: TObject; Index, Count: Integer);
    procedure HandleLinePutt(Sender: TObject; Index, Count: Integer);
    procedure InterceptBuffer();
    procedure HandleGutterClick(Sender: TObject; Button: TMouseButton;
    X, Y, Line: Integer; Mark: TSynEditMark);
    procedure HandleGutterPaint(Sender: TObject; aLine, X, Y: Integer);
    procedure HandleSpecialLineColors(Sender: TObject; Line: Integer;
    var Special: Boolean; var FG, BG: TColor);
    procedure DoAddBreakPoint(AUnit: string; ALine: Integer);
    procedure DoDeleteBreakPoint(AUnit: string; ALine: Integer);
    procedure ShiftBreakpoints(AFrom: Integer; AOffset: Integer);
    procedure InitColors();
    procedure SetDebugCursor(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure SaveToFile(AFile: string);
    procedure LoadFromFile(AFile: string);
    procedure MarkAllLines(AState: TLineState);
    procedure ClearMappings();
    procedure UpdateMapping(AMapping: TUnitMapping);
    property D16UnitName: string read FD16UnitName write FD16UnitName;
    property Refactor: TSimpleRefactor read FRefactor;
    property BreakPointColor: TColor read FBreakPointColor write FBreakPointColor;
    property DebugCursorColor: TColor read FDebugCursorColor write FDebugCursorColor;
    property DebugCursor: Integer read FDebugCursor write SetDebugCursor;
    property OnAddBreakPoint: TBreakPointEvent read FOnAddBreakPoint write FOnAddBreakPoint;
    property OnDeleteBreakPoint: TBreakPointEvent read FOnDeleteBreakPoint write FOnDeleteBreakPoint;
  end;

implementation

uses
  SynHighlighterPas, SynEditSearch, BreakPoint, ColorFunctions;

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
  OnSpecialLineColors := HandleSpecialLineColors;
  FDebugCursor := -1;
  InitColors();
end;

destructor TIDEEdit.Destroy;
begin
  FRefactor.Free;
  FLineInfo.Free;
  inherited;
end;

procedure TIDEEdit.DoAddBreakPoint(AUnit: string; ALine: Integer);
begin
  if Assigned(FOnAddBreakPoint) then
  begin
    FOnAddBreakPoint(AUnit, ALine);
  end;
end;

procedure TIDEEdit.DoDeleteBreakPoint(AUnit: string; ALine: Integer);
begin
  if Assigned(FOnDeleteBreakPoint) then
  begin
    FOnDeleteBreakPoint(AUnit, ALine);
  end;
end;

procedure TIDEEdit.HandleGutterClick(Sender: TObject; Button: TMouseButton; X,
  Y, Line: Integer; Mark: TSynEditMark);
begin
  if X > 16 then Exit;
  
  if FLineInfo.Items[Line-1].BreakPointState = bpsNone then
  begin
    FLineInfo.Items[Line-1].BreakPointState := bpsNormal;
    DoAddBreakPoint(FD16UnitName, Line);
  end
  else
  begin
    FLineInfo.Items[Line-1].BreakPointState := bpsNone;
    DoDeleteBreakPoint(FD16UnitName, Line);
  end;
  Self.Repaint();
end;

procedure TIDEEdit.HandleGutterPaint(Sender: TObject; aLine, X, Y: Integer);
var
  LColor: TColor;
begin
  if (FLineInfo.Count > 0) then
  begin
    if Assigned(BookMarkOptions.BookmarkImages) then
    begin
      if FLineInfo.Items[ALine-1].BreakPointState <> bpsNone then
      begin
        BookMarkOptions.BookmarkImages.Draw(Canvas, X, Y, 1);
      end
      else
      begin
        if (FLineInfo.Items[ALine-1].IsPossibleBreakPoint) then
        begin
          BookMarkOptions.BookmarkImages.Draw(Canvas, X, Y, 0);
        end;
      end;
      if aLine = DebugCursor then
      begin
        BookMarkOptions.BookmarkImages.Draw(Canvas, X, Y, 2);
      end;
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

  ShiftBreakpoints(Index + (Count-1), -Count);
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

  ShiftBreakpoints(Index, Count);

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

procedure TIDEEdit.HandleSpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);
begin
  if FLineInfo.Items[Line - 1].BreakPointState <> bpsNone then
  begin
    FG := clNone;
    BG := FBreakPointColor;
    Special := True;
  end
  else
  begin
    if DebugCursor = Line then
    begin
      FG := clNone;
      BG := DebugCursorColor;
      Special := True;
    end;
  end;
end;

procedure TIDEEdit.InitColors;
begin
  //c7c7ff
  FBreakPointColor := HexToTColor('c7c7ff');
  ActiveLineColor := HexToTColor('F0F0F0');//HexToTColor('D6D6D6');
  DebugCursorColor := HexToTColor('cc9999');
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

procedure TIDEEdit.SetDebugCursor(const Value: Integer);
begin
  FDebugCursor := Value;
  if FDebugCursor > -1 then
  begin
    CaretY := Value;
  end;
  Repaint();
end;

procedure TIDEEdit.ShiftBreakpoints(AFrom: Integer; AOffset: Integer);
var
  i: Integer;
begin
  for i := AFrom to FLineInfo.Count - 1 do
  begin
    if FLineInfo.Items[i].BreakPointState <> bpsNone then
    begin
      DoDeleteBreakPoint(FD16UnitName, i + 1);
      DoAddBreakPoint(FD16UnitName, i + AOffset + 1);
    end;
  end;
end;

procedure TIDEEdit.UpdateMapping(AMapping: TUnitMapping);
var
  LMapping: TLineMapping;
  LBreak: TBreakPoint;
begin
  ClearMappings();
  for LMapping in AMapping.Mapping do
  begin
    if (LMapping.UnitLine > 0) and (LMapping.UnitLine <= FLineInfo.Count) then
    begin
      FLineInfo.Items[LMapping.UnitLine - 1].Mapping.Assign(LMapping);
      FLineInfo.Items[LMapping.UnitLine - 1].BreakPointState := bpsNone;
    end;
  end;
  for LBreak in AMapping.BreakPoints do
  begin
    if (LBreak.UnitLine > 0) and (LBreak.UnitLine < FLineInfo.Count) then
    begin
      FLineInfo.Items[LBreak.UnitLine - 1].BreakPointState := bpsNormal;
    end;
  end;
end;

end.
