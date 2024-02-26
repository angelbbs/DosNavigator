{/////////////////////////////////////////////////////////////////////////
//
//  Dos Navigator Open Source 1.51.08
//  Based on Dos Navigator (C) 1991-99 RIT Research Labs
//
//  This programs is free for commercial and non-commercial use as long as
//  the following conditions are aheared to.
//
//  Copyright remains RIT Research Labs, and as such any Copyright notices
//  in the code are not to be removed. If this package is used in a
//  product, RIT Research Labs should be given attribution as the RIT Research
//  Labs of the parts of the library used. This can be in the form of a textual
//  message at program startup or in documentation (online or textual)
//  provided with the package.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//
//  1. Redistributions of source code must retain the copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//     must display the following acknowledgement:
//     "Based on Dos Navigator by RIT Research Labs."
//
//  THIS SOFTWARE IS PROVIDED BY RIT RESEARCH LABS "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
//  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
//  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The licence and distribution terms for any publically available
//  version or derivative of this code cannot be changed. i.e. this code
//  cannot simply be copied and put under another distribution licence
//  (including the GNU Public Licence).
//
//////////////////////////////////////////////////////////////////////////}
{$I STDEFINE.INC}
unit arc_LHA; {LHA}

interface

uses
  Archiver
  ;

type
  PLHAArchive = ^TLHAArchive;
  TLHAArchive = object(TARJArchive)
    constructor Init;
    procedure GetFile; virtual;
    function GetID: Byte; virtual;
    function GetSign: TStr4; virtual;
    end;

type
  LHAHdr = record
    Size: Byte;
    Sum: Byte;
    MethodID: array[1..5] of Char;
    PackedSize: LongInt;
    OriginSize: LongInt;
    Date: LongInt;
    Attr: Byte;
    Level: Byte;
    Name: array[0..255] of Char;
    end;

implementation
uses
  Advance, Advance1, Defines, Objects2, Streams, Dos, xTime, VPUtils
  ;

{ ----------------------------- LHA ------------------------------------}

constructor TLHAArchive.Init;
  var
    Sign: TStr5;
    q: String;
  begin
  Sign := GetSign;
  SetLength(Sign, Length(Sign)-1);
  Sign := Sign+#0;
  FreeStr := SourceDir+DNARC;
  TObject.Init;
  {$IFNDEF OS2}
  Packer := NewStr(GetVal(@Sign[1], @FreeStr[1], PPacker, 'LHA'));
  UnPacker := NewStr(GetVal(@Sign[1], @FreeStr[1], PUnPacker, 'LHA'));
  Extract := NewStr(GetVal(@Sign[1], @FreeStr[1], PExtract, 'e -a'));
  ExtractWP := NewStr(GetVal(@Sign[1], @FreeStr[1], PExtractWP, 'x -a'));
  Add := NewStr(GetVal(@Sign[1], @FreeStr[1], PAdd, 'a -a'));
  Move := NewStr(GetVal(@Sign[1], @FreeStr[1], PMove, 'm -a'));
  Delete := NewStr(GetVal(@Sign[1], @FreeStr[1], PDelete, 'd -a'));
  Garble := NewStr(GetVal(@Sign[1], @FreeStr[1], PGarble, ''));
  Test := NewStr(GetVal(@Sign[1], @FreeStr[1], PTest, '-t'));
  IncludePaths := NewStr(GetVal(@Sign[1], @FreeStr[1], PIncludePaths,
         '-d'));
  ExcludePaths := NewStr(GetVal(@Sign[1], @FreeStr[1], PExcludePaths, ''));
  ForceMode := NewStr(GetVal(@Sign[1], @FreeStr[1], PForceMode, '-m'));
  RecoveryRec := NewStr(GetVal(@Sign[1], @FreeStr[1], PRecoveryRec, ''));
  SelfExtract := NewStr(GetVal(@Sign[1], @FreeStr[1], PSelfExtract, '-s'));
  Solid := NewStr(GetVal(@Sign[1], @FreeStr[1], PSolid, ''));
  RecurseSubDirs := NewStr(GetVal(@Sign[1], @FreeStr[1], PRecurseSubDirs,
         ''));
  SetPathInside := NewStr(GetVal(@Sign[1], @FreeStr[1], PSetPathInside,
         ''));
  StoreCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PStoreCompression, '-z'));
  FastestCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PFastestCompression, ''));
  FastCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PFastCompression, ''));
  NormalCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PNormalCompression, ''));
  GoodCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PGoodCompression, ''));
  UltraCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PUltraCompression, ''));
  ComprListChar := NewStr(GetVal(@Sign[1], @FreeStr[1], PComprListChar,
         '@'));
  ExtrListChar := NewStr(GetVal(@Sign[1], @FreeStr[1], PExtrListChar, ''));
  {$ELSE}
  Packer := NewStr(GetVal(@Sign[1], @FreeStr[1], PPacker, 'LH32'));
  UnPacker := NewStr(GetVal(@Sign[1], @FreeStr[1], PUnPacker, 'LH32'));
  Extract := NewStr(GetVal(@Sign[1], @FreeStr[1], PExtract, 'e -a'));
  ExtractWP := NewStr(GetVal(@Sign[1], @FreeStr[1], PExtractWP, 'x -a'));
  Add := NewStr(GetVal(@Sign[1], @FreeStr[1], PAdd, 'a -a -e'));
  Move := NewStr(GetVal(@Sign[1], @FreeStr[1], PMove, 'm -a -e'));
  Delete := NewStr(GetVal(@Sign[1], @FreeStr[1], PDelete, 'd -a'));
  Garble := NewStr(GetVal(@Sign[1], @FreeStr[1], PGarble, ''));
  Test := NewStr(GetVal(@Sign[1], @FreeStr[1], PTest, '-t'));
  IncludePaths := NewStr(GetVal(@Sign[1], @FreeStr[1], PIncludePaths, ''));
  ExcludePaths := NewStr(GetVal(@Sign[1], @FreeStr[1], PExcludePaths, ''));
  ForceMode := NewStr(GetVal(@Sign[1], @FreeStr[1], PForceMode, '-m'));
  RecoveryRec := NewStr(GetVal(@Sign[1], @FreeStr[1], PRecoveryRec, ''));
  SelfExtract := NewStr(GetVal(@Sign[1], @FreeStr[1], PSelfExtract, ''));
  Solid := NewStr(GetVal(@Sign[1], @FreeStr[1], PSolid, ''));
  RecurseSubDirs := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PRecurseSubDirs, '-s'));
  StoreCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PStoreCompression, ''));
  FastestCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PFastestCompression, ''));
  FastCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PFastCompression, ''));
  NormalCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PNormalCompression, ''));
  GoodCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PGoodCompression, ''));
  UltraCompression := NewStr(GetVal(@Sign[1], @FreeStr[1],
         PUltraCompression, ''));
  ComprListChar := NewStr(GetVal(@Sign[1], @FreeStr[1], PComprListChar,
         ''));
  ExtrListChar := NewStr(GetVal(@Sign[1], @FreeStr[1], PExtrListChar, ''));
  {$ENDIF}

  q := GetVal(@Sign[1], @FreeStr[1], PAllVersion, '0');
  AllVersion := q <> '0';
  q := GetVal(@Sign[1], @FreeStr[1], PPutDirs, '0');
  PutDirs := q <> '0';
 {$IFNDEF DPMI32}
  {$IFDEF OS2}
  q := GetVal(@Sign[1], @FreeStr[1], PShortCmdLine, '0');
  {$ELSE}
  q := GetVal(@Sign[1], @FreeStr[1], PShortCmdLine, '1');
  {$ENDIF}
  ShortCmdLine := q <> '0';
 {$ELSE}
  q := GetVal(@Sign[1], @FreeStr[1], PSwapWhenExec, '0');
  SwapWhenExec := q <> '0';
 {$ENDIF}
  {$IFNDEF OS2}
  q := GetVal(@Sign[1], @FreeStr[1], PUseLFN, '0');
  UseLFN := q <> '0';
  {$ENDIF}
  end { TLHAArchive.Init };

