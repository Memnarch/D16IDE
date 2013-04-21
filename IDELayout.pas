unit IDELayout;

interface

uses
  Classes, Types, Windows, Forms, SysUtils, Generics.Collections, IDEView, EventGroups, Events,
  JvDockControlForm, JvDockTree, JvDockVIDStyle, JvDockVSNetStyle;

type
  TIDELayout = class
  private
    FServer: TJvDockServer;
    FViews: TObjectList<TIDEView>;
    FProjectViews: TObjectList<TIDEView>;
    FEmulatorViews: TObjectList<TIDEView>;
    FCompilerViews: TObjectList<TIDEView>;
    FCurrentUnitViews: TObjectList<TIDEView>;
    FDebuggerViews: TObjectList<TIDEView>;
    procedure InvokeEvents(AList: TObjectList<TIDEView>; AEventData: TEventData);
  public
    constructor Create(AHostForm: TForm);
    destructor Destroy(); override;
    procedure RegisterView(AView: TIDEView; AGroups: TEventGroups);
    procedure CallEvent(AGroup: TEventGroup; AEventData: TEventData);
    procedure LoadFromFile(AFile: string);
    procedure SaveToFile(AFile: string);
    procedure Load(AName: string);
    procedure Save(AName: string);
  end;



implementation

{ TIDELayout }

procedure TIDELayout.CallEvent(AGroup: TEventGroup; AEventData: TEventData);
begin
  case AGroup of
    egProject: InvokeEvents(FProjectViews, AEventData);
    egCurrentUnit: InvokeEvents(FCurrentUnitViews, AEventData);
    egCompiler: InvokeEvents(FCompilerViews, AEventData);
    egEmulator: InvokeEvents(FEmulatorViews, AEventData);
    egDebugger: InvokeEvents(FDebuggerViews, AEventData);
  end;
end;

constructor TIDELayout.Create(AHostForm: TForm);
begin
  FServer := TJvDockServer.Create(AHostForm);
  FServer.DockStyle := TJvDockVSNetStyle.Create(FServer);
  FViews := TObjectList<TIDEView>.Create(False);
  FProjectViews := TObjectList<TIDEView>.Create(False);
  FEmulatorViews := TObjectList<TIDEView>.Create(False);
  FCompilerViews := TObjectList<TIDEView>.Create(False);
  FCurrentUnitViews := TObjectList<TIDEView>.Create(False);
  FDebuggerViews := TObjectList<TIDEView>.Create(False);
end;

destructor TIDELayout.Destroy;
begin
  FViews.Free();
  FProjectViews.Free;
  FEmulatorViews.Free;
  FCompilerViews.Free;
  FCurrentUnitViews.Free;
  FDebuggerViews.Free;
  FServer.Free();
  inherited;
end;

procedure TIDELayout.InvokeEvents(AList: TObjectList<TIDEView>;
  AEventData: TEventData);
var
  LView: TIDEView;
begin
  for LView in AList do
  begin
    LView.Event(AEventData);
  end;
end;

procedure TIDELayout.Load(AName: string);
begin
  LoadFromFile(ExtractFilePath(Application.ExeName) + AName + '.ini');
end;

procedure TIDELayout.LoadFromFile(AFile: string);
begin
  if FileExists(AFile) then
  begin
    LoadDockTreeFromFile(AFile);
  end;
end;

procedure TIDELayout.RegisterView(AView: TIDEView; AGroups: TEventGroups);
begin
  AView.DockClient.DockStyle := FServer.DockStyle;
  FViews.Add(AView);

  if egProject in AGroups then
  begin
    FProjectViews.Add(AView);
  end;

  if egCurrentUnit in AGroups then
  begin
    FCurrentUnitViews.Add(AView);
  end;

  if egCompiler in AGroups then
  begin
    FCompilerViews.Add(AView);
  end;

  if egEmulator in AGroups then
  begin
    FEmulatorViews.Add(AView);
  end;

  if egDebugger in AGroups then
  begin
    FDebuggerViews.Add(AView);
  end;
end;

procedure TIDELayout.Save(AName: string);
begin
  SaveToFile(ExtractFilePath(Application.ExeName) + AName + '.ini');
end;

procedure TIDELayout.SaveToFile(AFile: string);
begin
  SaveDockTreeToFile(AFile);
end;

end.
