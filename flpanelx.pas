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

unit
FlPanelX;

interface

uses
  Defines, Streams,
  Views, Drivers, FilesCol, PDSetup, Drives, xTime
  ;

type
  PFilePanelRoot = ^TFilePanelRoot;
  {` ������ ⨯ 䠩����� ������ }
  TFilePanelRoot = object(TView)
    isValid, MSelect, SelectFlag, Loaded, ChangeLocked: Boolean;
    SelfNum: Boolean; // �����᪨ - TPanelNum;
      {` ����� �� ������: �ࠢ�� ��� ����� `}
    InfoView, DirView, DriveLine, SortView: PView;
    Delta, OldDelta, OldPos, DeltaX: LongInt;
    Files: PFilesCollection;
    DirectoryName, OldDirectory: String;
    ScrollBar: PMyScrollBar;
    DrawDisableLvl, SelNum, LineLength: LongInt;
    SelectedLen, PackedLen: TSize;
    WasActive, PosChanged, CommandEnabling,
    {QuickSearch,}QuickViewEnabled: Boolean;
    TotalInfo: TSize;
    FreeSpace: String[50];
    PanelSetupSet: TPanelSetupSet;
      {` ���� ⥪��� ����஥� ��� ��� ⨯�� ������� `}
    PanSetup: PPanelSetup;
      {` ����뢠�� ������ PanelSetupSet �� ���� ⥪�饣� ⨯� ������ `}
    PresetNum: Byte;
      {` �� ���� ������ ����� ��ந���� ⥪�騥 ����ன�� `}
    LFNLen, ExtLen: Byte;
      {`2 ������ ����� ��������� ��ப �� Panel^.PanSetup^.Show.
      ������� ⮫쪮 ��� �᪮७�� ����㯠. `}
    LFNLonger250: Boolean;
      {` ���� ����� �ப�� � ������ ���� ��᫥���� `}
    DriveLetter: Char;
      {` ��� �롮� ������祭�� ��᪠ � ������� ��᪮� � ���� ��᪮�;
        ���筮 �� Drive^.GetDriveLetter, �� � ����� ��६�饭�� �� �����
        ��᪮� ����� �६���� ���� � ��㣮�. `}
    PrevPresetNum: Byte;
    PrevPanelSetupSet: TPanelSetupSet;

    Drive: PDrive;
    ForceReading: Boolean;
    DriveState: Word;
    LastCurPos: TPoint;
    SelectedInfoInDividerMin, SelectedInfoInDividerMax: Word; {AK155}
    TotalInfoInDividerMin, TotalInfoInDividerMax: Word; {AK155}
      {` ��न���� ��� D&D `}
    _Tmr1: TEventTimer;
    constructor Init(var Bounds: TRect; ADrive: Integer;
         AScrBar: PMyScrollBar);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    destructor Done; virtual;
    procedure Awaken; virtual;
    procedure CommandHandle(var Event: TEvent);
    procedure ChangeBounds(var Bounds: TRect); virtual;
    function Valid(Command: Word): Boolean; virtual;
    procedure GetUserParams(var FileRec: PFileRec; var List: String;
         BuildList: Boolean);
    procedure ReadDirectory;
    procedure RereadDir;
    procedure RedrawPanelInfoDir; virtual; {<flpanelx.001>}
      {` ����ᮢ��� ������, ������ � ���������. ����� ��᪮�
      �� ����ᮢ뢠���� `}
    procedure SendLocated;
     {` ����������� ��㣮� (��䠩�����) ������ �� 㤥ঠ���
      ����� �� 䠩��. �ᯮ������ ��� QView � DizView`}
    procedure IncDrawDisabled;
    procedure DecDrawDisabled;
    procedure ChkNoMem;
    procedure ChDir(Dir: String);
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Reorder;
      {` ������஢��� 䠩�� � ᮮ⢥��⢨� � ⥪�騬� (�������訬���)
      ��⠭������ ���஢�� `}
    function CalcColPos(ColFlag: Word): Integer;
      {` �������� ������ ��᫥���� �� �������, �⬥祭��� � ColFlag.
       ������� ����� � ���⨪��쭠� ����� ��᫥ ��� � ���� ����樨
       �� �室��. ���ਬ��, CalcColPos(psnSize)=0. `}
    function CalcLengthWithoutName: Integer;
    function CalcNameLength: Integer;
    function CalcLength: Integer;
    procedure FormatName(P: PFileRec; var S: String; var L: Integer);
     {` ��ନ஢��� ��ப� ����� ��� �������, L - 䠪��᪠� �ਭ�
       (����� ���� �� LFNLen, � 12, �᫨ ��� DualName ��⠭�����
       ����� ���⪨� ���) `}
    procedure GetEmpty(var B; SC: Word; Scroll: Boolean); virtual;
     {` ������� � ��࠭�� ���������� ���� B � �㦭� ���� Draw-���
        ࠧ����⥫� ������� (SC). �ᯮ������ ��� �ନ஢����
        ������ ������⮢ ������ � ��� ᮥ������� ࠧ����⥫�
        � ���⨪���묨 ����ﬨ ������� `}
    procedure GetParam(i: Integer);
      {` ����㧨�� ����ன�� (���筮) �� ����.
         ����⢥��� ����� ��室���� � ������ 4 ࠧ�鸞� i. �᫨ �
      ����� ࠧ�鸞� ���� ��-� ���㫥��� - ����ன�� ����㦠����
      ���������, �᫨ ���� �㫨 - ����㦠���� ⮫쪮 ᥪ�� Show
      (�� ��� ��� ����ᮢ �������).
         �᫨ ����� 1..10, � �� ����� ����. ����ன�� �
      ���� ����� ���� ������������ ��। ����㧪��.
         �᫨ ����� ࠢ�� 11, � ��� ��������筮, �� ����ன��
      ����㦠���� �� �� ����, � �� ��㣮� ������.
         �᫨ ����� ࠢ�� 12, � �������� ���⠬� ����ன��
      ⥪��� � �����������.
         ����� ������ ����㧪� ⮫쪮 ���� � ⥪��� ����ன�� ����
      ᮢ������ �� ᮤ�ঠ��� � ⮩, ����� ������ ���� ����㦥��,
      ����� �⮩ �����᫥���� ����㧪� ��뢠���� ���� ����㧪� ����.
         ��. ⠪�� CM_ToggleShowMode.
      `}
    procedure Rebound;
    procedure SetupPanelFromDrive;
      {` ��᫥ ᬥ�� Drive �ਭ��� � �ᯮ�짮����� ᥪ�� ����஥�,
      ᮮ⢥�������� ������ ������ Drive  `}
    procedure AddSelected(PF: PFileRec);
      {` �᫨ PF^ �뤥���, �� ���뢠���� � SelNum, SelectedLen, PackedLen`}
    end;
  {`}

  {                                                                        }
  { WARNING: The following vars are mirrored in FLPANEL.PAS via ABSOLUTEs! }
  { �� �� �������਩ Cat. �᫨ � �� ��� � ����᭨�, ��祬 �� �㦭�.
    � ��� 䮪�� �모��, �த�, �㦥 �� �⠫�. ��� �� �⡮�.}

const
  ActivePanel: PFilePanelRoot = nil;
    {` �����⥫� �� ��⨢��� 䠩����� ������ ��⨢���� ��������.
     ��⠭���������� � TFilePanel.SetState, ⠪ �� ��� �⮣� ��⮤�
     ���祭�� �⮩ ��६����� �ᥣ�� ���४⭮.`}
  PassivePanel: PFilePanelRoot = nil;
    {` �����⥫� �� ���ᨢ��� 䠩����� ������ ��⨢���� ��������.
    �. ActivePanel. `}
  CtrlWas: Boolean = False;
    {` �� ����� Ctrl ����� � ��५����. �ᯮ������ ��� �᪮७����
    ��ᬮ�� 䠩��� � ������ (⨯� Ctrl-Up, Up, ������� Ctrl.
    ����᭮, �� �������筮� ᫥����� �� ���᪠���� Ctrl ��
    ��६�饭�� �� ����� ��᪮� �������� �� ����� 横�� � ���ᮬ
    ᮡ���, �. ��ࠡ��� kbCtrlLeft `}
  DirsToChange: array[0..9] of PString = (nil, nil, nil, nil, nil, nil,
     nil, nil, nil, nil);
  QuickSearch: Boolean = False;
  {AK155 5-01-2002. �� �⮣� �뫮 ⠪�� ����
� TFilePanelRoot � � Tree.TTreeView. ��᪮��� �� ������ �ᯮ�짮�����
QuickSearch ����� ���� ⮫쪮 ����, ����⢥��� �襭��� ����
������쭠� ��६�����, � �� �� ࠧ���뢠��� �� ��ꥪ⠬ ��祣�, �஬�
��� ���� �� �����. ������� ��� �ॢ�饭�� ��� ���� � ���������
��६����� ���㦨�� ������� �஠������஢��� �� � TCommandLine.Update }

//JO: �� ������ ���஢�� � TFilePanelRoot.ReadDirectory
//    ���祭�� True �������� � ��楤��� ���᪠ �⮡� �� ���஢���
//    ������ � १���⠬� ���᪠; ����� ᫥����, �⮡� �� ��室� ��
//    ��楤��� �ᥣ�� �뫮 ���祭�� False
  RereadNoSort: Boolean  = False;

var
  CurrentDirectory: String;
  PShootState: Word;

function OtherFilePanel(P: PFilePanelRoot): PFilePanelRoot;

implementation

uses
  Lfn, Files, Advance, Advance1, Advance2, Advance3, VpSysLow,
  Messages, DNApp, DNHelp, Startup, Commands, Histries, HistList, FLTools,
  FileFind, CmdLine, ArcView, Archiver, DiskImg, DiskInfo, FileCopy,
  DNUtil, FlTl, Dos, Filediz, Collect, VPUtils,
  DnIni_p, DnIni {-$VIV}
  {$IFDEF MODEM} {$IFDEF LINK}, NavyLink {$ENDIF} {$ENDIF}
  {$IFDEF UUENCODE}, UUCode {$ELSE}
  {$IFDEF UUDECODE}, UUCode {$ENDIF} {$ENDIF}
  {$IFDEF USEWPS}, Strings
  {$IFDEF OS2}, Dn2PmApi {$ENDIF}
  {$IFDEF WIN32}, U_KeyMap {$ENDIF}
  {$ENDIF}
  {$IFDEF PLUGIN}, Plugin {$ENDIF}
  , DblWnd, FlPanel, FileType
  {$IFDEF NetBrowser}, NetBrwsr{$ENDIF}
  {$IFDEF ARVID}, Arvid {$ENDIF}
  ;

procedure TFilePanelRoot.IncDrawDisabled;
  begin
  Inc(DrawDisableLvl);
  end;

procedure TFilePanelRoot.DecDrawDisabled;
  begin
  Dec(DrawDisableLvl);
  ChkNoMem;
  end;

procedure TFilePanelRoot.ChkNoMem;
  begin
  if Drive^.NoMemory and (DrawDisableLvl = 0) then
    begin
    Application^.OutOfMemory;
    Drive^.NoMemory := False;
    end;
  end;

constructor TFilePanelRoot.Init;
  begin
  inherited Init(Bounds);
  NewTimer(_Tmr1, 0);
  CommandEnabling := True;
  Abort := False;
  HelpCtx := hcFilePanel;
  GrowMode := gfGrowHiY+gfGrowHiX;
  Options := Options or ofSelectable or ofTopSelect or ofFirstClick;

  EventMask := $FFFF;

  ScrollBar := AScrBar;
  OldDelta := -1;
  PosChanged := False;

  if  (ADrive <= 0) or not ValidDrive(Char(ADrive+64)) then
    ADrive := 0;
  Drive := New(PDrive, Init(ADrive, @Self));

  if Abort then
    Exit;
  PresetNum := FMSetup.NewPanelPreset+1;
  PrevPresetNum := PresetNum;
  PanelSetupSet := PanSetupPreset[PresetNum];
  PrevPanelSetupSet := PanelSetupSet;
  SetupPanelFromDrive;
  isValid := True;
  {GetDir(ADrive, DirectoryName);}

  if not Abort then
    ReadDirectory;
  isValid := isValid and not Abort;
  DecDrawDisabled;
  end { TFilePanelRoot.Init };

constructor TFilePanelRoot.Load;
  var
    I: LongInt;
    dumm: array[1..20] of Byte;
  begin
  inherited Load(S);
  NewTimer(_Tmr1, 0);
  ChangeLocked := False;
  GetPeerViewPtr(S, ScrollBar);
  GetPeerViewPtr(S, DirView);
  GetPeerViewPtr(S, InfoView);
  GetPeerViewPtr(S, DriveLine);
  GetPeerViewPtr(S, SortView);
  Drive := PDrive(S.Get);
  if Drive = nil then
    New(Drive, Init(0, @Self))
  else
    Drive^.Panel := @Self;
  SetupPanelFromDrive;
  S.Read(PresetNum, SizeOf(PresetNum));
  S.Read(PanelSetupSet, SizeOf(PanelSetupSet));
  S.Read(PrevPresetNum, SizeOf(PrevPresetNum));
  S.Read(PrevPanelSetupSet, SizeOf(PrevPanelSetupSet));

 {$IFNDEF DPMI32}
//JO: � �ᥢ�� � �������� ��p��� RunFirst = False ⮫쪮 ��᫥
//    ᬥ�� �몠, ���p�� �� ����� �맢��� ��������� � �������;
//    � DPMI-��pᨨ RunFirst = False � ��᫥ ����᪠ ���譨� �p��p���,
//    ���p� ����� ��㤠���� 䠩�� �� ������
  if RunFirst then
 {$ENDIF}
    Drive^.RereadDirectory('');
  if Drive <> nil then
    begin
    Drive^.SizeX := Size.X;
    DirectoryName := Drive^.GetDir;
    end;
  S.Read(Delta, 2);
  OldDelta := -1;
  PosChanged := False;
  S.Read(ForceReading, 1);
//JO: 11-05-2006 - ���������p���� ���� ��p��� �뫨 ��� � p�⫠���᪮�
//    ��pᨨ; ��� 祣� �� �㦭� - �� ������ ����⭮, �� �� ����稥
//    ��p������ ⠪�� ����p��� ���: �p� ���p㧪� ������ ���᪠ ��� ��⢨
//    � 䠩��, ���p� ���� ⥪�騬, ��祬�-� ���� ��������� ��
//    ���祭�� Drive^.CurDir; ��᫥ ���������p������ ������� ��� ���
//    �������⥫��� �p����� �� ��p�� ����� �� ����祭�, � ���뢠�, ��
//    � �����p��p� Init ���祭�� Files �� ���樠����p����, � ����� ���
//    �� ���樠����p����� � � Load
{ Files := PFilesCollection(S.Get);
  if Files <> nil then
    for I := 0 to Files^.Count-1 do
      PFileRec(Files^.At(I))^.Owner := @Drive^.CurDir;} {DataCompBoy}
  Loaded := True;
