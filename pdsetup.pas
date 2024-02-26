{AK155 = Alexey Korop, 2:461/155@fidonet}

unit PDSetup;
  { ⨯� � ��६����, �易��� � 䠩���묨 �����ﬨ �
    ��⠢����묨 � ��� ��᪠�� }

{$I stdefine.inc}

interface

uses
  Commands;

type
  TPanelShowSetup = record
  {` ���� ������ ������� ����஥� ���� ������ dlgPanelShowSetup }
    ColumnsMask: Word; {Checkbox[11]}
    DirRegister: Word; {Combo}
    FileRegister: Word; {Combo}
    LFNLen: String[3];
    EXTLen: String[3];
    TabulateExt: Word; {Combo}
    NoTabulateDirExt: Word; {Checkbox[1]}
    ShowCurFile: Word; {Checkbox[1]}
    CurFileNameType: Word; {Combo}
    SelectedInfo: Word; {Combo}
    FilterInfo: Word; {Combo}
    PathDescrInfo: Word; {Combo}
    PackedSizeInfo: Word; {Combo}
    BriefPercentInfo: Word; {Combo}
    LFN_InFooter: Word; {Combo}
    TotalsInfo: Word; {Combo}
    FreeSpaceInfo: Word; {Combo}
    MiscOptions: Word; {` Checkbox[2]: ZoomPanel, ShowTitles `}
    end;
  {`}

  TPanelSortSetup = record
  {` ���� ������ ������� ����஥� ���஢�� ������ dlgPanelSortSetup }
    SortMode: Word;
    SortFlags: Word;
    Ups: array[1..4] of Word;
    CompareMethod: Word;
    end;
  {`}

  PPanelSetup = ^TPanelSetup;
  {`2 ���� ����஥� ������ }
  TPanelSetup = record
    Show: TPanelShowSetup;
    Sort: TPanelSortSetup;
    FileMask: String;
    end;
  {`}

  TPanelClass = (pcDisk, pcList, pcArc, pcArvid);
    {` ������ 䠩����� �������, ��� ������� �� ������ �������
     ᢮� ���� ����஥� ⨯� TPanelSetup `}

  PPanelSetupSet = ^TPanelSetupSet;
    {`2 ����� ����� ����஥� ��� ��� ����ᮢ ������� }
  TPanelSetupSet = array[TPanelClass] of TPanelSetup;
  {`}

  TDriveType = (dtUndefined, dtDisk, dtFind, dtTemp, dtList, dtArcFind,
       dtArc, dtNet, dtLink, dtArvid);

var
  PanSetupPreset: array[1..10] of TPanelSetupSet;
    {` 10 ������ ����஥�, ����� �롨����� �� Ctrl-��� `}

const
  dt2pc: array[TDriveType] of TPanelClass =
    (pcDisk, pcDisk, pcList, pcList, pcList, pcList,
     pcArc, pcDisk, pcDisk, pcArvid);

const // ���祭��
{$IFDEF DualName}
  cfnTypeOther = 0;
    {` ���祭�� CurFileNameType "�� ⠪��, ��� � ������" `}
  cfnAlwaysLong = 1;
{$ELSE}
  cfnAlwaysLong = 0;
    {` ���祭�� CurFileNameType "�ᥣ�� �������" `}
{$ENDIF}
  cfnHide = cfnAlwaysLong+1;
    {` ���祭�� CurFileNameType "�� �����뢠��" `}

type
  TFileColWidht = array[TFileColNumber] of ShortInt;
    {` ��ਭ� ������� (�஬� �����).
      ��� ������� ����࠭�祭��� �ਭ� (����, ���ᠭ��) �ਭ� -1.
      ��� ������� �६���, �ਭ� ���ன ������ �� ��⠭���� ��࠭�,
    �ਭ� �����⢥��� -2 (䠪��᪨ - 6 �� 24-�ᮢ�� � 7 ��
    12-�ᮢ�� �ଠ�).
      ����室��� ᮣ��ᮢ�������:
       - ���浪� ���祭�� � �⮬ ���ᨢ�,
       - ��⮢�� ��᮪ �த� psShowDescript,
       - ࠡ��� �㭪権, �ନ����� ᮮ⢥�����騥 ��ப� � ��������
         (GetFull, MakeDate, FileSizeStr).
      �� ������砥� ⠪��, �� �� ����⨯�� ������� (���� � �६���)
    ����� ���������� �ਭ�.
     `}
  TFileColAllowed = array [TFileColNumber] of Boolean;
    {` �����⨬���� ������� ��� ������� ⨯� ������ `}

const
  FileColWidht: TFileColWidht =
{Size  PSize Ratio Date Time CrDate CrTime LaDate LaTime Descr Path}
 (10,  11,   4,    9,   -2,  9,     -2,    9,     -2,    -1,   -1);

  PanelFileColAllowed: array[TPanelClass] of TFileColAllowed =
  ( {pcDisk}
 (True, False,False, True,True,True, True, True,  True,  True,  False)
  , {pcList}
 (True, False,False, True,True,True, True, True,  True,  False, True)
  , {pcArc}
 (True, True, True, True,True,False,False,False, False, False, False)
  , {pcArvid}
 (True, False,False, True,True,False,False,False, False, True,  False)
  );

