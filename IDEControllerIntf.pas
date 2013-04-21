unit IDEControllerIntf;

interface

uses
  Classes, Types, IdeUnit, Project, IDEPageFrame;

type
  IIDEController = interface
    function SaveUnit(AUnit: TIDEUnit): Boolean;
    function GetTabIndexBelowCursor(): Integer;
    function SaveProject(AProject: TProject): Boolean;
    procedure AddPage(ATitle: string; AFile: string = ''; AUnit: TIDEUnit = nil);
    function ClosePage(AIndex: Integer): Boolean;
    procedure CreateNewProject(ATitle: string; AProjectFolder: string);
    procedure ClearProjects();
    procedure OpenProject(AFile: string);
    function GetActiveIDEPage(): TIDEPage;
    function IDEUnitIsOpen(AUnit: TIDEUnit): Boolean;
    function GetPageIndexForIdeUnit(AUnit: TIDEUnit): Integer;
    procedure FokusIDEPageByUnit(AUnit: TIDEUnit);
    procedure FokusIDEEdit(AUnitName: string; ADebugCursor: Integer = -1; AErrorCursor: Integer = -1);
    procedure FokusFirstError();
    procedure NewUnit();
    procedure Compile();
    procedure PeekCompile();
    procedure Run();
    procedure Stop();
    procedure Pause();
  end;

implementation

end.
