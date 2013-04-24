unit MenuFormItem;

interface

uses
  Classes, Types, Forms, Menus, DockClient;

type
  TMenuFormItem = class(TMenuItem)
  private
    FForm: TDockClient;
    procedure HandleShowing(Sender: TObject);
    procedure HandleHiding(Sender: TObject);
    procedure HandleClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AForm: TDockClient); reintroduce;
  end;

implementation

uses
  JvDockControlForm;

{ TMenuFormItem }

constructor TMenuFormItem.Create(AOwner: TComponent; AForm: TDockClient);
begin
  inherited Create(AOwner);
  FForm := AForm;
  FForm.DockClient.OnFormShow := HandleShowing;
  FForm.DockClient.OnFormHide := HandleHiding;
  Caption := FForm.Caption;
  OnClick := HandleClick;
end;

procedure TMenuFormItem.HandleClick(Sender: TObject);
begin
  if GetFormVisible(FForm) then
  begin
    HideDockForm(FForm);
  end
  else
  begin
    ShowDockForm(FForm);
  end;
end;

procedure TMenuFormItem.HandleHiding(Sender: TObject);
begin
  Checked := False;
end;

procedure TMenuFormItem.HandleShowing(Sender: TObject);
begin
  Checked := True;
end;

end.
