unit IDEPageFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IDEEdit, IDEUnit;

type
  TIDEPage = class(TFrame)
  private
    { Private declarations }
    FIDEEdit: TIDEEdit;
    FIDEUnit: TIDEUnit;
    FOnUnitRenamed: TNotifyEvent;
    procedure SetIDEUnit(const Value: TIDEUnit);
    function GetIsPartOfProject: Boolean;
    function GetNeedsSaving: Boolean;
    procedure HandleOnRename(Sender: TObject);
    procedure DoOnUnitRenamed();
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property IsPartOfProject: Boolean read GetIsPartOfProject;
    property NeedsSaving: Boolean read GetNeedsSaving;
    property IDEEdit: TIDEEdit read FIDEEdit;
    property IDEUnit: TIDEUnit read FIDEUnit write SetIDEUnit;
    property OnUnitRenamed: TNotifyEvent read FOnUnitRenamed write FOnUnitRenamed;
  end;

implementation

uses
  UnitTemplates;

{$R *.dfm}

{ TIDEPage }

constructor TIDEPage.Create(AOwner: TComponent);
begin
  inherited;
  FIDEEdit := TIDEEdit.Create(Self);
  FIDEEdit.Parent := Self;
  FIDEEdit.Align := alClient;
  FIDEEdit.Lines.Text := CDefaultUnit;
end;

procedure TIDEPage.DoOnUnitRenamed;
begin
  if Assigned(FOnUnitRenamed) then
  begin
    FOnUnitRenamed(FIDEUnit);
  end;
end;

function TIDEPage.GetIsPartOfProject: Boolean;
begin
  Result := Assigned(FIDEUnit);
end;

function TIDEPage.GetNeedsSaving: Boolean;
begin
  Result := FIDEEdit.Modified;
end;

procedure TIDEPage.HandleOnRename(Sender: TObject);
begin
  FIDEEdit.Refactor.RenameHeader(TIDEUnit(Sender).Caption);
  DoOnUnitRenamed();
end;

procedure TIDEPage.SetIDEUnit(const Value: TIDEUnit);
begin
  FIDEUnit := Value;
  FIDEUnit.SourceLink := FIDEEdit.Lines;
  FIDEUnit.OnRename := HandleOnRename;
  DoOnUnitRenamed();
end;

end.
