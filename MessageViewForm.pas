unit MessageViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IDEView, VirtualTrees, LogTreeController, Events, IDEModule;

type
  TMessageView = class(TIDEView)
    LogTree: TVirtualStringTree;
    procedure LogTreeDblClick(Sender: TObject);
  private
    { Private declarations }
    FTreeController: TLogTreeController;
    FIDEData: TIDEData;
    procedure SetIDEData(const Value: TIDEData);
    procedure FocusFirstError();
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure Event(AEventData: TEventData); override;
    property IDEData: TIDEData read FIDEData write SetIDEData;
  end;

var
  MessageView: TMessageView;

implementation

uses
  CompilerEvents;

{$R *.dfm}

{ TMessageView }

constructor TMessageView.Create(AOwner: TComponent);
begin
  inherited;
  FTreeController := TLogTreeController.Create(LogTree);
end;

destructor TMessageView.Destroy;
begin
  FTreeController.Free;
  inherited;
end;

procedure TMessageView.Event(AEventData: TEventData);
var
  LData: TCompilerMessageEventData;
begin
  inherited;
  if AEventData.EventID = evCompilerMessage then
  begin
    LData := TCompilerMessageEventData(AEventData);
    FTreeController.Add(LData.Message, LData.D16UnitName, LData.Line, LData.Level);
  end;
  if AEventData.EventID = evStartCompiling then
  begin
    LogTree.Clear();
  end;
  if AEventData.EventID = evFinishCompiling then
  begin
    FocusFirstError();
  end;
end;

procedure TMessageView.FocusFirstError;
var
  LData: TLogEntry;
begin
  LData := FTreeController.GetFirstError();
  if LData.Line > -1 then
  begin
    Controller.FokusIDEEdit(LData.UnitName, -1, LData.Line);
  end;
end;

procedure TMessageView.LogTreeDblClick(Sender: TObject);
var
  LPos: TPoint;
  LNode: PVirtualNode;
  LData: PLogEntry;
begin
  if GetCursorPos(LPos) then
  begin
    LPos := LogTree.ScreenToClient(LPos);
    LNode := LogTree.GetNodeAt(LPos.X, LPos.Y);
    if Assigned(LNode) then
    begin
      LData := LogTree.GetNodeData(LNode);
      if Assigned(LData) then
      begin
        if LData.Line > -1 then
        begin
          Controller.FokusIDEEdit(LData.UnitName, -1, LData.Line);
        end;
      end;
    end;
  end;
end;

procedure TMessageView.SetIDEData(const Value: TIDEData);
begin
  FIDEData := Value;
  if Assigned(FIDEData) then
  begin
    FTreeController.Images := FIDEData.LogImages;
  end
  else
  begin
    FTreeController.Images := nil;
  end;
end;

end.
