unit LogTreeController;

interface

uses
  Classes, Types, Controls, SysUtils, VirtualTrees, CompilerDefines;

type
  TLogEntry = record
    Message: string;
    UnitName: string;
    Line: Integer;
    EntryType: TMessageLevel;
  end;

  PLogEntry = ^TLogEntry;

  TLogTreeController = class(TObject)
  private
    FTree: TVirtualStringTree;
    function GetImages: TImageList;
    procedure SetImages(const Value: TImageList);
    procedure HandleGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: UnicodeString);
  public
    constructor Create(ATree: TVirtualStringTree);
    destructor Destroy(); override;
    procedure Clear();
    procedure Add(AMessage: string; AUnitName: string = ''; ALine: Integer = -1; AEntryType: TMessageLevel = mlNone);
    property Images: TImageList read GetImages write SetImages;
  end;

implementation

{ TLogTreeController }

procedure TLogTreeController.Add(AMessage: string; AUnitName: string = '';
  ALine: Integer = -1; AEntryType: TMessageLevel = mlNone);
var
  LData: PLogEntry;
  LNode: PVirtualNode;
begin
  LNode := FTree.AddChild(nil);
  LData := FTree.GetNodeData(LNode);
  LData.Message := AMessage;
  LData.UnitName := AUnitName;
  LData.Line := ALine;
  LData.EntryType := AEntryType;
end;

procedure TLogTreeController.Clear;
begin
  FTree.Clear();
end;

constructor TLogTreeController.Create(ATree: TVirtualStringTree);
begin
  FTree := ATree;
  FTree.NodeDataSize := SizeOf(TLogEntry);
  FTree.TreeOptions.PaintOptions := FTree.TreeOptions.PaintOptions - [toShowTreeLines] + [toHideFocusRect];
  FTree.TreeOptions.SelectionOptions := FTree.TreeOptions.SelectionOptions + [toFullRowSelect];
  FTree.OnGetText := HandleGetText;
end;

destructor TLogTreeController.Destroy;
begin
  inherited;
end;

function TLogTreeController.GetImages: TImageList;
begin
  Result := TImageList(FTree.Images);
end;

procedure TLogTreeController.HandleGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: UnicodeString);
var
  LData: PLogEntry;
begin
  LData := Sender.GetNodeData(Node);
  if LData.EntryType = mlNone then
  begin
    CellText := LData.Message;
  end
  else
  begin
    CellText := 'Error in ' + LData.UnitName + '(' + IntToStr(LData.Line) + '): ' + LData.Message;
  end;
end;

procedure TLogTreeController.SetImages(const Value: TImageList);
begin
  FTree.Images := Value;
end;

end.
