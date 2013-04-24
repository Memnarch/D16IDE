unit CPUViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, StdCtrls, ExtCtrls, Emulator, IDEView, Events;

type
  TCPUView = class(TIDEView)
    RegisterList: TValueListEditor;
    pnlBottom: TPanel;
    Label3: TLabel;
    lbQueue: TLabel;
    Label4: TLabel;
    lbCycles: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Event(AEventData: TEventData); override;
  end;

var
  CPUView: TCPUView;

implementation

uses
  EmuTypes, DebugEvents;

{$R *.dfm}

{ TCPUView }

procedure TCPUView.Event;
var
  LData: TDebugEeventData;
begin
  if AEventData.EventID = CDebugStep then
  begin
    LData := TDebugEeventData(AEventData);
    RegisterList.Values['A'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegA), 4);
    RegisterList.Values['B'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegB), 4);
    RegisterList.Values['C'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegC), 4);
    RegisterList.Values['X'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegX), 4);
    RegisterList.Values['Y'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegY), 4);
    RegisterList.Values['Z'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegZ), 4);
    RegisterList.Values['I'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegI), 4);
    RegisterList.Values['J'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegJ), 4);
    RegisterList.Values['EX'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegEX), 4);
    RegisterList.Values['SP'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegSP), 4);
    RegisterList.Values['PC'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegPC), 4);
    RegisterList.Values['IA'] := '0x' + IntToHex(LData.Debugger.ReadRegister(CRegIA), 4);
//    lbQueue.Caption := IntToStr(FEmu.InterruptQueue.Count);
//    lbCycles.Caption := IntToStr(FEmu.Cycles);
  end;
end;

end.
