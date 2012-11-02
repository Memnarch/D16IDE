unit SearchForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SynEdit, SynEditMiscClasses, SynEditSearch, SynEditTypes,
  ImgList;

type
  TSimpleSearchForm = class(TFrame)
    edFind: TEdit;
    btnPrevious: TButton;
    btnNext: TButton;
    SearchImages: TImageList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edFindKeyPress(Sender: TObject; var Key: Char);
    procedure btnNextClick(Sender: TObject);
    procedure btnPreviousClick(Sender: TObject);
  private
    { Private declarations }
    FIndex: Integer;
    FScope: TSynEdit;
    FOptions: TSynSearchOptions;
    procedure SelectIndex(AIndex: Integer);
    procedure UpdateSearch();
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AScope: TSynEdit); reintroduce;
    procedure FindNext();
    procedure FindPrevious();
  end;
implementation

uses
  Math;

{$R *.dfm}

{ TSimpleSearchForm }

procedure TSimpleSearchForm.btnNextClick(Sender: TObject);
begin
  FindNext();
end;

procedure TSimpleSearchForm.btnPreviousClick(Sender: TObject);
begin
  FindPrevious();
end;

constructor TSimpleSearchForm.Create(AOwner: TComponent;
  AScope: TSynEdit);
begin
  inherited Create(AOwner);
  FScope := AScope;
end;

procedure TSimpleSearchForm.edFindKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if Trim(edFind.Text) <> '' then
    begin
      FIndex := 0;
      FOptions := [ssoEntireScope];
      FScope.SearchEngine.Pattern := edFind.Text;
      FScope.SearchEngine.Options := FOptions;
      if FScope.SearchEngine.FindAll(FScope.Text) = 0 then
      begin
        ShowMessage('Searchstring ' + QuotedStr(edFind.Text) + ' not found');
      end
      else
      begin
        SelectIndex(FIndex);
      end;
    end;
    Key := #0;
  end;
end;

procedure TSimpleSearchForm.FindNext;
begin
  if Visible then
  begin
    UpdateSearch();
    if FIndex + 1 < FScope.SearchEngine.ResultCount then
    begin
      Inc(FIndex);
      SelectIndex(FIndex);
    end;
  end;
end;

procedure TSimpleSearchForm.FindPrevious;
begin
  if Visible then
  begin
    UpdateSearch();
    if (FIndex - 1 >= 0) then
    begin
      Dec(FIndex);
      SelectIndex(FIndex);
    end;
  end;
end;

procedure TSimpleSearchForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TSimpleSearchForm.SelectIndex(AIndex: Integer);
begin
  FScope.SelStart := FScope.SearchEngine.Results[AIndex] - 1;
  FScope.SelLength := FScope.SearchEngine.Lengths[AIndex];
end;

procedure TSimpleSearchForm.UpdateSearch;
begin
  FScope.SearchEngine.FindAll(FScope.Text);
  FIndex := Min(Max(FIndex, 0), FScope.SearchEngine.ResultCount - 1);
end;

end.