procedure DefaultInit;
{` ��� �뫮 ���� �믨�뢠�� �������� ����⠭�� � �ᥬ�
����ன���� ��� ०����, ���⮬� � ����騫 � ���� ����ப�
������� � ���� �ᯮ����⥫쭮� ����⠭�, � ���������� ���⮢
ᤥ��� �ணࠬ��� DefaultInit. ����� ��� ��뢠���� ⮫쪮 ��
���樠����樨, �� �� ��砥 ����� �㤥� ᤥ���� �� �맮� ��
(�����) ������� "����⠭����� 㬮�砭��". `}

implementation

const
  ColumnsDefaults: array[TPanelClass] of array[1..10] of
    record
      Param: Word;
      LFNLen: String[3];
      EXTLen: String[3];
      end =
  (
(*
  psShowSize = $0001;
  psShowDate = $0002;
  psShowTime = $0004;
  psShowCrDate = $0008;
  psShowCrTime = $0010;
  psShowLADate = $0020;
  psShowLATime = $0040;
  psShowDescript = $0080;
  psShowDir = $0100;
  psShowPacked = $0200;
  psShowRatio = $0400;
*)
//  ColumnsDefaultsDisk1
    ((Param: 0; LFNLen: '12'; EXTLen: '3'),
     (Param: $7FF; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '18'; EXTLen: '4'),
     (Param: 0; LFNLen: '18'; EXTLen: '0'),
     (Param: 0; LFNLen: '38'; EXTLen: '4'),
     (Param: 0; LFNLen: '252'; EXTLen: '0'),
     (Param: psShowSize; LFNLen: '252'; EXTLen: '0'),
     (Param: psShowDescript; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '12'; EXTLen: '3')
    ),

//  ColumnsDefaultsFind
    ((Param: psShowDir; LFNLen: '12'; EXTLen: '3'),
     (Param: $7FF; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '18'; EXTLen: '4'),
     (Param: 0; LFNLen: '18'; EXTLen: '0'),
     (Param: 0; LFNLen: '38'; EXTLen: '4'),
     (Param: 0; LFNLen: '252'; EXTLen: '0'),
     (Param: psShowSize; LFNLen: '252'; EXTLen: '0'),
     (Param: psShowDir; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '12'; EXTLen: '3')
    ),

//  ColumnsDefaultsArch
    ((Param: 0; LFNLen: '12'; EXTLen: '3'),
     (Param: $7FF; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '18'; EXTLen: '4'),
     (Param: 0; LFNLen: '18'; EXTLen: '0'),
     (Param: 0; LFNLen: '38'; EXTLen: '4'),
     (Param: 0; LFNLen: '252'; EXTLen: '0'),
     (Param: psShowSize+psShowPacked+psShowRatio;
        LFNLen: '252'; EXTLen: '0'),
     (Param: psShowSize+psShowPacked+psShowRatio;
        LFNLen: '12'; EXTLen: '3'),
     (Param: psShowRatio; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '12'; EXTLen: '3')
    ),

//  ColumnsDefaultsArvd:
    ((Param: 0; LFNLen: '12'; EXTLen: '3'),
     (Param: $7FF; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '18'; EXTLen: '4'),
     (Param: 0; LFNLen: '18'; EXTLen: '0'),
     (Param: 0; LFNLen: '38'; EXTLen: '4'),
     (Param: 0; LFNLen: '252'; EXTLen: '0'),
     (Param: psShowSize; LFNLen: '252'; EXTLen: '0'),
     (Param: psShowDescript; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '12'; EXTLen: '3'),
     (Param: 0; LFNLen: '12'; EXTLen: '3')
    )
  );

procedure DefaultInit;
  var
    i: Integer;
    pc: TPanelClass;
  begin
  FillChar(PanSetupPreset, SizeOf(PanSetupPreset), 0);
  for i := 1 to 10 do
    for pc := Low(TPanelClass) to High(TPanelClass) do
      with PanSetupPreset[i][pc] do
        begin
        FileMask := '*.*';
        Show.ColumnsMask  := ColumnsDefaults[pc][i].Param
           {$IFDEF DualName} or psLFN_InColumns {$ENDIF} ;
        Show.LFNLen := ColumnsDefaults[pc][i].LFNLen;
        Show.ExtLen := ColumnsDefaults[pc][i].ExtLen;
        if Show.ColumnsMask <> 0 then
          Show.MiscOptions := 2; { ��������� ������� }

        Show.TabulateExt := 3; {�ᥣ��}
        Show.FilterInfo := fseInDivider;
        Show.ShowCurFile := 1;
        Show.SelectedInfo := fseInDivider;
        Sort.SortMode := psmLongExt;
        Sort.CompareMethod := 2; { �� ������ ॣ���� }
        Sort.Ups[1] := upsDirs;
        end;
  end;

begin
DefaultInit;
end.