function TLHAArchive.GetID;
  begin
  GetID := arcLHA;
  end;

function TLHAArchive.GetSign;
  begin
  GetSign := sigLHA;
  end;

procedure TLHAArchive.GetFile;
  var
    HS, i: AWord;
    FP: TFileSize;
    P: LHAHdr;
    s: String;
    DT: DateTime;
  begin
  ArcFile^.Read(P.Size, SizeOf(P.Size));
  if  (P.Size = 0) then
    begin
    FileInfo.Last := 1;
    Exit;
    end;
  ArcFile^.Read(P.Sum, P.Size-SizeOf(P.Size));
  if  (ArcFile^.Status <> stOK) or (P.MethodID[1] <> '-')
       or (P.MethodID[2] <> 'l')
  then
    begin
    FileInfo.Last := 2;
    Exit;
    end;
  FP := ArcFile^.GetPos+2;
  if P.Level = 2 then
    begin
    P.Name[0] := Chr(Byte(P.Name[3])-3);
    System.Move(P.Name[6], P.Name[1], Byte(P.Name[0]));
    FP := FP-2;
    GetUNIXDate(P.Date, DT.Year, DT.Month, DT.Day, DT.Hour, DT.Min,
       DT.Sec);
    PackTime(DT, P.Date);
    ArcFile^.Seek(FP+Byte(P.Name[0])+$1b-P.Size);
    end;
  ArcFile^.Read(HS, 2);
  System.Move(P.Name, FileInfo.FName, Byte(P.Name[0])+1);
  FileInfo.Last := 0;
  FileInfo.Attr := P.Attr and not Hidden;
  FileInfo.USize := P.OriginSize;
  FileInfo.PSize := P.PackedSize;
  FileInfo.Date := P.Date;
  if  (HS <> 0) and (P.Level <> 0) then
    begin
    HS := HS-2;
    ArcFile^.Read(P.Name, Min(255, HS));
    if  (P.Name[0] = #2) then
      begin
      i := 1;
      s := '';
      while (i < Min(255, HS)) and (P.Name[i] > #31) do
        begin
        AddStr(s, P.Name[i]);
        Inc(i)
        end;
      Replace(#255, '\', s);
      System.Insert(s, FileInfo.FName, 1);
      end;
    end;
  ArcFile^.Seek(FP+P.PackedSize);
  end { TLHAArchive.GetFile };

end.
