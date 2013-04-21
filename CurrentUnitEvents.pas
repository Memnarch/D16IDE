unit CurrentUnitEvents;

interface

uses
  Classes, Types, IDEUnit, PascalUnit, Events;

const
  evCurrentUnitCacheChanged = 100;

type
  TCurrentUnitEventData = class(TEventData)
  private
    FPascalUnit: TPascalUnit;
  public
    property UnitCache: TPascalUnit read FPascalUnit write FPascalUnit;
  end;

implementation

end.
