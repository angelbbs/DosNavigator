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

unit DblWnd;

interface

uses
  Views, Defines, Streams, Drivers, FlPanelX, FlPanel, U_KeyMap
  ;

type
  TPanelDescr = record
  {` ����⥫� ����� (�� ����) ������� }
    AnyPanel: PView; // �᫨ �� �⮩ ������ ��-� ����� - � ������ ��.
    FilePanel: PFilePanel; { �������� ������. ������� �ᥣ��, ��,
      ��������, ����, �⮡� �������� ��䠩�����.
      �᫨ ����� 䠩����� ������, � AnyPanel = FilePanel }
    PanelType: Byte; // ⨯ AnyPanel
    Drive: Byte; // ��� FilePanel
    end;
  {`}

  TPanelNum = boolean;
  {` ��뫪� �� ���� �� ���� ������; ��� ����來��� ��।����
  ⠪�� ����⠭�� pLeft � pRight. ���祭�� �⮣� ⨯� �㦠�
  ��� �⢥� �� ����� "�����", ���ਬ��, ��� �����������
  TDoubleWindow.Panel.
  `}

const
  pLeft = false; // ��� TPanelNum
  pRight = true; // ��� TPanelNum


type
  PSeparator = ^TSeparator;
  {`2 ���⨪���� ࠧ����⥫� ����� �����ﬨ. ������� ����� �����
  ࠬ�� �ࠢ�� ������ � �ࠢ�� ����� ࠬ�� ����� ������ (�� ᠬ��
  ���� ������ ࠬ�� �� ����� �����.) }
  TSeparator = object(TView)
    OldX, OldW: AInt;
    constructor Init(R: TRect; AH: Integer);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    end;
  {`}

  PDoubleWindow = ^TDoubleWindow;
  {`2 ���寠����� ��������.}
  TDoubleWindow = object( {TStd}TWindow)
    Separator: PSeparator; // ���⨪���� ����� �����ﬨ
    Panel: array[TPanelNum] of TPanelDescr;
    OldBounds: TRect;
    OldPanelBounds: TRect;
    NonFilePanelType: Byte;
      {`⨯ ��䠩����� ������; 0, �᫨ ⠪���� ���`}
    NonFilePanel: TPanelNum;
      {`����� �� ������� ��䠩�����; ����, �᫨ ��� 䠩���� `}
    PanelZoomed: Boolean;
      {` ���� �� ������� ���ᨬ���஢��� `}
    SinglePanel: Boolean;
      {` �뫠 �� ������ �� ���ᨬ���樨 �����⢥���� `}
    isValid: Boolean;
    constructor Init(Bounds: TRect; ANumber, ADrive: Integer);
    procedure InitPanel(N: TPanelNum; R: TRect);
    procedure InitInterior;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure SwitchView(dtType: Byte);
      {`������� ����⨢��� ������ 㪠������� ⨯�, �᫨ ᥩ�� �
      ��� ��㣮� ⨯; � �᫨ ������ ⠪�� - � ᤥ���� ������
      䠩�����`}
    function Valid(C: Word): Boolean; virtual;
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure HandleCommand(var Event: TEvent);
      {`DblWnd`}
    procedure SwitchPanel(N: TPanelNum);
      {`�����/�������� ������`}
    procedure ChangeDrv(N: TPanelNum);
      {`ᬥ���� ��� � �������� (Alt-F1/F2)`}
    procedure SetMaxiState(P: PFilePanelRoot);
      {` ��⠭����� ���ﭨ� ���ᨬ���஢������ ��⨢��� 䠩�����
        ������ � ᮮ⢥��⢨� � �� ����ன��� `}
    procedure ToggleViewMaxiState(P: PView; Other: TPanelNum);
      {` ������஢��� ���ﭨ� ���ᨬ���஢������ ��⨢��� ������
        (��������, ��䠩�����). ����� ��㣮� ������ - Other `}
    end;
    {`}

const
  CDoubleWindow = #80#81#82+ { 1-3    Frame (P,A,I)            }
  #83#84+ { 4,5    Scroll Bar (Page, Arrow) }
  #85#86#87#88#89+ { 6-10   Panel (NT,Sp,ST,NC,SC)   }
  #90#91+ { 11,12  Panel Top (A,P)          }
  #92#93+ { 13,14  Viewer (NT,ST)           }
  #94#95#96#97+
  #98#99#100+ { 15-21  Tree (T,NI,SI,Df,DS,SI,DI}
  #101+ { 22     Tree info                }
  #102#103+ { 23,24  Disk info (NT, HT)       }
  #119#120#121#122+
  #123#124#125+ { 25-31  File Info                }
  #165+ { 32  File Panel               }
  #172#173#174#175#176#177#180#181+ { 33-40 Highlight groups}
  #186#187#188+ { 41-43 Drive Line }
  #192#193#194#195#196+ { 44-48 JO - 5 additional highlight groups}
  #130#131; { 49,50 JO - File Info (LFN in footer)}

const
  dtPanel = 1;
  dtInfo = 2;
  dtTree = 3;
  dtQView = 4;
  dtDizView = 5;
  {$IFDEF NETINFO}
  dtNetInfo = 6; {-$VIV}
  {$ENDIF}

