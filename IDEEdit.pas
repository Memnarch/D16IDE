unit IDEEdit;

interface

uses
  Classes, Types, SynEdit, SimpleRefactor;

type
  TIDEEdit = class(TSynEdit)
  private
    FRefactor: TSimpleRefactor;
  public
    constructor Create(AOwner: TComponent); override;
    property Refactor: TSimpleRefactor read FRefactor;
  end;

implementation

uses
  SynHighlighterPas, Graphics;

{ TIDEEdit }

constructor TIDEEdit.Create(AOwner: TComponent);
begin
  inherited;
  FRefactor := TSimpleRefactor.Create(Lines);
  Highlighter := TSynPasSyn.Create(Self);
  TSynPasSyn(Highlighter).AsmAttri.Foreground := clBlack;
  TSynPasSyn(Highlighter).KeyAttri.Foreground := clNavy;
  Name := 'IDEEdit';
  Gutter.ShowLineNumbers := True;
  WantTabs := True;
  TabWidth := 2;
  Options := Options - [eoSmartTabs];
  DoubleBuffered := True;
end;

end.
