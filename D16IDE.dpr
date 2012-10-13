program D16IDE;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Project in 'Project.pas',
  IdeUnit in 'IdeUnit.pas',
  CompilerDefines in '..\D16Pascal\CompilerDefines.pas',
  CompilerUtil in '..\D16Pascal\CompilerUtil.pas',
  ProjectOptionDialog in 'ProjectOptionDialog.pas' {ProjectOption},
  CPUViewForm in 'CPUViewForm.pas' {CPUView};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TProjectOption, ProjectOption);
  Application.CreateForm(TCPUView, CPUView);
  Application.Run;
end.
