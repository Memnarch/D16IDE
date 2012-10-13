unit CPUViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, StdCtrls, ExtCtrls, Emulator;

type
  TCPUView = class(TForm)
    RegisterList: TValueListEditor;
    ASMView: TListBox;
    pnlBottom: TPanel;
    Label1: TLabel;
    Label7: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbPC: TLabel;
    lbIA: TLabel;
    lbQueue: TLabel;
    Label4: TLabel;
    lbCycles: TLabel;
  private
    { Private declarations }
    FEmu: TD16Emulator;
  public
    { Public declarations }
    procedure SetEmulator(AEmu: TD16Emulator);
    procedure LoadASMFromFile(AFile: string);
    procedure UpdateData();
  end;

var
  CPUView: TCPUView;

implementation

uses
  EmuTypes;

{$R *.dfm}

{ TCPUView }

procedure TCPUView.LoadASMFromFile(AFile: string);
begin
  ASMView.Items.LoadFromFile(AFile);
end;

procedure TCPUView.SetEmulator(AEmu: TD16Emulator);
begin
  FEmu := AEmu;
  FEmu.OnIdle := UpdateData;
end;

procedure TCPUView.UpdateData;
begin
  RegisterList.Values['A'] := '0x' + IntToHex(FEmu.Registers[CRegA], 4);
  RegisterList.Values['B'] := '0x' + IntToHex(FEmu.Registers[CRegB], 4);
  RegisterList.Values['C'] := '0x' + IntToHex(FEmu.Registers[CRegC], 4);
  RegisterList.Values['X'] := '0x' + IntToHex(FEmu.Registers[CRegX], 4);
  RegisterList.Values['Y'] := '0x' + IntToHex(FEmu.Registers[CRegY], 4);
  RegisterList.Values['Z'] := '0x' + IntToHex(FEmu.Registers[CRegZ], 4);
  RegisterList.Values['I'] := '0x' + IntToHex(FEmu.Registers[CRegI], 4);
  RegisterList.Values['J'] := '0x' + IntToHex(FEmu.Registers[CRegJ], 4);

  lbPC.Caption := '0x' + IntToHex(FEmu.Registers[CRegPC], 4);
  lbIA.Caption := '0x' + IntToHex(FEmu.Registers[CRegIA], 4);
  lbQueue.Caption := IntToStr(FEmu.InterruptQueue.Count);
  lbCycles.Caption := IntToStr(FEmu.Cycles);
end;

end.
