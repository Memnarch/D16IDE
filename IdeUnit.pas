unit IdeUnit;

interface

uses
  Classes, Types, SynEdit;

type
  TIDEUnit = class
  private
    FSavePath: string;
    FCaption: string;
    FImageIndex: Integer;
    FSourceLink: TStrings;
    FOnRename: TNotifyEvent;
    function GetFileName: string;
    procedure DoOnRename();
    procedure CheckIfReady();
    procedure SetSourceLink(const Value: TStrings);
    procedure SetCaption(const Value: string);
  public
    destructor Destroy(); override;
    procedure Save();
    procedure Load();
    property Caption: string read FCaption write SetCaption;
    property SavePath: string read FSavePath write FSavePath;
    property FileName: string read GetFileName;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property SourceLink: TStrings read FSourceLink write SetSourceLink;
    property OnRename: TNotifyEvent read FOnRename write FOnRename;
  end;

implementation

uses
  Windows, SysUtils;

{ TIDEUnit }

procedure TIDEUnit.CheckIfReady;
begin
  if not Assigned(FSourceLink) then
  begin
    raise Exception.Create('No SOurceLink assigned');
  end;
end;

destructor TIDEUnit.Destroy;
begin
  inherited;
end;

procedure TIDEUnit.DoOnRename;
begin
  if Assigned(FOnRename) then
  begin
    FOnRename(Self);
  end;
end;

function TIDEUnit.GetFileName: string;
begin
  Result := ChangeFileExt(IncludeTrailingBackslash(FSavePath) + FCaption, '.pas');
end;

procedure TIDEUnit.Load;
begin
  CheckIfReady();
  FSourceLink.LoadFromFile(FileName);
end;

procedure TIDEUnit.Save;
begin
  CheckIfReady();
  FSourceLink.SaveToFile(FileName);
end;

procedure TIDEUnit.SetCaption(const Value: string);
begin
  FCaption := Value;
  DoOnRename();
end;

procedure TIDEUnit.SetSourceLink(const Value: TStrings);
begin
  FSourceLink := Value;
  if FileExists(FileName) then
  begin
    Load();
  end;
end;

end.
