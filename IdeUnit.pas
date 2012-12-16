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
    FExtension: string;
    FOnAfterSave: TNotifyEvent;
    FOnAfterLoad: TNotifyEvent;
    function GetFileName: string;
    procedure DoOnRename();
    procedure SetSourceLink(const Value: TStrings);
    procedure SetCaption(const Value: string);
    procedure SetFileName(const Value: string);
    procedure DoAfterLoad();
    procedure DoAfterSave();
    function GetIsOpen: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Save();
    procedure Load();
    property Caption: string read FCaption write SetCaption;
    property SavePath: string read FSavePath write FSavePath;
    property FileName: string read GetFileName write SetFileName;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property SourceLink: TStrings read FSourceLink write SetSourceLink;
    property OnRename: TNotifyEvent read FOnRename write FOnRename;
    property IsOpen: Boolean read GetIsOpen;
    property OnAfterSave: TNotifyEvent read FOnAfterSave write FOnAfterSave;
    property OnAfterLoad: TNotifyEvent read FOnAfterLoad write FOnAfterLoad;
  end;

implementation

uses
  Windows, SysUtils;

{ TIDEUnit }

constructor TIDEUnit.Create;
begin
  FExtension := '.pas';
end;

destructor TIDEUnit.Destroy;
begin
  inherited;
end;

procedure TIDEUnit.DoAfterLoad;
begin
  if Assigned(FOnAfterLoad) then
  begin
    FOnAfterLoad(Self);
  end;
end;

procedure TIDEUnit.DoAfterSave;
begin
  if Assigned(FOnAfterSave) then
  begin
    FOnAfterSave(Self);
  end;
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
  Result := ChangeFileExt(IncludeTrailingBackslash(FSavePath) + FCaption, FExtension);
end;

function TIDEUnit.GetIsOpen: Boolean;
begin
  Result := Assigned(FSourceLink);
end;

procedure TIDEUnit.Load;
begin
  if IsOpen then
  begin
    FSourceLink.LoadFromFile(FileName);
    DoAfterLoad();
  end;
end;

procedure TIDEUnit.Save;
begin
  if IsOpen then
  begin
    FSourceLink.SaveToFile(FileName);
    DoAfterSave();
  end;
end;

procedure TIDEUnit.SetCaption(const Value: string);
begin
  FCaption := Value;
  DoOnRename();
end;

procedure TIDEUnit.SetFileName(const Value: string);
begin
  FSavePath := ExtractFilePath(Value);
  Caption := ChangeFileExt(ExtractFileName(Value), '');
  FExtension := ExtractFileExt(Value);
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