implementation
uses
  DiskInfo, Commands, FileCopy, FilesCol, Advance, Advance1, Advance2,
  Startup, DNApp, TopView_, Tree, FViewer
  {$IFDEF NETINFO}, NetInfo {-$VIV} {$ENDIF}
  , Dos, VPUtils
  ;

constructor TDoubleWindow.Init;
  var
    P: PFilePanel;
    R: TRect;
    PV: PView;
    i: TPanelNum;
  begin
  inherited Init(Bounds, '', ANumber);
  Options := Options or ofTileable;
  EventMask := $FFFF;
  Abort := False;
  if  (ADrive <= 0) or not ValidDrive(Char(ADrive+64)) then
    ADrive := 0;
  Panel[pLeft].Drive := ADrive;
  Panel[pRight].Drive := ADrive;
  GetExtent(R);
  R.Grow(-1, 0);
  R.A.X := R.B.X div 2;
  R.B.X := R.A.X+2;
  Separator := New(PSeparator, Init(R, Size.X));
  Insert(Separator);
  InitInterior;
  PassivePanel := Panel[pLeft].FilePanel;
  if not Abort then
    isValid := True;
  case FMSetup.LeftPanelType of
    fdoInfoDrive:
      Message(@Self, evCommand, cmDiskInfo, nil);
    fdoTreeFrive:
      Message(@Self, evCommand, cmDirTree, nil);
    fdoRightOnly:
      Message(@Self, evCommand, cmHideLeft, nil);
  end {case};
  end { TDoubleWindow.Init };

procedure TDoubleWindow.InitPanel(N: TPanelNum; R: TRect);
  var
    PV: PMyScrollBar;
    P: PFilePanel;
    P1: PInfoView;
    P2: PDirView;
    P3: PSortView;
    PD: PDriveLine;
    B: TRect;
  begin
  if Abort then
    Exit;
  B := R;
  B.A.X := B.B.X;
  Inc(B.B.X);
  Inc(B.A.Y);
  Dec(B.B.Y, 3);
  New(PV, Init(B));
  New(P, Init(R, Panel[N].Drive, PV));
  if Abort then
    begin
    Dispose(P, Done);
    Dispose(PV, Done);
    Exit
    end;

  New(P1, Init(R));
  P1^.Panel := P;
  P1^.CompileShowOptions;
  P^.InfoView := P1;

  New(P2, Init(R));
  P2^.Panel := P;
  P^.DirView := P2;
  P2^.EventMask := $FFFF;

  New(P3, Init(R));
  P3^.Panel := P;
  P^.SortView := P3;
  P3^.EventMask := evMouseDown;

  New(PD, Init(R, P));
  P^.DriveLine := PD;

  P^.ChangeBounds(R);

  Insert(PV);
  Insert(P3);
  Insert(P2);
  Insert(P1);
  Insert(P);
  Insert(PD);
  with Panel[N] do
    begin
    AnyPanel := P;
    FilePanel := PFilePanel(P);
    PanelType := dtPanel;
    FilePanel.SelfNum := N;
    P^.Select;
    end;
  end { TDoubleWindow.InitPanel };

function TDoubleWindow.Valid;
  begin
  Valid := inherited Valid(C) and isValid;
  end;

procedure TDoubleWindow.ChangeBounds(var Bounds: TRect);
  var
    D: TPoint;
    R: TRect;
    SVisible: Boolean;
    N: TPanelNum;
  label 1;
  begin
  D.X := Bounds.B.X-Bounds.A.X-Size.X;
  D.Y := Bounds.B.Y-Bounds.A.Y-Size.Y;
  GetExtent(R);
  R.Grow(-1, 0);
  R.A.X := (R.B.X*Separator^.OldX) div Separator^.OldW;
  if D.EqualsXY(0, 0) and (R.A.X = Separator^.Origin.X) then
    begin
    SetBounds(Bounds);
    DrawView;
    end
  else
    begin
    FreeBuffer;
    SetBounds(Bounds);
    GetExtent(Clip);
    GetBuffer;
    Lock;
    GetExtent(R);
    Frame^.ChangeBounds(R);
    SVisible := Separator^.GetState(sfVisible);
    for N := pLeft to pRight do
      begin
      with Panel[N] do
        if not AnyPanel^.GetState(sfVisible) then
          begin
          if SVisible then
            Separator^.Hide;
          GetExtent(R);
          R.Grow(-1, -1);
          Panel[not N].AnyPanel^.ChangeBounds(R);
          goto 1;
          end;
      end;
    if not SVisible then
      Separator^.Show;
    GetExtent(R);
    R.Grow(-1, 0);
    R.A.X := (R.B.X*Separator^.OldX) div Separator^.OldW;
    R.B.X := R.A.X+2;
    Separator^.ChangeBounds(R);
    GetExtent(R);
    R.Grow(-1, -1);
    R.A.X := (R.B.X*Separator^.OldX) div Separator^.OldW+2;
    Panel[pRight].AnyPanel^.ChangeBounds(R);
    GetExtent(R);
    R.Grow(-1, -1);
    R.B.X := (R.B.X*Separator^.OldX) div Separator^.OldW;
    Panel[pLeft].AnyPanel^.ChangeBounds(R);
