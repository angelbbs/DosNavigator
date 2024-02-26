{/////////////////////////////////////////////////////////////////////////
//
//  Dos Navigator/2 Open Source
//
//  This unit is free for commercial and non-commercial use as long as
//  the following conditions are aheared to.
//
//  Any Copyright notices in the code are not to be removed.
//
//  Redistribution and use in source forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//
//  1. Redistributions of source code must retain the copyright
//     notice and this list of conditions.
//  2. All advertising materials mentioning use of this unit must
//     display or contain in online help or documentation the following
//     acknowledgement:
//     "Based on Dos Navigator/2 Open Source"
//
//  The licence and distribution terms for any publically available
//  version or derivative of this code cannot be changed. i.e. this code
//  cannot simply be copied and put under another distribution licence
//  (including the GNU Public Licence).
//
//////////////////////////////////////////////////////////////////////////}
{$I STDEFINE.INC}
{(c) Alexey Korop (AK155), 2002, 2007}
unit Calculat;
{&Delphi+}

interface
uses
  Commands
  ;

type
  CReal = Extended;
  PCReal = ^CReal;

function Evalue(const s: String; CCV: Pointer): CReal;
{��ࠬ��� CCV ࠢ�� nil ��� ���⮣� ���᫨⥫�. �� �맮��
�� ���஭��� ⠡���� - �� PCalcView. � �⮬ ��砥
� �㭪�� ���������� SUM � MUL, � � ���࠭���
����������� ����� �祥� }

function GetErrOp(var x: Integer): String;

var
  EvalueError: Boolean;
  CalcErrMess: TStrIdx;
  CalcErrPos: LongInt;
  Res: CReal;
  CalcSym: String;

var
  MultR: String;
    { �����⥫� �⥯���� 10 � ��樮���쭮� ������祭��,
    �� 3 ᨬ����, ���� � �ன�� - �஡��. ������ ����樮���
    ᮮ⢥��⢮���� ᫥���騬 ����㭠த�� ������祭�� �,
    ᮮ⢥��⢥���, �⥯��� 10:
          ' d  �  m  u  p  n  f  da k  M  G  T  P ';
           -1 -2 -3 -6 -9 -12-15 1  3  6  9  12 15
      ���ਬ��, ��� ���᪮�� �� ��ப� ����� ����� ���:
          ' �  �  �  �� �  �  �  �� �  �  �  �  � '
    �᫨ ��樮����� ������祭�� �� �㦭�, ��⠢��� MultR=''.
    }

implementation

uses
  Advance1
  , math, sysutils
{$IFDEF SpreadSheet}
  , Calc
{$ENDIF}
  ;

var
  Expression: String;
{$IFDEF SpreadSheet}
  CurCalcView: PCalcView;
{$ENDIF}

  { ��᫮ � 㪠������ ��⥬� ��童��� }
function GetV(S: String; Base: Integer; var Value: CReal): Boolean;
  const
    HexDigits = '0123456789ABCDEFG';
  var
    RR, FractValue: CReal;
    j: Byte;
    c, MaxC: Char;
    d: LongInt;
  begin
  Result := False;
  if Length(S) = 0 then
    Exit;
  RR := 0;
  UpStr(S);
  {楫�� ����}
  for j := 1 to Length(S) do
    begin
    c := System.UpCase(S[j]);
    if c = '.' then
      Break;
    d := Pos(c, HexDigits)-1;
    if  (d < 0) or (d >= Base) then
      Exit;
    RR := RR*Base+d;
    end;
  Delete(S, 1, j);
  if  (Length(S) < 1) then
    begin
    Value := RR;
    Result := True;
    Exit
    end;
  {�஡��� ����}
  FractValue := 1;
  for j := 1 to Length(S) do
    begin
    FractValue := FractValue/Base;
    d := Pos(S[j], HexDigits)-1;
    if  (d < 0) or (d >= Base) then
      Exit;
    RR := RR+d*FractValue;
    end;
  Value := RR;
  Result := True;
  end { GetV };

{ ��᫥ �����筮�� �᫠ ��� �஡��� ����� ���� ������� �����⥫�
(��直� ����- ����- � �.�.). �����⥫� �ᯮ������� ����㭠த��
(u=����) � ���᪨�. �����⥫� '����' ���������, ⠪ ��� ���
����㭠த��� ������祭�� 'h' ���䫨���� � ��ᥬ���୮� �ମ�
��⭠����筮�� �᫠ }
function GetDec(S: String; var Value: CReal): Boolean;
  const
    MultE = ' d  �  m  u  p  n  f  da k  M  G  T  P ';
    //       -1 -2 -3 -6 -9 -12-15 1  3  6  9  12 15
    MultV: array[1..Length(MultE) div 3] of CReal =
      (1e-1, 1e-2, 1e-3, 1e-6, 1e-9, 1e-12, 1e-15
      , 1e1, 1e3, 1e6, 1e9, 1e12, 1e15);
  var
    R: Integer;
    l: LongInt;
    m: String;
  begin
  Val(S, Value, R);
  if  (R <> 0) then
    begin
    m := ' '+Copy(S, R, 255)+' ';
    l := Pos(m, MultE);
    if (l = 0) and (Length(MultE) = Length(MultR)) then
      l := Pos(m, MultR);
    if l <> 0 then
      begin
      SetLength(S, R-1);
      Val(S, Value, R);
      Value := Value*MultV[(l+2) div 3];
      end;
    end;
  Result := R = 0;
  end { GetDec };

function GetValue(S: String; var Value: CReal): Boolean;
  var
    BaseChar: Char;
  begin
  BaseChar := UpCase(S[Length(S)]);
  if  (BaseChar = 'H') then
    begin
    SetLength(S, Length(S)-1);
    GetValue := GetV(S, 16, Value);
    end
  else if S[1] = '$' then
    begin
    Delete(S, 1, 1); {DelFC(S);}
    GetValue := GetV(S, 16, Value)
    end
  else if (UpStrg(Copy(S, 1, 2)) = '0X') then
    GetValue := GetV(Copy(S, 3, 255), 16, Value)
  else if (BaseChar in ['O', 'Q']) then
    begin
    SetLength(S, Length(S)-1);
    GetValue := GetV(S, 8, Value)
    end
  else if (BaseChar = 'B') then
    begin
    SetLength(S, Length(S)-1);
    GetValue := GetV(S, 2, Value)
    end
  else
    GetValue := GetDec(S, Value);
  end { GetValue };

var
  Operand: CReal;
  SymType, PrevSymType: Integer;
  CurrOp: Integer; { ⥪��� ������ (��� �訡��)}
  T: Byte; { ������ ����ࠡ�⠭���� ᨬ���� ��ப� ��ࠦ���� }

const
  Delimiters: String[50] = '()*/+-=^<>:#,!|\&%~ '#3;
  { �����᪨� ࠧ����⥫�. }

  MaxOp = 127;
  { �ਮ���� � ⥪��}
  { �ਮ���� � �⥪� }
  prio1: String[MaxOp] = '19244556733323444553333559';
  { �ਮ���� � ⥪��}
  prio2: String[MaxOp] = '00 44556733323444553333558';
  { �ਮ���� � �⥪� }
  OpChars = #3'()+-*/^:=<>,#|\&%#4<<<<<<~'#1#2;
  { #1 �।�⠢��� 㭠�� �����, #2 - 㭠�� ����,
      #3 - ����� ��ࠦ����; ������ '<' - �� ����ᨬ����� ��.
      #4 - div (�� �����⢥���� ����ୠ� ������, ������
      ⮫쪮 ⥪�⮢�� ����ࠦ����. ��, �� ��� ����� �����।�⢥���
      �।����� ����ࠬ ����ᨬ������ ����権, ���� �ᯮ������.
      �᫨ ����������� ��������� ��� ����樨 � ⮫쪮 ⥪�⮢묨
      ������祭�ﬨ, �� ��⠢���� �᫥� �� div, ���४����� Op2Base
      � �� ���뢠� ��⠢��� ᨬ��� � ��ப� �ਮ��⮢.)
  }

  Op2Chars = '<>!';
  Op2 = '>='#0'<='#0'<>'#0'!='#0'<<'#0'>>'; {����ᨬ����� ����樨}
  OpDiv = 19;
  Op2Base = OpDiv + 1;
  LetterBinOp = ' DIV OR  XOR AND MOD SHL SHR ';
  LetterBinOpType: array[1..7] of Integer =
    (OpDiv, 15, 16, 17, 18, Op2Base+4, Op2Base+5);

  FnBase = Length(OpChars)+1;

