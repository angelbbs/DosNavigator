{ Win32-specific country tools unit by A.Korop (AK155)}
{$IFNDEF Win32} This is the Win32 version! {$ENDIF}
unit Country_;

interface
uses
  Defines;

procedure QueryUpcaseTable;

procedure GetSysCountryInfo;

function QueryToAscii(CP: word; var ToAscii: TXLat): Boolean;

function QueryABCSort(CP: Word; var ABCSortXlat: TXLat): Boolean;

implementation

uses
  Windows, advance, advance1, strings, U_KeyMap
  ;

{ AK155 �⮡� ������� ⠡���� ��ॢ��� �� ���孨� ॣ���� ��� ����஢��
OEM, � �� ���� ��祣� ����, 祬 ��४���஢��� ����� ᨬ����� � ANSI,
��ॢ��� �� ���孨� ॣ���� � ANSI � ��४���஢��� ���⭮. �� �⮬
��室���� ������� � ᨬ������, ����� �� ��४��������� �㤠-�
(���ਬ��, �ᥢ����䨪�). �� ��⠥� �� �㪢���, � ���� �� ����騬�
ࠧ���� ���孥�� � ������� ॣ����.
  ������ �� ��諮�� �१ OEM, � �� �१ ���, ⠪ ��� � Win9x
��� ��ॢ��� �� ���孨� ॣ���� � ����.
  �᫨ ��-� 㬥�� ᮧ���� ��� ⠡���� ����� 樢���������� - ������
��ᨬ. }

procedure QueryUpcaseTable;
  const
    LT = SizeOf(TXLat);
  var
    CommonChars: TXLat;
    C: Char;
  begin
  NullXlat(UpCaseArray);
  OemToCharBuff(@UpCaseArray, @UpCaseArray, LT);
  CharUpperBuff(@UpCaseArray, LT);
  CharToOemBuff(@UpCaseArray, @UpCaseArray, LT);

  NullXlat(CommonChars);
  OemToCharBuff(@CommonChars, @CommonChars, LT);
  CharToOemBuff(@CommonChars, @CommonChars, LT);

  for C := Low(TXLat) to High(TXLat) do
    begin
    if C <> CommonChars[C] then
      UpcaseArray[C] := C;
    end;
  end;

var
  ResBuf: array[0..7] of char; // १���� GetInfoElement, ASCIIZ

procedure GetInfoElement(ElType: LCTYPE);
  var
    l: Longint;
  begin
  l := GetLocaleInfo(
    LOCALE_USER_DEFAULT, // LCID Locale,      // locale identifier
    ElType,  // information type
    @ResBuf, //LPTSTR lpLCData,  // information buffer
    SizeOf(ResBuf)//int cchData       // size of buffer
  );
  CharToOem(@ResBuf, @ResBuf);
  end;

procedure GetSysCountryInfo;
  begin
  with CountryInfo do
    begin
    GetInfoElement(LOCALE_IDATE );
    DateFmt := byte(ResBuf[0]) - byte('0');

    GetInfoElement(LOCALE_ITIME);
    TimeFmt := byte(ResBuf[0]) - byte('0');

    GetInfoElement(LOCALE_SDATE);
    DateSep := ResBuf[0];

    GetInfoElement(LOCALE_STIME);
    TimeSep := ResBuf[0];

    GetInfoElement(LOCALE_STHOUSAND);
    ThouSep := ResBuf[0];
    if ThouSep = #255 then
      ThouSep := ' '; // �� ��ࠧ��� �஡��?

    GetInfoElement(LOCALE_SDECIMAL);
    DecSep := ResBuf[0];

    GetInfoElement(LOCALE_ICURRDIGITS);
    DecSign := ResBuf[0];

    GetInfoElement(LOCALE_SCURRENCY);
    Currency := StrPas(ResBuf);

    GetInfoElement(LOCALE_ICURRENCY);
    CurrencyFmt := byte(ResBuf[0]) - byte('0');
    end;
  end;

function QueryToAscii(CP: word; var ToAscii: TXLat): Boolean;
  const
    LT = SizeOf(TXLat);
  var
    UniString, UniStringBack: array[0..LT-1] of WChar;
    i: Integer;
    l: Longint;
  begin
  NullXlat(ToAscii);
  l := MultiByteToWideChar(CP, 0,
    @ToAscii, LT,
    @UniString, LT);
  Result := l=LT;

  l := WideCharToMultiByte(CP_OEMCP, 0,
    @UniString, LT,
    @ToAscii, LT,
    nil, nil);
  Result := Result and (l=LT);

{  ����᫥���饥 蠬���⢮ �㦭� ��� ��祬.
   �� ��४���஢���� �� ���� � 1-������ ����஢�� �� 㬮�砭��
��⥬� ����뢠�� �������� ����: ����� ᨬ����, �� ���騥
�筮�� ��ॢ���, �� ����騥 "��宦��" ��ॢ��, ��ॢ������ � �� ᠬ�
"��宦��" ᨬ����. � १���� ⠡��� ToAscii ����뢠����
���������筮�, �� �ਢ���� � �����⭮��� �� ����஥��� ���⭮�
⠡����. ��� ����� ����� �⪫���� �� ����� 䫠��
WC_NO_BEST_FIT_CHARS, �� �� ࠡ�⠥� ⮫쪮 ��� NT 5. ��� � ��室����
������� ����஥���� ⠡���� �� ���������筮�⥩.
   �ᯮ�짮����� "?" � ����⢥ ������⥫� "����ॢ������" ᨬ�����
������᭮, ⠪ ��� ��� ��� �����筮 �����쪨�, � ����஥��� ���⭮�
⠡���� ���� �� ������ ����� � ����訬.
}
  l := MultiByteToWideChar(CP_OEMCP, 0,
    @ToAscii, LT,
    @UniStringBack, LT);
  Result := Result and (l=LT);

  for i := 0 to LT-1 do
    if UniString[i] <> UniStringBack[i] then
      ToAscii[Char(i)] := '?';
  end;

function QueryABCSort(CP: Word; var ABCSortXlat: TXLat): Boolean;
  begin
  Result := False; //!! ���� �� ॠ�������� (04.09.2005)
  end;

end.