1:
    Redraw;
    UnLock;
    end;
  end { TDoubleWindow.ChangeBounds };

constructor TDoubleWindow.Load;
  const
    SaveBlockLen =
      SizeOf(OldBounds) +
      SizeOf(OldPanelBounds) +
      SizeOf(NonFilePanelType) +
      SizeOf(NonFilePanel) +
      SizeOf(PanelZoomed) +
      SizeOf(SinglePanel);
  var
    N: TPanelNum;
  begin
  inherited Load(S);
  S.Read(OldBounds, SaveBlockLen);
  GetSubViewPtr(S, Separator);
  for N := pLeft to pRight do
    with Panel[N] do
      begin
      S.Read(PanelType, SizeOf(PanelType)+SizeOf(Drive));
      GetSubViewPtr(S, FilePanel);
      if FilePanel = nil then
        Fail;
      AnyPanel := FilePanel;
      FilePanel.SelfNum := N;
      end;
  PassivePanel := OtherFilePanel(ActivePanel);

  if NonFilePanelType <> 0 then
    GetSubViewPtr(S, Panel[NonFilePanel].AnyPanel);

  {Cat}
  if  (Separator = nil)
    or (Panel[pLeft].AnyPanel = nil) or (Panel[pRight].AnyPanel = nil)
  then
    Fail;
  {/Cat}

  case NonFilePanelType of
    dtQView, dtDizView:
      with Panel[not NonFilePanel].FilePanel^ do
        begin
        QuickViewEnabled := True;
        SendLocated;
        end;

    dtTree:
      with PHTreeView(Panel[NonFilePanel].AnyPanel)^ do
        ReadAfterLoad;

    dtInfo:
      with PDiskInfo(Panel[NonFilePanel].AnyPanel)^ do
        begin
        OtherPanel := Panel[not NonFilePanel].FilePanel;
        ReadData;
        end;
  end {case};

  isValid := True;
  end { TDoubleWindow.Load };

procedure TDoubleWindow.Store;
  const
    SaveBlockLen =
      SizeOf(OldBounds) +
      SizeOf(OldPanelBounds) +
      SizeOf(NonFilePanelType) +
      SizeOf(NonFilePanel) +
      SizeOf(PanelZoomed) +
      SizeOf(SinglePanel);
  var
    N: TPanelNum;
  begin
  inherited Store(S);
  S.Write(OldBounds, SaveBlockLen);
  PutSubViewPtr(S, Separator);
  for N := pLeft to pRight do
    with Panel[N] do
      begin
      S.Write(PanelType, SizeOf(PanelType)+SizeOf(Drive));
      PutSubViewPtr(S, FilePanel);
      end;
  if NonFilePanelType <> 0 then
    PutSubViewPtr(S, Panel[NonFilePanel].AnyPanel);
  end { TDoubleWindow.Store };


const
  VScrollRect: TRect = (A:(X:1;Y:1);B:(X:2;Y:5));
    {����⢥���, �� B.X-A.X = 1, � ���� ���⨪����.
    ��⠫쭮� �� �����.}

{ �������� ���⨪��쭮�� �஫���� ��� ������ ��ᬮ�� }
function MakeVScroll: PViewScroll;
  begin
  Result := New(PViewScroll, Init(VScrollRect));
  Result^.Options := Result^.Options or ofPostProcess;
  end;

{ ����஫� ᢥ��ᮧ������ ��䠩����� ������ P; �� �訡��� �㤥� P=nil }
function ValidVP(var P: PView; S: PView {�஫����}): Boolean;
  begin
  Result := False;
  if (S = nil) or (P = nil) or not P^.Valid(0) then
    begin
    S.Free;
    P.Free;
    P := nil;
    Exit;
    end;
  Result := True;
  end;

procedure InsertView(var P: PView; S: PView; Manager: PDoubleWindow);
  begin
  if ValidVP(P, S) then
    with Manager do
      begin
      Insert(P);
      Insert(S);
      P^.Hide;
      end;
  end;

{ ����ந⥫� ��䠩����� ������� }

function InsertQView(R1: TRect;
    Manager: PDoubleWindow; Other: PFilePanelRoot): PView;
  var
    S: PViewScroll;
  begin
  S := MakeVScroll;
  Result := New(PQFileViewer, Init(R1, nil, '', '', S, True,
           (EditorDefaults.ViOpt and 1) <> 0));
  InsertView(Result, S, Manager);
  end { InsertQView };

function InsertDizView(R1: TRect;
    Manager: PDoubleWindow; Other: PFilePanelRoot): PView;
  var
    S: PViewScroll;
  begin
  S := MakeVScroll;
  Result := New(PDFileViewer, Init(R1, nil, '', '', S, True,
    (EditorDefaults.ViOpt and 1) <> 0));
  InsertView(Result, S, Manager);
  end { InsertDizView };

