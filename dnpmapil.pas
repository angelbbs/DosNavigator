(*���������������������������������������������������������
//�                                                       �
//�      Dos Navigator/2 Runtime Dymanic Link Library     �
//�      OS/2 Presentation Manager API interface          �
//�      ��������������������������������������������������
//�      by Jaroslaw Osadtchiy (JO), 2:5030/1082.53       �
//�      modified by Aleksej Kozlov (Cat), 2:5030/1326.13 �
//�      modified by Alexey Korop (AK155), 2:461/155      �
//�                                                       �
//���������������������������������������������������������
*)

{$X+,T-,Cdecl+,AlignRec-,OrgName+,V-,Use32-,Delphi+}
{$I STDEFINE.INC}

library DnPmApil;

{$Linker
DESCRIPTION 'Dos Navigator/2 OS/2 PM API interface'}

uses
  Os2Def, Os2Base, OS2PMApi, Strings
  ;

{$IFDEF PLUGIN}
(*{$DYNAMIC DN2CAT.LIB}*)
{$ENDIF}

const
  PMStatus: Byte = 0; {Cat}
  { 0 = Not checked yet                          }
  { 1 = Full Screen without Presentation Manager }
  { 2 = Full Screen with Presentation Manager    }
  { 3 = Windowed                                 }

var
  Tib: PTib;
  Pib: PPib;
  Anchor: HAB;
  Queue: HMQ;
  hSw: lHandle;
  SwData: SwCntrl;
  hwndDeskTop, MyWindow: HWND;

function WinQueryObjectSh(pszObjectID: PChar): lHandle;
  begin
  WinQueryObjectSh := WinQueryObject(pszObjectID);
  end;

function WinOpenObjectSh(hObject: lHandle; ulView: ULong; Flag: Boolean)
  : Boolean;
  begin
  WinOpenObjectSh := WinOpenObject(hObject, ulView, Flag);
  if Result then
    WinSetActiveWindow(hwndDeskTop, WinQueryWindow(SwData.HWND, QW_NEXTTOP));
      { WinOpenObject ���뢠�� ����� �� �� ��।��� �����, � �������뢠��
      �� ��� ���誮 DN, �� ��㤮���. ��⨢����� ᫥���饣� �� DN ���� -
      �� ��� ࠧ ��⨢����� ⮫쪮 �� ����⮩ �����. }
  end;

function WinCreateObjectSh(pszClassName: PChar; pszTitle: PChar;
    pszSetupString: PChar; pszLocation: PChar): lHandle;
  begin
  WinCreateObjectSh := WinCreateObject(pszClassName, pszTitle,
      pszSetupString, pszLocation, 0);
  end;

function WinSetTitleAndIconSh(szTitle, szIconPath: PChar): Integer;
  begin
  WinSetTitleAndIconSh := WinSetTitleAndIcon(szTitle, szIconPath);
  end;

function IsBGWindow: Boolean; {AK155}
  var
    Focus: HWND;
  begin
  IsBGWindow := False;
  if MyWindow <> 0 then
    begin
    Focus := WinQueryFocus(hwndDeskTop);
    IsBGWindow := Focus <> MyWindow;
    end;
  end;

procedure XSetTitle(Title: String);
  var
    I: Byte;
  begin
  if hSw <> 0 then
    begin
    with SwData do
      begin
      if Length(Title) > MaxNameL then
        begin
        Move(Title[1], szSwTitle[0], MaxNameL);
        szSwTitle[MaxNameL] := #0;
        end
      else
        begin
        Move(Title[1], szSwTitle[0], Length(Title));
        szSwTitle[Length(Title)] := #0;
        end;
      WinSetWindowText(HWND, @szSwTitle[0]);
      end;
    WinChangeSwitchEntry(hSw, @SwData);
    end;
  end { XSetTitle };

