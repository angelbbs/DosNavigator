{$IFDEF WIN32}
 {.$DEFINE SEVENZIP}{piwamoto:unpack ARJ,CAB,ZIP with 7-Zip (www.7-zip.org)}
{$ENDIF}

{$DEFINE DEBUG}

 {$IFDEF VIRTUALPASCAL}{$DEFINE NONBP}{$DEFINE LINEPOSIT}{$ENDIF}
 {$IFDEF FPC}{$DEFINE NONBP}{$ENDIF}

 {$IFNDEF VIRTUALPASCAL} {$IFNDEF DPMI} {$DEFINE REALMODE} {$ENDIF} {$ENDIF}

 {$IFDEF VIRTUALPASCAL}
  {$DEFINE USESYSUTILS}   {Cat: �᫨ ����� ��������� ����� SysUtils ��� �ᯮ�짮���� ��堭��� �᪫�祭��; � ��������� ���ᨨ �� �� �� �� �����}
  {.$DEFINE PLUGIN}        {Cat: ������᪠� �����}
  {.$DEFINE COLORER}       {Cat: ������ Colorer - ����� �ᯮ�짮������ � �� � ������᪮� ���ᨨ ⮦�}
  {$DEFINE USELONGSTRING}  {Cat: �ᯮ�짮����� ������� ��ப ���-��� (� ��⭮��, � ।����)}
  {.$DEFINE USEANSISTRING} {Cat: �ᯮ�짮����� ������� ��ப ����� ($H+); 㦥 ������������,     }
                           {     �� ��� �� ࠡ�⠥�; �������, �᫨ �㤥� �㦭�, �� ��� ��  ;-) }
  { !!  �� ��������� �⮣� ��ࠬ��� ������ ��������� ��ᮢ���⨬묨  !! }
 {$ENDIF}

{$IFDEF DEBUG}
 {$IFDEF VIRTUALPASCAL}
  {$IFDEF OS2} {.$DEFINE DEBUGMEM} {$ENDIF} {Cat: �஢��塞 �� ��室� � ��襬 � ���, ᪮�쪮 ����� ��蠫��� � � ����� ����}
  {.$DEFINE LOGOBJLOADSTORE} {Cat: ��襬 � ��� �� �맮�� ��⮤�� Load � Store}
  {$DEFINE SHOWRC} {Cat: ��������� �� � ᮮ�饭�� �� �訡��� �᫮�� ���� �訡�� (RC)}
 {$ENDIF}
{$ENDIF}

{.$DEFINE RegExp}
{$DEFINE Calendar}
{$DEFINE Game}
{$DEFINE TrashCan}
{$DEFINE CHCOL}
{$DEFINE SS}

{$IFDEF REALMODE}
 {$DEFINE LITE}
{$ENDIF}

{$DEFINE UUENCODE}
{$DEFINE UUDECODE}
{$DEFINE DBView}
{$IFNDEF NONBP}{TEMPORARY COMPILE LITE VERSION FOR NON BP}
 {.$DEFINE Modem}
 {.$DEFINE Link}
 {$DEFINE DiskEdit}
 {$DEFINE DiskFormat}
 {$DEFINE Reanimator}
 {$DEFINE DBView}
 {$DEFINE PrintManager}
 {$DEFINE SpreadSheet}
 {$DEFINE CdPlayer}
 {$DEFINE MEMINFO}
 {$DEFINE SYSINFO}
 {$DEFINE NETINFO}
 {.$DEFINE PHONES}
 {$DEFINE ARVID}

 {$DEFINE DisAsm}
 {.$DEFINE UPLOWSTRSINDLG}

 {$IFDEF DPMI}
  {$DEFINE BIGCOLLECTION}
  {.$DEFINE QSort}{$DEFINE POGLSORT}
  {$DEFINE NO_OVERLAY}
  {$DEFINE NOEXTRA}
  {$DEFINE PKTVIEW}
  {.$DEFINE OldCollection}
 {$ELSE}
  {.$DEFINE BIGCOLLECTION}
  {.$DEFINE QSort}{$DEFINE POGLSORT}
  {$UNDEF NO_OVERLAY}
  {$UNDEF NOEXTRA}
  {$DEFINE OFFS}
  {$DEFINE OldCollection} {���� ��ᥬ����� ��⮤� *Collection}
 {$ENDIF}

 {$DEFINE BIT_16}

 {.$DEFINE StreamDebug}
 {.$DEFINE SORTDEBUG}
 {.$DEFINE CHDIRDEBUG}
 {$DEFINE UserSaver}

