unit DockClient;

interface

uses
  Classes, Types, Forms, JvDockControlForm;

type
  TDockClient = class(TForm)
  private
    FDockClient: TJvDockClient;
  public
    constructor Create(AOwner: TComponent); override;
    property DockClient: TJvDockClient read FDockClient;
  end;

implementation

{ TDockClient }

constructor TDockClient.Create(AOwner: TComponent);
begin
  inherited;
  FDockClient := TJvDockClient.Create(Self);
end;

end.
