unit ProjectTreeController;

interface

uses
  Classes, Types, Windows, SysUtils, Generics.Collections, VirtualTrees, Project, IDEUnit, Controls;

type
  TProjectNodeData = record
    Item: TObject;
  end;

  PProjectNodeData = ^TProjectNodeData;

  TProjectTreeController = class
  private
    FProject: TProject;
    FTree: TVirtualStringTree;
    FImages: TImageList;
    procedure SetProject(const Value: TProject);
    procedure HandleUnitsChanged(Sender: TObject; const Item: TIDEUnit;
      Action: TCollectionNotification);
    procedure RebuildTree();
    function HasProject(): Boolean;
    // EventHandlers
    procedure ProjectTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure ProjectTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure SetImages(const Value: TImageList);
  public
    constructor Create(ATree: TVirtualStringTree);
    property Project: TProject read FProject write SetProject;
    property Images: TImageList read FImages write SetImages;
  end;

implementation

{ TProjectTreeController }

constructor TProjectTreeController.Create(ATree: TVirtualStringTree);
begin
  FTree := ATree;
  FTree.OnGetText := ProjectTreeGetText;
  FTree.OnGetImageIndex := ProjectTreeGetImageIndex;
  FTree.TreeOptions.MiscOptions := FTree.TreeOptions.MiscOptions - [toToggleOnDblClick];
end;

procedure TProjectTreeController.HandleUnitsChanged(Sender: TObject;
  const Item: TIDEUnit; Action: TCollectionNotification);
begin
  RebuildTree();
end;

function TProjectTreeController.HasProject: Boolean;
begin
  Result := Assigned(FProject);
end;

procedure TProjectTreeController.ProjectTreeGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
begin
  if Node = Sender.GetFirst() then
  begin
    ImageIndex := 2;
  end
  else
  begin
    ImageIndex := 1;
  end;
end;

procedure TProjectTreeController.ProjectTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  LUnit: TIdeUnit;
begin
  if Node = FTree.GetFirst() then
  begin
    CellText := FProject.ProjectName;
  end
  else
  begin
    LUnit := TIdeUnit(PProjectNodeData(FTree.GetNodeData(Node)).Item);
    if Assigned(LUnit) then
    begin
      CellText := ChangeFileExt(LUnit.Caption, '.pas');
    end;
  end;
end;

procedure TProjectTreeController.RebuildTree;
var
  LProjectNode, LUnitNode: PVirtualNode;
  LData: PProjectNodeData;
  LUnit: TIDEUnit;
begin
  FTree.BeginUpdate();
  try
    FTree.Clear;
    if HasProject then
    begin
      LProjectNode := FTree.AddChild(nil);
      LData := FTree.GetNodeData(LProjectNode);
      LData.Item := FProject;
      for LUnit in FProject.Units do
      begin
        LUnitNode := FTree.AddChild(LProjectNode);
        LData := FTree.GetNodeData(LUnitNode);
        LData.Item := LUnit;
      end;
      FTree.Expanded[LProjectNode] := True;
    end;
  finally
    FTree.EndUpdate();
  end;
end;

procedure TProjectTreeController.SetImages(const Value: TImageList);
begin
  FImages := Value;
  FTree.Images := FImages;
end;

procedure TProjectTreeController.SetProject(const Value: TProject);
begin
  FProject := Value;
  if Assigned(FProject) then
  begin
    FProject.Units.OnNotify := HandleUnitsChanged;
  end;
  RebuildTree();
end;

end.
