unit IDETabSheet;

interface

uses
  Classes, Types, SysUtils, Controls, ComCtrls, JVComCtrls, IDEPageFrame;

type
  TIDETabSheet = class(TTabSheet)
  private
    FIDEPage: TIDEPage;
    procedure HandleOnUnitRenamed(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; APageControl: TJvPageControl); reintroduce;
    property IDEPage: TIDEPage read FIDEPage;
  end;

implementation

uses
  IDEUnit;

{ TIDETabSheet }

constructor TIDETabSheet.Create(AOwner: TComponent;
  APageControl: TJvPageControl);
begin
  inherited Create(AOwner);
  PageControl := APageControl;
  FIDEPage := TIDEPage.Create(Self);
  FIDEPage.Parent := Self;
  FIDEPage.Align := alClient;
  FIDEPage.OnUnitRenamed := HandleOnUnitRenamed;
end;

procedure TIDETabSheet.HandleOnUnitRenamed(Sender: TObject);
begin
  Caption := TIDEUnit(Sender).Caption;
end;

end.