function InsertTree(R1: TRect;
    Manager: PDoubleWindow; Other: PFilePanelRoot): PView;
  var
    S: PMyScrollBar;
    P: PView;
  begin
  S := New(PMyScrollBar, Init(VScrollRect));
  S^.Options := S^.Options or ofPostProcess;
  { ������� ����� �� ���⨪��� ����� �������� (2 ��ப�) � ��ॢ��}
  Dec(R1.B.Y, 2);
  Result := New(PHTreeView, Init(R1, 0, False, S));
  if ValidVP(Result, S) then
    begin
    R1.A.Y := R1.B.Y;
    Inc(R1.B.Y, 2);
    P := New(PTreeInfoView, Init(R1, PHTreeView(Result)));
    PHTreeView(Result)^.Info := P;
    with Manager do
      begin
      Insert(P);
      Insert(Result);
      Insert(S);
      end;
    end;
  end { InsertTree };

function InsertInfo(R1: TRect;
    Manager: PDoubleWindow; Other: PFilePanelRoot): PView;
  begin
  Result := New(PDiskInfo, Init(R1, Other));
  Result^.Hide;
  Manager.Insert(Result);
  PDiskInfo(Result)^.InsertDriveView;
  PDiskInfo(Result)^.ReadData;
  // �� ���� ������ ��᫥ Insert
  end { InsertTree };


type
  TPanelConstructor = function(R1: TRect;
    Manager: PDoubleWindow; Other: PFilePanelRoot): PView;

{ � ��� ���ᨢ �� 㣮��� (������, � �ਬ���) ����� �������� ᢮�
����� ����� ��� nil, ��᫥ 祣� ��� ���� ⨯ ��䠩����� ������
����� �㤥� ��� �஡��� �������-�몫���� �१ SwitchView ��
ᮮ⢥������� ������.}

const
  PanelConstructor: array[dtInfo..10] of TPanelConstructor =
    (  InsertInfo
     , InsertTree
     , InsertQView
     , InsertDizView
     , nil
     , nil
     , nil
     , nil
     , nil
    );

procedure TDoubleWindow.SwitchView(dtType: Byte);
  var
    R1: TRect;
    V: PView;
    N, Selected: TPanelNum;
    VisibleN: Boolean;
  label Ex;
  begin
  Lock;

  if PanelZoomed then
    Message(@Self, evCommand, cmMaxi, nil);
      { �� PanelZoomed ����� ���ॡ������� SwitchView ⮫쪮 �᫨
       ���ᨬ���஢����� ������ - 䠩�����. �� ���� �� ��-� �த�
       Ctrl-Q �� ���ᨬ���஢����� ������. �⮡� �뫮 ��� ���뢠��
       ��䠩����� ������, ���ᨬ����� ���� ����. }

  Selected := Panel[pRight].AnyPanel^.GetState(sfSelected);
  N := not Selected;
  VisibleN := Panel[N].AnyPanel^.GetState(sfVisible);
  Panel[N].AnyPanel^.GetBounds(R1);

  { �᫨ ��䠩����� ������ �뫠 - �� ���� � �� ��砥 㭨�⮦���.
�᫨ ��� �뫠, � ��⮬ ������ ⨯� dtType, � ���� �㤥� ����⠭�����
䠩����� ������; � ��⠫��� ����� ᮧ���� ������ dtType. �᫨ ��
�� �뫮, ���� ������� 䠩����� ������}
  with Panel[N].AnyPanel^ do
    begin
    if not VisibleN then
      SwitchPanel(N);
    Hide;
    if NonFilePanelType <> 0 then
      Free;
    end;

  if NonFilePanelType <> dtType then
    begin
    NonFilePanelType := 0;
    V := PanelConstructor[dtType](R1, @self, Panel[not N].FilePanel);
    if V = nil then
      goto Ex;
    NonFilePanel := N;
    NonFilePanelType := dtType;
    Panel[N].AnyPanel := V;
    R1.A.Y := 1;
    R1.B.Y := Size.Y-1;
    V^.Locate(R1);
    V^.Show;
    Panel[N].PanelType := dtType;
    Panel[Selected].AnyPanel^.Select;
    if dtType in [dtQView, dtDizView] then
      Panel[Selected].FilePanel.QuickViewEnabled := True;
    Redraw;
    end
  else
    begin
    NonFilePanelType := 0;
    if VisibleN then
      begin
      Panel[N].AnyPanel := Panel[N].FilePanel;
      R1.A.Y := 1;
      R1.B.Y := Size.Y-1;
      Panel[N].FilePanel^.Locate(R1);
      Panel[N].FilePanel^.Show;
      Panel[N].PanelType := dtPanel;
      Panel[not N].FilePanel.QuickViewEnabled := False;
      if not N <> Selected then
        Panel[not N].FilePanel^.Select;
      end
    else
      if not VisibleN then
        SwitchPanel(N);
    end;

Ex:
  UnLock;
  end { TDoubleWindow.SwitchView };

procedure TDoubleWindow.InitInterior;
  var
    R: TRect;
    RP: array[TPanelNum] of TRect;
    N: TPanelNum;
  begin
  GetExtent(R);
  R.Grow(-1, -1);
  RP[pRight] := R;
  RP[pLeft] := R;
  RP[pLeft].B.X := RP[pLeft].B.X div 2;
  RP[pRight].A.X := RP[pLeft].B.X + 2;

  for N := pLeft to pRight do
    begin
    InitPanel(N, RP[N]);
    if Abort then
      Exit;
    end;
  end { TDoubleWindow.InitInterior };