//  MSelect := False;
  isValid := True;
  StopQuickSearch;
//  QuickViewEnabled := False;
  CommandEnabling := True;
  end { TFilePanelRoot.Load };

procedure TFilePanelRoot.Awaken;
  begin
  SetupPanelFromDrive;
 {! AK155 27.04.05 � ��� �ᥣ� ��������ᠭ���� ��ଠ�쭮 ࠡ�⠥� }
(*
  RereadDir;
  if  (DriveLine <> nil) then
    if  (FMSetup.Show and fmsDriveLine <> 0) and
        (State and sfVisible <> 0)
    then
      begin
      if not DriveLine^.GetState(sfVisible) then
        DriveLine^.Show;
      end
    else if DriveLine^.GetState(sfVisible) then
      DriveLine^.Hide;
*)
  end;

procedure TFilePanelRoot.Store;
  begin
  inherited Store(S);
  PutPeerViewPtr(S, ScrollBar);
  PutPeerViewPtr(S, DirView);
  PutPeerViewPtr(S, InfoView);
  PutPeerViewPtr(S, DriveLine);
  PutPeerViewPtr(S, SortView);
  if  (ActivePanel <> @Self) or (Drive^.DriveType <> dtDisk)
    or (StartupData.Unload and osuPreserveDir <> 0)
  then
    S.Put(Drive)
  else
    S.Put(nil);
  S.Write(PresetNum, SizeOf(PresetNum));
  S.Write(PanelSetupSet, SizeOf(PanelSetupSet));
  S.Write(PrevPresetNum, SizeOf(PrevPresetNum));
  S.Write(PrevPanelSetupSet, SizeOf(PrevPanelSetupSet));
  S.Write(Delta, 2);
  S.Write(ForceReading, 1);
 {PFilesCollection(Files)^.Selected := ScrollBar^.Value;
  S.Put(Files);} //JO: 11-05-2006 - �. �������p�� � TFilePanelRoot.Load;
  end { TFilePanelRoot.Store };

function TFilePanelRoot.Valid;
  begin
  Valid := isValid;
  if  (Command = cmClose) then
    Valid := Drive^.Disposable;
  end;

destructor TFilePanelRoot.Done;
  var
    P: PDrive;
  begin
  if Files <> nil then
    Dispose(Files, Done);
  Files := nil;
  if Drive <> nil then
    Dispose(Drive, Done);
  Drive := nil;
  if ActivePanel = @Self then
    begin
    ActivePanel := nil;
    PassivePanel := nil;
    { ������ 㭨�⮦����� ⮫쪮 ��� �ࠧ�, ⠪ �� �� 㪠��⥫�
    ����� ������ �� ���� ࠧ }
    end;
  inherited Done;
  end;

procedure TFilePanelRoot.SetState(AState: Word; Enable: Boolean);
   {�� ������ �� �ᯮ������ �� ᬥ�� �� ��䠩����� ������ � ���⭮}
  var
    SortEn: Boolean;
  begin
  inherited SetState(AState, Enable);
  if AState = sfVisible then
    begin
    if DirView <> nil then
      DirView^.SetState(AState, Enable);
    if SortView <> nil then
      begin
      if (AState = sfVisible) then
        SortEn := Enable and ((FMSetup.Show and fmsSortIndicator) <> 0)
      else
        SortEn := Enable;
      SortView^.SetState(AState, SortEn);
      end;
    if DriveLine <> nil then
      DriveLine^.SetState(AState, Enable);
    if Enable and Loaded then
      RereadDir;
    end;
  end;

procedure TFilePanelRoot.ChangeBounds;
  var
    R: TRect;
    InfoViewHeight: LongInt;
  begin
  if DriveLine <> nil then
    begin
    R := Bounds;
    R.A.Y := R.B.Y;
    Inc(R.B.Y);
    DriveLine^.SetBounds(R);
    DriveLine^.SetState(sfVisible, FMSetup.Show and fmsDriveLine <> 0);
    end;
  if InfoView <> nil then
    begin
    if Loaded then { ��� �⮣� InfoView^.Draw ����� ��横������ }
      LineLength := CalcLength;
    PInfoView(InfoView)^.CompileShowOptions;
      { �� �⮬ ��।������ InfoView^.Size.Y }
    InfoViewHeight := InfoView^.Size.Y;
    R := Bounds;
    R.A.Y := R.B.Y-InfoViewHeight;
    InfoView^.SetBounds(R); {��� ����� ���� ��������� Size.X}
    { ����ᮢ����� InfoView^ �� �ᯥ��, � ����� ⠪�, ���筮, �� ���� ࠧ}
    Dec(Bounds.B.Y, InfoViewHeight);
    end;
  SetBounds(Bounds);
  R := Bounds;
  R.B.Y := R.A.Y;
  Dec(R.A.Y);
  if DirView <> nil then
    DirView^.SetBounds(R);
  if SortView <> nil then
    SortView^.SetBounds(R);
  if ScrollBar <> nil then
    begin
    R := Bounds;
    R.A.X := R.B.X;
    Inc(R.B.X);
    ScrollBar^.SetBounds(R)
    end;
  if Drive <> nil then
    begin
    Drive^.SizeX := Size.X;
    DirectoryName := Drive^.GetDir;
    end;
  end { TFilePanelRoot.ChangeBounds };

procedure TFilePanelRoot.SendLocated;
  var
    S: String;
    R: LongInt;
    CurFileRec: PFileRec;
  begin
  if  (Files^.Count = 0) or (Drive^.DriveType = dtArc) or
      (State and sfVisible = 0)
  then
    Exit;
  R := ScrollBar^.Value;
  if R >= Files^.Count then
    Exit;
  if not QuickViewEnabled or (Drive^.DriveType >= dtArc) then
    Exit;
  CurFileRec := PFileRec(Files^.At(R));
  Message(Owner, evCommand, cmLoadViewFile, CurFileRec)
  end;

{-DataCompBoy-}
procedure TFilePanelRoot.RereadDir;
  var
    P, PP, CurP: PFileRec;
    I, J, Pos: LongInt;
    l: LongInt;
    FC {,FCC}: PFilesCollection;
    NewDir: String;
    BB: Boolean;
    TF: TFileRec;
    WasLoaded, B: Boolean;
    PanelHeight: Integer; // ���� ������ ��� ��ப� ���������� �������

  begin
  PanelHeight := Size.Y-Byte((Pansetup^.Show.MiscOptions and 2) <> 0);
  {$IFDEF DualName}
  uLfn := PanSetup^.Show.ColumnsMask and psLFN_InColumns <> 0;
  {$ENDIF}
  Abort := False;
  OldDelta := Delta;
  PosChanged := False;
  WasLoaded := Loaded;
  if Loaded then
    begin
    LineLength := CalcLength;
    if Files <> nil then
      ScrollBar^.SetParams(PFilesCollection(Files)^.Selected, 0,
         Files^.Count-1,
         PanelHeight*((Size.X+1) div LineLength), 1);
    CurrentDirectory := ActiveDir;
    Loaded := False;
    if WasActive and (UpStrg(ActiveDir) <> UpStrg(DirectoryName)) then
      begin
      DirectoryName := ActiveDir;
      ReadDirectory;
      ScrollBar^.SetValue(0);
      Exit
      end;
    end;
  if  (Files = nil) or (Files^.Count = 0) then
    begin
    OldDelta := -1;
    Delta := 0
    end;
  ClrIO;
  Loaded := False;
(* AK155 ��祬 �� ��� ������������ ��� ��᮪ - ������⭮
  RedrawPanelInfoDir;
  if Abort then
    begin
    Dispose(Files, Done);
    New(Files, Init(10, 10));
    Abort := False;
    Exit;
    end;
*)
  NewDir := Drive^.GetRealDir;
  if Abort then
    begin
    Dispose(Files, Done);
    New(Files, Init(10, 10));
    Abort := False;
    Exit;
    end;
  if GetState(sfFocused) then
    CurrentDirectory := DirectoryName;
  if  (Files = nil) or (Files^.Count = 0) then
    begin
    DirectoryName := NewDir;
    ReadDirectory;
    RedrawPanelInfoDir;
    Exit
    end;
  FC := PFilesCollection(Files);
  Files := nil;
  IncDrawDisabled;
  Pos := ScrollBar^.Value;
  if UpStrg(NewDir) <> UpStrg(DirectoryName) then
    begin
    Pos := 0;
    DirectoryName := NewDir
    end;
  I := 0;
  CurP := FC^.At(Pos);
  while (I < FC^.Count) do
    begin
    P := FC^.At(I); {-$VOL}
    if  (P <> CurP) and (P <> nil) and not P^.Selected then
      FC^.AtReplace(I, nil); {-$VOL}
    Inc(I);
    end;
  ReadDirectory;
  B := not (Drive^.DriveType in [dtTemp, dtFind, dtList, dtArcFind]);
  if  (FC^.Count > 0) then
    begin
    SelNum := 0;
    SelectedLen := 0;
    PackedLen := 0;
    BB := False;
    for I := 0 to FC^.Count-1 do
      begin
      PP := FC^.At(I);
      if  (PP <> nil) and PP^.Selected or (PP = CurP) then
        for J := 0 to Files^.Count-1 do
          begin
          P := Files^.At(J); {-$VOL}
          if  (UpStrg(P^.FlName[uLfn]) = UpStrg(PP^.FlName[uLfn]))
            and (WasLoaded or (UpStrg(P^.Owner^) = UpStrg(PP^.Owner^)))
          then
            begin
            if B then
              begin
              l := TFileRecFixedSize+Length(PP^.FlName[True]);
              Move(PP^, TF, l);
              TF.UsageCount := 1; { �������� P^.UsageCount=1 }
              P^.UsageCount := PP^.UsageCount;
              Move(P^, PP^, l);
              Move(TF, P^, l);
              PP^.Selected := TF.Selected;
              end;
            FC^.AtPut(I, P); {-$VOL}
            Files^.AtPut(J, PP); {-$VOL}
            if PP^.TType = ttUpDir then
              PP^.Selected := False;
            AddSelected(PP);
            Break;
            end;
          end;
      end;
    if not BB then
      begin
      for I := 0 to Files^.Count-1 do
        begin
        P := Files^.At(I);
        if  (UpStrg(CurP^.FlName[uLfn]) = UpStrg(P^.FlName[uLfn])) and
            (UpStrg(CurP^.Owner^) = UpStrg(P^.Owner^))
        then
          begin
          Pos := I;
          Break;
          end;
        end;
      end;
    end
  else
    Pos := 0;
  Dispose(FC, Done);
  ScrollBar^.SetValue(Pos);
  DecDrawDisabled;
  DirectoryName := NewDir;
  RedrawPanelInfoDir;
  if GetState(sfFocused) and (Drive^.DriveType = dtDisk) then
    GlobalMessage(evCommand, cmRereadInfo, nil);
  SendLocated;
  end { TFilePanelRoot.RereadDir };
{-DataCompBoy-}

procedure TFilePanelRoot.RedrawPanelInfoDir;
  begin
  { if (ActivePanel = @Self) then
  begin Drive^.lChDir(DirectoryName); if TypeOf(Drive^) = TypeOf(TDrive) then CurrentDirectory := DirectoryName; end;}
  DrawView;
  if InfoView <> nil then
    InfoView^.DrawView;
  if DirView <> nil then
    DirView^.DrawView;
  if SortView <> nil then
    SortView^.SetState(sfVisible, (FMSetup.Show and fmsSortIndicator) <> 0);
      { �ᯮ�����, ���ਬ��, �� ����㧪� ����� }
  end;

{-DataCompBoy-}
procedure TFilePanelRoot.ReadDirectory;
  var
    SM: Word;
  begin
  if  (Owner <> nil) and
      (PDoubleWindow(Owner)^.NonFilePanelType = dtQView)
  then
    NeedLocated := GetSTime; {�⮡� ᬥ���� ����� ��⠫���}
  LineLength := CalcLength;
  Drive^.Panel := @Self;
  case Drive^.DriveType of
    dtArc, dtArcFind:
      HelpCtx := hcArchives;
    dtLink:
      HelpCtx := hcLinkPanel;
    else {case}
      HelpCtx := hcFilePanel;
  end {case};
  DosError := 0;
  PosChanged := False;
  Loaded := False;
  Abort := False;
  ClrIO;
  FreeSpace := '';
  if Files <> nil then
    begin
    Dispose(Files, Done);
//JO: �᫨ ��������饣� ��᢮���� nil ����� �� ������, � �� �맮��
//    ��� ������� ������ Drive^.GetDirectory � ����让 ����⭮����
//    �ந�室�� ������� ��᫥ ��� �������
    Files := nil;
    end;
  Files := PFilesCollection(Drive^.GetDirectory(
         PanSetup^.FileMask, TotalInfo));

//  if PanSetup^.Show.FreeSpaceInfo <> fseNotShow then
    Drive^.GetFreeSpace(FreeSpace);

  if (PanSetup^.Show.ColumnsMask and psShowDescript <> 0) or
     (FMSetup.Options and fmoAlwaysCopyDesc <> 0) or
     (PanSetup^.Sort.SortMode = psmDIZ) or
     (PanSetup^.Show.PathDescrInfo <> fseNotShow)
  then
    Drive^.ReadDescrptions(Files);


  {$IFDEF OS2}
  if DosError = 49 then
    MessageBox(GetString(dl_CodePage_FS_Error), nil, mfError+mfOKButton)
    ; {JO: �⫮� �㯮� �� HPFS � ���ࠢ��쭮� CP}
  {$ENDIF}
  if Files = nil then
    Files := New(PFilesCollection, Init($10, $10));
  PFilesCollection(Files)^.Panel := @Self;
  SelNum := 0;
  SelectedLen := 0;
  PackedLen := 0;

  SM := PanSetup^.Sort.SortMode;
  if RereadNoSort then
    SM := psmUnsorted;
  PFilesCollection(Files)^.SortMode := SM;

  { �뢠�� ���஢�� �� ���ᠭ��, ���⮬� Sort ���� ������
  ��᫥ ReadDescrptions }
  if SM <> psmUnsorted then
    Files^.Sort;
  if Abort then
    Exit;

  Files^.DelDuplicates(TotalInfo);
    { ��� �������� ��᫥ ���᪠ � ������ ᯨ᪠ � ��室��
      �����⠫����, �᫨ 䠩�� �� �����⠫���� ������⢮����
      � �� ���孥� �஢�� ⮦�.}

  if DriveState and dsInvalid > 0 then
    Exit;

  Drive^.SizeX := Size.X;
  if Drive^.DriveType = dtDisk
  then
    DirectoryName := Drive^.GetRealDir
  else
    DirectoryName := Drive^.GetDir;
  if GetState(sfSelected) then
    Message(Owner, evCommand, cmChangeTree, @DirectoryName);

  ScrollBar^.SetParams(ScrollBar^.Value, 0, Files^.Count-1,
         (Size.Y-Byte((Pansetup^.Show.MiscOptions and 2) <> 0))
    * ( (Size.X+1) div LineLength), 1);
  if  (ActivePanel = @Self) and (Drive^.DriveType = dtDisk) then
    CurrentDirectory := DirectoryName
  else
    Lfn.lChDir(CurrentDirectory);
  if Drive^.DriveType = dtDisk then
    Message(CommandLine, evCommand, cmRereadInfo, nil);
  Message(Owner, evCommand, cmRereadInfo, nil);
  if DriveLine <> nil then
    DriveLine^.DrawView;
  ChkNoMem;
  end { TFilePanelRoot.ReadDirectory };
{-DataCompBoy-}