{$ELSE VIRTUALPASCAL}
 {$DEFINE NO_OVERLAY}
 {$DEFINE NOEXTRA}
 {$DEFINE BIT_32}
 {$DEFINE FILE_32}
 {$IFDEF WIN32}
  {$DEFINE WIN95_HIGHPRIORITY} {Cat: ��� Win9x ����蠥� �ਮ��� ��-�, ���� ���� �ମ��� ��-�� �ਢ��� ConAgent-�}
  {$DEFINE USELFN}
  {$DEFINE RecodeWhenDraw} {��ਫ���᪨� ����� 䠩��� �࠭���� � ANSI,}
                            {� ��४��������� ⮫쪮 �� �ᯮ�짮�����}
 {$ENDIF}
 {$IFDEF DPMI32}
  {.$DEFINE NOASM} {Cat:todo DPMI32}
  {$DEFINE USELFN}
  {$DEFINE DualName}
 {$ENDIF}
 {$IFDEF USELFN}
  {$DEFINE STRINGLFN} {����砥� ����� ������, �� ���騩 ����� ����� ������ ࠡ��� � ������묨 LFN}
 {$ENDIF}
 {$DEFINE VPBETA}     {����砥� ᮧ����� DN.ERR �� ����᪨� �訡���}
                      {����� �� ��ਠ�� ������祭�� dn2cat.dll � �������� ��������� ���ᨨ}
 {.$DEFINE OldCollection} {���� ��ᥬ����� ��⮤� *Collection}
 {$DEFINE NoCallspcb} {��������! ���䨣� ���ᨩ, ᪮������� � � ��� NoCallspcb ��ᮢ���⨬�!}
 {$DEFINE EAOP}       {����樨 � Extended Attributes � OS/2}
                      {����樨 � Security Attributes � WinNT}
 {$IFNDEF DPMI32}
  {$DEFINE USEWPS}    {����⨥ 䮫��஢ WPS}
 {$ENDIF}
 {$Use32+}
 {$DEFINE QSORT}
 {.$DEFINE POGLSORT}
 {$DEFINE SpreadSheet}
 {$DEFINE PrintManager}
 {$DEFINE Printer}
 {$DEFINE PrintFromEditor}
 {.$DEFINE PKTVIEW} {��ଠ�쭮 ���������� � ࠡ�⠥�, �� ���� ��}
 {$DEFINE DisAsm}  {��ଠ�쭮 ���������� � ࠡ�⠥�, �� ���� ��}
 {$DEFINE PHONES}
 {$DEFINE ARVID}
 {.$DEFINE NETINFO}
 {$DEFINE FileNotify}
 {$IFNDEF DPMI32}
  {$IFNDEF WIN32} {JO: �६����, � Win32 ��� �� ᮢᥬ ��⮢}
   {$DEFINE Tasklist}
  {$ENDIF}
 {$ENDIF}
 {.$DEFINE CHDIRTIMER}
 {.$DEFINE SORTTIMER}
 {.$DEFINE COPYTIMER}
{$ENDIF VIRTUALPASCAL}

{$IFDEF BPIDE}
 {$UNDEF CHCOL}
 {$UNDEF SYSINFO}
 {$UNDEF MEMINFO}
 {$UNDEF UUENCODE}
 {$UNDEF UUDECODE}
 {$UNDEF Modem}
 {$UNDEF Link}
 {$UNDEF DisAsm}
{$ENDIF}

{$IFDEF LITE}
 {.$UNDEF TrashCan}
 {$UNDEF Game}
 {.$UNDEF UUENCODE}
 {.$UNDEF UUDECODE}
 {.$UNDEF Calendar}
 {.$UNDEF CdPlayer}
 {$UNDEF NETINFO}
 {.$UNDEF PHONES}
 {.$UNDEF SS}
 {.$UNDEF PrintManager}
 {.$UNDEF CHCOL}
 {$UNDEF SpreadSheet}
 {.$UNDEF DBView}
 {.$UNDEF Link}
 {$UNDEF DisAsm}
 {.$DEFINE MINARCH}
 {$UNDEF ARVID}
 {$UNDEF DiskEdit}
 {$UNDEF Reanimator}
{$ENDIF}

{.$DEFINE BANK}

{$IFDEF BANK}
 {$UNDEF Modem}
 {$UNDEF DiskEdit}
 {$UNDEF DBView}
 {$UNDEF DisAsm}
{$ENDIF}

{$DEFINE FULLOVR}
{$DEFINE FULLOVR2}
{$DEFINE VIEWSOVR}
{$DEFINE ADVANCEOVR}
{$DEFINE CollectOVR}
{$DEFINE MicroedOvr}
{$DEFINE VIDEOOVR}

{ Only TPW uses "WObjects"; BP 7 calls the same unit "Objects" }
{$IFDEF windows}
  {$IFNDEF ver70}
    {$DEFINE wobjects}
  {$ENDIF}
{$ENDIF}

{$IFDEF Modem}
  {$IFDEF DN}
    {$DEFINE CL_MASTER}
  {$ENDIF}
  {$IFDEF NLCLIENT}
    {$DEFINE CL_MASTER}
  {$ENDIF}
{$ENDIF}

{.$DEFINE PACKFILE}

{$IFDEF PLUGIN} {$DEFINE PLUGINRES} {$ENDIF}
{$IFNDEF DNPRG} {$UNDEF PLUGIN} {$ENDIF}
{$IFDEF PLUGIN} {$IFDEF OS2} {$DEFINE PLUGIN_OS2} {$DEFINE TRUE_DYNAMIC} {$ENDIF} {$IFDEF WIN32} {$DEFINE PLUGIN_WIN32} {$IFNDEF VPBETA} {$DEFINE TRUE_DYNAMIC} {$ENDIF} {$ENDIF} {$ENDIF} {Cat}

{.$IFDEF PLUGIN} {.$UNDEF GAME} {.$ENDIF} {Cat}
{$IFDEF PLUGIN} {.$DEFINE MINARCH} {$ENDIF} {Cat}
{$IFDEF PLUGIN_WIN32} {$DEFINE MIRRORVARS} {$ENDIF} {Cat}
{$IFNDEF BIT_32} {$UNDEF USEANSISTRING} {$UNDEF USELONGSTRING} {$ENDIF} {Cat}
{$IFDEF LOGOBJLOADSTORE} {$UNDEF NoCallspcb} {$ENDIF} {Cat}
{$IFDEF VIRTUALPASCAL} {$IFDEF USEANSISTRING} {$H+} {$DEFINE USELONGSTRING} {$ELSE} {$H-} {$ENDIF} {$ENDIF} {Cat}

{$IFDEF Win32}{$DEFINE DualName } {$ENDIF} {AK155}
{$IFDEF Win32} {$DEFINE NetBrowser} {$ENDIF} {JO}
