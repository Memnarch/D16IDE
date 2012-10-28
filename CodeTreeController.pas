unit CodeTreeController;

interface

uses
  Classes, Types, VirtualTrees, PascalUnit;

type
  TCodeNodeData = record
    Caption: string;
    Line: Integer;
  end;

  PCodeNodeData = ^TCodeNodeData;

  TCodeTreeController = class
  private
    FTree: TVirtualStringTree;
  public
    constructor Create(ATree: TVirtualStringTree);
    procedure BuildCodeTreeFromUnit(AUnit: TPascalUnit);
  end;

implementation

uses
  CodeElement, VarDeclaration, ProcDeclaration, DataType;

{ TFTreeController }

procedure TCodeTreeController.BuildCodeTreeFromUnit(AUnit: TPascalUnit);
var
  LUses, LProcedures, LVars, LTypes, LNode: PVirtualNode;
  LElement: TCodeElement;
  LName: string;
  LPreFix: string;
begin
  FTree.BeginUpdate;
  FTree.Clear;
  LUses := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(LUses)).Caption := 'Uses';
  PCodeNodeData(FTree.GetNodeData(LUses)).Line := -1;
  LVars := FTree.AddChild(nil);
  LTypes := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(LTypes)).Caption := 'Types';
  PCodeNodeData(FTree.GetNodeData(LTypes)).Line := -1;
  PCodeNodeData(FTree.GetNodeData(LVars)).Caption := 'Vars';
  PCodeNodeData(FTree.GetNodeData(LVars)).Line := -1;
  LProcedures := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(LProcedures)).Caption := 'Procedures';
  PCodeNodeData(FTree.GetNodeData(LProcedures)).Line := -1;
  for LName in AUnit.UsedUnits do
  begin
      LNode := FTree.AddChild(LUses);
      PCodeNodeData(FTree.GetNodeData(LNode)).Caption := LName;
  end;
  for LElement in AUnit.SubElements do
  begin
    LNode := nil;
    if LElement is TVarDeclaration then
    begin
      LNode := FTree.AddChild(LVars);
      PCodeNodeData(FTree.GetNodeData(LNode)).Caption := LElement.Name + ': ' + TVarDeclaration(LElement).DataType.Name;
    end;
    if LElement is TProcDeclaration then
    begin
      LNode := FTree.AddChild(LProcedures);
      PCodeNodeData(FTree.GetNodeData(LNode)).Caption := LElement.Name;
    end;
    if (LElement is TDataType) and (TDataType(LElement) <> TDataType(LElement).BaseType) then
    begin
      LNode := FTree.AddChild(LTypes);
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
  FTree.FullExpand(nil);
  FTree.EndUpdate;
end;

constructor TCodeTreeController.Create(ATree: TVirtualStringTree);
begin
  FTree := ATree;
end;

end.
