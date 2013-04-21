unit Events;

interface

uses
  Classes, Types;

type
  //eventdata base class
  TEventData = class
  private
    FEventID: Integer;
  public
    property EventID: Integer read FEventID write FEventID;
  end;

implementation

end.
