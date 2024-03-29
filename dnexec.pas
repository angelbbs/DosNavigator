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
unit DnExec;

interface

uses
  Defines, FilesCol, Commands, U_KeyMap
  ;

procedure ExecString(const S: AnsiString; const WS: String);
  {` �믮����� ��ப� S^ �१ �������� ������. WS, �᫨ ���
  �� ����, �뢮����� �� ��࠭ ��। �맮��� ���. ������ `}
procedure ExecStringRR(S: AnsiString; const WS: String; RR: Boolean); {JO}
{JO:  �⫨砥��� �� ExecString ����稥� �㫥�᪮� ��६����� RR, �����}
{     㪠�뢠��, �����뢠�� ������ ��᫥ �믮������ ��� ���           }

function SearchExt(FileRec: PFileRec; var HS: String): Boolean;
{DataCompBoy}
function ExecExtFile(const ExtFName: String; UserParams: PUserParams;
     SIdx: TStrIdx): Boolean; {DataCompBoy}
procedure ExecFile(const FileName: String); {DataCompBoy}

procedure AnsiExec(const Path: String; const ComLine: AnsiString); {JO}

const
  fExec: Boolean = False; {�믮������ ������ �ணࠬ��}

implementation

uses
  {$IFDEF OS2}
  Os2Base, DnIni,
  {$ENDIF}
  {$IFDEF WIN32}
  Windows,
  {$ENDIF}
  {$IFDEF DPMI32} dpmi32, {$ENDIF}
  DNUtil, Advance, DNApp, Advance1, Lfn,
  Dos, FlPanelX, CmdLine, Views, Advance2, Drivers, Advance4,
  VideoMan, Memory, VpSysLow, VPSysLo2, Events,
  {$IFDEF UserSaver}
  UserSavr,
  {$ENDIF}
  Startup, UserMenu, Messages, Strings, filetype, lfnvp, TitleSet
  {$IFDEF OS2}, Dn2PmApi {$ENDIF} {AK155 ��� ����ᮢ�� ������}
  ;

