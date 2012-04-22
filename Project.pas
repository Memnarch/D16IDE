unit Project;

interface

uses
  Classes, Types, Generics.Collections, IDEUnit;

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
    property ProjectName: string read FProjectName write FProjectName;
    property ProjectPath: string read FProjectPath write FProjectPath;
    property Units: TObjectList<TIDEUnit> read FUnits;
    property Optimize: Boolean read FOptimize write FOptimize;
    property Assemble: Boolean read FAssemble write FAssemble;
    property BuildModule: Boolean read FBuildModule write FBuildModule;
    property UseBigEndian: Boolean read FUseBigEndian write FUseBigEndian;
  end;

implementation

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

end.
