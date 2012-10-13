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
  public
    constructor Create();
    destructor Destroy(); override;
    procedure SaveToFile(AFile: string);
    property ProjectName: string read FProjectName write FProjectName;
    property ProjectPath: string read FProjectPath write FProjectPath;
    property Units: TObjectList<TIDEUnit> read FUnits;
    property Optimize: Boolean read FOptimize write FOptimize;
    property Assemble: Boolean read FAssemble write FAssemble;
    property BuildModule: Boolean read FBuildModule write FBuildModule;
    property UseBigEndian: Boolean read FUseBigEndian write FUseBigEndian;
  end;

implementation

uses
  xmldom, XMLIntf, msxmldom, XMLDoc;
{ TProject }

constructor TProject.Create;
begin
  FUnits := TObjectList<TIDEUnit>.Create();
  FOptimize := True;
  FAssemble := True;
  FBuildModule := False;
  FUseBigEndian := True;
end;

destructor TProject.Destroy;
begin
  FUnits.Free;
  inherited;
end;

procedure TProject.SaveToFile(AFile: string);
var
  LDoc: IXMLDocument;
  LRootNode, LSubNode: iXMLNode;
  LUnit: TIDEUnit;
begin
  LDoc := TXMLDocument.Create(nil);
  LDoc.Active := True;
  LRootNode := LDoc.AddChild('Project');
  LRootNode.Attributes['Name'] := ChangeFileExt(ExtractFileName(AFile), '');
//  LNode := ProjectTree.GetFirstChild(ProjectTree.GetFirst());
//  while Assigned(LNode) do
//  begin
  for LUnit in FUnits do
  begin
    LSubNode := LRootNode.AddChild('Unit');
    LSubNode.Attributes['Path'] := LUnit.FileName;
  end;
  LDoc.SaveToFile(AFile);
end;

end.