{JO}
{ AnsiExec - ������ DOS.Exec , ����� � ����⢥ }
{ ������������ �ᯮ���� ��ப� ⨯� Ansistring }
{ � ᮮ⢥��⢥��� �� ����� ��࠭�祭�� � 255 ᨬ�����}
procedure AnsiExec(const Path: String; const ComLine: AnsiString);
  var
    PathBuf: array[0..255] of Char;
    Ans1: AnsiString;
    c: Longint;
    S: String;
  begin
  Ans1 := ComLine+#0;

  SysTVKbdDone;
  {JO: �. VpSysLo2 ; �᫨ �⮣� �� ������ - �� �맮��     }
  {    ���᮫��� �ணࠬ� �த� ��娢��஢ ��� ���������� }
  {    ������ ��� � "���ࠢ����" �������� �����஬}
  {    (���ਬ��, 4OS2) ���譨� �ணࠬ�� �� ����� ����� �  }
  {    ����������                                           }
  S := ActiveDir;
  MakeNoSlash(S);
  ChDir(S);
  c := IOResult;
  DosError := SysExecute(StrPCopy(PathBuf, Path), PChar(Ans1), nil,
      ExecFlags = efAsync, nil, -1, -1, -1);
{$IFNDEF Win32}
//  �᢮������� ��⠫��
  if ActiveDir[2] = ':' then
    ChDir(Copy(ActiveDir, 1, 2) + '\');
{$ENDIF Win32}
  ChDir(StartDir);

  SysTVKbdInit;
  {Cat: � OS/2: ��६�� � ������樥� Ctrl-C ��� Ctrl-Break
                      � WinNT: ��६�� � �ய������� ��設��� �����}
  end { AnsiExec };
{/JO}

{AK155 30-12-2001
�� ����⪠ ��।����� ⨯ ��뢠���� �ணࠬ��, �⮡� GUI-�ணࠬ��
��뢠�� ��� �������� �����襭��, � �� ��稥 - � ���������.
�᫨ ���७�� �� 㪠����, � ������� ����⮪ �ᯮ����� GUI-�ணࠬ��
�� ��������. � ��⭮�� �� �ந��������, ���� �� ��६����� ���㦥���
Path, ⠪ ��� �� ��㤭� ᤥ���� �� �ਢ�. ���ਬ��, �᫨ ����᪠����
����� prog, � ���ࠢ��쭮 �᪠�� � ����� 䠩� prog.exe. ����� �������,
�� ������, � ���-� ࠭��, ���ਬ��, � ⥪�饬 ��⠫���, ���� prog.com
��� prog.cmd, � �� ��� �맮���, ��� �� GUI. ����, Far ����� ������
⠪. ������ � ⥪騩 ��⠫�� notepad.cmd � ������ � �����ப� notepad.
� ��⮬ ������ Enter  �� �⮬ ᠬ�� notepad.cmd.
}
{������� - ��� �����⥬� ��� Win32 PE, ��� 100 ��� Win16 NE,
 ��� 0 ��� ���� }
function Win32Program(const S: String): SmallWord;
  const
    PETag = $00004550; {'PE'#0#0}
    NETag = $454E; {'NE'}
  var
    f: file;
    PathEnv: String;
    Dir: DirStr;
    Name: NameStr;
    Ext: ExtStr;
    RealName: String;
    NewExeOffs: SmallWord;
    NewHeader: record
      signature: LongInt;
      dummy1: array[1..16] of Byte;
      SizeOfOptionalHeader: SmallWord;
      Characteristics: SmallWord;
      {OptionalHeader}
      dummy2: array[1..68] of Byte;
      Subsystem: SmallWord;
      end;
    l: LongInt;
  begin { Win32Program }
  Result := 0;
  RealName := S;
  if  (RealName[1] = '"') and ((RealName[Length(RealName)] = '"')) then
    RealName := Copy(RealName, 2, Length(RealName)-2);
  RealName := lFExpand(RealName);
  DelRight(RealName);
  FSplit(RealName, Dir, Name, Ext);
  UpStr(Ext);
  if Ext <> '.EXE' then
    Exit;
  FileMode := Open_Access_ReadOnly or open_share_DenyNone;
  ClrIO;
  Assign(f, RealName);
  Reset(f, 1);
  if  (IOResult <> 0) and (Dir = '') then
    begin
    PathEnv := GetEnv('PATH');
    RealName := FSearch(S, PathEnv);
    if RealName = '' then
      Exit;
    Assign(f, RealName);
    Reset(f, 1);
    if IOResult <> 0 then
      Exit; {�����-�, ⠪ ���� �� ������, ࠧ �� �� ��諨}
    end;
  Seek(f, $3C);
  BlockRead(f, NewExeOffs, 2, l);
  if  (NewExeOffs = 0) or (l <> 2) then
    begin
    Close(f); {Cat}
    Exit;
    end;
  Seek(f, NewExeOffs);
  BlockRead(f, NewHeader, SizeOf(NewHeader), l);
  Close(f);
  with NewHeader do
    begin
    if SmallWord(signature) = NETag then
      Result := 100
    else if (l >= 70) and (signature = PETag)
         and (SizeOfOptionalHeader >= 70)
    then
      Result := Subsystem;
    end;
  end { Win32Program };

{$IFDEF Win32}
function GUIProgram(const S: String): Boolean;
  begin
  Result := Win32Program(S) in [2 {IMAGE_SUBSYSTEM_WINDOWS_GUI}, 100];
  end;
{$ENDIF}

{$IFDEF OS2}
{Cat 12-01-2002
�� ����⪠ ��।����� ⨯ ��뢠���� �ணࠬ��, �⮡� GUI-�ணࠬ��
��뢠�� ��� �������� �����襭��, � �� ��稥 - � ���������.
��� OS/2 ����訢��� DosQueryAppType, ����, ��� �����뢠�� ��ᯥਬ����,
��� �ᯥ譮 ࠡ�⠥� �� ⮫쪮 �� ����� 䠩��, ��� ᪠���� � ���㬥��樨,
�� �� 㤠���� ᪮ନ�� � 楫�� ��������� ��ப� (� ����, ��⥬� ᠬ�
����뢠�� �� ��।����� ��ப� ��ࠬ���� � �����⢫�� ���� ��
��६����� ���㦥��� Path). ����筮, ��� ��࠭⨨, �� �� �㤥� �ᥣ��
ࠡ���� �ࠢ��쭮, �� ��� �� ������ �� 㤠���� ᤥ���� ����.
}
function GUIProgram(SS: String): Boolean;
  var
    S: String;
    Flags: LongInt;
    l: Integer;
  begin
  l := 0;
  while SS[1+l] = '"' do
    Inc(l);
  S := Copy(SS, 1+l, Length(SS)-2*l)+#0;
  SS := lFExpand(S);  { �஢��塞 � ⥪�饬 ��⠫��� }
  if DosQueryAppType(@SS[1], Flags) <> 0 then
    { �������� �ᮡ� ��砨, �ਢ���騥 � �訡��, � �易��� � ���� �஡����:
    2    Error_File_Not_Found
           �᫨ �� 㪠���� ���७��, ��⥬� �।�������� EXE, ���⮬� ��
           �訡�� ᮮ�頥��� �� COM, BAT, CMD-䠩��, �᫨ EXE � ⠪�� ��
           ������ �� ������. �᫨ �� �������� ᮮ⢥�����騩 EXE, � ��� ���
           �㦥, ��᪮��� ��ᬮ�७ �㤥� EXE ���-� ������, � ����饭 COM,
           BAT, CMD �� ⥪�饣� ��⠫���.
    191  Error_Invalid_Exe_Signature
           �� ᮮ�頥��� �� �� 䠩��, ����� �� �������� �������� "ᠬ�
           �� ᥡ�", � ���� � �� BAT � CMD ⮦� - ��� ������������
           �������� �����஬. ������, ��� COM-䠩���, ��� ��� � ��
           ᮤ�ঠ� �⮩ ᠬ�� Exe_Signature, �訡�� �� ���������.
  }
    GUIProgram := False
  else
    { ��ᬠ�ਢ��� �������騥 ��� 䫠�� � ���� 2-0:
      000   fapptyp_NotSpec
      001   fapptyp_NotWindowCompat
      010   fapptyp_WindowCompat
      011   fapptyp_WindowApi
  }
    GUIProgram := (Flags and 3 = 3);
  if not Result then
    begin { �஢��塞 �� Path }
    if DosQueryAppType(@S[1], Flags) = 0 then
      GUIProgram := (Flags and 3 = 3);
    end;
  end { GUIProgram };
{/Cat}
{$ENDIF}

{-DataCompBoy-}
procedure ExecStringRR(S: AnsiString; const WS: String; RR: Boolean); {JO}
  var
    I: Integer;
    EV: TEvent;
    X, Y: SmallWord; {Cat}
    ScreenSize: TSysPoint; {Cat}
    {$IFDEF DPMI32}
    DosRunString: String;
    {$ENDIF}
    ActDir1: String;

  begin
  {$IFNDEF DPMI32}
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneDOSMem;
  DoneMemory;
  SwapVectors;
  {$ENDIF}
  if TimerMark then
    DDTimer := GetCurMSec
  else
    DDTimer := 0;
  if WS <> '' then
    Writeln(WS);
  SetTitle(S);
  fExec := True;
  {$IFNDEF DPMI32}
  if GUIProgram(S) then
    {$IFDEF OS2}
    S := 'start /f /PGM '+ S
  else
    case Win32Program(S) of
      2 {IMAGE_SUBSYSTEM_WINDOWS_GUI}:
        S := ExecWin32GUI+' ' + S;
      3 {IMAGE_SUBSYSTEM_WINDOWS_CUI}:
        S := ExecWin32CUI+' ' + S;
    end {case};
    {$ELSE}
    begin
    if opSys = opWNT then
      S := 'start "" ' + S
    else
      S := 'start ' + S
    end
    {$ENDIF}
    ;
  {$ENDIF}
  {$IFNDEF DPMI32}
  AnsiExec(GetEnv('COMSPEC'), '/c ' + S);
  {$ELSE}
  SaveDsk;
  Application^.Done;
  DosRunString:=' ' + S + #13;
  if LoaderSeg <> 0 then
    Move(DosRunString, Pointer(LongInt(LoaderSeg)*$10+CommandOfs)^,
      Length(DosRunString) + 2);
  if TimerMark
    then DDTimer:=GetCurMSec
    else DDTimer:=0;
  MakeNoSlash(ActiveDir);
  ChDir(ActiveDir);
  asm
   mov ax, 9904h
   mov dx, word ptr DDTimer
   mov cx, word ptr DDTimer+2
   int 2Fh

   mov ax, 9902h
   mov cl, 1
   int 2Fh

   mov ax, 1 {dpmiFreeDesc}
   mov bx, LoaderSeg
   int 31h   {DPMI}
  end;
  remove_i24;
  RemoveDpmi32Exceptionhandlers;
  Halt(1);
  {$ENDIF}
  fExec := False;
  {AK155, Cat: �⮡� �����ப� � ���� �� �������� �� �뢮�}
  SysGetCurPos(X, Y);
  if InterfaceData.Options and ouiHideStatus = 0 then
    Inc(Y);
  if X <> 0 then
    Writeln;
  SysTvGetScrMode(@ScreenSize, True);
  if Y >= ScreenSize.Y then
    Writeln;
  {/AK155, Cat}
  if TimerMark then
    begin
    DDTimer := GetCurMSec - DDTimer;
    EV.What := evCommand;
    EV.Command := cmShowTimeInfo;
    EV.InfoPtr := nil;
    Application^.PutEvent(EV);
    end;
  I := DosError;
  ClrIO;
  SwapVectors;
  EraseFile(SwpDir+'$DN'+ItoS(DNNumber)+'$.LST'); {DataCompBoy}
  InitDOSMem;
  InitMemory;
  InitVideo;
  SysTVDetectMouse; { AK155 ��� �⮣� ��� OS/2 ����� �� ������ ����,
    �᫨ �맢����� �ணࠬ�� �믮����� SysTVHideMouse }
  InitEvents;
  InitSysError;
  {$IFDEF OS2}
  DN_WinSetTitleAndIcon('DN/2', @DN_IconFile[1]);
  {AK155 ��� �⮣� ������ � ��������� ���� �� ����⠭���������� }
  {$ENDIF}
  Application^.Redraw;
  {JO}
  if RR then
    begin
    ActDir1 := '>' + ActiveDir; //�ਧ��� �����뢠��� �����⠫���� � ��⢨
    GlobalMessage(evCommand, cmPanelReread, @ActDir1);
    GlobalMessage(evCommand, cmRereadInfo, nil);
    end;
  {/JO}

  {AK155 ��� �⮣� ����� �����ப� �� �⠭������ �� ����}
  {$IFDEF Win32}
  if  (CommandLine <> nil) then
    begin
    SysTVSetCurPos(-2, -2);
    SysCtrlSleep(1); // �� ��� ��⪨ �����
    CommandLine^.Update;
    end;
  {$ENDIF}
  {/AK155}
  end { ExecStringRR };
{-DataCompBoy-}

{JO}
procedure ExecString(const S: AnsiString; const WS: String);
  begin
  ExecStringRR(S, WS, True);
  end;
{/JO}
{-DataCompBoy-}
function SearchExt(FileRec: PFileRec; var HS: String): Boolean;
  var
    AllRight: Boolean;
    f: PTextReader;
    F1: lText;
    s, s1: String;
    BgCh, EnCh: Char;
    EF, First: Boolean;
    I: Integer;
    Local: Boolean;
    FName: String;
    UserParam: tUserParams;
    {$IFDEF OS2}
    WriteEcho: Boolean;
    {$ENDIF}
  label RL;

  begin
  First := True;
  Message(Desktop, evBroadcast, cmGetUserParams, @UserParam);
  UserParam.Active := FileRec;
  FName := FileRec^.FlName[True];
  {lGetDir(0, ActiveDir);}
  {Cat:warn ���������஢�� �� � ����� �⫮�� �����, �� ���� �㤥� �஢����, �� ������� �� �����}
  SearchExt := False;
  Local := True;
  f := New(PTextReader, Init('DN.EXT'));
  if f = nil then
    begin
RL:
    Local := False;
    f := New(PTextReader, Init(SourceDir+'DN.EXT'));
    end;
  if f = nil then
    Exit;
  AllRight := False;
  BgCh := '{';
  EnCh := '}';
  Abort := False;
  EF := False;
  if PShootState and 8 > 0 then
    begin
    BgCh := '[';
    EnCh := ']';
    end
  else if PShootState and 3 > 0 then
    begin
    BgCh := '(';
    EnCh := ')';
    end;
  while (not f^.Eof) and (not AllRight) do
    begin
    s := f^.GetStr;
    if s[1] <> ' ' then
      begin
      I := PosChar(BgCh, s);
      if  (I = 0) or (s[I+1] = BgCh) then
        Continue;
      s1 := Copy(s, 1, I-1);
      DelLeft(s1);
      DelRight(s1);
      if s1[1] <> ';' then
        begin
        if InExtFilter(FName, s1) then
          begin
          lAssignText(F1, SwpDir+'$DN'+ItoS(DNNumber)+'$'+CmdExt);
          ClrIO;
          lRewriteText(F1);
          if IOResult <> 0 then
            begin
            Dispose(f, Done);
            Exit;
            end;
          {$IFNDEF OS2}
          Writeln(F1.T, '@echo off');
          {$ELSE}
          WriteEcho := True;
          {$ENDIF}
          System.Delete(s, 1, PosChar(BgCh, s));
          repeat
            Replace(']]', #0, s);
            Replace('))', #1, s);
            Replace('}}', #2, s);
            DelLeft(s);
            DelRight(s);
            if s[Length(s)] = EnCh then
              begin
              SetLength(s, Length(s)-1);
              EF := True;
              if s <> '' then
                begin
                Replace(#0, ']', s);
                Replace(#1, ')', s);
                Replace(#2, '}', s);
                s := MakeString(s, @UserParam, False, nil);
                HS := s;
                {$IFDEF OS2}
                {JO: ��� ���� �᫨ ��ப� �� REXX'� ��� Perl'�, � �� �㦭� ��������� @Echo off}
                if WriteEcho and (Copy(s, 1, 2) <> '/*')
                       and (Copy(s, 1, 2) <> '#!')
                then
                  Writeln(F1.T, '@Echo off');
                WriteEcho := False;
                {$ENDIF}
                Writeln(F1.T, s);
                Break
                end;
              end;
            if s <> '' then
              begin
              Replace(#0, ']', s);
              Replace(#1, ')', s);
              Replace(#2, '}', s);
              if  (BgCh <> '[') then
                s := MakeString(s, @UserParam, False, nil);
              if First and (BgCh <> '[') then
                HS := s;
              {$IFDEF OS2}
              {JO: ��� ���� �᫨ ��ப� �� REXX'� ��� Perl'�, � �� �㦭� ��������� @Echo off}
              if WriteEcho and (Copy(s, 1, 2) <> '/*')
                   and (Copy(s, 1, 2) <> '#!')
              then
                Writeln(F1.T, '@Echo off');
              WriteEcho := False;
              {$ENDIF}
              Writeln(F1.T, s);
              First := False;
              end;
            if  (f^.Eof) then
              Break;
            if not EF then
              s := f^.GetStr;
          until (IOResult <> 0) or Abort or EF;
          Close(F1.T);
          AllRight := True;
          end;
        end;
      end;
    end;
  Dispose(f, Done);
  {D.Filter:=''; MakeTMaskData(D);}
  if not EF and not Abort and Local then
    goto RL;
  if EF and (BgCh = '[') then
    begin
    EraseFile(SwpDir+'$DN'+ItoS(DNNumber)+'$.MNU');
    lRenameText(F1, SwpDir+'$DN'+ItoS(DNNumber)+'$.MNU');
    EF := ExecUserMenu(False);
    if not EF then
      lEraseText(F1);
    end;
  SearchExt := not Abort and EF;
  end { SearchExt };
{-DataCompBoy-}

{-DataCompBoy-}
function ExecExtFile(const ExtFName: String; UserParams: PUserParams;
     SIdx: TStrIdx): Boolean;
  var
    F: PTextReader;
    S, S1: String;
    FName: String;
    Event: TEvent;
    I, J: Integer;
    Success, CD: Boolean;
    Local: Boolean;
  label 1, 1111, RepeatLocal;

  begin
  ExecExtFile := False;
  FileMode := $40;
  Local := True;
  FName := UserParams^.Active^.FlName[True];

  F := New(PTextReader, Init(ExtFName));

  if F = nil then
    begin
RepeatLocal:
    Local := False;
    F := New(PTextReader, Init(SourceDir+ExtFName));
    end;
  if F = nil then
    Exit;
  while not F^.Eof do
    begin
    S := F^.GetStr;
    DelLeft(S);
    S1 := fDelLeft(Copy(S, 1, pred(PosChar(':', S))));
    if  (S1 = '') or (S1[1] = ';') then
      Continue;
    if InExtFilter(FName, S1) then
      goto 1111;
    end;
  ExecExtFile := False;
  Dispose(F, Done);
  {D.Filter := ''; MakeTMaskData(D);}
  if Local then
    goto RepeatLocal;
  Exit;
1111:
  Delete(S, 1, Succ(Length(S1)));
  Dispose(F, Done);
{$IFDEF DPMI32}
  // AK155 27/08/05 ��᪮��� DN/2 �� �����蠥��� �� �믮������
  // ���譥� �������, � � ����祬 �஢����� Valid(cmQuit)
  if not Application^.Valid(cmQuit) then
    begin
    Exit;
    end;
{$ENDIF}
  ClrIO;
  S1 := '';
  S := MakeString(S, UserParams, False, @S1);
  if S1 <> ''
  then
    TempFile := '!'+S1+'|'+MakeNormName(UserParams^.Active^.Owner^, FName)
  else if TempFile <> ''
  then
    TempFile := MakeNormName(UserParams^.Active^.Owner^, FName);
  {if TempFile <> '' then SaveDsk;}
 {$IFNDEF DPMI32}
  TempFileSWP := TempFile;
  TempFile := '';
 {$ENDIF}
  if Abort then
    begin
    Exit;
    end;
  if S[1] = '*' then
    Delete(S, 1, 1); {DelFC(S);}
  lGetDir(0, S1);
  {$IFDEF DPMI32}
  if UpStrg(MakeNormName(lfGetLongFileName(UserParams^.Active^.Owner^),
         '.')) <>
    UpStrg(MakeNormName(S1, '.'))
  then
    begin
    DirToChange := S1;
    lChDir(lfGetLongFileName(UserParams^.Active^.Owner^));
    end;
  {$ELSE}
  if UpStrg(MakeNormName(UserParams^.Active^.Owner^, '.')) <>
    UpStrg(MakeNormName(S1, '.'))
  then
    begin
    DirToChange := S1;
    lChDir(UserParams^.Active^.Owner^);
    end;
  {$ENDIF}
  ExecExtFile := True;
  {$IFDEF UserSaver}
  InsertUserSaver(False); {JO}
  {$ENDIF}
  ExecStringRR(S, '', False);
 {$IFNDEF DPMI32}
  if TempFileSWP <> '' then
    Message(Application, evCommand, cmRetrieveSwp, nil);
 {$ENDIF}
  end { ExecExtFile };
{-DataCompBoy-}

{-DataCompBoy-}
procedure ExecFile(const FileName: String);
  var
    S, M: String;
    fr: PFileRec;

  procedure PutHistory(B: Boolean);
    begin
    if M = '' then
      Exit;
    CmdLine.Str := M;
    CmdLine.StrModified := True;
    CmdDisabled := B;
    Message(CommandLine, evKeyDown, kbDown, nil);
    Message(CommandLine, evKeyDown, kbUp, nil);
    end;

  procedure RunCommand(B: Boolean);
    var
      ST: SessionType;
      S: String; {//AK155}
    begin
    if  (PCommandLine(CommandLine)^.LineType in [ltWindow,
         ltFullScreen])
    then
      begin
      if PCommandLine(CommandLine)^.LineType = ltFullScreen then
        ST := stOS2FullScreen
      else
        ST := stOS2Windowed;
      RunSession(M, False, ST);
      CmdLine.StrModified := True;
      Message(CommandLine, evKeyDown, kbDown, nil);
      Exit;
      end;
    {AK155, �. dnutil.ExecCommandLine}
    S := '';
    CommandLine^.SetData(S);
    {/AK155}
    if B then
      ExecString(M, #13#10+ {$IFDEF RecodeWhenDraw}CharToOemStr 
           {$ENDIF}(ActiveDir)+'>'+ {$IFDEF RecodeWhenDraw}CharToOemStr 
        {$ENDIF}(M))
    else
      ExecString(M, '');
    end { RunCommand };

  label ex;
  begin { ExecFile }
  fr := CreateFileRec(FileName);
  S := fr^.FlName[True];
  FreeStr := '';
  M := '';
  if  (ShiftState and (3 or kbAltShift) <> 0) or
      not InExtFilter(S, Executables)
  then
    begin
    if SearchExt(fr, M) then
      begin
      {PutHistory(true);}
      M := SwpDir+'$DN'+ItoS(DNNumber)+'$'+CmdExt+' '+FreeStr;
      RunCommand(False);
      {M := S; PutHistory(false);}
      {CmdDisabled := false;}
      GlobalMessage(evCommand, cmClearCommandLine, nil);
      end;
    goto ex;
    end;
  {$IFNDEF Win32}
  M := S;
  {$ELSE}
  M := {$IFDEF RecodeWhenDraw}CharToOemStr {$ENDIF}(S);
  {$ENDIF}
  PutHistory(False);
  M := S;

  if Pos(' ', M) <> 0 then
    {AK155}
    M := '"'+M+'"';

  RunCommand(True);
ex:
  DelFileRec(fr);
  end { ExecFile };

end.
