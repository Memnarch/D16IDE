unit IDEView;

interface

uses
  Classes, Types, Forms, DockClient, Events, IDEControllerIntf;

type
  TIDEView = class(TDockClient)
  private
    FController: IIDEController;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Event(AEventData: TEventData); virtual;
    property Controller: IIDEController read FController write FController;
  end;

implementation

{ TIDEView }

constructor TIDEView.Create(AOwner: TComponent);
begin
  inherited;
  BorderStyle := bsSizeToolWin;
end;

procedure TIDEView.Event(AEventData: TEventData);
begin

end;

end.
