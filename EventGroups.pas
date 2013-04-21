unit EventGroups;

interface

type
  TEventGroup = (egProject, egCurrentUnit, egCompiler, egEmulator, egDebugger);
  TEventGroups = set of TEventGroup;

implementation

end.