type
  FnEval = procedure (var D: CReal);
  FnEval2 = procedure (var D: CReal; d2: CReal);
  FnEval3 = procedure (var D: CReal; d2, d3: CReal);
  PFnDesc = ^TFnDesc;
  TFnDesc = object
    n {ame}: String[8];
    E {val}: Pointer {FnEval};
    A {rguments}: Integer;
    end;

procedure SinEv(var d: CReal);
  begin
  d := sin(d);
  end;

procedure CosEv(var d: CReal);
  begin
  d := cos(d);
  end;

procedure TgEv(var d: CReal);
  begin
  d := Tan(d);
  end;

procedure CtgEv(var d: CReal);
  begin
  d := Cotan(d);
  end;

procedure CosecEv(var d: CReal);
  begin
  d := 1/sin(d);
  end;

procedure SecEv(var d: CReal);
  begin
  d := 1/cos(d);
  end;

procedure ArcSinEv(var d: CReal);
  begin
  d := ArcSin(d);
  end;

procedure ArcCosEv(var d: CReal);
  begin
  d := ArcCos(d);
  end;

procedure ArcSecEv(var d: CReal);
  begin
  d := ArcCos(1/d);
  end;

procedure ArcCoSecEv(var d: CReal);
  begin
  d := ArcSin(1/d);
  end;