{ ������/�������� ������ }
procedure TDoubleWindow.SwitchPanel(N: TPanelNum);
  var
    R, RN: TRect;
    ThisPanel: PView;
    NewXBound: Integer;
    ForceResize: Boolean;
  begin
  if PanelZoomed or not Panel[not N].AnyPanel^.GetState(sfVisible) then
    Exit;
  Lock;
  GetBounds(R);
  ThisPanel := Panel[N].AnyPanel;
  if ThisPanel^.GetState(sfVisible) then
    begin // �����
    OldBounds := R;
    NewXBound := Separator^.Origin.X+R.A.X+1;
    if N then {��뢠�� �ࠢ��}
      R.B.X := NewXBound
      { �᫨ �ਭ� �������� �⠫� ����� MinWinSize.X, �
      ChangeBounds ����� ���� ��ࠢ�, �� � �ॡ����}
    else {��뢠�� �����}
      begin
      R.A.X := NewXBound;
      if R.B.X-R.A.X < MinWinSize.X then
        R.A.X := R.B.X - MinWinSize.X;
        { � ��� ���� ������� �����, ⠪ �� ������ �� ᠬ� }
      end;
    ThisPanel^.Hide;
    end
  else
    begin // ��������
    ThisPanel^.Show;
    R.A.X := OldBounds.A.X;
    R.B.X := OldBounds.B.X;
    end;
  if OldBounds.B.X - OldBounds.A.X = MinWinSize.X then {<Dblwnd.002>}
    begin
    Inc(R.B.X);
    ChangeBounds(R);
    Dec(R.B.X);
    end;
  Locate(R);
  UnLock;
  end { TDoubleWindow.SwitchPanel };

{ ����� ��᪠ �१ ���� Alt-F1/F2 }
procedure TDoubleWindow.ChangeDrv(N: TPanelNum);
  var
    R, R1: TRect;
    S: String;
    P: TPoint;
    ThisPanel: PView;
    PanelSelected, PanelVisible: Boolean;
  begin
  ThisPanel := Panel[N].AnyPanel;
  PanelVisible := ThisPanel^.GetState(sfVisible);
  if (NonFilePanelType <> 0) and (N = NonFilePanel) then
    begin
    ThisPanel^.GetBounds(R);
    R.A.Y := 1;
    R.B.Y := Size.Y;
    Panel[N].FilePanel^.Locate(R);
    end;
  GetBounds(R);
  if not PanelVisible or (Panel[N].PanelType <> dtPanel) then
    begin
    with ThisPanel do
      P.X := Origin.X + Size.X div 2 - 8;
    P.Y := Origin.Y+3;
    S := SelectDrive(P.X, P.Y,
      Panel[N].FilePanel^.DirectoryName[1], True);
    if S = '' then
      Exit;
    ClrIO;
    Lock;
    if not PanelVisible then
      SwitchPanel(N);
    Message(Panel[N].FilePanel, evCommand, cmChangeDrv, @S);
    with Panel[N] do
      begin
      if PanelType <> dtPanel then
        begin
        with Panel[NonFilePanel].AnyPanel^ do
          begin
          PanelSelected := GetState(sfSelected);
          GetBounds(R1);
          Hide;
          Free;
          end;
        NonFilePanelType := 0;
        R1.A.Y := 1;
        R1.B.Y := Size.Y-1;
        FilePanel^.Locate(R1);
        AnyPanel := FilePanel;
        PanelType := dtPanel;
        FilePanel^.Show;
        if PanelSelected then
          FilePanel^.Select;
        end;
      end;
    end
  else
    begin
    Message(Panel[N].FilePanel, evCommand, cmChangeDrive, nil);
    end;
  if  (ShiftState and 3 <> 0) and (PanelSelected <> N) then
    ThisPanel^.Select;
  UnLock;
  end { TDoubleWindow.ChangeDrv };

procedure TDoubleWindow.SetMaxiState(P: PFilePanelRoot);
  var
    Other: TPanelNum;
  begin
  if PanelZoomed and (P = PassivePanel) then
    begin { ����⪠ ���ᨬ���஢��� ���ᨢ��� ������, ����� ��⨢��� 㦥
      ���ᨬ���஢���. � �⮬ ��砥 �� ���ᨬ����㥬 ��, � �������,
      ���뢠�� � �� ����ன��� 䫠� ���ᨬ���樨. ������ �⮩ ���樨
      �������� �ࠢ������ � PassivePanel, � �� �஢�મ� ��������,
      ⠪ ��� �� �६� Load ������ ������ ����� ���� ���������. }
    with P^.PanSetup^.Show do
      MiscOptions := MiscOptions and not 1;
    end
  else if ((P^.PanSetup^.Show.MiscOptions and 1) <> 0) <>
     PanelZoomed
  then
    ToggleViewMaxiState(P, not P^.SelfNum);
  end;

