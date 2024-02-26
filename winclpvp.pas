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
{Writted by DataCompBoy at 29.07.2000 21:04:26}
{AK155 = Alexey Korop, 2:461/155@fidonet}
{Cat = Aleksej Kozlov, 2:5030/1326.13@fidonet}

{Cat
   28/08/2001 - ��।���� �㭪樨 ��� ᮢ���⨬��� � ⨯��� AnsiString �
   LongString, � ⠪�� ��� �����প� ������権 � �����묨 ��ப���

   05/09/2001 - �모�� NeedStream �� GetWinClip � SyncClipOut
}

unit WinClpVp;

interface

uses
  Defines, Streams, Collect
  ;

function SetWinClip(PC: PLineCollection): Boolean; {$IFDEF DPMI32}
  inline;
  begin {Cat:todo DPMI32}
  end; {$ENDIF}
function GetWinClip(var PCL: PLineCollection {; NeedStream: boolean})
  : Boolean; {$IFDEF DPMI32}
  inline;
  begin {Cat:todo DPMI32}
  end; {$ENDIF}
function GetWinClipSize: Boolean; {$IFDEF DPMI32}
  inline;
  begin {Cat:todo DPMI32}
  end; {$ENDIF}
procedure SyncClipIn; {$IFDEF DPMI32}
  inline;
  begin {Cat:todo DPMI32}
  end; {$ENDIF}
procedure SyncClipOut {(NeedStream: boolean)}; {$IFDEF DPMI32}
  inline;
  begin {Cat:todo DPMI32}
  end; {$ENDIF}

procedure CopyLines2Stream(PC: PCollection; var PCS: PStream);
{$IFDEF DPMI32} inline;
  begin {Cat:todo DPMI32}
  end; {$ENDIF}
procedure CopyStream2Lines(PCS: PStream; var PC: PCollection);
{$IFDEF DPMI32} inline;
  begin {Cat:todo DPMI32}
  end; {$ENDIF}

implementation

{$IFNDEF DPMI32}

uses
  {$IFDEF OS2}Os2Base, Dn2PmApi, {$ELSE}VpSysLow, {$ENDIF}
  Microed, Advance, Advance1, DnIni
  ;

procedure SyncClipIn;
  begin
  if ClipBoard <> nil then
    SetWinClip(PLineCollection(ClipBoard));
  end;

procedure SyncClipOut {(NeedStream: boolean)};
  begin
  GetWinClip(PLineCollection(ClipBoard) {, NeedStream});
  end;

{Cat: ������� ��ࠡ��� ������権 � �����묨 ��ப���}
function SetWinClip(PC: PLineCollection): Boolean;
  var
    B: PChar;
    idx: PChar;
    Size: LongInt;
    I, J: LongInt;
    P: PString; {AK155}
    PL: PLongString;
    S: LongString;
  begin
  Size := 0;

  if PC = nil then
    Exit; {Cat: ������樨 ����� � �� ����}

  if PC^.LongStrings then
    begin
    for I := 0 to PC^.Count-1 do
      begin
      PL := PC^.At(I);
      if PL = nil then
        Inc(Size, 2)
      else
        Inc(Size, Length(PL^)+2);
      end;
    end
  else
    {AK155 ��ࠢ���� �訡�� � ������ �����
(�� ���뢠����, �� � ������樨 ����� ���� nil) }
    begin
    for I := 0 to PC^.Count-1 do
      begin
      P := PC^.At(I);
      if P = nil then
        Inc(Size, 2)
      else
        Inc(Size, Length(P^)+2);
      end;
    end;
  {/AK}
  Dec(Size);
  GetMem(B, Size);
  idx := B;
  for I := 0 to PC^.Count-1 do
    begin
    if I > 0 then
      begin
      S := #$0D#$0A;
      Move(S[1], idx^, Length(S));
      Inc(idx, Length(S));
      end;
    if PC^.LongStrings then
      S := CnvLongString(PC^.At(I))
    else
      S := CnvString(PC^.At(I));
    {JO}
    for J := 1 to Length(S) do
      if S[J] = #0 then
        S[J] := ' ';
    {/JO}
    Move(S[1], idx^, Length(S));
    Inc(idx, Length(S));
    end;
  Byte(idx^) := 0;
  {$IFDEF OS2}
  SetWinClip := DN_XClipCopy(B, Size);
  {$ELSE}
  SetWinClip := SysClipCopy(B, Size);
  {$ENDIF}
  FreeMem(B, Size);
  end { SetWinClip };
{/Cat}