procedure ArcTanEv(var d: CReal);
  begin
  d := ArcTan(d);
  end;

procedure ArcCoTanEv(var d: CReal);
  begin
  d := PI/2-ArcTan(d);
  end;

procedure LnEv(var d: CReal);
  begin
  d := ln(d);
  end;

procedure LgEv(var d: CReal);
  begin
  d := ln(d)/ln(10);
  end;

procedure ExpEv(var d: CReal);
  begin
  d := Exp(d);
  end;

procedure SqrEv(var d: CReal);
  begin
  d := d*d;
  end;

procedure SqrtEv(var d: CReal);
  begin
  d := Sqrt(d);
  end;

procedure SinhEv(var d: CReal);
  begin
  d := Sinh(d);
  end;

procedure CoshEv(var d: CReal);
  begin
  d := Cosh(d);
  end;

procedure TanhEv(var d: CReal);
  begin
  d := Tanh(d);
  end;

procedure CotanhEv(var d: CReal);
  begin
  d := 1/Tanh(d);
  end;

procedure ArcSinhEv(var d: CReal);
  begin
  d := ArcSinh(d);
  end;

procedure ArcCoshEv(var d: CReal);
  begin
  d := ArcCosh(d);
  end;

procedure ArcTanhEv(var d: CReal);
  begin
  d := ln((1+d)/(1-d))/2;
  end;

procedure SignEv(var d: CReal);
  begin
  if d < 0 then
    d := -1
  else if d > 0 then
    d := 1
  end;

procedure NotEv(var d: CReal);
  begin
  d := not Round(d);
  end;

procedure AbsEv(var d: CReal);
  begin
  d := Abs(d);
  end;

procedure RadEv(var d: CReal);
  begin
  d := (d*PI)/180;
  end;