{-DataCompBoy-}
procedure TFilePanelRoot.GetUserParams;
  var
    PF: PFileRec;
    S: String[1];
    T: lText;
    I: LongInt;

  begin
  FileRec := nil;
  List := '';
  if not GetState(sfVisible) or (Files = nil) or (Files^.Count = 0) then
    Exit;
  FileRec := Files^.At(ScrollBar^.Value);
  if BuildList then
    begin
    if GetState(sfSelected) then
      S := '$'
    else
      S := '';
    List := SwpDir+'$dn'+ItoS(DNNumber)+S+'.lst';
    {JO: ��� ����� - �祭� ᯮ�� ������. ����� ᯨ᮪ � �������� ���ᨨ       }
    {    ᮧ������� �� ���⪨� ������, ⥯��� - �� ⥬, ����� �����. � �,    }
    {    � ��㣮� - ᯮ୮� �襭��, � ������ � �ଠ� dn.mnu , dn.xrn � ���� }
    {    �����, ��� ��� ᯨ᮪ �ᯮ������ ������ ���� �� �����������      }
    {    㪠����, �� ����� ������ ᮧ������ ᯨ᮪, �� ᥩ�� �� ���             }
    {    (�ᯮ������� ⮫쪮 ������ %1 � %2 ��� ��⨢��� � ���ᨢ��� ������    }
    {    ᮮ⢥��⢥���)                                                         }

    {Make list}
    {$IFDEF DualName}
    uLfn := PanSetup^.Show.ColumnsMask and psLFN_InColumns <> 0;
    {$ENDIF}
    lAssignText(T, List);
    ClrIO;
    lRewriteText(T);
    if Abort then
      Exit;
    if  (SelNum = 0) then
      begin
      PF := Files^.At(ScrollBar^.Value);
      Writeln(T.T, PF^.FlName[uLfn]);

      end
    else
      for I := 1 to Files^.Count do
        begin
        PF := Files^.At(I-1);
        if  (PF^.Selected) then
          Writeln(T.T, PF^.FlName[uLfn]);
        end;
    Close(T.T);
    end
  else
    List := '';
  end { TFilePanelRoot.GetUserParams };
{-DataCompBoy-}

