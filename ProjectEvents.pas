unit ProjectEvents;

interface

uses
  Classes, Types, Events, Project;

const
  evProjectChanged = 0;

type
  TProjectEvenetData = class(TEventData)
  private
    FProject: TProject;
  public
    property Project: TProject read FProject write FProject;
  end;

implementation

end.