{AK155 GetWinClip ��९�ᠭ ���� ���������, ⠪ ��� � �����,
����� ��� ���⠫���, ��-�����, �� ࠡ�⠫�, � ��-�����,
������ �� �祭� �������� :) }
function GetWinClip(var PCL: PLineCollection {; NeedStream: boolean})
  : Boolean;
  var
    Size: LongInt;
    Buf: PChar;
    {idx : PChar;
      s: string;}
    Start, Stop: PChar;
    i: LongInt;
    {ODOA: boolean;}
    f0D: Boolean; { ⮫쪮 �� �� 0D }

    {Cat: ��९�ᠫ ��� ᮢ���⨬��� � ⨯��� AnsiString � LongString
      ������� ��ࠡ��� ������権 � �����묨 ��ப���}

    { ⥪�� �� Start^ (�����⥫쭮) �� Stop^ (�᪫��⥫쭮)
     �८�ࠧ����� � ��ப� � �������� � PCL }
  procedure Str2Collection;
    var
      l: LongInt;
      P: PString;
      PL: PLongString;
    begin
    l := Stop-Start;
    if l = 0 then
      with PCL^ do
        AtInsert(Count, nil)
    else if PCL^.LongStrings then
      begin
      New(PL);
      SetLength(PL^, l);
      Move(Start^, PL^[1], l);
      with PCL^ do
        AtInsert(Count, PL);
      end
    else
      begin
      GetMem(P, l+1);
      SetLength(P^, l);
      Move(Start^, P^[1], l);
      with PCL^ do
        AtInsert(Count, P);
      end;
    Start := Stop+1;
    end { Str2Collection };
  {/Cat}

  begin { GetWinClip }
  GetWinClip := False;
  {$IFDEF OS2}
  if not DN_XClipCanPaste then
  {$ELSE}
  if not SysClipCanPaste then
    {$ENDIF}
    Exit;
  {$IFDEF OS2}
  Buf := DN_XClipPaste(Size);
  {$ELSE}
  Buf := SysClipPaste(Size);
  {$ENDIF}
  if Buf = nil then
    Exit;
  GetWinClip := True;

  if PCL <> nil then
    PCL^.FreeAll
  else
    New(PCL, Init($10, $10, True));

  Start := Buf;
  Stop := Start;

  for i := 1 to Size-1 do
    begin
    case Stop^ of
      #$0D:
        begin
        Str2Collection;
        f0D := True;
        end;
      #$0A:
        begin
        if f0D then
          Inc(Start)
        else
          Str2Collection;
        f0D := False;
        end;
      else {case}
        f0D := False;
    end {case};
    Inc(Stop);
    end;
  Str2Collection;
  {/AK155}

  {$IFDEF OS2}
  DosFreeMem(Buf);
  {$ELSE}
  FreeMem(Buf, Size);
  {$ENDIF}
  Buf := nil;
  Size := 0;

  {Cat: �ਢ���� � �㡫�஢���� ��ப � Clipboard-�
      � ��砥 �ᯮ�짮����� "⥪�⮢��� ���� ��⥬�"
      � १���� �모�뢠��� �������� ������ �����
      ���, �.�. � ��᮫�⭮ �� �������, ����� ᯮᮡ
      ࠡ��� Clipboard-� �������� ����� �ࠢ����...}
  (*
   if NeedStream then begin
     I := 0;
     if ClipBoardStream<>nil then
      ClipBoardStream^.Seek(Max(ClipBoardStream^.GetPos-{$IFDEF USELONGSTRING} 4 {$ELSE} 1 {$ENDIF}, 0));
     CopyLines2Stream( PCL, ClipBoardStream );
   end;
*)
  end { GetWinClip };

function GetWinClipSize: Boolean;
  begin
  {$IFDEF OS2}
  GetWinClipSize := DN_XClipCanPaste;
  {$ELSE}
  GetWinClipSize := SysClipCanPaste;
  {$ENDIF}
  end;

{Cat: ������� ��ࠡ��� ������権 � �����묨 ��ப���}
procedure PackLinesStream(var PCS: PStream); {-$VOL begin}
  var
    ps: PString;
    pls: PLongString;
    sp: TFileSize;
    MS: PStream;
    LongStrings: Boolean;
    TempString: String;
    TempLongString: LongString;
  begin
  sp := PCS^.GetSize-cbSize;
  PCS^.Seek(0);
  PCS^.Read(LongStrings, 1); {�⠥� 䫠��� "��������" ��ப}
  if LongStrings then
    while PCS^.GetPos < sp do
      begin
      (*
        pls:=PCS^.ReadLongStr;
        DisposeLongStr(pls);
*)
      PCS^.ReadLongStrV(TempLongString);
      end
  else
    while PCS^.GetPos < sp do
      begin
      (*
        ps:=PCS^.ReadStr;
        DisposeStr(ps);
*)
      PCS^.ReadStrV(TempString);
      end;

  MS := GetMeMemoStream;
  if MS = nil then
    Exit;
  MS^.Write(LongStrings, 1); {��襬 䫠��� "��������" ��ப}
  if LongStrings then
    while (PCS^.GetPos < PCS^.GetSize) do
      begin
      pls := PCS^.ReadLongStr;
      MS^.WriteLongStr(pls);
      DisposeLongStr(pls);
      end
  else
    while (PCS^.GetPos < PCS^.GetSize) do
      begin
      ps := PCS^.ReadStr;
      MS^.WriteStr(ps);
      DisposeStr(ps);
      end;
  Dispose(PCS, Done);
  PCS := MS;
  end { PackLinesStream }; {-$VOL end}

