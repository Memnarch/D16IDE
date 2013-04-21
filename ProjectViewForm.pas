unit ProjectViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IDEView, VirtualTrees, ProjectTreeController, Events, IDEModule;

type
  TProjectView = class(TIDEView)
    ProjectTree: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
    procedure ProjectTreeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ProjectTreeDblClick(Sender: TObject);
  private
    { Private declarations }
    FTreeController: TProjectTreeController;
    FIDEData: TIDEData;
    procedure SetIDEData(const Value: TIDEData);
  public
    { Public declarations }
    procedure Event(AEventData: TEventData); override;
    property IDEData: TIDEData read FIDEData write SetIDEData;
  end;

var
  ProjectView: TProjectView;

implementation

uses
  ProjectEvents, IDEUnit, Project;

{$R *.dfm}

procedure TProjectView.Event(AEventData: TEventData);
begin
  inherited;
  if AEventData.EventID = evProjectChanged then
  begin
    FTreeController.Project := TProjectEvenetData(AEventData).Project;
  end;
end;

procedure TProjectView.FormCreate(Sender: TObject);
begin
  Name := 'ProjectView';
  ProjectTree.NodeDataSize := SizeOf(Cardinal);
  FTreeController := TProjectTreeController.Create(ProjectTree);
end;

procedure TProjectView.ProjectTreeContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  LNode: PVirtualNode;
begin
  LNode := ProjectTree.GetNodeAt(MousePos.X, MousePos.Y);
  if LNode = ProjectTree.GetFirst() then
  begin
    ProjectTree.PopupMenu := FIDEData.ProjectPopup;
  end
  else
  begin
    if Assigned(LNode) then
    begin
      ProjectTree.PopupMenu := FIDEData.UnitPopup;
    end
    else
    begin
      ProjectTree.PopupMenu := nil;
    end;
  end;
end;

procedure TProjectView.ProjectTreeDblClick(Sender: TObject);
var
  LPos: TPoint;
  LNode: PVirtualNode;
  LData: PProjectNodeData;
  LUnit: TIDEUnit;
begin
  LUnit := nil;
  GetCursorPos(LPos);
  LPos := ProjectTree.ScreenToClient(LPos);
  LNode := ProjectTree.GetNodeAt(LPos.X, LPos.Y);
  if Assigned(LNode) then
  begin
    if LNode = ProjectTree.GetFirst() then
    begin
      LData := ProjectTree.GetNodeData(LNode);
      if Assigned(LData) then
      begin
        LUnit := TProject(LData.Item).ProjectUnit;
      end;
    end
    else
    begin
      LData := ProjectTree.GetNodeData(LNode);
      if Assigned(LData) then
      begin
        LUnit := TIDEUnit(LData.Item);
      end;
    end;

    if Assigned(LUnit) then
    begin
      if not Controller.IDEUnitIsOpen(LUnit) then
      begin
        Controller.AddPage(LUnit.Caption, '', LUnit);
      end;
        Controller.FokusIDEPageByUnit(LUnit);
    end;
  end;
end;

procedure TProjectView.SetIDEData(const Value: TIDEData);
begin
  FIDEData := Value;
  if Assigned(FIDEData) then
  begin
    FTreeController.Images := FIDEData.TreeImages;
  end
  else
  begin
    FTreeController.Images := nil;
  end;
end;

end.
