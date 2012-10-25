unit WatchViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, Emulator;

type
  TWatchView = class(TForm)
    ValueListEditor1: TValueListEditor;
  private
    { Private declarations }
    FEmulator: TD16Emulator;
    procedure UpdateData();
  public
    { Public declarations }
    procedure SetEmulator(AEmulator: TD16Emulator);
  end;

var
  WatchView: TWatchView;

implementation

{$R *.dfm}

{ TWatchView }

procedure TWatchView.SetEmulator(AEmulator: TD16Emulator);
begin
  FEmulator := AEmulator;
  FEmulator.OnIdle := UpdateData;
end;

procedure TWatchView.UpdateData;
begin

end;

end.