procedure RadGEv(var d: CReal);
  begin
  d := (d*PI)/200;
  end;

procedure DegEv(var d: CReal);
  begin
  d := (d*180)/PI;
  end;

procedure GradEv(var d: CReal);
  begin
  d := (d*200)/PI;
  end;

procedure RoundEv(var d: CReal);
  begin
  d := Round(d);
  end;

procedure FactEv(var d: CReal);
  var
    i: Integer;
    r: CReal;
  begin
  r := 1;
  for i := 1 to Trunc(d) do
    r := r*i;
  d := r;
  end;

procedure PiEv(var d: CReal);
  begin
  d := PI;
  end;

procedure LogEv(var d: CReal; d2: CReal);
  begin
  d := logN(d, d2);
  end;

procedure RootEv(var d: CReal; d2: CReal);
  begin
  d := Exp(ln(d2)/d);
  end;

procedure IfEv(var d: CReal; d2, d3: CReal);
  begin
  if d <> 0 then
    d := d2
  else
    d := d3;
  end;

const
  FnMax = 52;
  CalcBase = FnBase+FnMax; { ����᪨ �� ���஭��� ⠡���� }
  FnTab: array[0..FnMax-1] of TFnDesc =
    (
      (n: 'SIN'; E: @SinEv; A: 1)
    , (n: 'COS'; E: @CosEv; A: 1)
    , (n: 'TG'; E: @TgEv; A: 1)
    , (n: 'TAN'; E: @TgEv; A: 1)
    , (n: 'CTG'; E: @CtgEv; A: 1)
    , (n: 'COTAN'; E: @CtgEv; A: 1)
    , (n: 'SEC'; E: @SecEv; A: 1)
    , (n: 'COSEC'; E: @CosecEv; A: 1)
    , (n: 'ASIN'; E: @ArcSinEv; A: 1)
    , (n: 'ARCSIN'; E: @ArcSinEv; A: 1)
    , (n: 'ACOS'; E: @ArcCosEv; A: 1)
    , (n: 'ARCCOS'; E: @ArcCosEv; A: 1)
    , (n: 'ARCSEC'; E: @ArcSecEv; A: 1)
    , (n: 'ARCCOSEC'; E: @ArcCosecEv; A: 1)
    , (n: 'ATAN'; E: @ArcTanEv; A: 1)
    , (n: 'ARCTAN'; E: @ArcTanEv; A: 1)
    , (n: 'ACTG'; E: @ArcCoTanEv; A: 1)
    , (n: 'ARCCOTAN'; E: @ArcCoTanEv; A: 1)
    , (n: 'LN'; E: @LnEv; A: 1)
    , (n: 'LG'; E: @LgEv; A: 1)
    , (n: 'EXP'; E: @ExpEv; A: 1)
    , (n: 'SQR'; E: @SqrEv; A: 1)
    , (n: 'SQRT'; E: @SqrtEv; A: 1)
    , (n: 'SH'; E: @SinhEv; A: 1)
    , (n: 'SINH'; E: @SinhEv; A: 1)
    , (n: 'CH'; E: @CoshEv; A: 1)
    , (n: 'COSH'; E: @CoshEv; A: 1)
    , (n: 'TH'; E: @TanhEv; A: 1)
    , (n: 'TANH'; E: @TanhEv; A: 1)
    , (n: 'CTH'; E: @CotanhEv; A: 1)
    , (n: 'COTANH'; E: @CotanhEv; A: 1)
    , (n: 'ARCSINH'; E: @ArcSinhEv; A: 1)
    , (n: 'ASH'; E: @ArcSinhEv; A: 1)
    , (n: 'ARCCOSH'; E: @ArcCoshEv; A: 1)
    , (n: 'ACOSH'; E: @ArcCoshEv; A: 1)
    , (n: 'ACH'; E: @ArcCoshEv; A: 1)
    , (n: 'ATH'; E: @ArcTanhEv; A: 1)
    , (n: 'ARTH'; E: @ArcTanhEv; A: 1)
    , (n: 'ARCTANH'; E: @ArcTanhEv; A: 1)
    , (n: 'FACT'; E: @FactEv; A: 1)
    , (n: 'SIGN'; E: @SignEv; A: 1)
    , (n: 'NOT'; E: @NotEv; A: 1)
    , (n: 'ABS'; E: @AbsEv; A: 1)
    , (n: 'RAD'; E: @RadEv; A: 1)
    , (n: 'RADG'; E: @RadGEv; A: 1)
    , (n: 'DEG'; E: @DegEv; A: 1)
    , (n: 'GRAD'; E: @GradEv; A: 1)
    , (n: 'ROUND'; E: @RoundEv; A: 1)
    , (n: 'PI'; E: @PiEv; A: 0)
    , (n: 'LOG'; E: @LogEv; A: 2)
    , (n: 'ROOT'; E: @RootEv; A: 2)
    , (n: 'IF'; E: @IfEv; A: 3)
    );

