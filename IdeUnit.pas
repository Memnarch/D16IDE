unit IdeUnit;

interface

uses
  Classes, Types, SynEdit;

type
  TIDEUnit = class
  private
    FSynEdit: TSynEdit;
    FSavePath: string;
    FCaption: string;
    FImageIndex: Integer;
    function GetIsOpen: Boolean;
    function GetSynEdit: TSynEdit;
  public
    destructor Destroy(); override;
    procedure Open();
    procedure Close();
    procedure SaveToFile(AFile: string);
    property Caption: string read FCaption write FCaption;
    property SavePath: string read FSavePath write FSavePath;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property SynEdit: TSynEdit read GetSynEdit;
    property IsOpen: Boolean read GetIsOpen;
  end;

implementation

uses
  SysUtils;

{ TIDEUnit }

procedure TIDEUnit.Close;
begin
  FSynEdit.Free;
  FSynEdit := nil;
end;

destructor TIDEUnit.Destroy;
begin
  if IsOpen then
  begin
    Close();
  end;
  inherited;
end;

function TIDEUnit.GetIsOpen: Boolean;
begin
  Result := Assigned(FSynEdit);
end;

function TIDEUnit.GetSynEdit: TSynEdit;
begin
  Result := FSynEdit;
  if not Assigned(FSynEdit) then
  begin
    raise Exception.Create('Unit is not open');
  end;
end;

procedure TIDEUnit.Open;
begin
  if not IsOpen then
  begin
    FSynEdit := TSynEdit.Create(nil);
    FSynEdit.Name := 'SynEdit';
    FSynEdit.Gutter.ShowLineNumbers := True;
    FSynEdit.WantTabs := True;
    FSynEdit.TabWidth := 2;
    FSynEdit.Options := FSynEdit.Options - [eoSmartTabs];
    if (SavePath <> '') and FileExists(FSavePath) then
    begin
      FSynEdit.Lines.LoadFromFile(FSavePath);
    end;
  end;
end;

procedure TIDEUnit.SaveToFile(AFile: string);
begin
  ForceDirectories(ExcludeTrailingBackslash(ExtractFilePath(AFile)));
  FSynEdit.Lines.SaveToFile(AFile);
end;

end.
