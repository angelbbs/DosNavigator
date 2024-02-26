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
{.$I ZCONF.INC}
{Cat = Aleksej Kozlov, 2:5030/1326.13@fidonet}

program DN;
{$IFNDEF DPMI32}
{$R DN.res}
{$ENDIF}

{Cat: ��⮤� �����প� �������� �����﫨��, ���⮬� ��� ��᮪
      ���������஢��; �०��� ��� 㡨���� ���� �����}

uses
{$IFDEF DPMIDEBUG}
  deb_link,
{$ENDIF}
  Drivers, Lfn, Files,
  DN1, Dos, DNApp,
  Menus, FlPanelX, FlPanel, FileCopy, Filediz, Filelst, Eraser,
  DiskInfo, Advance, Advance1, Advance2, Advance4, highlite,
  Startup, Dialogs, Gauges, Memory, DblWnd, Messages, HistList,
  FileFind, Commands, Tree, FViewer, CmdLine, FBB, DNStdDlg,
  FilesCol, UserMenu, Colors, Microed, Editor, Macro,
  ArcView, HelpFile, Validate, ASCIITab, xTime, Drives, Archiver,
  ArchSet, ArchDet, Setups, DNUtil, XDblWnd, Histries, CCalc,
  DnIni, Collect, Objects2, Views, Scroller, Calculat,
  HelpKern, VideoMan
  {$IFDEF SpreadSheet}, Calc, CellsCol {$ENDIF}
  {$IFDEF DBView}, DBView, DBWatch {$ENDIF}
  {$IFDEF Modem}, modemio, Terminal
  , apTimer, apUART, apPort
  {$IFDEF LINK}, NavyLink {$ENDIF}
  {$IFDEF PHONES}, uDialer {$ENDIF} {$ENDIF}
  {$IFDEF Game}, Tetris {$ENDIF}
  {$IFDEF Printer}, PrintMan {$ENDIF}
  {$IFDEF Calendar}, Calendar {$ENDIF} {JO}
  {$IFDEF PHONES}, Phones {$ENDIF}
  {$IFDEF SS}, Idlers {$ENDIF}
  , ColorSel, ColorVGA
  {$IFDEF NETINFO}, Novell {$ENDIF}
  {$IFDEF LINEPOSIT}, SysUtils, VPUtils {$ENDIF}
  {$IFDEF OS2}, EAOper {$ENDIF}
  , VpSysLow
{$IFDEF DPMI32} , dpmi32 {$ENDIF}
  ;

{$IFDEF LINEPOSIT}

{&Delphi+}
var
  E: Exception;
  FileName: ShortString;
  LineNo: LongInt;
  DNErrFile: Text;

  {$ENDIF}

begin
SysDisableHardErrors;

{CtrlBreakHandler := TVCtrlBreak;
SysCtrlSetCBreakHandler;}
{$IFDEF LINEPOSIT}
try
  {Init09Handler;}
  {Cat: �஢��塞 �� ��室�, ᪮�쪮 ����� ��蠫���
      ᮧ��� ���, �㤠 ���� �����뢠���� �� �맮�� ��⮤�� Load � Store}
  begin
 {$IFNDEF DPMI32}
  repeat
 {$ENDIF}
  RUN_IT;
 {$IFNDEF DPMI32}
  until not RestartOnExit;
 {$ENDIF}
  end
  {/Cat}
except
  on E: EControlC do
    begin
    {�����᪨ �� ������� �� Ctrl-C, � Close �१ ������,
       ��� ��⥬��� ����, ��� ��⥬�� ᯨ᮪ �����. � Ctrl-Crek, Ctrl-C
       ��ࠡ��뢠���� � killer � � �� ��������.}
    CloseWriteStream;
    end;
  on E: Exception do
    begin
    CloseWriteStream;
    ClearScreen;
    SysTvShowBuf(0, ScreenWidth*ScreenHeight);
    SourceDir := SourceDir+'DN.ERR';
    Writeln('Fatal Error'^M^J'-----------'^M^J^M^J+
      'Exception 0', Hex2(ExitCode), 'h at address ',
           Hex8(LongInt(ExceptAddr)));
    Writeln(E.Message);
    if GetLocationInfo(ExceptAddr, FileName, LineNo) <> nil then
      Writeln('Source location: '+FileName+' line ', LineNo);
    Writeln('Please report to RU.SHELL.DN'^M^J+
      '( file '+SourceDir+' )'^M^J^M^J+
      'Press any key...');
{$I-}
    Assign(DNErrFile, SourceDir);
    ClrIO;
    Append(DNErrFile);
    if IOResult <> 0 then
      Rewrite(DNErrFile);
    Writeln(DNErrFile, '');
    Writeln(DNErrFile, 'DN/2 ' + VersionName + ' compiled '+VersionDate);
    Writeln(DNErrFile, E.Message);
    if GetLocationInfo(ExceptAddr, FileName, LineNo) <> nil then
      Writeln(DNErrFile, 'Source location: '+FileName+' line ', LineNo)
    else
      Writeln(DNErrFile, 'Exception at addr '+Ptr2Hex(ExceptAddr));
    Close(DNErrFile);
    repeat
      SysCtrlSleep(1); {JO}

    until SysKeyPressed;
    while SysKeyPressed do
      SysReadKey;
    SysTVInitCursor;
    end;
end;
{$ELSE} {LINEPOSIT}
 {$IFNDEF DPMI32}
repeat
 {$ENDIF}
RUN_IT;
 {$IFNDEF DPMI32}
until not RestartOnExit;
 {$ENDIF}
{$ENDIF} {LINEPOSIT}

(*{$ENDIF PLUGIN}*)
{$IFDEF DPMI32}
remove_i24;
RemoveDpmi32Exceptionhandlers;
{$ENDIF}

end.
