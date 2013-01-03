unit WatchViewForm;

interface

uses
  Types, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, Emulator, RoutineMapping, Debugger;

type
  TWatchView = class(TForm)
    Values: TValueListEditor;
  private
    FDebugger: TDebugger;
    { Private declarations }
    function SpecifierToAddress(ASpecifier: string): Word;
    function AccessToAddress(AString: string): Word;
    function IsRegisterOnly(AString: string): Boolean;
  public
    { Public declarations }
    property Debugger: TDebugger read FDebugger write FDebugger;
    procedure UpdateData(ARoutine: TRoutineMapping);
  end;

var
  WatchView: TWatchView;

implementation

uses
  StrUtils, EmuTypes;

{$R *.dfm}

{ TWatchView }

function TWatchView.AccessToAddress(AString: string): Word;
var
  LData: TStringDynArray;
  LSpecifier: string;
begin
  Result := 0;
  LData := SplitString(AString, '+');
  for LSpecifier in LData do
  begin
    Result := Result + SpecifierToAddress(LSpecifier);
  end;
end;

function TWatchView.IsRegisterOnly(AString: string): Boolean;
begin
  Result := RegisterToIndex(Trim(AString)) > -1;
end;

function TWatchView.SpecifierToAddress(ASpecifier: string): Word;
var
  LValue: Integer;
begin
  if TryStrToInt(Trim(ASpecifier), LValue) then
  begin
    Result := LValue;
  end
  else
  begin
    Result := FDebugger.ReadRegister(RegisterToIndex(Trim(ASpecifier)));
  end;
end;

procedure TWatchView.UpdateData(ARoutine: TRoutineMapping);
var
  LParameter: TParameter;
  LValue: Integer;
  LText: string;
begin
  Values.Strings.BeginUpdate();
  try
    Values.Strings.Clear;
    if Assigned(ARoutine) then
    begin
      for LParameter in ARoutine.Parameters do
      begin
        if IsRegisterOnly(LParameter.Access) then
        begin
          LValue := FDebugger.ReadRegister(RegisterToIndex(Trim(LParameter.Access)));
        end
        else
        begin
          LValue := FDebugger.ReadWord(AccessToAddress(LParameter.Access));
        end;
        case AnsiIndexText(LParameter.TypeName, ['string', 'char']) of
          0: LText := FDebugger.ReadString(LValue);
          1: LText := Char(LValue and 127);
          else
          begin
            LText := IntToStr(LValue);
          end;
        end;
        Values.InsertRow(LParameter.Name, LText, True);
      end;
      for LParameter in ARoutine.Locals do
      begin
        LValue := FDebugger.ReadWord(AccessToAddress(LParameter.Access));
        case AnsiIndexText(LParameter.TypeName, ['string', 'char']) of
          0: LText := FDebugger.ReadString(LValue);
          1: LText := Char(LValue and 127); //FDebugger.ReadChar(LValue);
          else
          begin
            LText := IntToStr(LValue);
          end;
        end;
        Values.InsertRow(LParameter.Name, LText, True);
      end;
    end;
  finally
    Values.Strings.EndUpdate();
  end;
end;

end.
