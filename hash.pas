unit Hash;

interface
uses
  Collect, Objects2;

type
  THashIndex = Longint;
  THashTable = array[0..0] of THashIndex;

  PHash = ^THash;
  {`2 ���-⠡���, ������筠� � ������樨. ��������� ��᫥
  ���������� ������樨, ⠪ ��� �ॡ�� ������ �����⥫쭮��
  �᫠ ����⮢. �ᯮ������ ��� �祭� ����ண� ���᪠
  ����� � ������樨, ���筮 �����஢�����.
     ��� ࠧ�襭�� �������� �ᯮ������ ���஢����,
  ���⮬� ��९������� ��-⠡���� ��᮫�⭮ �������⨬�,
  � ���� ������ ���������� ���쬠 ������⥫쭮.
    ������ ��-⠡���� - �⥯��� 2, �ॢ����� �᫮ ����⮢
  �� 10% ��� �����. �᫨ �� ᮧ����� ��� ⠪�� ⠡���� ��
  墠�� �����, ��᫥ Init �㤥� HT=nil.
  `}
  THash = object(TObject)
    HT: ^THashTable;
      {` ���-⠡���.
      ����ন� ������� � Items^ ��� EmptyIndex (᢮�����) `}
    Count: Integer;
      {` ��᫮ ����⮢ HT`}
    Items: PItemList;
      {` ����� Items ������樨 `}
    hf: integer;
      {` ������ � HT, 0..Count-1 `}
    RehashStep: integer;
      {` ��� ���஢���� ��᫥����� ���᪠. ����஢����
      �������� �ਡ�������� �⮣� 蠣� �� ����� ࠧ���� HT.
      ��� ������ ���� ������� ���� � Count, � ����, ��᪮���
      Count - �⥯��� ������, RehashStep ������ ���� ������ `}
    procedure Hash(Item: Pointer); virtual;
      {` �� �᭮����� ᮤ�ন���� Item^ �������� ���⮢�
      ��-������ hf � 蠣 ���஢���� RehashStep.
      ��� ��⮤ ��易⥫쭮 ���� ��४����.`}
    function Equal(Item1, Item2: Pointer): Boolean; virtual;
      {` ��������� �� ���� Item1^ � Item2^.
      ��� ��⮤ ��易⥫쭮 ���� ��४����. `}
    constructor Init(BaseColl: PCollection);
      {` १�ࢨ஢���� ����� ��� HT^ � ���⪠ HT `}
    function GetHashIndex(Item: Pointer; var N: THashIndex): Boolean;
      {` ���� ����� � ��-⠡���.
      �᫨ ������ (१���� True) N - ������ � HT.
      �᫨ �� ������  (१���� False) N - ������ � HT, �㤠
      ��� ���� �������. `}
    function AddItem(CollIndex: Integer): Boolean;
      {` ������ � ��-⠡���� ������ ����� Items^[CollIndex]^.
      ������� False, �᫨ ����� c ⠪�� ���箬 㦥 ���� `}
    destructor Done; virtual;
    end;

implementation

const
  EmptyIndex = $FFFFFFFF;

constructor THash.Init(BaseColl: PCollection);
  var
    Size: Longint;
    MinCount: Integer;
  begin
  inherited Init;
  MinCount := BaseColl^.Count * 11 div 10; // ����� 10%
  Count := 1024;
  while Count < MinCount do
    Count := Count*2;
  Size := Count * SizeOf(Longint);
  GetMem(HT, Size);
  if HT <> nil then
    FillChar(HT^, Size, $FF);
  Items := BaseColl^.Items;
  end;

destructor THash.Done;
  begin
  if HT <> nil then
    FreeMem(HT);
  inherited Done;
  end;

procedure THash.Hash(Item: Pointer);
  begin
  RunError(211);
  end;

function THash.Equal(Item1, Item2: Pointer): Boolean;
  begin
  RunError(211);
  end;

function THash.GetHashIndex(Item: Pointer; var N: THashIndex): Boolean;
  begin
  Hash(Item);
  while True do
    begin
    N := HT^[hf];
    if N = EmptyIndex then
      begin
      Result := False;
      Break; { �� ��諨 }
      end;
    if Equal(Item, Items^[N]) then
      begin
      Result := True;
      Break; { ��諨 }
      end;
    { ���஢���� }
    hf := (hf + RehashStep) mod Count;
    end;
  { �� ��諨 }
  end;

function THash.AddItem(CollIndex: Integer): Boolean;
  var
    N: THashIndex;
  begin
  Result := not GetHashIndex(Items^[CollIndex], N);
  if Result then
    HT^[hf] := CollIndex;
  end;

end.
