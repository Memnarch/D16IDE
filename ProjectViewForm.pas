unit ProjectViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IDEView, VirtualTrees, ProjectTreeController, Events, IDEModule,
  Menus, IDEActionModule, ActnList;

type
  TProjectView = class(TIDEView)
    ProjectTree: TVirtualStringTree;
    ProjectPopup: TPopupMenu;
    NewUnit2: TMenuItem;
    AddUnit2: TMenuItem;
    Options3: TMenuItem;
    UnitPopup: TPopupMenu;
    NewUnit1: TMenuItem;
    AddUnit1: TMenuItem;
    RemoveUnit1: TMenuItem;
    Options2: TMenuItem;
    ActionList: TActionList;
    actRemoveSelectedUnit: TAction;
    procedure FormCreate(Sender: TObject);
    procedure ProjectTreeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ProjectTreeDblClick(Sender: TObject);
    procedure actRemoveSelectedUnitExecute(Sender: TObject);
  private
    { Private declarations }
    FTreeController: TProjectTreeController;
    FIDEData: TIDEData;
    FIDEActions: TIDEActions;
    procedure SetIDEData(const Value: TIDEData);
    procedure SetIDEActions(const Value: TIDEActions);
  public
    { Public declarations }
    procedure Event(AEventData: TEventData); override;
    property IDEData: TIDEData read FIDEData write SetIDEData;
    property IDEActions: TIDEActions read FIDEActions write SetIDEActions;
  end;

var
  ProjectView: TProjectView;

implementation

uses
  ProjectEvents, IDEUnit, Project;

{$R *.dfm}

procedure TProjectView.actRemoveSelectedUnitExecute(Sender: TObject);
var
  LItem: TObject;
  LIndex: Integer;
begin
  LItem := FTreeController.GetSelectedItem();
  if LItem is TIDEUnit then
  begin
    LIndex := Controller.GetPageIndexForIdeUnit(TIDEUnit(LItem));
    if (LIndex = -1) or Controller.ClosePage(LIndex)  then
    begin
      FTreeController.Project.Units.Remove(TIDEUnit(LItem));
    end;
  end;
end;

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
    ProjectTree.PopupMenu := ProjectPopup;
  end
  else
  begin
    if Assigned(LNode) then
    begin
      ProjectTree.PopupMenu := UnitPopup;
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

procedure TProjectView.SetIDEActions(const Value: TIDEActions);
begin
  FIDEActions := Value;
  if Assigned(FIDEActions) then
  begin
    //UnitPopup
    NewUnit1.Action := FIDEActions.actNewUnit;
    AddUnit1.Action := FIDEActions.actAddExistingUnit;
    RemoveUnit1.Action := actRemoveSelectedUnit;
    Options2.Action := FIDEActions.actProjectOptions;
    //Projectpopup
    NewUnit2.Action := FIDEActions.actNewUnit;
    AddUnit2.Action := FIDEActions.actAddExistingUnit;
    Options3.Action := FIDEActions.actProjectOptions;
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
