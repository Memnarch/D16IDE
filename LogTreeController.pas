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
    function GetPrefixForEntryType(AType: TMessageLevel): string;
    procedure HandleGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: UnicodeString);
    procedure HandleGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
  public
    constructor Create(ATree: TVirtualStringTree);
    destructor Destroy(); override;
    procedure Clear();
    procedure Add(AMessage: string; AUnitName: string = ''; ALine: Integer = -1; AEntryType: TMessageLevel = mlNone);
    function GetFirstError(): TLogEntry;
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
  FTree.OnGetImageIndex := HandleGetImageIndex;
end;

destructor TLogTreeController.Destroy;
begin
  inherited;
end;

function TLogTreeController.GetFirstError: TLogEntry;
var
  LNode: PVirtualNode;
  LData: PLogEntry;
begin
  Result.Line := -1;
  LNode := FTree.GetFirst();
  while Assigned(LNode) do
  begin
    LData := FTree.GetNodeData(LNode);
    if Assigned(LData) and (LData.Line > -1) and (LData.EntryType in [mlError, mlFatal]) then
    begin
      Result := LData^;
    end;
    LNode := FTree.GetNextSibling(LNode);
  end;
end;

function TLogTreeController.GetImages: TImageList;
begin
  Result := TImageList(FTree.Images);
end;

function TLogTreeController.GetPrefixForEntryType(AType: TMessageLevel): string;
begin
  case AType of
    mlWarning: Result := 'Warning';
    mlError: Result := 'Error';
    mlFatal: Result := 'Fatal';
    else
    begin
      Result := '';
    end;
  end;
end;

procedure TLogTreeController.HandleGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  LData: PLogEntry;
begin
  if Kind in [ikNormal, ikSelected] then
  begin
    LData := Sender.GetNodeData(Node);
    case LData.EntryType of
      mlWarning: ImageIndex := 0;
      mlError: ImageIndex := 1;
      mlFatal: ImageIndex := 2;
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
    CellText := GetPrefixForEntryType(LData.EntryType) + ' in ' + LData.UnitName + '(' + IntToStr(LData.Line) + '): ' + LData.Message;
  end;
end;

procedure TLogTreeController.SetImages(const Value: TImageList);
begin
  FTree.Images := Value;
end;

end.
