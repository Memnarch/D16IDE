unit IDEPageFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IDEEdit, IDEUnit, SearchForm;

type
  TIDEPage = class(TFrame)
  private
    { Private declarations }
    FIDEEdit: TIDEEdit;
    FIDEUnit: TIDEUnit;
    FSearchForm: TSimpleSearchForm;
    FOnUnitRenamed: TNotifyEvent;
    FIDEIcons: TImageList;
    procedure SetIDEUnit(const Value: TIDEUnit);
    function GetIsPartOfProject: Boolean;
    function GetNeedsSaving: Boolean;
    procedure HandleOnRename(Sender: TObject);
    procedure DoOnUnitRenamed();
    procedure HandleAfterSave(Sender: TObject);
    procedure HandleAfterLoad(Sender: TObject);
    procedure SetIDEIcons(const Value: TImageList);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure ShowSearch();
    procedure HideSearch();
    procedure FindNext();
    procedure FindPrevious();
    property IsPartOfProject: Boolean read GetIsPartOfProject;
    property NeedsSaving: Boolean read GetNeedsSaving;
    property IDEEdit: TIDEEdit read FIDEEdit;
    property IDEUnit: TIDEUnit read FIDEUnit write SetIDEUnit;
    property IDEIcons: TImageList read FIDEIcons write SetIDEIcons;
    property OnUnitRenamed: TNotifyEvent read FOnUnitRenamed write FOnUnitRenamed;
  end;

implementation

uses
  UnitTemplates, LineInfo;

{$R *.dfm}

{ TIDEPage }

constructor TIDEPage.Create(AOwner: TComponent);
begin
  inherited;
  FIDEEdit := TIDEEdit.Create(Self);
  FIDEEdit.Parent := Self;
  FIDEEdit.Align := alClient;
  FIDEEdit.Lines.Text := CDefaultUnit;
  FSearchForm := TSimpleSearchForm.Create(Self, FIDEEdit);
  FSearchForm.Visible := False;
  FSearchForm.Parent := Self;
  FSearchForm.Align := alBottom;
end;

destructor TIDEPage.Destroy;
begin
  if Assigned(FIDEUnit) then
  begin
    FIDEUnit.OnRename := nil;
    FIDEUnit.OnAfterSave := nil;
    FIDEUnit.OnAfterLoad := nil;
  end;
  inherited;
end;

procedure TIDEPage.DoOnUnitRenamed;
begin
  if Assigned(FOnUnitRenamed) then
  begin
    FOnUnitRenamed(FIDEUnit);
  end;
end;

procedure TIDEPage.FindNext;
begin
  FSearchForm.FindNext();
end;

procedure TIDEPage.FindPrevious;
begin
  FSearchForm.FindPrevious();
end;

function TIDEPage.GetIsPartOfProject: Boolean;
begin
  Result := Assigned(FIDEUnit);
end;

function TIDEPage.GetNeedsSaving: Boolean;
begin
  Result := FIDEEdit.Modified;
end;

procedure TIDEPage.HandleAfterLoad(Sender: TObject);
begin
  FIDEEdit.MarkAllLines(ltNone);
end;

procedure TIDEPage.HandleAfterSave(Sender: TObject);
begin
  FIDEEdit.MarkAllLines(ltSaved);
end;

procedure TIDEPage.HandleOnRename(Sender: TObject);
begin
  FIDEEdit.Refactor.RenameHeader(TIDEUnit(Sender).Caption);
  FIDEEdit.D16UnitName := TIDEUnit(Sender).Caption;
  DoOnUnitRenamed();
end;

procedure TIDEPage.HideSearch;
begin
  FSearchForm.Visible := False;
end;

procedure TIDEPage.SetIDEIcons(const Value: TImageList);
begin
  FIDEIcons := Value;
  FIDEEdit.BookMarkOptions.BookmarkImages := Value;
end;

procedure TIDEPage.SetIDEUnit(const Value: TIDEUnit);
begin
  FIDEUnit := Value;
  FIDEUnit.SourceLink := FIDEEdit.Lines;
  FIDEUnit.OnRename := HandleOnRename;
  FIDEUnit.OnAfterSave := HandleAfterSave;
  FIDEUnit.OnAfterLoad := HandleAfterLoad;
  FIDEEdit.D16UnitName := FIDEUnit.Caption;
  DoOnUnitRenamed();
end;

procedure TIDEPage.ShowSearch;
begin
  FSearchForm.Visible := True;
  FSearchForm.edFind.SetFocus();
end;

end.
