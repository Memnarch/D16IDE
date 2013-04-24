unit DebugEvents;

interface

uses
  Classes, Types, Debugger, Events;

const
  CDebugStep = 200;

type
  TDebugEeventData = class(TEventData)
  private
    FDebugger: TDebugger;
  public
    property Debugger: TDebugger read FDebugger write FDebugger;
  end;

implementation

end.
