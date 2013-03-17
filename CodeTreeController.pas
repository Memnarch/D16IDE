unit CodeTreeController;

interface

uses
  Classes, Types, Generics.Collections, VirtualTrees, PascalUnit, CodeElement;

type
  TCodeNodeData = record
    Caption: string;
    Line: Integer;
  end;

  PCodeNodeData = ^TCodeNodeData;

  TCodeTreeController = class
  private
    FTree: TVirtualStringTree;
    FUses: PVirtualNode;
    FTypes: PVirtualNode;
    FVars: PVirtualNode;
    FProcedures: PVirtualNode;
    procedure CreateSectionNodes();
    procedure BuildCodeTreeFromElements(AElements: TObjectList<TCodeElement>);
  public
    constructor Create(ATree: TVirtualStringTree);
    procedure BuildCodeTreeFromUnit(AUnit: TPascalUnit);
  end;

implementation

uses
  VarDeclaration, ProcDeclaration, DataType;

{ TFTreeController }

procedure TCodeTreeController.BuildCodeTreeFromElements(
  AElements: TObjectList<TCodeElement>);
var
  LNode: PVirtualNode;
  LElement: TCodeElement;
  LPreFix: string;
begin
  for LElement in AElements do
  begin
    LNode := nil;
    if LElement is TVarDeclaration then
    begin
      LNode := FTree.AddChild(FVars);
      PCodeNodeData(FTree.GetNodeData(LNode)).Caption := LElement.Name + ': ' + TVarDeclaration(LElement).DataType.Name;
    end;
    if (LElement is TProcDeclaration) and (not TProcDeclaration(LElement).IsDummy) then
    begin
      LNode := FTree.AddChild(FProcedures);
      PCodeNodeData(FTree.GetNodeData(LNode)).Caption := LElement.Name;
    end;
    if (LElement is TDataType) and (TDataType(LElement) <> TDataType(LElement).BaseType) then
    begin
      LNode := FTree.AddChild(FTypes);
      LPreFix := '';
      if TDataType(LElement).RawType = rtPointer then
      begin
        LPreFix := '^';
      end;
      if TDataType(LElement).RawType = rtArray then
      begin
        LPreFix := 'array of ';
      end;
      PCodeNodeData(FTree.GetNodeData(LNode)).Caption := LElement.Name + ': ' + LPreFix + TDataType(LElement).BaseType.Name;
    end;
    if Assigned(LNode) then
    begin
      PCodeNodeData(FTree.GetNodeData(LNode)).Line := LElement.Line;
    end;
  end;
end;

procedure TCodeTreeController.BuildCodeTreeFromUnit(AUnit: TPascalUnit);
var
  LNode: PVirtualNode;
  LName: string;
begin
  FTree.BeginUpdate;
  FTree.Clear;
  CreateSectionNodes();
  for LName in AUnit.UsedUnits do
  begin
    LNode := FTree.AddChild(FUses);
    PCodeNodeData(FTree.GetNodeData(LNode)).Caption := LName;
  end;
  BuildCodeTreeFromElements(AUnit.SubElements);
  BuildCodeTreeFromElements(AUnit.ImplementationSection);
  FTree.FullExpand(nil);
  FTree.EndUpdate;
end;

constructor TCodeTreeController.Create(ATree: TVirtualStringTree);
begin
  FTree := ATree;
end;

procedure TCodeTreeController.CreateSectionNodes;
begin
  FUses := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(FUses)).Caption := 'Uses';
  PCodeNodeData(FTree.GetNodeData(FUses)).Line := -1;
  FVars := FTree.AddChild(nil);
  FTypes := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(FTypes)).Caption := 'Types';
  PCodeNodeData(FTree.GetNodeData(FTypes)).Line := -1;
  PCodeNodeData(FTree.GetNodeData(FVars)).Caption := 'Vars';
  PCodeNodeData(FTree.GetNodeData(FVars)).Line := -1;
  FProcedures := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(FProcedures)).Caption := 'Procedures';
  PCodeNodeData(FTree.GetNodeData(FProcedures)).Line := -1;
end;

end.
