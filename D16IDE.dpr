program D16IDE;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Project in 'Project.pas',
  IdeUnit in 'IdeUnit.pas',
  CompilerDefines in '..\D16Pascal\CompilerDefines.pas',
  CompilerUtil in '..\D16Pascal\CompilerUtil.pas',
  ProjectOptionDialog in 'ProjectOptionDialog.pas' {ProjectOption},
  CPUViewForm in 'CPUViewForm.pas' {CPUView},
  WatchViewForm in 'WatchViewForm.pas' {WatchView},
  IDEEdit in 'IDEEdit.pas',
  IDEPageFrame in 'IDEPageFrame.pas' {IDEPage: TFrame},
  IDETabSheet in 'IDETabSheet.pas',
  UnitTemplates in 'UnitTemplates.pas',
  ProjectTreeController in 'ProjectTreeController.pas',
  SimpleRefactor in 'SimpleRefactor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TProjectOption, ProjectOption);
  Application.Run;
end.