procedure ScanSym;
  var
    t0: Integer;
    i: Integer;
    c: Char;
  begin
  while Expression[T] = ' ' do
    Inc(T);
  t0 := T;
  while Pos(Expression[T], Delimiters) = 0 do
    Inc(T);
  SymType := 0;
  c := Expression[t0];
  if T = t0 then
    begin {������ - ࠧ����⥫�}
    Inc(T);
    if Pos(c, Op2Chars) <> 0 then
      begin
      CalcSym := Copy(Expression, t0, 2);
      i := Pos(CalcSym, Op2);
      if i <> 0 then
        begin
        Inc(T);
        SymType := Op2Base+i div 3;
        Exit;
        end
      end;
    CalcSym := c;
    SymType := Pos(CalcSym, OpChars);
    end
  else if (c = '$') or ((c >= '0') and (c <= '9')) then
    begin {�᫮}
    if  (c <> '$') and (System.UpCase(Expression[T-1]) = 'E')
      and (Expression[T] in ['-', '+'])
    then
      begin {��宦� �� �᫮ ���� 5e-3}
      repeat
        Inc(T)
      until Pos(Expression[T], Delimiters) <> 0;
      end;
    CalcSym := {UpStrg(}Copy(Expression, t0, T-t0) {)};
    end
  else
    begin {������ ���� �㭪�� ��� �㪢����� ������ �த� AND}
    CalcSym := UpStrg(Copy(Expression, t0, T-t0));
    i := Pos(' '+CalcSym+' ', LetterBinOp);
    if i <> 0 then
      begin
      SymType := LetterBinOpType[(3+i) div 4];
      Exit;
      end;

    for i := 0 to FnMax-1 do
      begin
      if CalcSym = FnTab[i].n then
        begin
        SymType := FnBase+i;
        Exit;
        end;
      end;

{$IFDEF SpreadSheet}
    if CurCalcView <> nil then
      with PCalcView(CurCalcView)^ do
        begin
        if Expression[T] = '(' then
          begin { ��-� �த� sum(a1:a30) � wkz}
          for i := T+1 to Length(Expression) do
            if Expression[i] = ')' then
              begin
              if GetFuncValue(CalcSym+System.Copy(Expression, T, i-T+1))
              then
                begin
                T := i+1;
                SymType := CalcBase;
                Exit
                end
              else
                Break;
              end;
          end
        else if GetCellValue(CalcSym) then
          begin
          SymType := CalcBase;
          Exit
          end;
        end;
{$ENDIF}
    end;
  end { ScanSym };

procedure SetError(Id: TStrIdx);
  begin
  CalcErrMess := Id;
  CalcErrPos := T-2;
  raise eMathError.Create('');
  end;