{-DataCompBoy-}
procedure TFilePanelRoot.CommandHandle;
  var
    PF: PFileRec;
    CurPos: LongInt;
    MPos: TPoint;
    LastRDelay: Word;

  procedure CE;
    begin
    ClearEvent(Event)
    end;
  procedure CED;
    begin
    ClearEvent(Event);
    DrawView
    end;

  procedure GotoSingle(Name: String);
    var
      A: LongInt;
    begin
    A := Files^.Count;
    UpStr(Name);
    while A <> 0 do
      begin
      Dec(A);
      if UpStrg(PFileRec(Files^.At(A))^.FlName[True]) = Name then
        Break;
      {AK155 ��࠭��, ��祬� ��� �ࠢ�������� ⮫쪮 ������� ���. }
      end;
    IncDrawDisabled;
    OldDirectory := DirectoryName;
    ScrollBar^.SetValue(A);
    DecDrawDisabled;
    Rebound;
    end;

  function ChangeUp: Boolean;
    var
      S: String;
    begin
    Result := False;
    if ChangeLocked then
      Exit;
    ChangeUp := Drive^.isUp;
    DeltaX := 0;
    if Drive^.isUp then
      begin
      Drive^.ChangeUp(S);
      SetupPanelFromDrive;
      end
    else
      Exit;
    IncDrawDisabled;
    ReadDirectory;
    AddToDirectoryHistory(DirectoryName, Integer(Drive^.DriveType));
    if S <> '' then
      GotoSingle(S);
    DecDrawDisabled;
    Rebound;
    end;

  function ReplaceDrive(C: Char): Boolean;
    var
      PDr: PDrive;
    begin
    ReplaceDrive := False;
    New(PDr, Init(Byte(C)-64, @Self));
    if Abort then
      begin
      Dispose(PDr, Done);
      Exit;
      end;
    Dispose(Drive, Done);
    Drive := PDr;
    SetupPanelFromDrive;
    DeltaX := 0;
    {if WasFull then Drive^.Flags := Drive^.GetFullFlags
               else Drive^.Flags := 0;}
    Drive^.SizeX := Size.X;
    DirectoryName := Drive^.GetDir;
    if GetState(sfActive+sfSelected) then
      SetState(sfActive+sfSelected, True);
    Rebound;
    ReplaceDrive := True;
    end { ReplaceDrive };

  procedure GotoFile(FileName: String);
    var
      Dr: String;
      Nm: String;
      Xt: String;
      Name: String;
      A: LongInt;
      I: Byte;
      PathInside: String; {JO}
      Drv: PDrive; {JO}
    label WrongArc;
    begin
    if ChangeLocked then
      Exit;

    {JO: ���� ��३� � ���������� 䠩�� � ��娢� �� ������ ���᪠}
    PathInside := FileName;
    if PathInside[2] = ':' then
      PathInside[2] := ';'; {JO: ���塞 �����稥 �� ����� �� �� }
    I := PosChar(':', PathInside);
    if I > 0 then
      begin
      PathInside := Copy(FileName, I+1, 255);
      FileName := Copy(FileName, 1, I-1);
      end
    else
      PathInside := '';
    {/JO}

    lFSplit(FileName, Dr, Nm, Xt);
    if Copy(Dr, 1, 5) = cLINK_ then
      Delete(Dr, 1, 5);
    MakeNoSlash(Dr);
    if ((Dr[2] = ':') or (Copy(Dr, 1, 2) = '\\'))
         and not (Drive^.DriveType in [dtDisk, dtLink, dtArc])
    then
      { ���室�� � ������ ���᪠, ᯨ᪠ � �.�. �� ��� }
      begin
      Dispose(Drive, Done);
      New(Drive, Init(Byte(UpCase(Dr[1]))-64, @Self));
      end;
    {DirectoryName := GetNormPath(Dr);} {commented by AK155}
    IncDrawDisabled;
    OldDirectory := Dr;
    DeltaX := 0;
    DirectoryName := Drive^.GetDir;
    Drive^.lChDir(Dr); {AK155, was Drive^.lChDir(DirectoryName);}
{JO: �� �����뢠�� �⥢�� ��⠫��, �� ���ண� �� ��諨}
    if (Drive^.DriveType = dtNet)
       and (DirectoryName = Drive^.GetDir) then
      begin
      DecDrawDisabled;
      Exit;
      end;
{/JO}
    DriveLetter := Drive^.GetDriveLetter;
    DirectoryName := Drive^.GetDir;
{JO: ���室�� � �����쪨 Network �� ���}
    if (Drive^.DriveType = dtNet)
        and (Copy(DirectoryName, 1, 2) = '\\') then
      begin
      Dispose(Drive, Done);
      New(Drive, Init($1B, @Self));
      Drive^.lChDir(DirectoryName);
      end;
{/JO}
    Drive^.SizeX := Size.X;
    OldDelta := -1;
    Delta := 0;
    ReadDirectory;
    AddToDirectoryHistory(DirectoryName, Integer(Drive^.DriveType));
    DecDrawDisabled;

    {JO: ���室�� � ���������� 䠩�� � ��娢�}
    if  (PathInside <> '') then
      begin
      Drv := nil;
      Drv := New(PArcDrive, Init(FileName, FileName));
      if Drv = nil then
        goto WrongArc;
      if Drive^.DriveType <> dtDisk then
        ReplaceDrive(FileName[1]);
      Message(@Self, evCommand, cmInsertDrive, Drv);
      if  (GetPath(PathInside) <> '\') and (Drive^.DriveType = dtArc)
      then
        begin
        Drive^.lChDir(Copy(GetPath(PathInside), 2, 255));
        ReadDirectory;
        end;
      GotoSingle(GetName(PathInside));
      Exit;
      end;
WrongArc:
    {/JO}

    if  (Nm = '') and (Xt = '') then
      Name := '..'
    else
      Name := Nm+Xt;
    if Name = '.' then Name := '';{directory name '.' bugfix by piwamoto}
{$IFDEF NetBrowser}
{JO: �⮡� ���४⭮ ��⠢��� �� �㦭�� ��� �� ��室� �� ��� � ������ ��}
    if TypeOf(Drive^) = TypeOf(TNetDrive) then
      begin
      for I := Length(FileName) downto 1 do
        if Copy(FileName, I, 3) = '\\\' then
          begin
          Name := Copy(FileName, I + 1, MaxStringLength);
          Break;
          end;
      end;
{/JO}
{$ENDIF}
    GotoSingle(Name);
    end { GotoFile };

  function isSeldir: Boolean;
    begin
    isSeldir := False;
    if Files^.Count = 0 then
      Exit;
    if CurPos >= Files^.Count then
      Exit;
    isSeldir := PFileRec(Files^.At(CurPos))^.Attr and Directory <> 0;
    end;

  procedure ViewFile(Command: Word);
    var
      S: String;
      P: PFileRec;
    begin
    if Files^.Count = 0 then
      Exit;
    CE;
    if CurPos >= Files^.Count then
      Exit;
    P := Files^.At(CurPos);
    if P^.Attr and Directory <> 0 then
      Exit;
    {&Frame-}
    asm
   mov eax,Command
   cmp eax,cmIntEditFile
   jnz @@1
   mov eax,cmIntFileEdit;
   jmp @@0
@@1:
   cmp eax,cmIntViewFile
   jnz @@2
   mov eax,cmIntFileView;
   jmp @@0
@@2:
   cmp eax,cmEditFile
   jnz @@3
   mov eax,cmFileEdit;
   jmp @@0
@@3: {AK155}
   cmp eax,cmFileTextView
   jne @@4
   mov eax,cmViewText
   jmp @@0
@@4: {/AK155}
   mov eax,cmFileView;
@@0:
   mov Command, eax
  end;
    Drive^.UseFile(P, Command);
    end { ViewFile };

  procedure Recount;
    var
      I: LongInt;
    begin
    SelectedLen := 0;
    PackedLen := 0;
    SelNum := 0;
    for I := 1 to Files^.Count do
      AddSelected(Files^.At(I-1));
    DrawView;
    if InfoView <> nil then
      InfoView^.DrawView;
    end;

  procedure CountLen;

    procedure DoCount(P: PFileRec);
      begin
      if (P^.Size < 0) and (not Abort) then
        Drive^.GetDirLength(P);
      end;

    procedure DoSelCount(P: PFileRec);
      begin
      if P^.Selected then
        DoCount(P);
      end;

    var
      P: PFileRec;
      i: Integer;
    begin { CountLen }
    CE;
    if  (PF = nil) then
      Exit;
    if (PF^.TType = ttUpDir) then
      Files^.ForEach(@DoCount) // � ⮬ �᫥ � �⬥祭��
    else
      begin // �⬥祭�� � ⥪�騩 ��⠫��
      if (SelNum <> 0) then
        Files^.ForEach(@DoSelCount);
      if (PF^.Attr and Directory <> 0) and (PF^.Size < 0) then
        Drive^.GetDirLength(PF)
      else if SelNum = 0 then
        Exit; // �⬥祭��� ���, � ��� � ⠪ �����⥭
      end;
    Abort := False;
    Recount;
    if InfoView <> nil then
      InfoView^.DrawView;
    end { CountLen };

  var
    WasFull: Boolean;

  procedure InsertDrive;
    var
      PDir: PString;
    begin
    if ChangeLocked or (Event.InfoPtr = nil) then
      Exit;
    DriveLetter := Drive^.GetDriveLetter;
    if  (PDrive(Event.InfoPtr)^.DriveType = dtTemp) and
        (Drive^.DriveType = dtTemp)
    then
      begin
      CE;
      Exit
      end;
    if PDrive(Event.InfoPtr)^.DriveType in [dtDisk, dtNet, dtLink] then
      begin
      if Drive <> nil then
        Dispose(Drive, Done);
      Drive := nil
      end;
    PDrive(Event.InfoPtr)^.Prev := Drive;
    Drive := Event.InfoPtr;
    Drive.Panel := @Self;
    SetupPanelFromDrive;

    if  (Drive^.DriveType = dtFind) and
        (Drive^.Prev <> nil) and (Drive^.Prev^.DriveType = dtArc)
    then
      begin
      with PArcDrive(Drive^.Prev)^ do
        begin
        if CurDir = '' then
          PDir := NewStr(ArcName+':\')
        else
          PDir := NewStr(ArcName+':'+CurDir)
        end;
      with PFindDrive(Drive)^ do
        begin
        DriveType := dtArcFind;
        UpFile^.Owner := PDir;
        Dirs^.Insert(PDir);
        end;
      end;
    if  (Drive^.DriveType = dtFind) and
        (Drive^.Prev <> nil) and (Drive^.Prev^.DriveType = dtArcFind)
    then
      with PFindDrive(Drive)^ do
        begin
        DriveType := dtArcFind;
        PDir := NewStr(PFindDrive(Drive^.Prev)^.UpFile^.Owner^);
        UpFile^.Owner := PDir;
        Dirs^.Insert(PDir);
        end;
    if  (Drive^.DriveType = dtArc) or (Drive^.DriveType = dtArvid) then
      Drive^.lChDir(#0);
    {if WasFull then Drive^.Flags := Drive^.GetFullFlags else Drive^.Flags := 0;}
    CE;
    DeltaX := 0;
    ReadDirectory;
    AddToDirectoryHistory(DirectoryName, Integer(Drive^.DriveType));
    ScrollBar^.SetValue(0);
    Rebound;
    end { InsertDrive };

  procedure EraseGroup;
    begin
    Drive^.EraseFiles(Event.InfoPtr);
    CE;
    end;

  procedure SelecType(S: Boolean);
    procedure Sel(P: PFileRec);
      begin
      if  (P^.TType = PF^.TType) and (P^.TType <> ttUpDir) then
        P^.Selected := S;
      end;
    procedure SelAll(P: PFileRec);
      begin
      P^.Selected := S;
      end;
    begin
    if  (CurPos >= Files^.Count)
      {or (PanelFlags and fmiHiliteFiles = 0)}
    then
      Exit;
    PF := Files^.At(CurPos);
    if PF^.TType <> ttUpDir then
      Files^.ForEach(@Sel)
    else
      begin
      Files^.ForEach(@SelAll);
      PF^.Selected := False;
      end;
    Recount;
    Owner^.Redraw;
    end { SelecType };

  procedure SelectExt(S: Boolean; G1, G2: LongInt; Invert: Boolean);
    var
      SS: String;
      a: Boolean;

    procedure Sel(P: PFileRec);
      begin
      if A then
        begin
        if  ( (SS = UpStrg(GetExt(P^.FlName[uLfn]))) xor Invert)
          and (P^.TType <> ttUpDir)
        then
          P^.Selected := S;
        end
      else
        begin
        if  ( (SS = UpStrg(GetSName(P^.FlName[uLfn]))) xor Invert)
          and (P^.TType <> ttUpDir)
        then
          P^.Selected := S;
        end
      end;

    begin { SelectExt }
    if  (CurPos >= Files^.Count) then
      Exit;
    PF := Files^.At(CurPos);
    if G1 = 10 then
      a := True
    else
      a := False;
    if a then
      SS := UpStrg(GetExt(PF^.FlName[uLfn]))
    else
      SS := UpStrg(GetSName(PF^.FlName[uLfn]));
    Files^.ForEach(@Sel);
    Recount;
    Owner^.Redraw;
    end { SelectExt };

  procedure HandleCommand;
    var
      FC: PCollection;
      W: Word;
    begin
    W := Event.Command;
    CE;
    FC := nil;
    case W of
      cmExtractTo, cmArcTest:
        begin
        FC := GetSelection(@Self, False);
        if FC = nil then
          Exit;
        end;
    end {case};
    Drive^.HandleCommand(W, FC);
    if FC <> nil then
      begin
      FC^.DeleteAll;
      Dispose(FC, Done);
      end;
    end { HandleCommand };

  var
    ExecLFN: TUseLFN;

  function MakeFName(Idx: LongInt; Mode: Boolean; Sq: Boolean): String;
    var
      LongName: Boolean;
    begin
    PF := Files^.At(Idx);
    ExecLFN := uLfn;
    if  (ShiftState and kbAltShift <> 0) then
      ExecLFN := ExecLFN xor InvLFN;
    FreeStr := PF^.FlName[ExecLFN];
    {Cat: � DN/2 �� ���� ��������� ��� � ���� �����}
    (*
   if PosChar('.', FreeStr) = 0 then AddStr(FreeStr, '.');
*)
    if  (ShiftState and (kbLeftShift+kbRightShift) <> 0) then
      begin
      {$IFDEF DualName}
      LongName := { � �������� LFN, � Alt _��_ �����, ��� ������� }
        (PanSetup^.Show.ColumnsMask and psLFN_InColumns <> 0) = { Flash 23.05.2005 }
        (ShiftState and kbAltShift = 0);
      if LongName then
        FreeStr := MakeNormName(PF^.Owner^, FreeStr)
      else
        FreeStr := MakeNormName(lfGetShortFileName(PF^.Owner^), FreeStr);
      {$ELSE}
      FreeStr := MakeNormName(PF^.Owner^, FreeStr);
    {$ENDIF}
      end;
    if Sq then
      if Mode
      then
        MakeFName := ' '+SquashesName(FreeStr)
      else
        MakeFName := SquashesName(FreeStr)
    else if Mode
    then
      MakeFName := ' '+FreeStr
    else
      MakeFName := FreeStr;
    end { MakeFName };

  procedure DoChange(SS: String);
    begin
    ClrIO;
    if SS = '' then
      Exit;
    if Drive^.DriveType <> dtDisk then
      begin
      if not ReplaceDrive(SS[1]) then
        Exit;
      end;
    SS := MakeNormName(SS, '.');
    OldDelta := -1;
    GotoFile(SS);
    Rebound;
    end { DoChange };
  (*DataCompBoy
 procedure DoExcept(P: PFileRec); {$IFDEF BIT_16}far;{$ENDIF}
 begin
   if (P <> nil) and (P^.Attr and Directory = 0) then
    if not InFilter(GetLFN(P^.LFN), FileMask) then P^.Size := -100;
 end;
*)
  procedure _GetFName;
    var
      S: String;
      dum: PFileRec;
    begin
    GetUserParams(dum, PString(Event.InfoPtr)^, False);
    S := PF^.FlName[uLfn];
    PString(Event.InfoPtr)^:= S+' '+CnvString(Event.InfoPtr);
    end;

  procedure _DoPush(a: Boolean);
    var
      S: String;
      {B,C: Boolean;}
    begin
    if not GetState(sfVisible) then
      Exit;
    if a and (Drive^.DriveType <> dtDisk) then
      PString(Event.InfoPtr)^:= CurrentDirectory
    else
      begin
      S := Drive^.GetRealName;
      if  (S <> '') and (S <> CurrentDirectory) then
        PString(Event.InfoPtr)^:= S;
      end;
    end;

  procedure _DoPushIntern;
    var
      S: String;
    begin
    S := Drive^.GetInternalName;
    if  (S <> '') then
      PString(Event.InfoPtr)^:= S;
    end;

  {-DataCompBoy-}
  procedure _DoRereadDir;
    var
      S, S1: String;
      I: LongInt;
    begin
    S := CnvString(Event.InfoPtr);
    S1 := S;
    if S[1] = '>' then //�ਧ��� �����뢠��� �����⠫���� � ��⢨
      S := Copy(S, 2, MaxStringLength);
    MakeNoSlash(S);
    I := Length(S);
    if  (Drive^.DriveType <> dtDisk) or
        (UpStrg(S) = Copy(UpStrg(
        {$IFDEF DPMI32}lfGetLongFileName{$ENDIF}(DirectoryName)), 1,
         Length(S)))
    then
      begin
      Drive^.RereadDirectory(S1);
      RereadDir;
      end
    else if (Drive^.DriveType = dtDisk)
           and (UpStrg(S[1]) = UpStrg(DirectoryName[1]))
    then
      begin
      if PanSetup^.Show.FreeSpaceInfo <> fseNotShow then
        Drive^.GetFreeSpace(FreeSpace);
      if InfoView <> nil then
        InfoView^.DrawView;
      end;
    end { _DoRereadDir };
  {-DataCompBoy-}

  procedure _PushName;
    var
      S: String;
      ps: PString;
    begin
    S := Drive^.GetRealName;
    if S <> '' then
      HistoryAdd(Event.InfoByte, S);
    end;

{ ����� ��᪠ �१ ���� Alt-F1/F2 }
  procedure _ChangeDrive;
    var
      S: String;
    begin
    if ChangeLocked then
      Exit;
    CE;
    Abort := False;
    OldDelta := -1;
    MPos.X := Origin.X+Size.X div 2;
    PDriveLine(DriveLine)^.Refresh; {AK155}
    if DriveSelectVCenter then
      {-$X-Man}
      MPos.Y := Origin.Y+Size.Y div 2 {-$VIV} {-$X-Man}
    else
      MPos.Y := Origin.Y+1; {-$X-Man}
    Owner^.MakeGlobal(MPos, MPos);
    S := SelectDrive(MPos.X, MPos.Y, DriveLetter, True);
    if S = cTEMP_ then
      begin
      Event.InfoPtr := New(PTempDrive, Init);
      InsertDrive;
      Exit;
      end
    else
      {$IFDEF PLUGIN}
     if S[1] = #26 then
      begin
      Event.InfoPtr := CreateDriveObject(Byte(S[2]), @Self);
      if Event.InfoPtr <> nil then
        InsertDrive;
      Exit;
      end
    else
      {$ENDIF}
      {$IFDEF NetBrowser}
     if S = cNET_ then
      begin
      Event.InfoPtr := New(PNetDrive, Init(@Self));
      if Event.InfoPtr <> nil then
        InsertDrive;
      Exit;
      end
    else
      {$ENDIF}
      {$IFDEF MODEM}
      {$IFDEF LINK}
     if S[1] = '+' then
      begin
      Event.InfoPtr := NewLinkDrive(S[2], @Self);
      InsertDrive;
      Exit;
      end
    else
      {$ENDIF}
      {$ENDIF}
     if S <> '' then
      begin
      ClrIO;
      Abort := False;
      if Drive^.DriveType <> dtDisk then
        begin
        if not ReplaceDrive(S[1]) then
          Exit;
        end
      else
        begin
        Drive^.lChDir(S);
        if Abort then
          begin
          ClrIO;
          RedrawPanelInfoDir;
          Lfn.lChDir(CurrentDirectory);
          Exit;
          end;
        Drive^.SizeX := Size.X;
        S := Drive^.GetDir;
        end;
      IncDrawDisabled;
      DirectoryName := S;
      ReadDirectory;
      AddToDirectoryHistory(DirectoryName, Integer(Drive^.DriveType));
      DecDrawDisabled;
      end;
    DriveLetter := Drive^.GetDriveLetter;
    DriveLine^.DrawView;
    RedrawPanelInfoDir;
    end { _ChangeDrive };

  procedure _ChangeDrv;
    var
      S: String;
    begin
    if ChangeLocked then
      Exit;
    StopQuickSearch;
    S := CnvString(Event.InfoPtr);
    CE;
    if S = cTEMP_ then
      begin
      Event.InfoPtr := New(PTempDrive, Init);
      InsertDrive;
      Exit;
      end
   {$IFDEF NetBrowser}
    else if S = cNET_ then
      begin
      Event.InfoPtr := New(PNetDrive, Init(@Self));
      InsertDrive;
      Exit;
      end
   {$ENDIF}
      {$IFDEF MODEM}
      {$IFDEF LINK}
    else if S[1] = '+' then
      begin
      Event.InfoPtr := NewLinkDrive(S[2], @Self);
      InsertDrive;
      Exit;
      end
      {$ENDIF};
    {$ENDIF};
    lGetDir(Byte(S[1])-64, S);
    {S:=GetNormPath(S);} {removed by AK155}
    MakeNoSlash(S);
    DoChange(S);
    DriveLetter := Drive^.GetDriveLetter;
    DriveLine^.DrawView;
    end { _ChangeDrv };

  procedure _DoDirHistory;
    var
      S: String;
      {Q: string;}
      Dr: PDrive;
      FreeByte: Byte;
    begin
    CE;
    S := DirHistoryMenu;
    if S <> '' then
      begin
      FreeByte := PosChar(':', Copy(S, 3, MaxStringLength))+2;
      if FreeByte > 2 then
        begin
        Dr := nil;
        Dr := New(PArcDrive, Init(S, S));
        {$IFDEF ARVID}
        if Dr = nil then
          Dr := New(PArvidDrive, Init(S));
        {$ENDIF}
        if Dr = nil then
          Exit;
        if Drive^.DriveType <> dtDisk then
          ReplaceDrive(S[1]);
        Message(@Self, evCommand, cmInsertDrive, Dr);
        {end}
        end
      else if S[Length(S)] = '\'
      then
        begin
        if not PathExist(S) then
          begin
          MessageBox(^C+GetString(dlDirectory)+' '+S
            +^M^C+GetString(dlDoes_Not_Exist), nil, mfError+mfOKButton);
          Exit;
          end;
        if Drive^.DriveType <> dtDisk then
          ReplaceDrive(S[1]);
        Self.ChDir(S);
        end
      else
        begin
        if not ExistFile(S) then
          begin
          MessageBox(^C+GetString(dlFile)+' '+S
            +^M^C+GetString(dlDoes_Not_Exist), nil, mfError+mfOKButton);
          Exit;
          end;
        if Drive^.DriveType <> dtDisk then
          ReplaceDrive(S[1]);
        {JO: ࠭�� �� ���室� � ᯨ�� �� ���ਨ ��⠫���� ⥪�騩 }
        {    ��⠫�� �� ������ �, ᮮ⢥��⢥���, ᯨ᮪ �� ��室��   }
        {    䠩���, ��室����� � ��� ��⠫���. ��� ��ࠢ����� �⮣� }
        {    ���������� ��ப�                                        }
        Drive^.lChDir(GetPath(S));

        Message(@Self, evCommand, cmInsertDrive, New(PFindDrive,
               InitList(S)))
        end;
      end;
    end { _DoDirHistory };

  procedure _CloseLinked;
    var
      S: String;
    begin
    if Drive^.DriveType = dtLink then
      begin
      lGetDir(0, S);
      ReplaceDrive(S[1]);
      RereadDir;
      end;
    end;

  procedure _DoCtrl;
    var
      OldDriveLetter: Char;
    begin
    if  ( (ShiftState and 3 <> 0) or (CmdLine.Str = ''))
      and (FMSetup.Show and fmsDriveLine <> 0)
    then
      begin
      OldDriveLetter := DriveLetter;
      repeat
        if Event.What = evKeyDown then
          begin
          case Event.KeyCode of
            kbCtrlLeft, kbCtrlShiftLeft:
              if DriveLine <> nil then
                PDriveLine(DriveLine)^.ShiftLetter(-1);
            kbCtrlRight, kbCtrlShiftRight:
              if DriveLine <> nil then
                PDriveLine(DriveLine)^.ShiftLetter(+1);
          end {case};
          DriveLine^.DrawView;
          end;
        GetEvent(Event);
        if Event.What = evNothing then
          TinySlice;
      until ShiftState and kbCtrlShift = 0;
      if DriveLetter <> OldDriveLetter then
        begin
          if DriveLetter = chTempDrive then DirectoryName := cTEMP_
        {$IFDEF NetBrowser}
          else if DriveLetter = chNetDrive then DirectoryName := cNET_
        {$ENDIF}
          else
            begin
            DirectoryName[1] := DriveLetter;
            DirectoryName[2] := ':';
            end;
          Message(@Self, evCommand, cmChangeDrv, @DirectoryName);
          Drive^.SizeX := Size.X;
          DirectoryName := Drive^.GetDir;
          DriveLine^.DrawView;
          Abort := False;
        end;
      CE;
      end;
    end { _DoCtrl };

  procedure _CtrlIns;
    var
      S: LongString;
      I: LongInt;
      b: Boolean;
    begin
    S := '';
    CE;
    b := False;
    if  (Files = nil) or (Files^.Count <= 0) then
      Exit;
    if SelNum = 0
    then
      S := MakeFName(CurPos, False, False)
    else
      for I := 0 to Files^.Count-1 do
        if PFileRec(Files^.At(I))^.Selected then
          begin
          S := S+MakeFName(I, b, True);
          b := True;
          end;
    {$IFDEF RecodeWhenDraw}
    S := CharToOemStr(S);
    {$ENDIF}
    PutInClipLong(S);
    end { _CtrlIns };

  {function _AltEnter: boolean; forward;} {Cat}
  procedure _CtrlEnter;
    var
      ExecLFN: TUseLFN;
      S: String;
      PF: PFileRec;
    begin
    CE;
    if Files^.Count = 0 then
      Exit;
    PF := Files^.At(CurPos);
    if  (PF <> nil) then
      begin
      ExecLFN := uLfn;
      if  (ShiftState and kbAltShift <> 0) then
        ExecLFN := ExecLFN xor InvLFN;
      S := PF^.FlName[ExecLFN];
      {Cat: � DN/2 �� ���� ��������� ��� � ���� �����}
      (*
    if (PF^.Attr and Directory = 0) and
       (PosChar('.', S) = 0) then AddStr(S, '.');
*)
      if Copy(S, 1, 2) = '..' then
        {$IFDEF DualName}
        if PanSetup^.Show.ColumnsMask and psLFN_InColumns <> 0 then
          if  (ShiftState and kbAltShift <> 0)
          then
            S := lfGetShortFileName(PF^.Owner^)+'\'
          else
            S := PF^.Owner^+'\'
        else if (ShiftState and kbAltShift <> 0)
          then
          S := PF^.Owner^+'\'
        else
          S := lfGetShortFileName(PF^.Owner^)+'\'
        {$ELSE}
        S := PF^.Owner^+'\'
          {$ENDIF}
      else if ShiftState and 3 <> 0 then
        {$IFDEF DualName}
        if PanSetup^.Show.ColumnsMask and psLFN_InColumns <> 0 then
          if  (ShiftState and kbAltShift <> 0)
          then
            S := MakeNormName(lfGetShortFileName(PF^.Owner^), S)
          else
            S := MakeNormName(PF^.Owner^, S)
        else if (ShiftState and kbAltShift <> 0)
          then
          S := MakeNormName(PF^.Owner^, S)
        else
          S := MakeNormName(lfGetShortFileName(PF^.Owner^), S)
        {$ELSE}
        S := MakeNormName(PF^.Owner^, S)
          {$ENDIF}
          ;
      S := SquashesName(S);
      {$IFDEF RecodeWhenDraw}
      S := CharToOemStr(S);
      {$ENDIF}
      Message(CommandLine, evCommand, cmInsertName, @S);
      end;
    end { _CtrlEnter };

  function _AltEnter: Boolean;
    var
      ExecLFN: Integer;
      S: String;
    begin

    if (OS2exec or Win32exec) and (Drive^.DriveType = dtDisk)
      and (PF^.TType = ttExec)
      and (ShiftState and (kbCtrlShift or 3) <> 0)
    then
      begin
      PShootState := ShiftState;
      S := PF^.FlName[uLfn];
      if ShiftState and kbCtrlShift = 0 then
        S := '>'+S
      else
        S := '<'+S;
      Message(Application, evCommand, cmExecString, @S);
      CE;
      _AltEnter := True;
      end
    else

      begin
      PShootState := ShiftState;
      CE;
      _AltEnter := False;
      end;
    end { _AltEnter: };

  procedure _GotoExt;
    var
      S: String;
    begin
    if  (Drive^.DriveType <> dtArvid) and (Drive^.DriveType <> dtArc)
    then
      begin
      if Drive^.DriveType = dtDisk then
        S := PF^.FlName[uLfn]
      else
        begin
        CE;
        Exit;
        end;
      {$IFDEF DPMI32}
      if OS2exec and (UpStrg(GetExt(PF^.FlName[uLfn])) = '.CMD') then
        begin
        S := 'call "'+S+'"';
        if ShiftState and 3 <> 0 then
          S := '<'+S
        else
          S := '>'+S;
        Message(Application, evCommand, cmExecString, @S);
        Exit;
        end;
      {$ENDIF}
      Message(Application, evCommand, cmExecFile, @S);
      end
    else
      ViewFile(cmViewFile)
      {else Message(Application, evCommand, cmExecCommandLine, nil);}
    end { _GotoExt };

  procedure _CtrlPgUp;
    begin
    CE;
    if not ChangeUp then
      if Drive^.DriveType in [dtDisk, dtNet, dtLink] then
        GotoFile(DirectoryName)
    end;

  procedure _Enter;
    var
      S: String;
    begin
    if PF^.FlName[True] = '..' then
      begin
      _CtrlPgUp;
      Exit;
      end;
    if not (Drive^.DriveType in [dtFind, dtTemp, dtList, dtArcFind])
    then
      Exit;
    if Drive^.DriveType <= dtArcFind then
      begin
      if Drive^.DriveType = dtArcFind
      then
//JO: ��� �஬������ �������樨 ����� - �뤥���� ���� � ��娢� ��
//    Owner'� UpFile (�.�. ��祪 '..') ������ ���������� � ��娢� �
//    ��ᮥ������ � ���� ���� � 䠩�� ����� ������� ��娢�
        S := MakeNormName(
          Copy(PFindDrive(Drive)^.UpFile^.Owner^, 1, Pos(':',
           Copy(PFindDrive(Drive)^.UpFile^.Owner^, 3, MaxStringLength))+2)
          +':'+ PF^.Owner^, PF^.FlName[True])
      else
        S := MakeNormName(PF^.Owner^, PF^.FlName[uLfn]);
      (*
{JO: ���室�� � ���������� 䠩�� � ��娢�}
      if PathFoundInArc(PF^.Owner^) and
          ArcViewer(S, S, FreeByte) then
            begin
            {$IFNDEF OS2}
              GotoSingle(GetLFN(PF^.LFN));
            {$ELSE}
              GotoSingle(PF^.Name);
            {$ENDIF}
              Exit;
            end;
{/JO}
*)
      if ShiftState and 3 <> 0 then
        begin
        Message(Owner, evCommand, cmChangeInactive, @S);
        Exit;
        end;
      Dispose(Drive, Done);
      New(Drive, Init(Byte(S[1])-64, @Self));
      SetupPanelFromDrive;
      DeltaX := 0;
      GotoFile(S);
      end;
    end { _Enter };

  procedure _CtrlPgDn;
    var
      S: String;
    begin
    CE;
    if ChangeLocked then
      Exit;
    if  (Files^.Count = 0) then
      Exit;
    PF := Files^.At(CurPos);
    if PF^.TType = ttUpDir then
      begin
      _CtrlPgUp;
      Exit;
      end;
    if Drive^.DriveType = dtArcFind then
      begin
      _Enter;
      Exit;
      end;
    S := MakeNormName(PF^.Owner^, PF^.FlName[uLfn]);
    if  (PF^.Attr and Directory = 0) then
      begin
      if not ArcViewer(S, S) then
        {AK155: �� CtrlPgDn �室�� � ��娢}
        _Enter
      else if PathFoundInArc(S) then
        {JO: ���室�� � ���������� 䠩�� � ��娢�    }
        GotoSingle(PF^.FlName[True]);
      end
    else
      begin { �室�� � ��⠫�� }
      S := MakeNormName(S, '.');
      GotoFile(S);
      end;
    end { _CtrlPgDn };

  procedure FindNextSelFile(pNext: Boolean); {-$VIV,VOL 19.05.99---}
    var
      I: LongInt;

    function CheckIt(I: LongInt): Boolean;
      begin
      CheckIt := False;
      if PFileRec(Files^.At(I))^.Selected then
        begin
        ScrollBar^.SetValue(I);
        CED;
        CheckIt := True;
        end;
      end;

    begin
    if Files = nil then
      Exit;
    if pNext then
      begin
      for I := CurPos+1 to Files^.Count-1 do
        if CheckIt(I) then
          Break;
      end
    else
      begin
      for I := CurPos-1 downto 0 do
        if CheckIt(I) then
          Break;
      end;
    end { FindNextSelFile };

  procedure _CheckKB;
    var
      I: LongInt;
      aaa: Word;
      bbb, ccc: Byte;
      l: LongInt;
      FC: PFilesCollection;
      s: String;
      s2: LongString;
      {$IFNDEF OS2}
      CondLfn: TUseLFN; {JO}
      {$ENDIF}
      PanelHeight: Integer; // ���� ������ ��� ��ப� ���������� �������
    begin
    PanelHeight := Size.Y-Byte((Pansetup^.Show.MiscOptions and 2) <> 0);
    case Event.KeyCode of
      kbCtrlAltShift1, kbCtrlAltShift2, kbCtrlAltShift3,
      kbCtrlAltShift4, kbCtrlAltShift5, kbCtrlAltShift6,
      kbCtrlAltShift7, kbCtrlAltShift8, kbCtrlAltShift9:
        begin
        I := (Event.KeyCode shr 8)-(kbCtrlAltShift1 shr 8);
        CE;
        if Drive^.DriveType <> dtDisk then
          Exit;
        if Msg(dlPromptForQDir, nil, mfQuery+mfYesButton+mfNoButton)
           <> cmYes
        then
          Exit;
        DisposeStr(DirsToChange[I]);
        DirsToChange[I] := NewStr(DirectoryName);
        Message(Application, evCommand, cmUpdateConfig, nil);
        case I of
          0:
            begin
            QDirs1 := CnvString(DirsToChange[0]);
            SaveDnIniSettings(@QDirs1);
            end;
          1:
            begin
            QDirs2 := CnvString(DirsToChange[1]);
            SaveDnIniSettings(@QDirs2);
            end;
          2:
            begin
            QDirs3 := CnvString(DirsToChange[2]);
            SaveDnIniSettings(@QDirs3);
            end;
          3:
            begin
            QDirs4 := CnvString(DirsToChange[3]);
            SaveDnIniSettings(@QDirs4);
            end;
          4:
            begin
            QDirs5 := CnvString(DirsToChange[4]);
            SaveDnIniSettings(@QDirs5);
            end;
          5:
            begin
            QDirs6 := CnvString(DirsToChange[5]);
            SaveDnIniSettings(@QDirs6);
            end;
          6:
            begin
            QDirs7 := CnvString(DirsToChange[6]);
            SaveDnIniSettings(@QDirs7);
            end;
          7:
            begin
            QDirs8 := CnvString(DirsToChange[7]);
            SaveDnIniSettings(@QDirs8);
            end;
          8:
            begin
            QDirs9 := CnvString(DirsToChange[8]);
            SaveDnIniSettings(@QDirs9);
            end;
        end {case};
        DoneIniEngine;
        end;
      kbAlt1, kbAlt2, kbAlt3, kbAlt4, kbAlt5, kbAlt6, kbAlt7, kbAlt8,
       kbAlt9:
        begin
        I := (Event.KeyCode shr 8)-(kbAlt1 shr 8);
        CE;
        if DirsToChange[I] <> nil then
          DoChange(CnvString(DirsToChange[I]));
        end;
      kbCtrl1..kbCtrl0:
        begin
        GetParam((Event.KeyCode shr 8)-(kbCtrl1 shr 8)+1
                  + ($10000*Byte(FullMenuPanelSetup)));
        Owner^.Redraw;
        end;
      kbCtrlMinus:
        begin
        GetParam(12);
        Owner^.Redraw;
        end;
      kbCtrlEqual:
        begin
        GetParam(11);
        Owner^.Redraw;
        end;
      kbAltIns: {if ShiftState and kbCtrlShift <>0 then _CtrlIns else}
        begin
        if  (PanSetup^.Show.ColumnsMask and psShowDescript = 0) and
            (FMSetup.Options and fmoAlwaysCopyDesc = 0)
            and (PF^.DIZ = nil)
        then
          begin
          if  (Drive^.DriveType = dtDisk) then
            begin
            GetDiz(PF);
            Drive^.EditDescription(PF);
            end;
          end
        else
          Drive^.EditDescription(PF);
        CE;
        end;
      kbBack, kbShiftBack:
        if  (FMSetup.Options and fmoBackGoesBack <> 0) and
            ( (ShiftState and 3 <> 0) or ((CmdLine.Str = '') and
                (not CmdLine.StrCleared) and (not QuickSearch)))
        then
          begin
          _CtrlPgUp;
          Exit;
          end;
      kbUp, kbDown, kbUpUp, kbDownUp:
        begin
        CtrlWas := ShiftState and kbCtrlShift <> 0;
           {AK155 IMHO �� ���� �����⨦���, ⠪ ��� ᮡ�⨥ �ꥤ���
           TFilePanel }
        end;
      kbCtrlR:
        begin
        Message(@Self, evCommand, cmForceRescan, nil);
        CE
        end;
      kbGrayAst, kbCtrlGAst:
        begin
        StopQuickSearch;
        InvertSelection(@Self, Event.KeyCode = kbCtrlGAst);
        CE
        end; { Flash }
      kbAltGPlus, kbAltGMinus, kbAltShiftGPlus, kbAltShiftGMinus,
       kbCtrlAltGPlus, kbCtrlAltGMinus:
        begin
        SelectExt(Event.KeyCode = kbAltGPlus, 1, 8, ShiftState and 3 <> 0)
        ;
        CE
        end;
      kbCtrlGPlus, kbCtrlGMinus:
        begin
        SelecType((Event.KeyCode = kbCtrlGPlus));
        CE;
        end;
      kbCtrlShiftGPlus, kbCtrlShiftGMinus:
        begin
        SelectExt((Event.KeyCode = kbCtrlShiftGPlus), 10, 3, False);
        CE;
        end;
      kbCtrlBSlash:
        begin
        if  (Drive^.DriveType = dtDisk) then
          begin
          {JO: ��࠭塞 � S ��� ��⠫��� ���孥�� �஢�� ��� ⥪�饣�}
          s := Drive^.CurDir+'\';
          l := GetRootStart(s)+1;
          s := Copy(s, l, PosChar('\', Copy(s, l, MaxStringLength))-1);
          end;
        Drive^.ChangeRoot;
        ReadDirectory;
        AddToDirectoryHistory(DirectoryName, Integer(Drive^.DriveType));
        ScrollBar^.SetValue(0);
        DecDrawDisabled;
        if Drive^.DriveType in [dtArc, dtArvid, dtList] then
          {-$VOL}
          begin
          _CtrlPgUp;
          Exit;
          end; {-$VOL}
        if s <> '' then
          GotoSingle(s);
        Owner^.Redraw;
        CE
        end;
      kbCtrlRight, kbCtrlLeft,
      kbCtrlShiftRight, kbCtrlShiftLeft:
        _DoCtrl;
      kbCtrlDel:
        if Files^.Count > 0 then
          begin
          I := 0;
          if SelNum = 0 then
            begin
            if PFileRec(Files^.At(CurPos))^.TType <> ttUpDir then
              Files^.AtFree(CurPos);
            end
          else
            while I < Files^.Count do
              if PFileRec(Files^.At(I))^.Selected then
                begin
                Files^.AtFree(I);
                if I < CurPos then
                  Dec(CurPos);
                end
              else
                Inc(I);
          ScrollBar^.SetParams(CurPos, 0, Files^.Count-1,
              PanelHeight*((Size.X+1) div LineLength), 1);
          Recount;
          CE;
          end;
      { Flash 23.05.2005: ��������� ���⨥ ���⪮�� ����� � ���� }
      kbCtrlIns, kbCtrlShiftIns, kbCtrlAltIns, kbCtrlAltShiftIns:
        {if ShiftState and kbCtrlShift<>0 then}_CtrlIns;
      kbCtrlEnter, kbCtrlShiftEnter, kbCtrlAltEnter:
        _CtrlEnter;
      kbLeft:
        if  (Size.X+2 > LineLength) then
          if  (Delta > 0) or
              (ScrollBar^.Value > PanelHeight)
          then
            begin
            if ScrollBar^.Value-Delta < PanelHeight
            then
              Dec(Delta, PanelHeight);
            ScrollBar^.SetValue
                (ScrollBar^.Value-PanelHeight);
            CE;
            end
          else
            begin
            if ScrollBar^.Value > 0 then
              ScrollBar^.SetValue(0);
            CE;
            end
        else if DeltaX > 0 then
          begin
          Dec(DeltaX);
          DrawView;
          if InfoView <> nil then
            InfoView^.DrawView;
          CE;
          end;
      kbRight:
        if Size.X+2 > LineLength then
          begin
          aaa := Delta;
          Owner^.Lock;
          ScrollBar^.SetValue(ScrollBar^.Value+PanelHeight);
          if aaa <> Delta then
            Delta := aaa+PanelHeight;
          CED;
          Owner^.UnLock;
          end
        else if DeltaX < LineLength-Size.X-1 then
          begin
          Inc(DeltaX);
          DrawView;
          if InfoView <> nil then
            InfoView^.DrawView;
          CE;
          end;
      kbHome:
        begin
        CE;
        DeltaX := 0;
        OldDelta := -1;
        ScrollBar^.SetValue(0);
        Owner^.Redraw
        end;
      kbEnd:
        begin
        CE;
        OldDelta := -1;
        ScrollBar^.SetValue(Files^.Count-1)
        end;
      kbAltEnter, kbAltGrayEnter, kbAltShiftEnter {$IFDEF Win32},
       kbAltHome {$ENDIF}:
        if _AltEnter then
          Exit
        else
          begin
          _GotoExt;
          Exit;
          end;
      kbEnter, kbShiftEnter:
        if CurPos < Files^.Count then
          begin
          PShootState := ShiftState;
          PF := Files^.At(CurPos);
          if ChangeLocked or (Message(Application, evCommand,
                 cmExecCommandLine, nil) <> nil)
          then
            begin
            CE;
            Exit;
            end;
          CE;
          FreeStr := 'AUTOEXEC.BAT';
          if  (Drive^.DriveType = dtDisk) and
              (PF^.Attr and Directory = 0) and {-$VOL}
              (UpStrg(PF^.FlName[True]) = FreeStr) and
              (Msg(dlAutoexecWarning, nil, mfYesNoConfirm) <> cmYes)
          then
            Exit;
          if  (Drive^.DriveType in [dtFind, dtTemp, dtArcFind]) or
              ( (Drive^.DriveType = dtList) and (PF^.TType <> ttUpDir))
          then
            begin
            _Enter;
            Exit;
            end;
          if  (FMSetup.Options and fmoEnterArchives <> 0)
            and (((Event.KeyCode = kbEnter) and (ShiftState and 3 = 0))
              )
            and (PF^.Attr and Directory = 0) and
              (not (Drive^.DriveType in [dtArc, dtFind, dtArvid,
                 dtArcFind]))
            and (ArcViewer(MakeNormName(PF^.Owner^, PF^.FlName[uLfn]),
                MakeNormName(PF^.Owner^, PF^.FlName[uLfn])))
          then
            begin
            CE;
            Exit;
            end;
          if  (PF <> nil) then
            if  (PF^.Attr and Directory <> 0) then
              begin
              if PF^.TType = ttUpDir
              then
                begin
                if not ChangeUp then
                  GotoFile(PF^.Owner^);
                end
              else
                begin
                GotoFile(MakeNormName(MakeNormName(PF^.Owner^,
                       PF^.FlName[True]), '.'));
                end;
              Exit;
              end
            else
              _GotoExt;
          end;
      kbCtrlPgUp:
        _CtrlPgUp;
      kbCtrlPgDn:
        _CtrlPgDn;
      kbDel:
        if  ( (CmdLine.Str = '') and (FMSetup.Options and fmoDelErase <>
               0))
        then
          Message(@Self, evCommand, cmPanelErase, nil);
      kbShiftDel:
        if  ( (CmdLine.Str = '') and (FMSetup.Options and fmoDelErase <>
               0))
        then
          Message(@Self, evCommand, cmSingleDel, nil);
      kbIns, kbSpace:
        if CurPos < Files^.Count then
          begin
          StopQuickSearch;
          if  (Event.CharCode = ' ') and ((CmdLine.Str <> '') or
                (FMSetup.Options and fmoSpaceToggle = 0))
          then
            Exit;
          CE;
          if Files^.Count = 0 then
            Exit;
          PF := Files^.At(CurPos);
          if PF^.TType <> ttUpDir then
            begin
            PF^.Selected := not PF^.Selected;
            if PF^.Size > 0 then
              SelectedLen := SelectedLen-(1-2*Integer(PF^.Selected))
                *PF^.Size;
            PackedLen := PackedLen-(1-2*Integer(PF^.Selected))*PF^.PSize;
            Dec(SelNum, 1-2*Integer(PF^.Selected));
            end;
          ScrollBar^.SetValue(CurPos+1);
          if CurPos = ScrollBar^.Value then
            DrawView;
          if InfoView <> nil then
            InfoView^.DrawView;
          end;
      kbGrayPlus {, kbShiftGPlus}:
        begin
        SelectFiles(@Self, True, ShiftState and 3 <> 0);
        CE
        end;
      kbGrayMinus {, kbShiftGMinus}:
        begin
        SelectFiles(@Self, False, ShiftState and 3 <> 0);
        CE
        end;
      kbAltUp, kbAltDown:
        FindNextSelFile(Event.KeyCode = kbAltDown); {-$VIV}
      else {case}
        if ShowKeyCode and 1 > 0 then
          begin
          l := Event.KeyCode;
          MessageBox('%x', @l, 0);
          end;
    end {case};
    end { _CheckKB };

  procedure _TagUntag;
    var
      I: LongInt;
    begin
    if  (PF <> nil) and (PF^.Selected xor (Event.Command = cmSingleTag))
    then
      I := kbIns
    else
      I := kbDown;
    Message(Owner, evKeyDown, I, nil);
    CE;
    end;

  procedure _ForceRescan;
    var
      PDr: PDrive;
    begin
    if Drive^.DriveType = dtArc then
      begin
      if PArcDrive(Drive)^.ReadArchive then
        RereadDir
      else
        begin
        PDr := Drive;
        Drive := Drive^.Prev;
        PDr^.Prev := nil;
        Dispose(PDr, Done);
        DeltaX := 0;
        Drive^.SizeX := Size.X;
        DirectoryName := Drive^.GetDir;
        ReadDirectory;
        AddToDirectoryHistory(DirectoryName, Integer(Drive^.DriveType));
        Rebound;
        end;
      end
    else
      begin
      if Drive^.DriveType in [dtTemp, dtFind, dtList, dtArcFind] then
        Drive^.RereadDirectory('');
      RereadDir;
      end;
    CE;
    end { _ForceRescan };

  procedure _FindForced;
    var
      PDr: PDrive;
    begin
    ForceReading := False;
    DeltaX := 0;
    PDr := Drive;
    Drive := Event.InfoPtr;
    Drive^.Prev := PDr^.Prev;
    PDr^.Prev := nil;
    Dispose(PDr, Done);
    RereadDir;
    CE;
    end;

  {$IFDEF UUDECODE}
  procedure CallUuDecode;
    var
      FC: PCollection;
    begin
    FC := GetSelection(@Self, False);
    if FC = nil then
      Exit;
    if FC^.Count <> 0 then
      begin
      UUDecode(FC);
      FC^.DeleteAll;
      end;
    Dispose(FC, Done);
    end;
  {$ENDIF}

  {JO}
  {$IFDEF USEWPS}
  {$IFDEF OS2}
  procedure _OpenWPSWindow(DirName: String);
    var
      Handle: LongInt;
      PS: PChar;
      PSArr: array[0..255] of Char;
    begin
    PS := PSArr;
    PS := StrPCopy(PS, DirName);
    Handle := DN_WinQueryObject(PS);
    DN_WinOpenObject(Handle, {OPEN_DEFAULT}0, True)
    end;

  procedure _CreateWPSObject(FileName: String; Prog: Boolean);
    var
      PS, PS1, ObjID: PChar;
      PSArr, PSArr1: array[0..255] of Char;
      Title: String;
      Dir, Name, Ext: String;
    begin
    lFSplit(FileName, Dir, Name, Ext);
    if Prog then
      begin
      Title := CapStrg(Name);
      if BigInputBox(GetString(dlCreateObject)+Name+Ext,
             GetString(dlObjectTitle), Title, 255, hsCreateWPSObject)
         <> cmOK
      then
        Exit;
      ObjID := 'WPProgram';
      FileName := 'EXENAME='+FileName;
      end
    else
      begin
      Title := Name+Ext;
      if MessageBox(GetString(dlCreateObject)+Title+' ?', nil,
           mfOKButton+mfCancelButton+mfConfirmation) <> cmOK
      then
        Exit;
      ObjID := 'WPShadow';
      FileName := 'SHADOWID='+FileName;
      end;
    PS := PSArr;
    PS := StrPCopy(PS, FileName);
    PS1 := PSArr1;
    PS1 := StrPCopy(PS1, Title);
    DN_WinCreateObject(ObjID, PS1, PS, '<WP_DESKTOP>');
    end { _CreateWPSObject };
  {$ENDIF}
  {/JO}
  {Cat}
  {$IFDEF WIN32}
  procedure _OpenExplorerWindow(PathName: String);
    var
      PrgBuf: array[0..511] of Char;
      ArgBuf: array[0..511] of Char;
      Arg: PChar;
    begin
    StrPCopy(@PrgBuf, GetEnv('windir')+'\explorer.exe');
    if Copy(PathName, Length(PathName)-2, 3) = '\..' then
      StrPCopy(@ArgBuf, '"'+Copy(PathName, 1, Length(PathName)-3)+'"')
    else
      begin
      Arg := @ArgBuf;
      if PathName[Length(PathName)] <> '\' then
        Arg := StrECopy(@ArgBuf, '/select,');
      StrPCopy(Arg, '"'+PathName+'"');
      end;
    SysExecute(@PrgBuf, @ArgBuf, nil, True, nil, -1, -1, -1);
    end;
  {$ENDIF}
  {$ENDIF}
  {/Cat}

  {JO}
  procedure _UpdateHighlight;
    var
      I: LongInt;
    begin
    if Files^.Count > 0 then
      for I := 0 to Files^.Count-1 do
        with PFileRec(Files^.At(I))^ do
          TType := GetFileType(FlName[True], Attr);
    end;
  {/JO}

  var
    FC: PFilesCollection;
    PSDEL: Byte;
    ColumnTitles: Boolean;
  begin { TFilePanelRoot.CommandHandle }
  ColumnTitles := (Pansetup^.Show.MiscOptions and 2) <> 0;
  if Drive <> nil
  then
//!    WasFull := Drive^.GetFullFlags = Drive^.Flags
  else
    WasFull := False;
  if ScrollBar <> nil
  then
    CurPos := ScrollBar^.Value
  else
    CurPos := 0;
  if Files <> nil
  then
    if Files^.Count > CurPos
    then
      PF := Files^.At(CurPos)
    else
      PF := nil
  else
    PF := nil;
  case Event.What of
    evCommand:
      case Event.Command of
        cmToggleDescriptions:
          begin
          CM_ToggleDescriptions(@Self);
          CE
          end;
        cmToggleLongNames:
          begin
          CM_ToggleLongNames(@Self);
          CE
          end;
        cmToggleShowMode:
          begin
          CM_ToggleShowMode(@Self);
          CE
          end;
        cmFastRename:
          begin
          if QuickRenameInDialog xor
              (ShiftState and (kbLeftShift+kbRightShift) <> 0)
          then
            CM_RenameSingleDialog(@Self, @Event)
          else
            CM_RenameSingleL(@Self, @Event)
            ;
          CE
          end;
        cmSingleTag, cmSingleUntag:
          _TagUntag;
        cmQuickChange1..cmQuickChange9:
          begin
          DoChange(CnvString(DirsToChange[Event.Command-cmQuickChange1]));
          CE;
          end;
        cmPanelMakeList:
          begin
          Message(@Self, evCommand, cmInsertDrive,
            New(PFindDrive, InitList(MakeNormName(PF^.Owner^,
                   PF^.FlName[uLfn]))));
          CE;
          end;
        cmPanelArcFiles:
          begin
          CM_ArchiveFiles(@Self);
          CE
          end;
        cmExtractArchive:
          begin
          if  (Drive^.DriveType <> dtArc) and
              (Drive^.DriveType <> dtArvid) and
              (Drive^.DriveType <> dtArcFind) and
              (PF <> nil) and
              (PF^.Attr and Directory = 0)
          then
            UnarchiveFiles(MakeNormName(PF^.Owner^, PF^.FlName[True]));
          CE
          end;
        cmReboundPanel:
          Rebound;
        {$IFDEF Printer}
        cmPrintFile:
          begin
          CM_Print(@Self);
          CE
          end;
        {$ENDIF}
        cmSetPassword, cmExtractTo,
        cmArcTest, cmRereadForced,
        cmMakeForced
        :
          HandleCommand;
        cmEraseGroup:
          EraseGroup;
        cmFindTree:
          (* {fmiDirLen �ࠧ������, ⠪ �� ��祣� �� �������.
              � � ᠬ�� cmFindTree ⮦� ���� �� ࠧ������� }
          if  (Drive^.DriveType = dtDisk) and
              (PanelFlags and fmiDirLen <> 0) and
              (Char(Event.InfoPtr^) = DirectoryName[1])
          then
            Char(Event.InfoPtr^) := #0*);
        cmInsertFile:
          if Files <> nil then
            begin
            Files^.AtInsert(Files^.Count, Event.InfoPtr);
            ScrollBar^.SetParams(ScrollBar^.Value, 0, Files^.Count-1,
                (Size.Y-Byte(ColumnTitles))*
                ( (Size.X+1) div LineLength), 1);
            DrawView;
            CE;
            end;
        cmViewText, cmViewHex, cmViewDBF, cmViewWKZ:
          begin
          if Files <> nil then
            if Files^.Count >= CurPos then
              Drive^.UseFile(Files^.At(CurPos), 22000+Event.Command);
          CE;
          end;
        cmInsertDrive:
          if Event.InfoPtr <> nil then
            InsertDrive
          else
            CE;

        cmEditFile, cmIntViewFile, cmIntEditFile, cmViewFile,
         cmFileTextView:
          begin
          if isSeldir then
            case Event.Command of
              cmViewFile, cmIntViewFile:
                if Drive^.DriveType <> dtArc then
                  CountLen
                else
                  CE;
              cmEditFile, cmIntEditFile:
                begin
                CM_SetAttributes(@Self, True, CurPos);
                CE
                end;
            end { case }
          else
            begin
            ViewFile(Event.Command);
            CE;
            end;
          end;
        cmCountLen:
          if Drive^.DriveType <> dtArc then
            CountLen
          else
            CE;
        cmSingleDel:
          CM_EraseFiles(@Self, True);
        cmGetFileName:
          begin
          _GetFName;
          CE
          end;
        cmTempCopyFiles:
          begin
          CM_CopyTemp(@Self);
          CE
          end;
        cmSelectPreset:
          begin {JO}
          CM_SelectColumn(@Self);
          CE
          end; {/JO}
        cmSortBy:
          begin
          CM_SortBy(@Self);
          CE
          end;
        cmPanelSortSetup:
          begin
          CM_PanelSortSetup;
          CE
          end;
        cmPanelShowSetup:
          begin
          CM_SetShowParms(@Self);
          CE
          end;
        cmTouchFile:
          begin
          if  (PF <> nil) then
            if  (PF^.Attr and Directory <> 0) then
              Message(@Self, evKeyDown, kbCtrlPgDn, nil)
            else if PF^.TType = ttExec then
              Message(@Self, evKeyDown, kbEnter, nil)
            else
              ViewFile(cmViewFile);
          CE;
          end;
        cmCompareDir:
          begin
          Message(Owner, evCommand, cmPanelCompare, Files);
          Recount;
          CE;
          end;
        cmPushName:
          if UpStrg(CurrentDirectory) <> UpStrg(Drive^.GetRealName) then
            _PushName;
        cmPushFirstName:
          _DoPush(False);
        cmPushFullName:
          _DoPush(True);
        cmPushInternalName:
          _DoPushIntern;
        cmPanelCompare:
          begin
          CM_CompareDirs(@Self, Event.InfoPtr);
          Recount;
          CE
          end;
        cmPanelSelect:
          begin
          SelectFiles(@Self, True, False);
          CE
          end;
        cmPanelUnselect:
          begin
          SelectFiles(@Self, False, False);
          CE
          end;
        cmPanelXSelect:
          begin
          SelectFiles(@Self, True, True);
          CE
          end;
        cmPanelXUnselect:
          begin
          SelectFiles(@Self, False, True);
          CE
          end;
        cmCopyFiles, cmMoveFiles, cmSingleCopy, cmSingleRename:
          begin
          CM_CopyFiles(@Self,
              (Event.Command = cmMoveFiles) or
              (Event.Command = cmSingleRename),
              (Event.Command = cmSingleCopy) or
              (Event.Command = cmSingleRename));
          CE
          end;
        cmPanelInvertSel:
          begin
          InvertSelection(@Self, False);
          CE
          end;
        cmPanelErase:
          begin
          CM_EraseFiles(@Self, False);
          CE
          end;
        cmPanelMkDir:
          begin
          CM_MakeDir(@Self);
          CE
          end;
        cmRereadDir:
          if GetState(sfVisible) then
            _DoRereadDir;
        cmTotalReread:
          if GetState(sfVisible) or (Drive^.DriveType <> dtDisk) then
            begin
            if Event.InfoPtr <> nil then
              Drive^.RereadDirectory(PString(Event.InfoPtr)^)
            else
              Drive^.RereadDirectory('');
            RereadDir;
            end;
        cmForceRescan:
          _ForceRescan;
        cmPanelReread:
          begin
          RereadDir;
          CE
          end;
        cmUpdateHighlight:
          begin
          if Drive^.DriveType in [dtTemp, dtFind,
                                  dtList, dtArcFind] then
            _UpdateHighlight;
          RereadDir;
          end;
        cmMakeList:
          begin
          CM_MakeList(@Self);
          CE
          end;
        cmChangeDrive:
          _ChangeDrive;
        cmChangeDrv:
          _ChangeDrv;

        cmDirBranch:
          begin
          Message(@self, evCommand, cmInsertDrive,
            Drive^.OpenDirectory(DirectoryName, False));
          CE
          end;
        cmDirBranchFull:
          begin
          Message(@self, evCommand, cmInsertDrive,
            Drive^.OpenDirectory(DirectoryName, True));
          CE
          end;
        {$IFDEF UUDECODE}
        cmUUDecodeFile:
          begin
          if Drive^.DriveType < dtArcFind then
            CallUuDecode;
          CE;
          end;
        {$ENDIF}
        {$IFDEF UUENCODE}
        cmUUEncodeFile:
          begin
          if  (PF <> nil) and (PF^.Attr and Directory = 0)
            and (Drive^.DriveType < dtArcFind)
          then
            UUEncode(MakeNormName(PF^.Owner^, PF^.FlName[uLfn]));
          CE;
          end;
        {$ENDIF}
        cmChangeNameCase:
          if  (PF <> nil) and (Drive^.DriveType < dtArcFind)
          then
            CM_ChangeCase(@Self);
        cmUnpDiskImg:
          begin
          if  (Drive^.DriveType < dtArcFind) then
            UnpackDiskImages(@Self,
              GetSelection(@Self, False));
          CE;
          end;
        cmChangeDirectory:
          begin
          Self.ChDir(PString(Event.InfoPtr)^);
          CE;
          end;
        cmStandAt:
          begin
          GotoFile(PString(Event.InfoPtr)^);
          CE;
          end;
        cmChangeDir:
          begin
          FreeStr := CM_ChangeDirectory(@Self);
          if FreeStr <> '' then
            begin
            if Drive^.DriveType = dtArc then
              ReplaceDrive(FreeStr[1]);
            GotoFile(MakeNormName(FreeStr, '.'));
            end;
          CE
          end;
        cmDirHistory:
          _DoDirHistory;
        cmCloseLinked:
          _CloseLinked;
        cmSetFAttr, cmSingleAttr:
          begin
          CM_SetAttributes(@Self, Event.Command = cmSingleAttr, CurPos);
          CE
          end;
        {$IFDEF OS2}
        cmSetEALongname:
          begin
          CM_SetEALongname(@Self, CurPos);
          CE
          end;
        {$ENDIF}
        cmPanelLongCopy:
          begin
          CM_LongCopy(@Self);
          CE
          end;
        cmLViewFile:
          begin
          SendLocated;
          CE
          end;
        cmFindFile:
          begin
{$IFDEF DualName}
          ShortNameSearch :=
            (PanSetup^.Show.ColumnsMask and psLFN_InColumns) = 0;
{$ENDIF}
          Drive^.DrvFindFile(GetSelection(@Self, False));
          CE
          end;
        cmFindGotoFile:
          begin
          PanSetup^.FileMask := x_x;
          GotoFile(PString(Event.InfoPtr)^);
          CE;
          Owner^.Select;
          Select;
          GlobalMessage(evCommand, cmRereadInfo, nil);
          end;
        cmAdvFilter:
          begin
          CM_AdvancedFilter(@Self);
          CE
          end;
        {$IFDEF USEWPS}
        {$IFDEF OS2}
        cmOpenWPSWindow:
          begin
          _OpenWPSWindow(DirectoryName);
          CE;
          end; {JO}
        cmCreateWPSObject:
          begin
          if  (PF <> nil) and (Drive^.DriveType < dtArcFind) then
            _CreateWPSObject(MakeNormName(PF^.Owner^, PF^.FlName[True]),
                 (PF^.TType = ttExec) );
          CE;
          end;
        {$ENDIF}
        {$IFDEF Win32} {Cat: � windows ᮤ���� ��몠 ���� �� ࠡ�⠥�}
        cmOpenWPSWindow:
          begin
          if PF <> nil then
            _OpenExplorerWindow(MakeNormName(PF^.Owner^,
                PF^.FlName[True]))
          else if DirectoryName <> 'TEMP:' then
            _OpenExplorerWindow(DirectoryName);
          CE;
          end;
        {$ENDIF}
        {$ENDIF}
      end {case};
    evKeyDown:
      _CheckKB;
    evBroadcast:
      case Event.Command of
        cmFindForced:
          if ForceReading then
            _FindForced;
        cmInsertDrive:
          InsertDrive;
        cmUnArchive:
          if Drive^.DriveType = dtArc then
            begin
            Drive^.CopyFiles(PCopyRec(Event.InfoPtr)^.FC, @Self, True);
            CE;
            end;
        cmCopyCollection:
          if Drive^.DriveType < dtArcFind then
            begin
            Drive^.CopyFiles(Event.InfoPtr, @Self, ShiftState and 7 <> 0);
            CE;
            end;
        cmDropped:
        if MouseInView(PCopyRec(Event.InfoPtr)^.Where) or
          DirView^.MouseInView(PCopyRec(Event.InfoPtr)^.Where)
            //AK155 5-02-2004
        then
            begin
            case Drive^.DriveType of
              dtFind, dtArcFind:
                ;
              else {case}
                CM_Dropped(@Self, Event.InfoPtr);
            end {case};
            CE;
            end;

        (*AK155 19-06-2002. ������, �த�, �� �뢠�� �������. ���� �������
��᮪ ���� � flpanel, ⠪ �� ����⢨⥫쭮 ࠡ�⠥�. � �᫨ �� ��᮪
�����������, � DN �����, �� � �ࠢ����� �� ࠢ�� �� ��������.
                 cmScrollBarChanged: if ScrollBar = Event.InfoPtr then begin
                                      if MSelect then
                                        begin
                                         if Files<>nil then begin
                                          CE; if Files^.Count = 0 then Exit;
                                          PF := Files^.At(ScrollBar^.Value);
                                          if not PF^.IsUpDir
                                                  and (PF^.Selected xor SelectFlag) then
                                           begin
                                            PF^.Selected := SelectFlag;
                                            if SelectFlag then begin Inc(SelNum); SelectedLen := SelectedLen + PF^.Size;
                                                                     PackedLen := PackedLen + PF^.PSize end
                                                          else begin Dec(SelNum); SelectedLen := SelectedLen - PF^.Size;
                                                                     PackedLen := PackedLen - PF^.PSize end;
                                           end;
                                         end;
                                        end;
                                      PosChanged := true;
                                      if InfoView <> nil then InfoView^.DrawView;
                                      CED; PosChanged := false;
                                      if (RepeatDelay <> 0) and QuickViewEnabled then
                                        NeedLocated := GetSTime;
                                     end; AK155*)
      end {case};
    evMouseDown:
      begin
      if Files^.Count = 0 then
        Exit;
      StopQuickSearch; {AK155}
      MSelect := Event.Buttons and mbRightButton <> 0;
      MakeLocal(Event.Where, MPos);
      if {$IFDEF DualName}
         (PanSetup^.Show.ColumnsMask and psLFN_InColumns = 0) or
           { ��ਭ� ������� ���⪮�� ����� �� ������� }
         {$ENDIF}
         ((MPos.X mod LineLength) <> LFNLen)
      then
        begin { D&D 䠩�� }
        if  (MPos.Y = 0) and ColumnTitles then
          begin
          LastRDelay := RepeatDelay;
          RepeatDelay := 0;
          if MSelect then
            begin
            PF := Files^.At(CurPos);
            SelectFlag := not PF^.Selected;
            end;
          repeat
            Message(Owner, evKeyDown, kbUp, nil)
          until not MouseEvent(Event, evMouseMove+evMouseAuto);
          RepeatDelay := LastRDelay;
          CE;
          MSelect := False;
          Exit;
          end;
        MakeLocal(Event.Where, MPos);
        CurPos := Delta+(MPos.X div LineLength)
              *(Size.Y-Byte(ColumnTitles))
          +MPos.Y-Byte(ColumnTitles);
        if Event.Double then
          begin
          MSelect := False;
          CE;
          if Files^.Count = 0 then
            Exit;
          if CurPos < Files^.Count then
            begin
            if ScrollBar^.Value <> CurPos then
              ScrollBar^.SetValue(CurPos)
            else
              begin
              PF := Files^.At(ScrollBar^.Value);
              if PF^.Attr and Directory <> 0 then
                begin
                Message(@Self, evKeyDown, kbCtrlPgDn, nil);
                CE;
                Exit
                end;
              if ShiftState and kbCtrlShift <> 0 then
                Message(@Self, evKeyDown, kbCtrlEnter, nil)
              else
                begin
                Message(CommandLine, evKeyDown, kbDown, nil);
                Message(@Self, evKeyDown, kbEnter, nil);
                CE
                end;
              end;
            end
          end
        else
          begin
          LastRDelay := RepeatDelay;
          RepeatDelay := 0;
          if MSelect and (CurPos < Files^.Count) then
            begin
            CurPos := Delta+(MPos.X div LineLength)
                  *(Size.Y-Byte(ColumnTitles))
              +MPos.Y-Byte(ColumnTitles);
            if  (CurPos >= Files^.Count) then
              CurPos := Files^.Count-1;
            if  (CurPos < 0) then
              CurPos := 0;
            PF := Files^.At(CurPos);
            SelectFlag := not PF^.Selected;
            ScrollBar^.SetValue(CurPos);
            Message(@Self, evBroadcast, cmScrollBarChanged, ScrollBar);
            if PF^.TType = ttUpDir
            then
              PF^.Selected := False;
            end;
          if not MSelect and (FMSetup.Options and fmoDragAndDrop <> 0)
          then
            begin
            MSelect := False;
            RepeatDelay := LastRDelay;
            CurPos := Delta+(MPos.X div LineLength)
                  *(Size.Y-Byte(ColumnTitles))
              +MPos.Y-Byte(ColumnTitles);
            if CurPos < Files^.Count then
              begin
              ScrollBar^.SetValue(CurPos);
              if MouseEvent(Event, evMouseMove) then
                CM_DragDropper(@Self, CurPos, @Event);
              end;
            CE;
            Exit;
            end;
          repeat
            MakeLocal(Event.Where, MPos);
            if MouseInView(Event.Where) then
              begin
              CurPos := Delta+(MPos.X div LineLength)
                    *(Size.Y-Byte(ColumnTitles))
                +MPos.Y-Byte(ColumnTitles);
              if CurPos < Files^.Count then
                ScrollBar^.SetValue(CurPos);
              end
            else
              begin
              if MPos.Y < 0 then
                ScrollBar^.SetValue(ScrollBar^.Value-1)
              else if MPos.Y >= (Size.Y-1) then
                ScrollBar^.SetValue(ScrollBar^.Value+1);
              end;
          until not MouseEvent(Event, evMouseAuto+evMouseMove+evMouseDown);
          RepeatDelay := LastRDelay;
          SendLocated;
          end;
        CE;
        MSelect := False;
        end
        (*               else
                 begin
                  psdel:=(MPos.X div LineLength) + 1;
                  Repeat
                   if (LFNLen - (LineLength*psdel - MPos.X) > 5) and
                      (LineLength*psdel - MPos.X >=0) then
                    EXTLen:=LineLength*psdel - MPos.X;
                   {Owner^.ReDraw;}
                   DrawView;
                   MouseEvent(Event, evMouseMove+evMouseUp);
                   MakeLocal(Event.Where, MPos);
                  Until Event.What=evMouseUp;
                  CE;
                 end*)
      else
        begin { ��������� ����� �ਭ� ������� "���" }
        PSDEL := MPos.X div LineLength;
        repeat
          if MPos.X-LineLength*PSDEL-EXTLen >= 5 then
            begin
            LFNLen := MPos.X div (PSDEL+1);
            Pansetup^.Show.LFNLen := ItoS(LFNLen);
            LineLength := CalcLength;
            end;
          Owner^.Redraw;
          MouseEvent(Event, evMouseMove+evMouseUp);
          MakeLocal(Event.Where, MPos);
        until Event.What = evMouseUp;
        CE;
        end;
      end;
  end {case};
  end { TFilePanelRoot.CommandHandle };
{-DataCompBoy-}

{-DataCompBoy-}
procedure TFilePanelRoot.ChDir;
  begin
  if Drive^.DriveType <> dtDisk then
    Exit;
  MakeNoSlash(Dir);
  Drive^.lChDir(Dir);
  DriveLetter := Drive^.GetDriveLetter;
  IncDrawDisabled;
  ReadDirectory;
  AddToDirectoryHistory(DirectoryName, Integer(Drive^.DriveType));
  ScrollBar^.SetValue(0);
  DecDrawDisabled;
  DrawView;
  GlobalMessage(evCommand, cmRereadInfo, nil);
  Owner^.Redraw;
  end;
{-DataCompBoy-}

procedure TFilePanelRoot.Reorder;
  var
    Cur: PFileRec;
    ScrollBarValue: LongInt;
  begin
  if Files = nil then
    Exit; //AK155 �� ��直� ��砩; �뢠�� �� nil - �� ����
  Files^.SortMode := PanSetup^.Sort.SortMode;
  if PanSetup^.Sort.SortMode = psmUnsorted then
    RereadDir { �����஢���� - �� ⠪��, ��� �⠥��� � ��᪠;
      �� ��᪮��� ��ࢮ��砫�� ���冷� �� 㦥 ����﫨, ����
      ������� ������ }
  else
    begin
    ScrollBarValue := ScrollBar^.Value;
    if ScrollBarValue >= Files^.Count then
      Exit; { AK155 IMHO ⠪ �뢠�� ⮫쪮 ��� 0 >= 0 }
    Cur := Files^.At(ScrollBarValue);
    Files^.Sort;
    for ScrollBarValue := 0 to Files^.Count-1 do
      if Files^.At(ScrollBarValue) = Cur then
        begin
        ScrollBar^.SetValue(ScrollBarValue);
        Break;
        end;
    end;
  end;

function TFilePanelRoot.CalcColPos(ColFlag: Word): Integer;
  var
    Flags: Word;
    i: TFileColNumber;
    L: Integer;
  begin
  Flags := PanSetup^.Show.ColumnsMask;
  Result := 0;
  i := Low(TFileColNumber);
  while Flags <> 0 do
    begin
    ColFlag := ColFlag shr 1;
    if ColFlag = 0 then
      Exit;
    if Odd(Flags) and Drive^.ColAllowed[i] then
      begin
      L := FileColWidht[i];
      if L = -1 then
        begin
        Result := MaxViewWidth;
        Exit;
        end;
      if L = -2 then {�६�}
        L := 7-CountryInfo.TimeFmt;
          {��� 24-�ᮢ��� �ଠ� - 6, ��� 12-�ᮢ��� - 7}
      Inc(Result, L);
      end;
    Flags := Flags shr 1;
    Inc(i);
    end;
  end;

function TFilePanelRoot.CalcLengthWithoutName;
  var
    Flags: Word;
    i: Integer;
    L: Integer;
  begin
  Result := CalcColPos($FFFFFFFF);
  end;

function TFilePanelRoot.CalcNameLength;
  begin
  Result := LFNLen;
  {$IFDEF DualName}
  uLfn := PanSetup^.Show.ColumnsMask and psLFN_InColumns <> 0;
  if not uLFN then
    Result := 12;
  {$ENDIF}
  end;

function TFilePanelRoot.CalcLength;
  begin
  Result := Min(CalcNameLength+1+CalcLengthWithoutName, MaxViewWidth);
  end;

procedure TFilePanelRoot.FormatName(P: PFileRec; var S: String; var L: Integer);
  var
    OPT: Word;
    NFM: TNameFormatMode;
    LogName: String;
    ThisExtLen: Integer;
    W: Integer;
    ExtNotExist: Boolean;
  begin
  S := P^.FlName[uLFN];
//angelbbs
//�ࠢ��쭠� ����஢�� �������
  {$IFDEF RecodeWhenDraw}
  if uLFN then
    S := CharToOemStr(S);
  {$ENDIF}

  OPT := flnPadRight or flnHighlight or flnHandleTildes;
  if P^.Selected and (Startup.FMSetup.TagChar[1] <> ' ') then
    OPT := OPT+flnSelected;

{���㫨஢��� ���७��
 ��������������������������Ŀ
 �         �������          � 0
 �      �᫨ ��� ����       � 1
 �  �᫨ ��� �� ����頥���  � 2
 �          �ᥣ��          � 3
 ����������������������������
}
  W := PosLastDot(S);
  ExtNotExist := (W = 1) or (W >= Length(S));
  ThisExtLen := EXTLen;
  if EXTLen <> 0 then
    case Pansetup^.Show.TabulateExt of
     0:
       ThisExtLen := 0;
     1:
       if ExtNotExist then
         ThisExtLen := 0
       else
         OPT := OPT or flnAutoHideDot;
     2:
       OPT := OPT or flnPreserveExt;
     3:
       OPT := OPT or flnAutoHideDot;
    end {case};
  L := LFNLen;
  {$IFDEF DualName}
  if not uLFN then
    begin
    L := 12;
    ThisExtLen := 3;
    OPT := OPT or flnAutoHideDot;
    end;
  {$ENDIF}

  if ((P^.Attr and Directory) <> 0) and
    (Pansetup^.Show.NoTabulateDirExt <> 0)
  then
    begin
    ThisExtLen := 0;
    OPT := OPT and not flnAutoHideDot;
    end;

  case P^.Attr and (Hidden+SysFile) of
    0:
      NFM := nfmNull;
    {Pavel Anufrikov -> }
    Hidden:
      NFM := nfmHidden;
    SysFile:
      NFM := nfmSystem;
    Hidden+SysFile:
      NFM := nfmHiddenSystem;
  end {case}; { <- Pavel Anufrikov}

  if P^.Attr and Directory <> 0 then
    begin
{          ������������Ŀ
������� �� �  ��� ����  � 0
  ��⠫��� �   ���묨   � 1
  .......  � � ����让  � 2
           �  ��������  � 3
           �    ���    � 4
           �������������� }
    case Pansetup^.Show.DirRegister of
      1:
        OPT := OPT or flnLowCase;
      2:
        OPT := OPT or flnCapitalCase;
      3:
        OPT := OPT or flnUpCase;
      4:
        if (not IsMixedCase(S)) {JO} then
          OPT := OPT or flnUpCase;
    end {case};
    end
  else
    begin { �������筮 }
    case Pansetup^.Show.FileRegister of
      1:
        OPT := OPT or flnLowCase;
      2:
        OPT := OPT or flnCapitalCase;
      3:
        OPT := OPT or flnUpCase;
      4:
        if (not IsMixedCase(S)) {JO} then
          OPT := OPT or flnLowCase;
    end {case};
    end;
  {$IFDEF OS2}
  if Drive^.ShowLogNames then
    begin
    LogName := '';
    if  (S <> '..')
           and (GetEAString(MakeNormName(P^.Owner^, S), '.LONGNAME',
           LogName, True) = 0) and
        (LogName <> '')
    then
      S := #221+FormatLongName(LogName, L-1, ThisEXTLen,
        OPT and not (flnUpCase or flnLowCase or flnCapitalCase),
        NFM)
    else
      S := FormatLongName(S, L, ThisEXTLen, OPT, NFM);
    end
  else
    {$ENDIF}
    S := FormatLongName(S, L, ThisEXTLen, OPT, NFM);
  end {TFilePanelRoot.FormatName};

procedure TFilePanelRoot.GetEmpty(var B; SC: Word; Scroll: Boolean);
  var
    X: AWord;
    Flags: Word;
    i: TFileColNumber;
    L: Integer;
  begin
  Flags := PanSetup^.Show.ColumnsMask;
  X := 0;
  if not LFNLonger250 then
    begin
    X := CalcNameLength+1;
    if X-(DeltaX*Byte(Scroll)) > 0 then
      TAWordArray(B)[X-(DeltaX*Byte(Scroll))-1] := SC;
    end;
  i := Low(TFileColNumber);
  while Flags <> 0 do
    begin
    if Odd(Flags) and Drive^.ColAllowed[i] then
      begin
      L := FileColWidht[i];
      if L = -1 then
        Exit;
      if L = -2 then {�६�}
        L := 7-CountryInfo.TimeFmt;
          {��� 24-�ᮢ��� �ଠ� - 6, ��� 12-�ᮢ��� - 7}
      if L <> 0 then
        begin
        inc(X, L);
        if X > 250 then
          Exit;
        if X-(DeltaX*Byte(Scroll)) > 0 then
          TAWordArray(B)[X-(DeltaX*Byte(Scroll))-1] := SC;
        end;
      end;
    Flags := Flags shr 1;
    Inc(i);
    end;
  end { TFilePanelRoot.GetEmpty };

procedure TFilePanelRoot.SetupPanelFromDrive;
  begin
  DriveLetter := Drive^.GetDriveLetter;
  PanSetup := @PanelSetupSet[dt2pc[Drive^.DriveType]];
  PInfoView(InfoView)^.CompileShowOptions;
  LFNLen := SToI(PanSetup^.Show.LFNLen);
  EXTLen := SToI(PanSetup^.Show.EXTLen);
  LFNLonger250 := (LFNLen >= 250)
    {$IFDEF DualName}
    and (PanSetup^.Show.ColumnsMask and psLFN_InColumns <> 0)
    {$ENDIF};
    {JO: �᫨ �ਭ� ������� ����� ����� 250 ᨬ�����,
     �� �����뢠�� ��᫥ ��⠫��� �������}
  if Owner <> nil { nil �뢠�� �� �६� Load } then
    PDoubleWindow(Owner)^.SetMaxiState(@Self);
  end;

procedure TFilePanelRoot.AddSelected(PF: PFileRec);
  begin
  with PF^ do
  if Selected then
    begin
    if Size > 0 then
      begin { � ��⠫��� � ��������� ࠧ��஬ Size=-1}
      SelectedLen := SelectedLen + Size;
      PackedLen := PackedLen + PSize;
      end;
    Inc(SelNum);
    end;
  end;

procedure TFilePanelRoot.GetParam(i: Integer);
  var
    c: TPanelClass;
    NewPresetNum: Integer;
    NewSetupSet: TPanelSetupSet;
    P: PFilePanelRoot;
    PC: TPanelClass;
    ShowOnly: Boolean;
  begin
  NewPresetNum := i and $0F;
  ShowOnly := (i and not $0F) = 0;
  PC := dt2pc[Drive^.DriveType];
  case NewPresetNum of
   1..10: { ���� }
    NewSetupSet := PanSetupPreset[NewPresetNum];
   11: { ��㣠� ������ }
    begin
    P := OtherFilePanel(@Self);
    NewSetupSet := P^.PanelSetupSet;
    NewPresetNum := P^.PresetNum;
    end;
   else {12, �⪠� }
    begin
    NewSetupSet := PrevPanelSetupSet;
    NewPresetNum := PrevPresetNum;
    end;
  end {case};
  if ShowOnly and MemEqual(PanelSetupSet[PC].Show, NewSetupSet[PC].Show,
       SizeOf(TPanelShowSetup))
  then
    begin { ������ ����㧪� ����, ᮢ�����饣� � ⥪�騬 }
    if not MenuOnError or (NewPresetNum <> PresetNum) then
      PresetNum := NewPresetNum
    else
      CM_SelectColumn(@Self);
      { ��� �������� ४����, �� �� ��㡨�� ��࠭�祭� ��न��
      ���짮��⥫� � ��������� ������ � ⮣� �� }
    Exit;
    end;

  Owner^.Lock;
  PrevPresetNum := PresetNum;
  PresetNum := NewPresetNum;
  if ShowOnly then
    begin
    for c := Low(TPanelClass) to High(TPanelClass) do
      begin
      PrevPanelSetupSet[c].Show := PanelSetupSet[c].Show;
      PanelSetupSet[c].Show := NewSetupSet[c].Show;
      end;
    end
  else
    begin
    PrevPanelSetupSet := PanelSetupSet;
    PanelSetupSet := NewSetupSet;
    if PrevPanelSetupSet[PC].FileMask <> PanelSetupSet[PC].FileMask then
      RereadDir;
    if not MemEqual(PrevPanelSetupSet[PC].Sort, PanelSetupSet[PC].Sort,
      SizeOf(PrevPanelSetupSet[PC].Sort))
    then
      Reorder;
    end;
  SetupPanelFromDrive;
  Rebound; { ����� ���������� � ������, � ������; ������ � �����㥬 ��� }
  Owner^.UnLock;
  end {TFilePanelRoot.GetParam};

procedure TFilePanelRoot.Rebound;
  var
    R: TRect;
  begin
  GetBounds(R);
  R.A.Y := 1;
  R.B.Y := Owner^.Size.Y-1;
  ChangeBounds(R);
  SortView^.SetState(sfVisible, (FMSetup.Show and fmsSortIndicator) <> 0);
    { �ᯮ������ �� ᬥ�� �������� �������� � setups.FMSetup }
  Owner^.Redraw;
  end;

function OtherFilePanel(P: PFilePanelRoot): PFilePanelRoot;
  begin
  Result := PDoubleWindow(P^.Owner)^.Panel[not P^.SelfNum].FilePanel;
  end;

end.

