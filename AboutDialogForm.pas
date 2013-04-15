unit AboutDialogForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls;

type
  TAboutDialog = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbIDEVersion: TLabel;
    lbCompilerVersion: TLabel;
    lbEmulatorVersion: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  AboutDialog: TAboutDialog;

implementation

uses
  IDEVersion, CompilerVersion, EmulatorVersion;

{$R *.dfm}

{ TAboutDialog }

constructor TAboutDialog.Create(AOwner: TComponent);
begin
  inherited;
  lbIDEVersion.Caption := CIDEVersion;
  lbCompilerVersion.Caption := CCompilerVersion;
  lbEmulatorVersion.Caption := CEmulatorVersion;
end;

end.
