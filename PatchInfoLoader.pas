unit PatchInfoLoader;

interface

uses
  Classes, Types, SysUtils, ExtActns;

type
  TPatchInfoLoader = class
  private

  public
    function DownloadInfoFile(AFile: string): Boolean;
  end;

implementation

uses
  IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP;


{ TPatchInfoLoader }

function TPatchInfoLoader.DownloadInfoFile(AFile: string): Boolean;
var
  LDL: TIdHTTP;
  LStream: TMemoryStream;
begin
  Result := False;
  if FileExists(AFile) then
  begin
    if not DeleteFile(AFile) then
    begin
      Exit;
    end;
  end;
  LDL := TIdHTTP.Create(nil);
  LStream := TMemoryStream.Create();
  try
    with LDL do
    begin
      Request.Connection := 'Keep-Alive';
      Request.ProxyConnection := 'Keep-Alive';
      Request.Referer := 'http://www.google.com';
      Request.CacheControl := 'no-cache';  //this force use no-cache
    end;
    LDL.Get('http://memnarch.bplaced.net/updates.info', LStream);
    LStream.SaveToFile(AFile);
    Result := True;
  finally
    LDL.Free;
    LStream.Free;
  end;
end;

end.
