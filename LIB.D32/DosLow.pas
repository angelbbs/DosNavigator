unit DosLow;

interface

var {���� 1024-���⭮� ࠡ�祩 ������, �ᯮ��㥬�� ��� �裡
  � real mode ���뢠��ﬨ. �� ������� �।���������� �ᥣ��
  ᢮������, ⠪ �� �࠭��� ����� � �⮩ ������ �����. }

  DosSeg: SmallWord;
    {Real mode segment; far16 ���� ������� ���� DosSeg:0}
  DosSegFlat: Pointer;
    {Flat ���� ������ }

implementation

uses
  dpmi32df, dpmi32;

begin
getdosmem(DosSeg, 1024);
DosSegFlat := Ptr(dosseg_linear(DosSeg));
end.