function XClipCanPaste: Boolean;
  var
    Fmt: ULong;
  begin
  Result := WinQueryClipBrdFmtInfo(WinInitialize(0), cf_Text, Fmt);
  end;

function XClipCopy(P: PChar; Size: LongInt): Boolean;
  var
    Q: PChar;
  begin
  Result := False;
  if WinOpenClipBrd(Anchor) then
    begin
    // Allocate giveable block of memory
    DosAllocSharedMem(Pointer(Q), nil, Size+1,
       pag_Write+pag_Commit+obj_Giveable);
    if Q <> nil then
      begin
      // Copy clipboard data across
      Move(P^, Q^, Size);
      Q[Size] := #0;
      // Insert data into clipboard
      WinEmptyClipbrd(Anchor);
        { AK155 24.05.2005
          �᫨ ���� �� ������, � � �� ����� ������� �०��� ����
        ������ ������, � ������� �ਫ������ (�������, ���ਬ��)
        ���� ����� ������� ������� ������ ����� �����. � १����
        ����砥���, �� �᫨ ������� ��-� ��⠢��� � ���� (� ����),
        � ��⮬ ��⠢�� �� DN ��� ��������, � ��������� �, �� ��������
        ᠬ�. � �᫨ ���� ������ - ��� ࠡ�⠥� ��� �஡���.
          ����� ������� � ���� ����� ����� ������⥫쭮, ⠪ ��� ��
        ����� �맢��� �஡���� � ����� ��⥬�� ��� �����প� ����.}
      Result := WinSetClipBrdData(Anchor, ULong(Q), cf_Text, cfi_Pointer);
      end;
    WinCloseClipBrd(Anchor);
    end;
  end;

function XClipPaste(var Size: LongInt): Pointer;
  var
    P: PChar;
    Flags: LongInt;
    l: LongInt;
  begin
  Result := nil;
  Size := 0;
  if WinOpenClipBrd(Anchor) then
    begin
    P := PChar(WinQueryClipBrdData(Anchor, cf_Text));
    if P <> nil then
      begin
      l := StrLen(P)+1;
      if  (DosQueryMem(P, l, Flags) = 0) and (Flags and 1 <> 0) then
        begin
        if DosAllocMem(Result, l, pag_Write or pag_Commit) = 0 then
          begin
          Size := l;
          Move(P^, Result^, Size);
          end;
        end;
      end;
    WinCloseClipBrd(Anchor);
    end;
  end { XClipPaste };

function XCheckPM: Byte;
  begin
  XCheckPM := PMStatus;
  end;

function WinSwitchToProgramSh(Pid: LongInt): LongInt;
  var
    wnd: HWND;
  begin
  wnd := 0;
  Result := WinSwitchToProgram(WinQuerySwitchHandle(wnd, Pid));
  end;

function WinQueryTaskTitleSh(PSessId: LongInt; var Title: String): LongInt;
  var
    PTitle: PChar;
    PTitleArr: array[0..255] of Char;
  begin
  PTitle := PTitleArr;
  Result := WinQueryTaskTitle(PSessId, PTitle, 255);
  Title := StrPas(PTitle);
  end;


