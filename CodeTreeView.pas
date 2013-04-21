unit CodeTreeView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IDEView, VirtualTrees, CodeTreeController, IDEModule, Events;

type
  TCodeView = class(TIDEView)
    CodeTree: TVirtualStringTree;
    procedure CodeTreeDblClick(Sender: TObject);
  private
    { Private declarations }
    FTreeController: TCodeTreeController;
    FIDEData: TIDEData;
    procedure SetIDEData(const Value: TIDEData);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure Event(AEventData: TEventData); override;
    property IDEData: TIDEData read FIDEData write SetIDEData;
  end;

var
  CodeView: TCodeView;

implementation

uses
  IDETabSheet, IDEPageFrame, CurrentUnitEvents;

{$R *.dfm}

procedure TCodeView.CodeTreeDblClick(Sender: TObject);
var
  LNode: PVirtualNode;
  LPos: TPoint;
  LPage: TIDEPage;
begin
  GetCursorPos(LPos);
  LPos := CodeTree.ScreenToClient(LPos);
  LNode := CodeTree.GetNodeAt(LPos.X, LPos.Y);
  if Assigned(LNode) then
  begin
    if PCodeNodeData(CodeTree.GetNodeData(LNode)).Line >= 0 then
    begin
      LPage := Controller.GetActiveIDEPage();
      if Assigned(LPage) then
      begin
        LPage.IDEEdit.SetFocus;
        LPAge.IDEEdit.CaretY := PCodeNodeData(CodeTree.GetNodeData(LNode)).Line;
      end;
    end;
  end;
end;

constructor TCodeView.Create(AOwner: TComponent);
begin
  inherited;
  FTreeController := TCodeTreeController.Create(CodeTree);
end;

destructor TCodeView.Destroy;
begin
  FTreeController.Free;
  inherited;
end;

procedure TCodeView.Event(AEventData: TEventData);
begin
  inherited;
  if AEventData.EventID = evCurrentUnitCacheChanged then
  begin
    FTreeController.BuildCodeTreeFromUnit(TCurrentUnitEventData(AEventData).UnitCache);
  end;
end;

procedure TCodeView.SetIDEData(const Value: TIDEData);
begin
  FIDEData := Value;
  if Assigned(FIDEData) then
  begin
    FTreeController.Images := FIDEData.CodeTreeImages;
  end
  else
  begin
    FTreeController.Images := nil;
  end;
end;

end.
