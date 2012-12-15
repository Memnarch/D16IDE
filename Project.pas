unit Project;

interface

uses
  Classes, Types, Windows, SysUtils, Generics.Collections, IDEUnit;

type
  TProject = class
  private
    FProjectPath: string;
    FProjectName: string;
    FUnits: TObjectList<TIDEUnit>;
    FBuildModule: Boolean;
    FOptimize: Boolean;
    FAssemble: Boolean;
    FUseBigEndian: Boolean;
    FProjectSource: TStringList;
    FProjectUnit: TIDEUnit;
    procedure SetProjectName(const Value: string);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure SaveToFile(AFile: string);
    procedure LoadFromFile(AFile: string);
    property ProjectName: string read FProjectName write SetProjectName;
    property ProjectPath: string read FProjectPath write FProjectPath;
    property Units: TObjectList<TIDEUnit> read FUnits;
    property ProjectUnit: TIDEUnit read FProjectUnit;
    property Optimize: Boolean read FOptimize write FOptimize;
    property Assemble: Boolean read FAssemble write FAssemble;
    property BuildModule: Boolean read FBuildModule write FBuildModule;
    property UseBigEndian: Boolean read FUseBigEndian write FUseBigEndian;
  end;

implementation

uses
  xmldom, XMLIntf, msxmldom, XMLDoc, SimpleRefactor;
{ TProject }

constructor TProject.Create;
begin
  FUnits := TObjectList<TIDEUnit>.Create();
  FOptimize := True;
  FAssemble := True;
  FBuildModule := False;
  FUseBigEndian := True;
  FProjectSource := TStringList.Create();
  FProjectUnit := TIDEUnit.Create();
end;

destructor TProject.Destroy;
begin
  FUnits.Free;
  FProjectUnit.Free;
  FProjectSource.Free;
  inherited;
end;

procedure TProject.LoadFromFile(AFile: string);
var
  LDoc: IXMLDocument;
  LNode, LRoot: IXMLNode;
  i: Integer;
  LPath: string;
  LUnit: TIDEUnit;
begin
  FProjectUnit.FileName := ChangeFileExt(AFile, '.d16r');
  LDoc := TXMLDocument.Create(nil);
  LDoc.Active := True;
  LDoc.LoadFromFile(AFile);
  LRoot := LDoc.ChildNodes.First;
  ProjectName := ChangeFileExt(LRoot.Attributes['Name'], '.d16p');
  ProjectPath := ExtractFilePath(AFile);
  for i := 0 to LRoot.ChildNodes.Count - 1 do
  begin
    LNode := LRoot.ChildNodes.Nodes[i];
    LPath := ProjectPath + LNode.Attributes['Path'];
    LUnit := TIDEUnit.Create();
    LUnit.FileName := LPath;
    FUnits.Add(LUnit);
  end;
end;

procedure TProject.SaveToFile(AFile: string);
var
  LDoc: IXMLDocument;
  LRootNode, LSubNode: iXMLNode;
  LUnit: TIDEUnit;
begin
  FProjectUnit.FileName := ChangeFileExt(AFile, '.d16r');
  FProjectUnit.Save;
  LDoc := TXMLDocument.Create(nil);
  LDoc.Active := True;
  LRootNode := LDoc.AddChild('Project');
  LRootNode.Attributes['Name'] := ChangeFileExt(ExtractFileName(AFile), '');
  for LUnit in FUnits do
  begin
    LSubNode := LRootNode.AddChild('Unit');
    LSubNode.Attributes['Path'] := ExtractRelativePath(FProjectPath, LUnit.FileName);
  end;
  LDoc.SaveToFile(AFile);
end;

procedure TProject.SetProjectName(const Value: string);
var
  LRefactor: TSimpleRefactor;
begin
  FProjectName := Value;
  if (not FProjectUnit.IsOpen) then
  begin
    if FileExists(FProjectUnit.FileName) then
    begin
      LRefactor := TSimpleRefactor.Create(FProjectSource);
      try
        FProjectSource.LoadFromFile(FProjectUnit.FileName);
        LRefactor.RenameHeader(ChangeFileExt(Value, ''));
        FProjectUnit.Caption := ChangeFileExt(Value, '');
        FProjectSource.SaveToFile(FProjectUnit.FileName);
      finally
        LRefactor.Free;
      end;
    end;
  end
  else
  begin
    FProjectUnit.Caption := ChangeFileExt(Value, '');
  end;
end;

end.