{&Cdecl-}
function CheckPM: Boolean; {Cat}
  {
label
  L;
}
  const
    ModuleInfoSize = 400000;
    PMSHELL = 'PMSHELL.EXE'#0;
    { PMSHELL: array[0..Length('PMSHELL.EXE')-1] of char = 'PMSHELL.EXE'; }
  var
    FailedModule: array[0..255] of Char;
    LibHandle: hModule;
    Dos32QuerySysState: function (func, arg1, Pid, _res_: ULong;
       Buf: Pointer; BufSz: ULong): ApiRet cdecl;
    ModuleInfo: PChar;
    SearchPos, I: LongInt;
  begin
  CheckPM := False;
  if DosLoadModule(FailedModule, SizeOf(FailedModule), 'DOSCALLS',
       LibHandle) = 0
  then
    if DosQueryProcAddr(LibHandle, 368, nil, @Dos32QuerySysState) = 0
    then
      begin
      GetMem(ModuleInfo, ModuleInfoSize);
      FillChar(ModuleInfo^, ModuleInfoSize, 0);
      Dos32QuerySysState(
        $00000004, // module data
        0, // reserved
        0, // all processes
        0, // reserved
        ModuleInfo,
        ModuleInfoSize);

      // search PMSHELL.EXE
      SearchPos := 0;
      while SearchPos+Length(PMSHELL) < ModuleInfoSize do
        if StrComp(@ModuleInfo[SearchPos], PMSHELL) = 0 then
          begin
          CheckPM := True;
          Break;
          end
        else
          Inc(SearchPos);
      (*
        SearchPos:=0;
        while SearchPos+Length(PMSHELL)<ModuleInfoSize do
          for I := 1 to Length(PMSHELL) do
            begin
              if ModuleInfo[SearchPos+I-1] <> PMSHELL[I] then
                begin
                  Inc(SearchPos);
                  Break;
                end;
              CheckPM := True;
              goto L;
            end;
        L:
*)

      FreeMem(ModuleInfo, ModuleInfoSize);
      DosFreeModule(LibHandle);
      end;
  end { CheckPM: };

procedure Done;
  begin
  if Queue <> 0 then
    WinDestroyMsgQueue(Queue);
  if Anchor <> 0 then
    WinTerminate(Anchor);
  end;
{&Cdecl+}

exports
WinQueryObjectSh Name'WinQueryObjectSh',
WinOpenObjectSh Name'WinOpenObjectSh',
WinCreateObjectSh Name'WinCreateObjectSh',
WinSetTitleAndIconSh Name'WinSetTitleAndIconSh',
XSetTitle Name'XSetTitle',
XClipCopy Name'XClipCopy',
XClipPaste Name'XClipPaste',
XClipCanPaste Name'XClipCanPaste',
XCheckPM Name'XCheckPM',
IsBGWindow Name'IsBGWindow', {AK155}
WinSwitchToProgramSh Name'WinSwitchToProgramSh', {JO}
WinQueryTaskTitleSh Name'WinQueryTaskTitleSh'; {JO}

initialization {Cat}
if PMStatus = 0 {��� �� �஢��﫨} then
  begin
  FillChar(SwData, SizeOf(SwData), 0);
  MyWindow := 0;
  AddExitProc(Done);
  if DosGetInfoBlocks(Tib, Pib) = 0 then
    with Pib^ do
      begin
      {�஢��塞 ����稥 Presentation Manager}
      if Pib_ulType = 2 then
        PMStatus := 3 {� ���誥}
      else if CheckPM then
        PMStatus := 2 {FS ��� PM}
      else
        PMStatus := 1; {FS ��� PM}

      {��⢮�塞�� �ਫ������� ��� Presentation Manager}
      if PMStatus >= 2 then
        begin
        Pib_ulType := 3;
        Anchor := WinInitialize(0);
        if Anchor <> 0 then
          begin
          Queue := WinCreateMsgQueue(Anchor, 0);
          hwndDeskTop := WinQueryDesktopWindow(Anchor, NULLHANDLE);
          end;
        hSw := WinQuerySwitchHandle(0, Pib_ulPid);

        {AK155: ������� SwData �����筮 ���� ࠧ }
        if hSw <> 0 then
          begin
          WinQuerySwitchEntry(hSw, @SwData);
          if  (PMStatus = 3) and (hwndDeskTop <> 0) then
            MyWindow := WinQueryWindow(SwData.HWND, QW_BOTTOM);
          {SwData.hwnd - �� 奭�� ࠬ��, � ����७�����
                       ���� � z-���浪� ��᫥���� ����� � ࠬ��}
          end;
        end
      end
  else
    PMStatus := 1;
  end;
end.