{ ������᪨� ������ � ���� �⥪��� � ���� �ਮ��⠬� }
var
  DataStack: array[1..20] of CReal;
  TDS: Integer; { 㪠��⥫� ���設� }
  OpStack: array[1..20] of
  record
    Infix: Boolean;
    Op, PrefixCount, Pos: Integer
    end;
  TOS: Integer; { 㪠��⥫� ���設� }
  i: Integer;

procedure RegisterOperand;forward;

procedure EvalPrefixOp;
  begin
  CurrOp := OpStack[TOS].Op;
  CalcErrPos := OpStack[TOS].Pos;
  case CurrOp of
    FnBase-3: { ~ }
      DataStack[TDS] := not Round(DataStack[TDS]);
    FnBase-2: {����� ����}
      begin
      end;
    FnBase-1: {����� �����}
      DataStack[TDS] := -DataStack[TDS];
    else {case}
      with FnTab[CurrOp-FnBase] do
        begin
        if TDS < A then
          SetError(dlNoOperand);
        case A of
          {     0: �� �뢠�� }
          1:
            FnEval(E)(DataStack[TDS]);
          2:
            begin
            FnEval2(E)(DataStack[TDS-1], DataStack[TDS]);
            Dec(TDS);
            end;
          3:
            begin
            FnEval3(E)(DataStack[TDS-2], DataStack[TDS-1], DataStack[TDS]);
            Dec(TDS, 2);
            end;
        end {case};
        end;
  end {case};
  Dec(TOS);
  CurrOp := 0;
  RegisterOperand;
  end { EvalPrefixOp };

procedure RegisterOperand;
  begin
  with OpStack[TOS] do
    begin
    Dec(PrefixCount);
    if PrefixCount < 0 then
      SetError(dlMissingOperation);
    if not Infix and (PrefixCount = 0) then
      EvalPrefixOp;
    end;
  SymType := 0;
  end;

procedure ToInt; {���������� � ��������� 楫�� �⥯��� }
  var
    N: Integer;
    R: CReal;
    neg: Boolean;
  begin
  N := Round(DataStack[TDS]);
  R := DataStack[TDS-1];
  DataStack[TDS-1] := 1;
  neg := N < 0;
  if neg then
    begin
    N := -N;
    R := 1/R;
    end;
  while N <> 0 do
    begin
    if odd(N) then
      DataStack[TDS-1] := DataStack[TDS-1]*R;
    R := R*R;
    N := N shr 1;
    end;
  end { ToInt };

