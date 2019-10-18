library beatmark;

uses
  SysUtils,
  Classes,
  Windows,
  Messages,
  MMSystem;

var
//  Data: PChar = nil;
  Audio: PSmallInt = nil;
  Samples: Integer = 0;
  Han: Integer = -1;
  Call: Integer = 0;
  Format: tWAVEFORMATEX;
  Header: TWaveHdr;
  Stereo: Boolean;

function CloseFile(): Double;
begin
  if Han <> 0 then
  begin
    waveOutReset(Han);
    waveOutClose(Han);
  end;
//  if Data <> nil then
//    FreeMem(Data);
  if Audio <> nil then
    FreeMem(Audio);
//  Data:=nil;
  Audio := nil;
  Samples := 0;
  Han := 0;
  Call := 0;
  Result := 0;
end;

function LoadFile(name: string): Double; stdcall;
var
  stream: TFileStream;
  size, sps, chan: Integer;
begin
  CloseFile();
  Stereo := False;
  stream := TFileStream.Create(name, fmOpenRead or fmShareDenyNone);
  stream.Position := 22;
  chan := 0;
  stream.ReadBuffer(chan, 2);
  if chan = 2 then
    Stereo := True;
  stream.ReadBuffer(sps, 4);
  stream.Position := 44;
  size := (stream.Size - stream.Position) and not 1;
  GetMem(Audio, size);
  stream.ReadBuffer(Audio^, size);
  stream.Free();
  Format.wFormatTag := WAVE_FORMAT_PCM;
  Format.nChannels := chan;
  Format.wBitsPerSample := 16;
  Format.nSamplesPerSec := sps;
  Format.nBlockAlign := Format.nChannels * Format.wBitsPerSample div 8;
  Format.nAvgBytesPerSec := Format.nBlockAlign * Format.nSamplesPerSec;
  Format.cbSize := 0;
  waveOutOpen(@Han, WAVE_MAPPER, @Format, 0, 0, 0);
  Samples := size div 2;
  if Stereo then
    Samples := Samples div 2;
  Result := Samples;
end;

function GetByte(Index: Double): Double; stdcall;
var
  val: Integer;
  cur: PSmallInt;
begin
  val := Round(Index);
  if (val < 0) or (val >= Samples) then
    Result := 0
  else
  begin
    cur := Audio;
    if Stereo then
    begin
      Inc(cur, val + val);
      val := cur^;
      Inc(cur);
      Result := (cur^ + val) / $fffe;
    end
    else
    begin
      Inc(cur, val);
      Result := cur^ / $7fff;
    end;
  end;
end;

function PlayFrom(Index: Double): Double; stdcall;
var
  from: PSmallInt;
const
  max = 1024 * 1024 * 8;
begin
  Result := 0;
  waveOutReset(Han);
  waveOutUnPrepareHeader(Han, @Header, SizeOf(Header));
  Call := Round(Index);
  if (Call < 0) or (Call >= Samples) then
    Exit;
  from := Audio;
  if Stereo then
  begin
    Inc(from, Call * 2);
    Header.dwBufferLength := (Samples - Call) * 4;
  end
  else
  begin
    Inc(from, Call);
    Header.dwBufferLength := (Samples - Call) * 2;
  end;
  Header.lpData := Pointer(from);
  Header.dwFlags := 0;
  Header.dwLoops := 0;
  if Header.dwBufferLength > max then
    Header.dwBufferLength := max;
  waveOutPrepareHeader(Han, @Header, SizeOf(Header));
  waveOutWrite(Han, @Header, SizeOf(Header));
end;

function CurrentPos(): Double; stdcall;
var
  time: tMMTIME;
begin
  time.wType := TIME_SAMPLES;
  waveOutGetPosition(Han, @time, SizeOf(time));
  Result := Integer(time.sample) + Call;
end;

exports
  LoadFile,
  GetByte,
  CloseFile,
  PlayFrom,
  CurrentPos;

begin
end.

