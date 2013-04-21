unit CodeTreeController;

interface

uses
  Classes, Types, Controls, Generics.Collections, VirtualTrees, PascalUnit,
  CodeElement, ProcDeclaration;

type
  TCodeType = (ctNone, ctSection, ctType, ctVar, ctUses, ctProcedure, ctFunction);

  TCodeNodeData = record
    Caption: string;
    Line: Integer;
    CodeType: TCodeType;
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
    function BuildParameterPostFix(AProc: TProcDeclaration): string;
    //event handlers
    procedure HandleGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure HandleCodeTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    function GetImages: TImageList;
    procedure SetImages(const Value: TImageList);
  public
    constructor Create(ATree: TVirtualStringTree);
    procedure BuildCodeTreeFromUnit(AUnit: TPascalUnit);
    property Images: TImageList read GetImages write SetImages;
  end;

implementation

uses
  VarDeclaration, DataType;

{ TFTreeController }

procedure TCodeTreeController.BuildCodeTreeFromElements(
  AElements: TObjectList<TCodeElement>);
var
  LNode: PVirtualNode;
  LData: PCodeNodeData;
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
      PCodeNodeData(FTree.GetNodeData(LNode)).CodeType := ctVar;
    end;
    if (LElement is TProcDeclaration) and (not TProcDeclaration(LElement).IsDummy) then
    begin
      LNode := FTree.AddChild(FProcedures);
      LData := PCodeNodeData(FTree.GetNodeData(LNode));
      LData.Caption := LElement.Name + BuildParameterPostFix(TProcDeclaration(LElement));
      if TProcDeclaration(LElement).IsFunction then
      begin
        LData.CodeType := ctFunction;
      end
      else
      begin
        LData.CodeType := ctProcedure;
      end;
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
      PCodeNodeData(FTree.GetNodeData(LNode)).CodeType := ctType;
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
    PCodeNodeData(FTree.GetNodeData(LNode)).Line := -1;
    PCodeNodeData(FTree.GetNodeData(LNode)).CodeType := ctUses;
  end;
  BuildCodeTreeFromElements(AUnit.SubElements);
  BuildCodeTreeFromElements(AUnit.ImplementationSection);
  FTree.FullExpand(nil);
  FTree.EndUpdate;
end;

function TCodeTreeController.BuildParameterPostFix(
  AProc: TProcDeclaration): string;
var
  i: Integer;
  LParameter: TVarDeclaration;
begin
  Result := '(';
  if AProc.Parameters.Count > 0 then
  begin
    for i := 0 to AProc.Parameters.Count - 1 do
    begin
      LParameter := TVarDeclaration(AProc.Parameters[i]);
      Result := Result + LParameter.Name + ': ' + LParameter.DataType.Name;
      if i < AProc.Parameters.Count - 1 then
      begin
        Result := Result + '; ';
      end;
    end;
  end;
  Result := Result + ')';
  if AProc.IsFunction then
  begin
    Result := Result + ': ' + AProc.ResultType.Name;
  end;
end;

constructor TCodeTreeController.Create(ATree: TVirtualStringTree);
begin
  FTree := ATree;
  FTree.NodeDataSize := SizeOf(TCodeNodeData);
  FTree.OnGetImageIndex := HandleGetImageIndex;
  FTree.OnGetText := HandleCodeTreeGetText;
end;

procedure TCodeTreeController.CreateSectionNodes;
begin
  FUses := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(FUses)).Caption := 'Uses';
  PCodeNodeData(FTree.GetNodeData(FUses)).Line := -1;
  PCodeNodeData(FTree.GetNodeData(FUses)).CodeType := ctSection;
  FVars := FTree.AddChild(nil);
  FTypes := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(FTypes)).Caption := 'Types';
  PCodeNodeData(FTree.GetNodeData(FTypes)).Line := -1;
  PCodeNodeData(FTree.GetNodeData(FTypes)).CodeType := ctSection;
  PCodeNodeData(FTree.GetNodeData(FVars)).Caption := 'Vars';
  PCodeNodeData(FTree.GetNodeData(FVars)).Line := -1;
  PCodeNodeData(FTree.GetNodeData(FVars)).CodeType := ctSection;
  FProcedures := FTree.AddChild(nil);
  PCodeNodeData(FTree.GetNodeData(FProcedures)).Caption := 'Procedures';
  PCodeNodeData(FTree.GetNodeData(FProcedures)).Line := -1;
  PCodeNodeData(FTree.GetNodeData(FProcedures)).CodeType := ctSection;
end;

function TCodeTreeController.GetImages: TImageList;
begin
  Result := TImageList(FTree.Images);
end;

procedure TCodeTreeController.HandleCodeTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  CellText := PCodeNodeData(Sender.GetNodeData(Node)).Caption;
end;

procedure TCodeTreeController.HandleGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  if Kind in [ikNormal, ikSelected] then
  begin
    case PCodeNodeData(Sender.GetNodeData(Node)).CodeType of
      ctSection: ImageIndex := 0;
      ctType: ImageIndex := 1;
      ctVar: ImageIndex := 2;
      ctUses: ImageIndex := 3;
      ctProcedure: ImageIndex := 4;
      ctFunction: ImageIndex := 5;
      else
      begin
        ImageIndex := -1;
      end;
    end;
  end
  else
  begin
    ImageIndex := -1;
  end;
end;

procedure TCodeTreeController.SetImages(const Value: TImageList);
begin
  FTree.Images := Value;
end;

end.