procedure CopyLines2Stream(PC: PCollection; var PCS: PStream);
  {-$VOL begin}
  var
    i: LongInt;
    P: PLineCollection absolute PC;
    Pos: TFileSize;
    LongStrings: Boolean;
    TempString: String;
    TempLongString: LongString;
  begin
  if PC = nil then
    Exit;
  if PCS = nil then
    PCS := GetMeMemoStream;
  if PCS = nil then
    Exit;
  Pos := PCS^.GetPos;
  if Pos = 0 then
    begin
    LongStrings := P^.LongStrings;
    PCS^.Write(LongStrings, 1) {��襬 䫠��� "��������" ��ப}
    end
  else
    with PCS^ do
      begin {���ࣨ���� ����ᠭ�� �����-� ����� � ᠬ��}
      Seek(0); {��砫� ��⮪� 䫠��� "��������" ��ப}
      Read(LongStrings, 1);
      Seek(Pos);
      end;
  if LongStrings then
    if P^.LongStrings then
      begin {��襬 ������ ��ப� �� ������樨 � ������ ��ப� ��⮪�}
      for i := 0 to P^.Count-1 do
        begin
        TempLongString := CnvLongString(P^.At(i));
        if TempLongString = '' then
          TempLongString := ' ';
        PCS^.WriteLongStr(@TempLongString);
        end;
      PCS^.WriteLongStr(nil);
      end
    else
      begin
      {��襬 ���⪨� ��ப� �� ������樨 � ������ ��ப� ��⮪�}
      for i := 0 to P^.Count-1 do
        begin
        TempLongString := CnvString(P^.At(i));
        if TempLongString = '' then
          TempLongString := ' ';
        PCS^.WriteLongStr(@TempLongString);
        end;
      PCS^.WriteLongStr(nil);
      end
  else if P^.LongStrings then
    begin {��襬 ������ ��ப� �� ������樨 � ���⪨� ��ப� ��⮪�}
    for i := 0 to P^.Count-1 do
      begin
      TempString := CnvLongString(P^.At(i));
      if TempString = '' then
        TempString := ' ';
      PCS^.WriteStr(@TempString);
      end;
    PCS^.WriteStr(nil);
    end
  else
    begin {��襬 ���⪨� ��ப� �� ������樨 � ���⪨� ��ப� ��⮪�}
    for i := 0 to P^.Count-1 do
      begin
      TempString := CnvString(P^.At(i));
      if TempString = '' then
        TempString := ' ';
      PCS^.WriteStr(@TempString);
      end;
    PCS^.WriteStr(nil);
    end;
  if  (PCS^.GetSize > cbSize) and (P^.Count > 1) then
    PackLinesStream(PCS);
  end { CopyLines2Stream }; {-$VOL end}

procedure CopyStream2Lines(PCS: PStream; var PC: PCollection);
  {-$VOL begin}
  var
    PS: PString;
    PLS: PLongString;
    LongStrings: Boolean;
  begin
  if PCS = nil then
    Exit;
  PCS^.Seek(0);
  PCS^.Read(LongStrings, 1); {�⠥� 䫠��� "��������" ��ப}
  if PC = nil then
    PC := New(PLineCollection, Init(50, 5, LongStrings));
  if PC = nil then
    Exit;
  if LongStrings then
    begin
    PLS := PCS^.ReadLongStr;
    while (PLS <> nil) and not PCS^.Eof do
      begin
      if PLS^ = ' ' then
        PLS^:= '';
      PC^.AtInsert(0, PLS);
      if  (PCS^.GetPos > cbSize) and (PC^.Count > 1) then
        PC^.AtFree(0);
      PLS := PCS^.ReadLongStr;
      end;
    end
  else
    begin
    PS := PCS^.ReadStr;
    while (PS <> nil) and not PCS^.Eof do
      begin
      if PS^ = ' ' then
        PS^:= '';
      PC^.AtInsert(0, PS);
      if  (PCS^.GetPos > cbSize) and (PC^.Count > 1) then
        PC^.AtFree(0);
      PS := PCS^.ReadStr;
      end;
    end;
  PC^.Pack;
  end { CopyStream2Lines }; {-$VOL end}
{/Cat}

{$ENDIF}

end.
