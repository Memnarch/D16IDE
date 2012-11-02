unit IDEEdit;

interface

uses
  Classes, Types, SynEdit, SimpleRefactor;

type
  TIDEEdit = class(TSynEdit)
  private
    FRefactor: TSimpleRefactor;
    procedure InternalKeyPress(Sender: TObject; var Key: Char);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Refactor: TSimpleRefactor read FRefactor;
  end;

implementation

uses
  SynHighlighterPas, SynEditSearch, Graphics;

{ TIDEEdit }

constructor TIDEEdit.Create(AOwner: TComponent);
begin
  inherited;
  FRefactor := TSimpleRefactor.Create(Self);
  Highlighter := TSynPasSyn.Create(Self);
  TSynPasSyn(Highlighter).AsmAttri.Foreground := clBlack;
  TSynPasSyn(Highlighter).KeyAttri.Foreground := clNavy;
  Name := 'IDEEdit';
  Gutter.ShowLineNumbers := True;
  WantTabs := True;
  TabWidth := 2;
  Options := Options - [eoSmartTabs];
  DoubleBuffered := True;
  SearchEngine := TSynEditSearch.Create(Self);
  OnKeyPress := InternalKeyPress;
end;

destructor TIDEEdit.Destroy;
begin
  FRefactor.Free;
  inherited;
end;

procedure TIDEEdit.InternalKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    FRefactor.CompleteBlocks();
  end;
end;

end.
