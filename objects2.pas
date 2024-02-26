unit Objects2;

{$I STDEFINE.INC}

interface

const
  vmtHeaderSize = 12;

type
  PEmptyObject = ^TEmptyObject;
  TEmptyObject = object
    {Cat: ��� ��ꥪ� �뭥ᥭ � ��������� ������; �������� �ࠩ�� ���஦��!}
    constructor Init;
    procedure Free;
    destructor Done; virtual;
    end;

  PObject = ^TObject;
  TObject = object(TEmptyObject)
    {Cat: ��� ��ꥪ� �뭥ᥭ � ��������� ������; �������� �ࠩ�� ���஦��!}
    ObjectIsInited: Boolean;
    constructor Init;
    destructor Done; virtual;
    end;

procedure FreeObject(var O);

procedure ObjChangeType(P: PObject; NewType: Pointer);
  {` ������� ⨯� ������� ��ꥪ�. � ����⢥ NewType ����
  㪠�뢠�� १���� TypeOf(���� ⨯). ���� ⨯, ����⢥���,
  ������ ���� ᮢ���⨬ �� ���� � ⨯��, ����� ���� ��ꥪ�
  �� ஦�����.
     �᭮���� �����祭�� - ������� ����㠫��� ��⮤��, � ����
  ��������� ��������� ��� �᧬������ ������.
  `}

implementation

const
  LinkSize = SizeOf(TEmptyObject);

constructor TEmptyObject.Init;
  begin
  FillChar(Pointer(LongInt(@Self)+LinkSize)^, SizeOf(Self)-LinkSize, #0)
  ; { Clear data fields }
  end;

procedure TEmptyObject.Free;
  begin
  if @Self <> nil then
    Dispose(PEmptyObject(@Self), Done);
  end;

destructor TEmptyObject.Done;
  begin
  end;

constructor TObject.Init;
  begin
  inherited Init;
  ObjectIsInited := True;
  end;

destructor TObject.Done;
  begin
  ObjectIsInited := False;
  end;

procedure FreeObject(var O);
  var
    OO: PObject absolute O;
  begin
  if OO <> nil then
    begin
    Dispose(OO, Done);
    OO := nil;
    end;
  end;

procedure ObjChangeType(P: PObject; NewType: Pointer);
  begin
  PWord(P)^ := Word(NewType);
  end;

end.
