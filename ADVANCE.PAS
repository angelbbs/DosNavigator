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
{AK155 = Alexey Korop, 2:461/155@fidonet}
{Cat = Aleksej Kozlov, 2:5030/1326.13@fidonet}

unit Advance;

interface

uses
  Dos,
  Strings,
  Objects2, Lfn {DataCompBoy}
  , Defines, Streams
  ;

{$IFDEF DNPRG}
{$I Version.Inc}
{DataCompBoy: DO NOT INCLUDE Version.inc IN OTHER UNITS!}
{simple add in USES Advance}
{$ENDIF}

type
  TNameFormatMode = (nfmNull, nfmHidden, nfmSystem, nfmHiddenSystem);

const
  NameFormatChar: array[TNameFormatMode] of Char =
    ('.', #176, #177, #178);

(*  flnPreferName = 1;  { �� ⠡㫨஢����� ���७��;
        �� �⮬ �ᥣ�� ExtSize = 0}
  flnHardExtArea = 2; { ���㫨஢��� ���७��
        �� �⮬ �ᥣ�� ExtSize <> 0}
{  flnUseCutChar = 8; �� �ᥣ�� �㦥� }
*)
  flnPreserveExt = 1; { �᫨ �� ��⠡㫨஢����� ������ ���७��
    楫���� �� ����頥���, � ��࠭��� ExtSize ᨬ����� ���
    ���� ���७�� (������ ᨬ��� ��१��)}
  flnAutoHideDot = 4; { �������� ��� ��। ���७��� �� �஡��;
    �뢠�� ⮫쪮 �� ExtSize <> 0}
  flnHighlight = 16;
  flnUpCase = 32;
  flnLowCase = 64;
  flnCapitalCase = 128;
  flnPadRight = 256;
  flnHandleTildes = 512;
  flnSelected = 1024;

const
  TextReaderBufSize = $1000;

type
  TTextReaderBuf = array[0..TextReaderBufSize-1] of Char;

  PTextReader = ^TTextReader;
  TTextReader = object
    Eof: Boolean;
    constructor Init(const FName: String); {DataCompBoy}
    function GetStr: String;
    function FileName: String; {DataCompBoy}
    destructor Done; virtual;
  private
    Handle: lFile; {DataCompBoy}
    BufSz: Integer;
    BufPos: Integer;
    Buf: TTextReaderBuf;
    Skip1: Boolean;
    end;

  { TColorIndexes }

  PColorIndex = ^TColorIndex;
  TColorIndex = record
    GroupIndex: Byte;
    ColorSize: Byte;
    ColorIndex: array[0..255] of Byte;
    end;

  { TCharImage = array [0..15] of Byte;}

type
  TCountryInfo = record
    {`����� ��� ������� ����஥� ��࠭� }
    DateFmt: Word; {Radiobuttons}
      {`0:MM-DD-YY, 1: DD-MM-YY, 2: YY-MM-DD`}
    TimeFmt: Word; {Radiobuttons}
      {`0:12hour, 1: 24hour`}
    DateSep: String[1]; {Inputline}
    TimeSep: String[1]; {Inputline}
    ThouSep: String[1]; {Inputline}
    DecSep: String[1]; {Inputline}
    DecSign: String[1]; {Inputline}
    CurrencyFmt: Word; {Radiobuttons}
      {` 0:'$123.00', 1:'123.00$', 2:'$ 123.00', 3:'123.00 $' 4: 123$00 `}
    Currency: String[4]; {Inputline}
    KbdToggleLayout: String[79]; {Inputline}
    ABCSortTable: String[79]; {Inputline}
    WinCodeTable: String[79]; {Inputline}
    CodeTables: String[255]; {Inputline}
    end; {`}

var
  RK: Byte;

const

  ColorIndexes: PColorIndex = nil;

  opUnk = 0; { Unknown  }
  opDOS = 1; { DOS      }
  opOS2 = 2; { OS/2     }
  opWin = 4; { Wind0ze  }
  opDV = 8; { DesqView }
  opWNT = 16; { Win NT & Win y2k }
  opDPMI32 = 32; { DPMI32 }
  {Cat: ���� �।��� ����� DOS � Win32, ���⮬� �⤥�쭮 �� DOS}

  Abort: Boolean = False;

  opSys: Byte = opUnk;

  { useful under OS2 with WinAPI emulator: if (opSys and opWin)=opWin then ...}

procedure CheckOS;
{ Check for OS - For checking API please use error codes }
{ Automatically called while program started }

procedure ClrIO;
  inline;
  begin
  InOutRes := 0;
  DosError := 0;
  Abort := False;
  end;

function MemOK: Boolean;
  inline;
  begin
  MemOK := True
  end; {JO}
function GetMeMemoStream: PStream; {-$VOL}
function MemAdjust(L: LongInt): LongInt;
procedure FillWord(var B; Count, W: Word);
procedure LocateCursor(X, Y: Byte);
procedure TinySlice;
  {` �⤠� ��⥬� ����� �६���. �� ��楤�� ��뢠���� ��
  横�� ᮡ�⨩ TGroup.Execute, � �⠫� ����, � �� ���樨,
  ����� ࠡ�⠥� Desktop ��� ������. �᫨ �� ��-� ᠬ �����
  横� (���ਬ��, � GetEvent), � �� ᠬ ������ � TinySlice ��뢠��,
  �᫨ �㦭�. �ਬ�� ⮣�, ��� �� ��������, �. � TView.MouseEvent `}

function FormatLongName(Name: String; Size, ExtSize: Byte;
  {` ��ଠ�஢��� ������� ��� ��� ����� ����� Size, � ⮬ �᫥
  ��� ⠡㫨஢����� ���७�� - ExtSize.
    �⤥��� ���� Options ������ �ᮡ������ �ଠ�஢���� (����⠭��
  � ������� �த� flnHighlight.
    FormatMode ��।���� ᨬ���, �뢮���� ����� �窨.}
     Options: Word;
    FormatMode: TNameFormatMode): String; (* X-Man *)
    {`}
{ ��६���� FormatLongName, ������ ���祭�� ������ �����
  �।�⠢���� �����: }
var
  flnNLength: Integer;
    {` ��᫥ FormatLongName ����� ᮡ�⢥��� �����, ��� ��१���� `}
  flnNSize: Integer;
    {` ��᫥ FormatLongName  ����� ����� ��᫥ ��१���� `}
  flnDotPos: Integer;
    {` ��᫥ FormatLongName  १�������� ������ �窨 (�᫨
      �� ⠡㫨�㥬) ��� ��᫥����� �஡��� ��। ����� ���७��
      (�᫨ ⠡㫨�㥬) `}
  flnPanelName: String;
    {` ��᫥ FormatLongName ���ଠ�஢����� ��� (��� ���������
      ᨬ����� �ࠢ����� ���ᢥ⪮� `}

const
  BreakChars: set of Char = [',', ' ', '[', ']', '{', '}', '(', ')',
   ':', ';', '.', '^',
  '&', '*', '!', '#', '$', '/', '\', '"', '%', '>', '<',
  '-', '+', '=', '|', '?', #13, #10, #9, #26, #12, '@'];

  HexStr: array[0..$F] of Char = '0123456789ABCDEF';
  N_O_E_M_S: array[1..5] of Char = 'NOEMS';
  cTEMP_: String[5] = 'TEMP:';
  cLINK_: String[5] = 'LINK:';
  cNET_: String[7] = 'Network';
  {.$IFNDEF OS2}
  x_x: String[3] = '*.*';
  {.$ELSE}
  {x_x     : string[3] = '*';}
  {.$ENDIF}

var
  OS2exec: Boolean; { use OS2exec to determine if starting of OS/2  }
  { programs is supported                         }
  { use opsys and opOS2 <> 0 to determine if OS/2 }
  { is running                                    }
  Win32exec: Boolean; {starting of Win32 programs is supported  }
  FreeStr: String;
  FreeLongStr: LongString;
  InterfaceStr: String;
    {` ����᪠� ��ப� ��� ��।�� ������ ����� �ணࠬ����.
    �ᯮ�짮���� �� ��� �ࠩ��� ����室����� �� ᫥���. `}
  DNNumber: Byte;

  {Cat: ���冷� ��६����� �� ������, ���� ���� �஡���� � ���������}

var
  {-DataCompBoy-}
  StartupDir: String;
    {` ��⠫��, ��㤠 �맢�� DN.EXE. � '\' � ���� `}
  SourceDir: String;
    {` ��⠫��, ��� ����� ���䨣� � ���ਨ. � '\' � ����.
      ��ࠢ����� Env-��६����� DN2. `}
  TempDir: String;
    {` �६���� ��⠫��. � '\' � ���� `}
  TempFile: String;
  TempFileSWP: String; {JO}
  LngFile: String;
  SwpDir: String;
    {` ��⠫�� ��� �ଥ���� ��������� 䠩��� � ᯨ᪮�,
    � � DPMI32 - ��� ᢮�� �� �६� �믮������ ���譥� �ணࠬ��.
    � '\' � ����. ��ࠢ����� Env-��६����� DNSWAP � ���稪�� /S. `}
  {-DataCompBoy-}
const
  DirToChange: String = ''; {DataCompBoy}
{$IFDEF DPMI32}
  DirToMoveContent: String = ''; {JO}
{$ENDIF}

const
  CL_SafeBuf = $8000;

  Linker: Pointer = nil;
  NeedLocated: LongInt = 0;

const
  CountryInfo: TCountryInfo =
    {`����᪠� ��६�����; �ᥣ�� ���४⭮ ���������`}
   (DateFmt: 0;
    TimeFmt: 0;
    DateSep: '.';
    TimeSep: ':';
    ThouSep: ' ';
    DecSep: '.';
    DecSign: '$';
    CurrencyFmt: 0;
    Currency: '$';
    KbdToggleLayout: 'ru441.xlt';
    ABCSortTable: 'sort866.xlt';
{$IFDEF DPMI32}
    WinCodeTable: 'win866r.xlt';
{$ELSE} {$IFDEF Win32}
    WinCodeTable: '1251';
{$ELSE} //OS2
    WinCodeTable: '0';
{$ENDIF}
{$ENDIF}
    CodeTables: 'KOI:koi8-r.xlt'
    );



type
  TCrc_Table = array[0..255] of LongInt;
const
  Crc_Table_Empty: Boolean = True;
  Crc_Table: ^TCrc_Table = nil;

type
  TPosArray = array[1..9] of TPoint;

  TFPos = record X: Integer; Y: TFileSize end;
  TFPosArray = array [1..9] of TFPos;

implementation

uses
  xTime, Startup, Advance1, VPUtils,
  VpSysLow, Advance2,
  Commands
  ;

{-DataCompBoy-}
constructor TTextReader.Init;
  var
    FileSz: TFileSize;
    ToRead: Integer;
  begin
  ClrIO;
  FileMode := $40;
  lAssignFile(Handle, FName);
  lResetFile(Handle, 1);
  if  (IOResult <> 0) or Abort then
    Fail;
  FileSz := FileSize(Handle.F);
  if  (IOResult <> 0) or Abort then
    Fail;
  Eof := FileSz = 0;
  if not Eof then
    begin
    ToRead := MinBufSize(FileSz, TextReaderBufSize);
    BlockRead(Handle.F, Buf, ToRead, BufSz);
    if  (IOResult <> 0) or Abort or (ToRead <> BufSz) then
      begin
      ClrIO;
      Close(Handle.F);
      ClrIO;
      Fail;
      end;
    end;
  BufPos := 0;
  end { TTextReader.Init };
{-DataCompBoy-}

{-DataCompBoy-}
function TTextReader.FileName: String;
  begin
  FileName := lFileNameOf(Handle);
  end;
{-DataCompBoy-}

{-DataCompBoy-}
function TTextReader.GetStr: String;
  var
    CurStr: String;
    BufBeg: Integer;
    Was: Boolean;

  procedure aStr(D: Integer);
    var
      Grow: Integer;
    begin
    Grow := Min((BufPos-BufBeg)-D-Byte(Was), 255-Length(CurStr));
    if Grow > 0 then
      begin
      Move(Buf[BufBeg], CurStr[Length(CurStr)+1], Grow);
      SetLength(CurStr, Length(CurStr)+Grow);
      end;
    end;

  var
    PrevC: Integer;
    C: Char;

  begin { TTextReader.GetStr: }
  CurStr := '';
  if not Eof then
    begin
    PrevC := -1;
    SetLength(CurStr, 0);
    BufBeg := BufPos;
    Was := False;
    repeat
      if BufPos = BufSz then
        begin
        aStr(0);
        ClrIO;
        BlockRead(Handle.F, Buf, TextReaderBufSize, BufSz);
        if BufSz = 0 then
          begin
          Eof := True;
          Break;
          end;
        BufPos := 0;
        BufBeg := 0;
        if Was then
          begin
          Skip1 := True;
          Break
          end;
        end;
      C := Buf[BufPos];
      Inc(BufPos);
      case C of
        #0, #10, #13:
          begin
          if Skip1 then
            begin
            BufBeg := BufPos;
            Skip1 := False;
            Continue;
            end;
          if Was then
            begin
            aStr(1);
            Dec(BufPos, Integer(PrevC = Integer(C)));
            Break;
            end
          else
            Was := True;
          PrevC := Integer(C);
          end;
        else {case}
          begin
          if Was then
            begin
            aStr(1);
            Dec(BufPos);
            Break;
            end;
          Skip1 := False
          end;
      end {case};
    until False;
    end;
  GetStr := CurStr;
  end { TTextReader.GetStr: };
{-DataCompBoy-}

{-DataCompBoy-}
destructor TTextReader.Done;
  begin
  ClrIO;
  Close(Handle.F);
  ClrIO;
  end;
{-DataCompBoy-}

{AK155 19.05.05 �� �������᪨� PString ������� �� �⥪��� String.
� ᮬ������� � ��������� ��� PString ���� � 16bit ���ᨨ,
� � 32bit - �� ᮢ��襭�� ��譥�.
   � ⠪�� ��� ���� ������ ��⨬���権 � ������� �������ਥ�.}
function FormatLongName(Name: String; Size, ExtSize: Byte;
     Options: Word;
    FormatMode: TNameFormatMode): String;

  var
    PSize, ESize: Integer; {PathSize, ExtensionSize}
    P, N, E: String; { Path, Name, Extension }
    EFlag, i: Byte;
    Hi: Boolean; { �ਧ��� ⮣�, �� ����� ᨬ}
    Hi1, Hi2, Hi3: Integer; { ����樨, ����� ������ ���� �뤥���� 梥⮬.
      Hi1 - ᨬ��� ��१�� ��� (�����ॢ��, �� ॠ�쭮 �� �㦥�,
        ⠪ ��� ���� ������� �� �뢠�� ����� � 梥⮬);
      Hi2 - ᨬ��� �⬥⪨ 䠩�� ��� ��१�� ����� ��। ���७���;
      Hi3 - ᨬ��� ��१�� �� �ࠢ�� ���� ����.
      }
    l: Integer;
  label
    MakeResult;
  begin { FormatLongName }
  if (Name = '..') or (Name = '.' {�뢠�� ����� �㦨� ��娢��}) then
    begin
    Result := AddSpace(Name, Size);
    Exit;
    end;
  if  (Options and flnUpCase) <> 0 then
    UpStr(Name)
  else if (Options and (flnLowCase or flnCapitalCase)) <> 0 then
    LowStr(Name);
  lFSplit(Name, P, N, E);
  Delete(E, 1, 1);
  if  (Options and flnCapitalCase) <> 0 then
    N[1] := UpCase(N[1]);
  SetLength(flnPanelName, Size);
  Hi1 := 0;
  Hi2 := 0;
  Hi3 := 0;
  if Size < 5+ExtSize then
    begin
    FillChar(flnPanelName[1], Size, FMSetup.RestChar[1]);
    Hi1 := Size;
    goto MakeResult;
    end;
  flnNLength := Length(N);
  flnNSize := flnNLength;
  ESize := Length(E); { 㦥 ��� �窨 }
  EFlag := Byte(ESize > 0);

  if Options and flnPreserveExt <> 0 then
    begin
    l := (Length(N) + Min(3, Length(P)));
      { ᪮�쪮 ����� �� ���� � ��� �� ���ᨬ��쭮� ��१�� ��� }
    if (Size - l > ESize) { ����७�� ����頥��� } or
       (l < Size-ExtSize) { ��� �� �㦭� ��१��� }
    then
      ExtSize := 0 { �� ⠡㫨�㥬 }
    else if ESize < ExtSize then
      ExtSize := ESize; { ���㫨�㥬, �� ���������㥬 ��१�� ����� }
    end;

  if (ExtSize <> 0) and (ESize > ExtSize) then
    begin { ��१�� ���७�� �� ⠡㫨஢����� ������ }
    ESize := ExtSize;
    Hi3 := Size;
    end;

  PSize := Max(3, Size-(ESize+EFlag)-flnNSize);
  if PSize >= Length(P) then
    PSize := Length(P)
  else
    begin { ��१�� ��� }
    P[PSize] := FMSetup.RestChar[1];
    Hi1 := PSize
    end;

  {  ��१�� ���७�� �� ��⠡㫨஢����� ������.
  �� ����� ��ꥤ����� � ��१��� �����, ⠪ ��� � ������ ��᫥����
  �窨 ����� ��������� �ਧ��� ���⮣�-��⥬���� 䠩��.}
  if (ExtSize <> 0) then
    i := ExtSize+1
  else
    begin
    ESize := Min(Length(E), Max(0, Size-EFlag-PSize-flnNSize));
    EFlag := Byte(ESize > 0);
    i := ESize+EFlag;
    if ESize < Length(E) then
      Hi3 := Size;
    end;
  { ����� i - �ਭ� ���� ���७��, ������ ������ �窨 }

  { ��१�� ����� }
  flnNSize := Min(Length(N), Max(1, Size-i-PSize));

  FillChar(flnPanelName[1], Size, ' ');
  if ExtSize = 0 then
    flnDotPos := PSize+flnNSize+1
  else
    flnDotPos := Size-ExtSize;
  { ����� flnDotPos - �� ������ �窨, �᫨ ��� � �।���� ����,
    ���� Size+1, �᫨ �窠 ��室�� �� ���� ��-�� ᫨誮� ��������
    ����� � ०��� ��� ⠡��樨 ���७�� }
  for i := 1 to PSize do
    flnPanelName[i] := P[i];
  for i := 1 to flnNSize do
    flnPanelName[PSize+i] := N[i];
  for i := 1 to ESize do
    flnPanelName[flnDotPos+i] := E[i];
  if (FormatMode <> nfmNull) or
     ((Options and flnAutoHideDot = 0) and (ESize <> 0))
  then
    flnPanelName[flnDotPos] := NameFormatChar[FormatMode];
      { ����ᥭ�� �ਧ���� ��ਡ�⮢ ��� ����⠭������� �窨.
        �᫨ ������ �窨 ��� ���� (� ���� �㤥� ��१��), � ��ਡ���
        �� ���� �����஢�����. �����, �� � ���ࠢ��쭮, �� ⠪
        �뫮 �ᥣ��.}
  if flnNSize < Length(N) then
    begin { ��१�� ����� }
    Hi2 := PSize+flnNSize + byte(flnDotPos <= Size);
      {�᫨ ������ �窨 ����������, � ��१�� �⠢�� ����� ���, �
      �᫨ ��� - ��室���� ��१��� �� 1 ᨬ��� ����� }
    flnPanelName[Hi2] := FMSetup.RestChar[1];
    end;
  if Hi3 <> 0 then {��१�� ���७��. ��� ����� �� ᠬ�� ����
      ��१��� ���, �᫨ ����� ��⠡㫨஢����. � �⮬ ��砥 �⬥⪠
      (�᫨ �� ����) ������ ���� ������ ��१��, ���⮬�
      ����� �ࠣ���� ������ ����� �� ����ᥭ�� ᨬ���� �⬥⪨. }
    flnPanelName[Hi3] := FMSetup.RestChar[1];
  if (Options and flnSelected) <> 0 then
    begin { �⬥⪠ }
    Hi2 := flnDotPos - byte(flnDotPos > Size);
      {�᫨ ������ �窨 ����������, � �⬥�� �⠢�� ����� ���, �
      �᫨ ��� - �� ��᫥���� ������㥬� ᨬ���. ��१�� �� �⮬
      ���������� }
    flnPanelName[Hi2] := FMSetup.TagChar[1];
    end;

MakeResult:
  Result := '';
  if  (Options and flnPadRight) = 0 then
    DelRight(flnPanelName);
{AK155 13.05.2005 �����, � � ���� ����ணࠬ��, ⨫�� �����������,
� � GetFull � ���� ������� ���졠 �� ����� ���� 梥�. ��� ��
��������� � �� �������.
  if  ( (Options and flnSelected) <> 0) and
      ( (Options and flnHighlight) <> 0)
  then
    AddStr(Res^, '~');
/AK155}

  for i := 1 to Length(flnPanelName) do
    begin
    Hi := { �ਧ��� ⮣�, �� ����� ᨬ��� ���� ���ᢥ��� }
       ( (Options and flnHighlight) <> 0) and
       ( (i = Hi1) or (i = Hi2) or (i = Hi3));
    if Hi then
      AddStr(Result, '~');
    if  (flnPanelName[i] = '~') and ((Options and flnHandleTildes) <> 0) then
      AddStr(Result, #0);
    AddStr(Result, flnPanelName[i]);
    {AK155: ��祬 ��� ��ன #0 - �ਤ㬠�� �� ᬮ�, ���⮬� �ࠫ ���.
� �⭮�⥫쭮 ��ࢮ�� #0 ���������, �� �� ������ ���ᯥ稢���
���ᮢ�� ⨫��. � ���� ᮮ⢥�������� ���४�� �
drivers._vp.MoveCStr. 06.01.2001}
    {
          if (flnPanelName[i]='~') and ((Options and flnHandleTildes)<>0)
          then AddStr(Res^,#0);}

    {/AK155}
    if Hi then
      AddStr(Result, '~');
    end;
{AK155 13.05.2005 - �. ���
  if  ( (Options and flnSelected) <> 0) and
      ( (Options and flnHighlight) <> 0)
  then
    AddStr(Res^, '~');
/AK155}
  end { FormatLongName };

procedure CheckOS;
  begin
  {$IFDEF OS2}opSys := opOS2; {$ENDIF}
  {$IFDEF WIN32}
  if SysPlatformId = 1 then
    opSys := opWin
  else
    opSys := opWNT;
  {$ENDIF}
  {$IFDEF DPMI32}
  opSys := opDPMI32;
  asm
  {OS2}
    mov   AX, 4010h
    int   2Fh
    cmp   AX, 4010h
    JZ    @nonOS2
    {OS2 detected}
    or    opSys, opOS2
  @nonOS2:
    mov   ax, 3306h
    int   21h           { get true dos version }
  {WinNT}{since WinNT don't support GetWinVer via int2f}
    cmp   bx,3205h
    jne   @nonWNT
    {Win NT based OS detected }
    or    opSys, opWNT+opWin
  @nonWNT:
  {DOS}
    cmp   bl,3
    jb    @nonDOS
    cmp   bl,7
    ja    @nonDOS
    {DOS detected}
    or    opSys, opDos
  @nonDOS:
  {DV}
    mov   ax, 2B01h
    mov   cx, 4445h
    mov   dx, 5351h
    int   21h           { Desqview Installed? }
    cmp   al, 255
    je    @nonDV
    {DesqView detected}
    or    opSys, opDV
  @nonDV:
  {WIN 3.x and 9x}
    mov   ax, 160Ah
    int   2Fh           { Windows Install? }
    or    ax,ax
    jne   @nonWin
    {Windows detected}
    or    opSys, opWin
  @nonWin:
  end; { checkos }
  {$ENDIF}
  end;


function GetMeMemoStream: PStream; {-$VOL begin}
  const
    _1: Byte = 1;
  var
    S: PStream;
    Pos: LongInt;
  begin
  S := New(PMemoryStream, Init(2048, 2048));
  {Cat: � ⥯��� ����襬 �㤠 �������, �⮡� ��㣨� ���� ��楤���,     }
  {     ����� ���� �� ��⮪� �, �� ��� �㤠 �� �����뢠��, ��⠫�,  }
  {     �� ��� ��⮪ ᮤ�ন� ������ ��ப�                              }
  S^.Seek(0);
  S^.Write(_1, 1);
  S^.Seek(0);
  {/Cat}
  if S^.Status <> stOK then
    begin
    Dispose(S, Done);
    S := nil
    end;
  GetMeMemoStream := S;
  end; {-$VOL end}

function MemAdjust(L: LongInt): LongInt;
  begin
  if Linker <> nil then
    begin
    if L > CL_SafeBuf then
      L := L-CL_SafeBuf
    else
      L := 0;
    end;
  MemAdjust := L;
  end;

procedure FillWord(var B; Count, W: Word);
  assembler;
  {&Frame-} {$USES EDI, ECX}
asm
    cld
    mov  eax, W
    mov  edi, B
    mov  ecx, Count
    rep  stosw
 end;

procedure LocateCursor(X, Y: Byte);
  begin
  SysTVSetCurPos {GotoXY}(X, Y)
  end;

procedure TinySlice;
  begin
  {$IFNDEF DPMI32}
  SysCtrlSleep(1);
{ �����-�, Idle-横� � DN ���쬠 ����, ���⮬� ���� ����⥫쭮
������ ��� ����� �����. �� �� �⮬ �㦭� ��࠭��� �����筮 �������
ॠ��� �� ��⮯���७�� ���������� (��ਮ� 33 ��), ���� ��� ��稭���
ࠧ�ࠦ��� �ମ���� ��� ��࣠����. ��� ���, ��� Win NT (����� 10 ��)
���� 9 �ਢ���� � ����⭮�� ��࣠���. ��� �� ����� �㤥� 1. � ��� OS/2
(32 �� ���筮) ��࣠���� ��� ࠢ��, � �᫨ 㢥����� �᫮, � ��࣠����
��� ᨫ쭥�.
}
  {$ELSE}
//  give_up_cpu_time;
//piwamoto: it crashes under W2K, so i get code from DN OSP
{AK155 ��� OS/2 int $28 ࠧ��㧪� ������ �� ����, �
 int $2f (DPMI Idle) - ����. ����⭮, ��� DPMI32 int $2f
 ���ਬ�����. ��� �� ��⠢�� ����᫮��� DPMI Idle}
  asm
    mov ax,$1680
    int $2f
  end;
  {$ENDIF}
  end;

begin
CheckOS;
{ Starting of OS/2 programs is possible under:              }
{ - OS/2 2.10+, OS2COMSPEC environment variable is required }
{ - OS/2 Warp 3+, no additional requirements                }
{ - OS/2 for PPC, future versions for IA64 (I hope)         }
{$IFDEF DPMI32}
OS2exec := (opSys and opOS2 <> 0) and
    ( (Lo(DosVersion) > 20) or
      ( (Lo(DosVersion) = 20) and
        ( (Hi(DosVersion) >= 30) or
          ( (Hi(DosVersion) >= 10) and (GetEnv('OS2COMSPEC') <> ''))
        )));
Win32exec := opSys and opWin <> 0; {��� NT ���� �� ࠡ�⠥�}
{$ENDIF}
{$IFDEF OS2}
OS2exec := True;
Win32exec := False;
{$ENDIF}
{$IFDEF WIN32}
OS2exec := False;
Win32exec := True;
{$ENDIF}
end.
