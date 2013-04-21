unit CompilerEvents;

interface

uses
  Classes, Types, Events, CompilerDefines;

const
  evStartCompiling = 200;
  evFinishCompiling = 201;
  evCompilerMessage = 202;

type
  TCompilerMessageEventData = class(TEventData)
  private
    FLevel: TMessageLevel;
    FD16UnitName: string;
    FMessage: string;
    FLine: Integer;
  public
    property Message: string read FMessage write FMessage;
    property D16UnitName: string read FD16UnitName write FD16UnitName;
    property Line: Integer read FLine write FLine;
    property Level: TMessageLevel read FLevel write FLevel;
  end;

implementation

end.
