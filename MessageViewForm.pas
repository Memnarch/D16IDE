unit MessageViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IDEView, VirtualTrees, LogTreeController;

type
  TMessageView = class(TIDEView)
    LogTree: TVirtualStringTree;
  private
    { Private declarations }
    FTreeController: TLogTreeController;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

var
  MessageView: TMessageView;

implementation

{$R *.dfm}

{ TMessageView }

constructor TMessageView.Create(AOwner: TComponent);
begin
  inherited;
  FTreeController := TLogTreeController.Create(LogTree);
end;

destructor TMessageView.Destroy;
begin
  FTreeController.Free;
  inherited;
end;

end.
