unit Debug;

interface

uses
  Classes, Types;

type
  TLogger = class
  private

  public
    class procedure LogInteger(AName: string; AValue: Integer);
    class procedure LogMessage(AText: string);
  end;

var
  SiMain: TLogger;

implementation

{ TLogger }

class procedure TLogger.LogInteger(AName: string; AValue: Integer);
begin

end;

class procedure TLogger.LogMessage(AText: string);
begin

end;

end.