procedure TDoubleWindow.ToggleViewMaxiState(P: PView; Other: TPanelNum);
  begin
  Lock;
  if not PanelZoomed then
    begin { ���ᨬ���஢��� }
    SinglePanel := not Panel[Other].AnyPanel^.GetState(sfVisible);
    if not SinglePanel then
      SwitchPanel(Other);
    GetBounds(OldPanelBounds);
    ChangeBounds(OldBounds);
    PanelZoomed := True;
    end
  else
    begin { ����� ���ᨬ����� }
    if SinglePanel then
      Hide; {AK155 ��祬�-� ��� �⮣� �� �������
        ���⪨ �ᯠ��⮩ ������ }
    ChangeBounds(OldPanelBounds);
    Show;
    PanelZoomed := False;
    if not SinglePanel then
      SwitchPanel(Other);
    end;
  UnLock;
  end;

procedure TDoubleWindow.HandleCommand;
  var
    Selected: Boolean;
    Visible: array [TPanelNum] of Boolean;
    Sp: PSeparator;
    EV: TEvent;

  procedure CE;
    begin
    ClearEvent(Event)
    end;

  { ������� �� Selected ������ 䠩�����, � ���� ����� �� � ��� 楯����
   ��䠩����� ������ }
  function isFilePanel: Boolean;
    begin
    result := (NonFilePanelType = 0) or (Selected <> NonFilePanel);
    end;

  procedure InsertPath(N: TPanelNum);
    var
      S: string;
    begin
    S := '';
    Message(Panel[N].AnyPanel, evCommand, cmGetDirName, @S);
    if S <> '' then
      begin
      if not (S[Length(S)] in ['\', '/']) then
        AddStr(S, '\');
      S := SquashesName(S);
      Message(CommandLine, evCommand, cmInsertName, @S);
      end;
    CE;
    end;

  { ����� ࠧ����⥫� ��ࠢ� (D=1) ��� ����� (D=-1). �᫨
  ����� Shift - � �� 楫�� 䠩����� ������� }
  procedure SeparatorMove(D: Integer);
    var
      X: Integer;
      N: TPanelNum;
      R: TRect;
    begin
    if Visible[pRight] and Visible[pLeft] then
      begin
      if ShiftState and (kbLeftShift+kbRightShift) <> 0 then
        begin
        { �� ᤢ��� �� �ਭ� 䠩����� ������� ���� ����� ������,
        �� ���� ���� ��� ᠬ�� �ਭ�. ���� ��⨢���, �᫨ ���
        䠩�����, ��� �����, �᫨ ��⨢��� - ��䠩�����.}
        N := Selected xor (Panel[Selected].PanelType <> dtPanel);
        D := D*Panel[N].FilePanel^.LineLength;
        end;
      Sp^.OldW := Size.X;
      X := Sp^.Origin.X + D + 1;
      Sp^.OldX := Min(Max(X, 0), Sp^.OldW);
      GetBounds(R);
      ChangeBounds(R);
      CE;
      end;
    end;

  var
    R, R1, R2: TRect;
    I, K: Integer;
    AP, PP: PFilePanel;
    D: Word;
    P: PView;
    N: TPanelNum;
    S: String;
    WPanel: TPanelDescr;
    WR: array[TPanelNum] of TRect;

  begin { TDoubleWindow.HandleCommand }
  for N := pLeft to pRight  do
    Visible[N] := Panel[N].AnyPanel^.GetState(sfVisible);
  Selected := Panel[pRight].AnyPanel^.GetState(sfSelected);
  Sp := Separator;
  case Event.What of
    evKeyDown:
      case Event.KeyCode of
        kbCtrlLeft, kbCtrlRight,
        kbCtrlShiftLeft, kbCtrlShiftRight:
          if  not QuickSearch and
              (FMSetup.LRCtrlInDriveLine <> fdlNoDifference) and
              (Visible[pLeft] and Visible[pRight]) then
            begin
            N := (ShiftState2 and 1 = 0);
            if (FMSetup.LRCtrlInDriveLine = fdlPassive) then
              N := N xor not Selected;
            Panel[N].AnyPanel^.HandleEvent(Event);
            Exit;
            end;

        kbAlt1, kbAlt2, kbAlt3, kbAlt4, kbAlt5, kbAlt0,
        kbAlt6, kbAlt7, kbAlt8, kbAlt9:
          if FMSetup.Options and fmoAltDifference <> 0 then
            begin
            if Visible[pLeft] and (ShiftState2 and 2 <> 0) then
              Panel[pLeft].AnyPanel^.HandleEvent(Event)
            else
              Panel[pRight].AnyPanel^.HandleEvent(Event);
            Exit;
            end;
        {
              kbCtrl1, kbCtrl2, kbCtrl3, kbCtrl4, kbCtrl5, kbCtrl6, kbCtrl7,
              kbCtrl8, kbCtrl9, kbCtrl0:
                     if FMSetup.Options and fmoCtrlDifference <> 0 then
                           begin
                             if Visible[pLeft] and (ShiftState2 and 1 <> 0) then
                                Panel[pLeft].AnyPanel^.HandleEvent(Event) else
                                Panel[pRight].AnyPanel^.HandleEvent(Event);
                             Exit;
                           end;
}
        kbAltLeft, kbAltShiftLeft:
          SeparatorMove(-1);
        kbAltRight, kbAltShiftRight:
          SeparatorMove(1);
        kbAltCtrlSqBracketL, kbCtrlSqBracketL:
          InsertPath(pLeft);
        kbAltCtrlSqBracketR, kbCtrlSqBracketR:
          InsertPath(pRight);
      end {case};
    evBroadcast:
      case Event.Command of
        cmLookForPanels:
          ClearEvent(Event);
        cmGetUserParams, cmGetUserParamsWL:
          begin
          PP := Panel[not Selected].FilePanel;
          AP := Panel[Selected].FilePanel;
          with PUserParams(Event.InfoPtr)^ do
            begin
            AP^.GetUserParams(Active, ActiveList, Event.Command =
               cmGetUserParamsWL);
            PP^.GetUserParams(Passive, PassiveList, Event.Command =
               cmGetUserParamsWL);
            end;
          CE;
          end;
        cmChangeDirectory:
          begin
          Panel[Selected].FilePanel^.ChDir(PString(Event.InfoPtr)^);
          CE;
          end;
        cmChangeDrv: {�����ப� ⨯� C: ��� *: }
          begin
          Event.What := evCommand;
          Panel[Selected].FilePanel^.HandleEvent(Event);
          ClearEvent(Event);
          end;
        cmIsRightPanel:
          if Event.InfoPtr = Panel[pRight].FilePanel then
            ClearEvent(Event);
      end {case};
    evCommand:
      case Event.Command of

        cmSwitchOther:
          if not PanelZoomed then
            begin
            CE;
            SwitchPanel(not Selected);
            end;
        cmZoom:
          begin
          { Flash 05-02-2004 >>> }
          if Panel[Selected].PanelType = dtQView then
            begin
            GetBounds(OldBounds);
            GetBounds(OldPanelBounds);
            if (Size.X < Desktop.Size.X) or PanelZoomed then
              Message(@Self, evCommand, cmMaxi, nil);
            end;
          { Flash 05-02-2004 <<< }
          end;
        cmMaxi:
          begin
          CE;
          if (NonFilePanelType <> 0) and (NonFilePanel = Selected) then
            begin { ࠡ�� � ��䠩����� ������� }
            ToggleViewMaxiState(Panel[Selected].AnyPanel, not Selected);
            end
          else
            begin { ࠡ�� � 䠩����� ������� }
            with ActivePanel^.PanSetup^.Show do
              MiscOptions := MiscOptions xor 1;
            SetMaxiState(ActivePanel);
            end;
          end;
        cmGetName:
          begin
          PString(Event.InfoPtr)^:= GetString(dlFileManager);
          K := (55-Length(PString(Event.InfoPtr)^)) div 2;
          for N := pLeft to pRight do
            begin
            S := '??'; // �� ��砩, �᫨ ���� �� ��ࠡ�⠥� cmGetName
            Message(Panel[N].AnyPanel, evCommand, cmGetName, @S);
            PString(Event.InfoPtr)^:= PString(Event.InfoPtr)^+
              Cut({$IFDEF RecodeWhenDraw}CharToOemStr{$ENDIF}(S),K);
            if N = pLeft then
              PString(Event.InfoPtr)^:= PString(Event.InfoPtr)^+',';
            end;
          CE
          end;
        cmPostHideRight, cmPostHideLeft: {Ctrl-F1/F2 �� UserScreen}
          begin
          N := Event.Command = cmPostHideRight;
          if not Visible[N] then
            begin
            SwitchPanel(N);
            Visible[N] := True;
            end;
          if Visible[not N] then
            SwitchPanel(not N);
          CE
          end;
        cmChangeInactive: {� ������ ���᪠ Shift-Enter }
          begin
          Event.Command := cmFindGotoFile;
          with Panel[not Selected] do
            begin
            FilePanel^.HandleEvent(Event);
            if PanelType <> dtPanel then
              SwitchView(PanelType);
            end;
          CE;
          end;
        cmPanelCompare:
          Panel[not Selected].FilePanel^.HandleEvent(Event);
        cmDiskInfo:
          begin
          if isFilePanel then
            begin
            SwitchView(dtInfo);
            Message(Panel[Selected].AnyPanel, evCommand, cmLViewFile, nil)
            end;
          CE;
          end;
        {$IFDEF NETINFO}
        cmNetInfo:
          begin
          if isFilePanel then
            begin {-$VIV start}
            SwitchView(dtNetInfo);
            Message(Panel[Selected].AnyPanel, evCommand, cmLViewFile, nil)
            end; {-$VIV end}
          CE;
          end;
        {$ENDIF}
        cmLoadViewFile:
          if not PanelZoomed then
            begin
            if  (NonFilePanelType in [dtQView, dtDizView]){ and
              NonFilePanel^.GetState(sfVisible)}
            then
              Panel[NonFilePanel].AnyPanel^.HandleEvent(Event);
            CE;
            end;
        cmPushFullName,
        cmPushFirstName,
        cmPushInternalName:
          begin {< dblwnd.001 >}
          if Visible[not Selected] then
             Panel[not Selected].AnyPanel^.HandleEvent(Event);
          CE;
          Exit;
          end;
        cmFindTree,
        cmRereadTree:
          if NonFilePanelType = dtTree then
            Panel[NonFilePanel].AnyPanel^.HandleEvent(Event);
        cmHideLeft, cmHideRight:
          begin
          N := Event.Command = cmHideRight;
          if Visible[N] and not Visible[not N] then
            Message(Application, evCommand, cmShowOutput, nil)
          else
            SwitchPanel(N);
          CE
          end;
        cmChangeLeft:
          begin
          ChangeDrv(pLeft);
          CE
          end;
        cmChangeRight:
          begin
//          ChangeDrvRight;
          ChangeDrv(pRight);
          CE
          end;
        cmDirTree:
          begin
          if isFilePanel then
            SwitchView(dtTree);
          CE
          end;
        cmQuickView:
          begin
          if isFilePanel then
            begin
            SwitchView(dtQView);
            Message(Panel[Selected].AnyPanel, evCommand, cmLViewFile, nil);
            end;
          CE;
          end;
        cmDizView:
          begin
          if isFilePanel then
            begin
            SwitchView(dtDizView);
            Message(Panel[Selected].AnyPanel, evCommand, cmLViewFile, nil);
            end;
          CE;
          end;
        cmSwapPanels:
          if not PanelZoomed then
            begin
//            Lock;
            for N := pLeft to pRight do
              begin
              if not Visible[N] then
                SwitchPanel(N);
              Panel[N].AnyPanel^.GetBounds(WR[N]);
              WR[N].B.Y := Size.Y-1;
              end;
            WPanel := Panel[pLeft];
            Panel[pLeft] := Panel[pRight];
            Panel[pRight] := WPanel;
            NonFilePanel := not NonFilePanel;
            for N := pLeft to pRight do
              begin
              Panel[N].AnyPanel^.ChangeBounds(WR[N]);
              if not Visible[not N] then
                SwitchPanel(N);
              Panel[N].FilePanel^.SelfNum := N;
              end;
            Redraw;
//            UnLock;
            CE
            end;
      end {case};
  end {case};
  inherited HandleEvent(Event);
  end { TDoubleWindow.HandleCommand };

{ --------------------------- TSeparator ----------------------------- }

constructor TSeparator.Load;
  begin
  inherited Load(S);
  S.Read(OldX, 4);
  end;

procedure TSeparator.Store;
  begin
  inherited Store(S);
  S.Write(OldX, 4);
  end;

constructor TSeparator.Init;
  begin
  inherited Init(R);
  OldX := Origin.X+1;
  OldW := AH;
  EventMask := $FFFF;
  end;

procedure TSeparator.HandleEvent;
  var
    P: TPoint;
    R: TRect;
    RD: Integer;
    B: Byte;
  begin
  inherited HandleEvent(Event);
  case Event.What of
    evMouseDown:
      begin
      MakeLocal(Event.Where, P);
      B := P.X;
      RD := RepeatDelay;
      RepeatDelay := 0;
      repeat
        Owner^.MakeLocal(Event.Where, P);
        if  (P.X >= 1) and (P.X < Owner^.Size.X-2) then
          begin
          OldX := P.X+1-B;
          OldW := Owner^.Size.X;
          R.A := Owner^.Origin;
          R.B.X := Owner^.Origin.X+Owner^.Size.X;
          R.B.Y := Owner^.Origin.Y+Owner^.Size.Y;
          Owner^.ChangeBounds(R);
          end;
      until not MouseEvent(Event, evMouseAuto+evMouseMove);
      RepeatDelay := RD;
      ClearEvent(Event);
      end;
  end {case};
  end { TSeparator.HandleEvent };

procedure TSeparator.Draw;
  var
    B: array[0..128] of record
      C: Char;
      B: Byte;
      end;
    C: Word;
    Ch: Char;
  begin
  RK := Owner^.GetColor(2);
  if Owner^.GetState(sfActive) then
    C := RK
  else
    C := Owner^.GetColor(1);
  if Owner^.GetState(sfDragging) then
    C := Owner^.GetColor(3);
  B[0].B := C;
  B[Size.Y-1].B := C;
  if Owner^.GetState(sfActive) and not Owner^.GetState(sfDragging) then
    begin
    B[0].C := #187;
    Ch := #186;
    B[Size.Y-1].C := #188;
    end
  else
    begin
    B[0].C := #191;
    Ch := #179;
    B[Size.Y-1].C := #217;
    end;
  MoveChar(B[1], Ch, C, Size.Y-2);
  WriteBuf(0, 0, 1, Size.Y, B);
  if Owner^.GetState(sfActive) and not Owner^.GetState(sfDragging) then
    begin
    B[0].C := #201;
    B[Size.Y-1].C := #200;
    end
  else
    begin
    B[0].C := #218;
    B[Size.Y-1].C := #192;
    end;
  WriteBuf(1, 0, 1, Size.Y, B);
  end { TSeparator.Draw };

end.


