unit ProjectOptionDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Project, StdCtrls;

type
  TProjectOption = class(TForm)
    cbOptimize: TCheckBox;
    cbAssemble: TCheckBox;
    cbBuildModule: TCheckBox;
    cbUseBigEndian: TCheckBox;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadFromProject(AProject: TProject);
    procedure SaveToProject(AProject: TProject);
  end;

var
  ProjectOption: TProjectOption;

implementation

{$R *.dfm}

{ TProjectOption }

procedure TProjectOption.LoadFromProject(AProject: TProject);
begin
  cbAssemble.Checked := AProject.Assemble;
  cbOptimize.Checked := AProject.Optimize;
  cbBuildModule.Checked := AProject.BuildModule;
  cbUseBigEndian.Checked := AProject.UseBigEndian;
end;

procedure TProjectOption.SaveToProject(AProject: TProject);
begin
  AProject.Assemble := cbAssemble.Checked;
  AProject.Optimize := cbOptimize.Checked;
  AProject.BuildModule := cbBuildModule.Checked;
  AProject.UseBigEndian := cbUseBigEndian.Checked;
end;

end.