procedure EvalText;

  label ExprEnd;

  begin
  T := 1;
  Expression := Expression+#3;

  TOS := 1;
  with OpStack[1] do
    begin
    Infix := True;
    Op := 1;
    PrefixCount := 1;
    end;

  SymType := 1;
  TDS := 0;

  while True do
    begin
    PrevSymType := SymType;
    ScanSym;
    if SymType = 0 then
      begin { ࠧ����� ���࠭� � �������� �� �⥪ ������ }
      Inc(TDS);
      if not GetValue(CalcSym, DataStack[TDS]) then
        SetError(dlWrongText);
      RegisterOperand;
      end
    else if (SymType = CalcBase) then
      begin {�������� �� �⥪ ���祭�� ��६�����}
      Inc(TDS);
      DataStack[TDS] := Res;
      RegisterOperand;
      end
    else if (SymType >= FnBase) and (FnTab[SymType-FnBase].A = 0) then
      begin
      Inc(TDS);
      FnEval(FnTab[SymType-FnBase].E)(DataStack[TDS]);
      RegisterOperand;
      end
    else
      begin { ࠧ������� � ����樥� }
      if  (OpStack[TOS].PrefixCount > 0) then
        { ��������� ���筨� ���祭�� }
        case SymType of
          2: { ��ࠦ���� � ᪮���� ������� }
            ;
          4, 5: { �ॢ�頥� � 㭠�� ���� � ����� }
            SymType := FnBase-6+SymType;
          FnBase-3..MaxOp: { 㭠�� ����樨 � �㭪樨 }
            ;
          else {case}
            SetError(dlNoOperand);
        end { case }
      else
        case SymType of
          2, FnBase-3..MaxOp:
            SetError(dlMissingOperation);
        end { case };
      while prio1[SymType] <= prio2[OpStack[TOS].Op] do
        { �믮����� ��䨪�� ����樨 � �⥪�; ��䨪�� � 㭠��
        �믮������� �� ���, � � RegisterOperand }
        begin
        CurrOp := OpStack[TOS].Op;
        CalcErrPos := OpStack[TOS].Pos;
        case CurrOp of
          4: {+}
            begin
            DataStack[TDS-1] := DataStack[TDS-1]+DataStack[TDS];
            Dec(TDS);
            end;
          5: {-}
            begin
            DataStack[TDS-1] := DataStack[TDS-1]-DataStack[TDS];
            Dec(TDS);
            end;
          6: {*}
            begin
            DataStack[TDS-1] := DataStack[TDS-1]*DataStack[TDS];
            Dec(TDS);
            end;
          7: {/}
            begin
            DataStack[TDS-1] := DataStack[TDS-1]/DataStack[TDS];
            Dec(TDS);
            end;
          OpDiv: {/}
            begin
            DataStack[TDS-1] := Trunc(DataStack[TDS-1]) div
              Trunc(DataStack[TDS]);
            Dec(TDS);
            end;
          8: {^ - ���������� � �⥯��� }
            begin
            if  (Abs(DataStack[TDS]) < $7FFFFFFF)
              and (Trunc(DataStack[TDS]) = DataStack[TDS])
            then
              ToInt
            else
              DataStack[TDS-1] := Exp(ln(DataStack[TDS-1])*DataStack[TDS]);
            Dec(TDS);
            end;
          9: { �६� }
            begin
            DataStack[TDS-1] := DataStack[TDS-1]*60+DataStack[TDS];
            Dec(TDS);
            end;
          10: { = }
            begin
            if DataStack[TDS-1] = DataStack[TDS] then
              DataStack[TDS-1] := -1
            else
              DataStack[TDS-1] := 0;
            Dec(TDS);
            end;
          11: { < }
            begin
            if DataStack[TDS-1] < DataStack[TDS] then
              DataStack[TDS-1] := -1
            else
              DataStack[TDS-1] := 0;
            Dec(TDS);
            end;
          12: { > }
            begin
            if DataStack[TDS-1] > DataStack[TDS] then
              DataStack[TDS-1] := -1
            else
              DataStack[TDS-1] := 0;
            Dec(TDS);
            end;
          {13 ',' � �⥪ �� �������� }
          15: { |  or }
            begin
            DataStack[TDS-1] := Round(DataStack[TDS-1])
                 or Round(DataStack[TDS]);
            Dec(TDS);
            end;
          16: { \  xor }
            begin
            DataStack[TDS-1] := Round(DataStack[TDS-1])
                 xor Round(DataStack[TDS]);
            Dec(TDS);
            end;
          17: { &  and }
            begin
            DataStack[TDS-1] := Round(DataStack[TDS-1])
                 and Round(DataStack[TDS]);
            Dec(TDS);
            end;
          18: { %  mod }
            begin
            DataStack[TDS-1] := Round(DataStack[TDS-1])
                 mod Round(DataStack[TDS]);
            Dec(TDS);
            end;
          Op2Base: { >= }
            begin
            if DataStack[TDS-1] >= DataStack[TDS] then
              DataStack[TDS-1] := -1
            else
              DataStack[TDS-1] := 0;
            Dec(TDS);
            end;
          Op2Base+1: { <= }
            begin
            if DataStack[TDS-1] <= DataStack[TDS] then
              DataStack[TDS-1] := -1
            else
              DataStack[TDS-1] := 0;
            Dec(TDS);
            end;
          14, Op2Base+2, Op2Base+3: { <> }
            begin
            if DataStack[TDS-1] <> DataStack[TDS] then
              DataStack[TDS-1] := -1
            else
              DataStack[TDS-1] := 0;
            Dec(TDS);
            end;
          Op2Base+4: { <<  shl }
            begin
            DataStack[TDS-1] := Round(DataStack[TDS-1])
                 shl Round(DataStack[TDS]);
            Dec(TDS);
            end;
          Op2Base+5: { >>  shr }
            begin
            DataStack[TDS-1] := Round(DataStack[TDS-1])
                 shr Round(DataStack[TDS]);
            Dec(TDS);
            end;
          else {case}
            SetError(dlNoOperand);
        end {case};
        CurrOp := 0;
        Dec(TOS); //PrevSymType := 0;
        end;
      case SymType of
        1:
          goto ExprEnd;
        3:
          begin { ����뢠���� ᪮��� ᮪�頥� � ���뢠�饩 }
          if OpStack[TOS].Op <> 2 then
            SetError(dlMissingLeftBracket);
          Dec(TOS);
          SymType := 0; { ���. � ᪮���� - ���࠭� }
          RegisterOperand;
          end;
        13: { , }
          begin
          if  (TOS < 3) or (OpStack[TOS].Op <> 2)
            or (OpStack[TOS-1].PrefixCount = 0)
          then
            SetError(dlWrongComma);
          Inc(OpStack[TOS].PrefixCount);
          Dec(OpStack[TOS-1].PrefixCount);
          end;
        else {case}
          begin { �������� ������ �� �⥪ }
          Inc(TOS);
          with OpStack[TOS] do
            begin
            Op := SymType;
            Infix := SymType < FnBase-3;
            if SymType < FnBase then
              PrefixCount := 1
            else
              PrefixCount := FnTab[SymType-FnBase].A;
            Pos := T-2;
            end;
          end;
      end {case};
      end
    end;

ExprEnd:
  if Expression[T-2] <> ' ' then
    Inc(T);
  if  (TOS <> 1) or (TDS <> 1) then
    SetError(dlMissingRightBracket);
  Res := DataStack[1];

  { ��� extended +0 � -0 ����� ࠧ�� �।�⠢�����, � -0 ��⮬ ⠪
� �⮡ࠦ�����, 㤨���� �. ��� �� ��� ��砩 �����塞 �� 0,
�� ���� 0, ����� ���� +0}
  if Res = 0 then
    Res := 0;

  end { EvalText };

function GetErrOp(var x: Integer): String;
  var
    OpName: String;
  begin
  x := T;
  Result := '';
  case CurrOp of
    0:
      begin
      Result := '';
      Exit;
      end;
    1..Op2Base-1:
      OpName := Copy(OpChars, CurrOp, 1);
    Op2Base..FnBase-1:
      OpName := Copy(Op2, 1+3*(CurrOp-Op2Base), 2);
    else {case}
      OpName := FnTab[CurrOp-FnBase].n
  end {case};
  Result := ' '+OpName;
  end;

function Evalue(const s: String; CCV: Pointer): CReal;
  var
    o: Pointer;
  begin
{$IFDEF SpreadSheet}
  CurCalcView := CCV;
{$ENDIF}
  Evalue := 0;
  try
    EvalueError := False;
    CurrOp := 0;
    CalcErrMess := dlMsgError;
    Expression := s;
    EvalText;
    Evalue := Res;
  except
    on E: eMathError do
      EvalueError := True;
    on E: EInvalidArgument do
      EvalueError := True;
  end {except};
  end;

procedure InitUnopPrio;
  var
    l, i: Integer;
  begin
  l := Length(prio1);
  SetLength(prio1, MaxOp);
  SetLength(prio2, MaxOp);
  for i := l+1 to Length(prio1) do
    if prio1[i] = #0 then
      begin
      prio1[i] := '9';
      prio2[i] := '8';
      end;
  end;

begin
InitUnopPrio;
end.


