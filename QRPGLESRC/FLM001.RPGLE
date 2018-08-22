000100180601       Ctl-Opt DFTNAME(FLM001) BNDDIR('FLB001':'QC2LE');
000200180513       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180513       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000400080228       // Process File/Table Layout selections
000500080228       Dcl-F FLD001         WORKSTN ;
000600080228       //-------- Prototypes ---------*
000700080228      /Copy QRPGLESRC,FLT001
000800180514       Dcl-PR QMHSNDPM             ExtPgm('QMHSNDPM');
000900180514          AwMSgId                  Char(7);
001000180514          AwMSgF                   Char(20);
001100180514          AwMSgDta                 Char(256);
001200180514          spLen                     Int(10:0);
001300180514          apTyp                    Char(10);
001400180514          apQue                    Char(10);
001500180514          spStk                     Int(10:0);
001600180514          spKy                      Int(10:0);
001700180514          spErr                     Int(10:0);
001800180514       End-PR;
001900180514       //***************************************************************
002000180514       //            Prototype for QMHRMVPM-Clear the message
002100180514       //****************************************************************
002200180514       Dcl-PR QMHRMVPM             ExtPgm('QMHRMVPM');
002300180514          spStk1                   Char(10);
002400180514          spCsc                     Int(10:0);
002500180514          apMsk                    Char(4);
002600180514          apMsr                    Char(10);
002700180514          spErc                     Int(10:0);
002800180514       End-PR;
002900180514
003000180514       Dcl-PR QCMDEXC                  ExtPgm('QCMDEXC');
003100180514          *N                       Char(32702) options(*varsize) const;
003200180514          *N                     Packed(15:5) const;
003300180514       End-PR;
003400180514
003500180517       // Program Info
003600180517
003700180517       Dcl-DS *N                       PSDS;
003800180517          PROGRAM                  Char(10) Pos(001);
003900180517       End-DS;
004000080228       //----- Stand Alone Fields -----*
004100180514       Dcl-S AwMSgId               Char(7);
004200180514       Dcl-S AwMSgF                Char(20);
004300180514       Dcl-S AwMSgDta              Char(256);
004400180514       Dcl-S apMsk                 Char(4);
004500180514       Dcl-S apMsr                 Char(10);
004600180514       Dcl-S apTyp                 Char(10);
004700180514       Dcl-S apQue                 Char(10);
004800180514       Dcl-S Cmd                   Char(32702) ;
004900080228       Dcl-S EOJ                   Char(2);
005000180514       Dcl-S ErrorOn                IND ;
005100180514       Dcl-S Length              Packed(15:5) ;
005200180517       Dcl-S Scrn#                  Int(3:0) Inz(1) ;
005300180514       Dcl-S spLen                  Int(10:0);
005400180514       Dcl-S spStk                  Int(10:0);
005500180514       Dcl-S spKy                   Int(10:0);
005600180514       Dcl-S spErr                  Int(10:0);
005700180514       Dcl-S spStk1                Char(10);
005800180514       Dcl-S spCsc                  Int(10:0);
005900180514       Dcl-S spErc                  Int(10:0);
006000180514       Dcl-S sql                   Char(512);
006100180610       Write Scrn01e;
006200180610       DoW Scrn# = 1;
006300180610         If ErrorON = *ON ;
006400180610           Write MsgCtl;
006500180610         EndIf;
006600180610         Exfmt SCRN01;
006700180610         ErrorOn = *OFF;
006800180610         ExSR ClrMsg ;
006900180610         If *IN03 = *ON ;
007000180610           Scrn# = *Zero;
007100180610           Leave;
007200180610         EndIf;
007300180610         ExSR Edit01;
007400180610         If ErrorOn = *OFF ;
007500180610           Callp FLC001O(FILES:LIBR) ;
007600180610           EOJ = FLM003(FILES:LIBR:RFMTIN);
007700180610           ErrorOn = *ON ;
007800180610           AwMSgDta= *Blanks;
007900180610           AwMSgDta= %TRIM(LIBR) + '/' + %TRIM(FILES) + ' has been displayed' ;
008000180610           Exsr SendMsg;
008100180610           If EOJ = 'CV' ;
008200180610             If EXCELYN = 'Y' ;
008300180610               EOJ = FLM010(FILES:LIBR:RFMTIN);
008400180610               ErrorOn = *ON ;
008500180610               AwMSgDta= *Blanks;
008600180610               AwMSgDta= 'Excel/.csv file ' + %TRIM(FILES) +
008700180610                         ' has been created' ;
008800180610               Exsr SendMsg;
008900180610             EndIf;
009000180610             If SQLYN = 'Y' ;
009100180610               EOJ = FLM015(FILES:LIBR:RFMTIN);
009200180610               ErrorOn = *ON ;
009300180610               AwMSgDta= *Blanks;
009400180610               AwMSgDta= 'SQL Table script for ' + %TRIM(FILES) +
009500180610                         ' has been created' ;
009600180610               Exsr SendMsg;
009700180610             EndIf;
009800180610             If XMLYN = 'Y' ;
009900180610               EOJ = FLM020(FILES:LIBR:RFMTIN);
010000180610               ErrorOn = *ON ;
010100180610               AwMSgDta= *Blanks;
010200180610               AwMSgDta= 'XML script for ' + %TRIM(FILES) +
010300180610                         ' has been created' ;
010400180610               Exsr SendMsg;
010500180610             EndIf;
010600180610             If JSONYN = 'Y' ;
010700180610               ErrorOn = *ON ;
010800180610               EOJ = FLM025(FILES:LIBR:RFMTIN);
010900180610               AwMSgDta= *Blanks;
011000180610               AwMSgDta= 'JSON Script for ' + %TRIM(FILES) +
011100180610                         ' has been created' ;
011200180610               Exsr SendMsg;
011300180610             EndIf;
011400180610           EndIf;
011500180610         EndIf;
011600180610       EndDo;
011700180610
011800180610       If Scrn# = *Zero;
011900180610         CallP FLC001C() ;
012000180610         *INLR = *ON;
012100180610       EndIf;
012200180610          //*------------------------------------------------------------------
012300180610          //* Edit01 - Edit the input fields in SCRN01
012400180610          //*------------------------------------------------------------------
012500180610          BegSR Edit01 ;
012600180610            ExSR ClrMsg;
012700180610            ErrorON = *OFF ;
012800180610            cmd = 'CHKOBJ OBJ('+ %trim(LIBR) +')' +
012900180610                 ' OBJTYPE(*LIB)';
013000180610            CallP(E) qcmdexc(cmd: %len(cmd));
013100180610            If %error;
013200180610              ErrorOn = *ON;
013300180610              AwMSgDta= *Blanks;
013400180610              AwMSgDta= 'Library ' + %TRIM(LIBR) + ' Not Found' ;
013500180610              Exsr SendMsg;
013600180610            EndIf;
013700180610            Cmd = 'CHKOBJ OBJ(' + %Trim(LIBR) + '/' + %Trim(FILES) + ') ' +
013800180610                  'OBJTYPE(*FILE)' ;
013900180610            CallP(E) qcmdexc(cmd: %len(cmd));
014000180610            If %error;
014100180610              ErrorOn = *ON;
014200180610              AwMSgDta= *Blanks;
014300180610              AwMSgDta= 'File ' + %TRIM(LIBR) + '/' + %Trim(FILES) +
014400180610                        ' not found' ;
014500180610              Exsr SendMsg;
014600180610            EndIf;
014700180610          EndSR;
014800180610       //-------------------------------------------------------------------------
014900180610       // SendMsg: Send to Message Subfile
015000180610       //-------------------------------------------------------------------------
015100180610       BegSr SendMsg;
015200180610
015300180610          AwMsgF = 'QCPFMSG   *LIBL     ';
015400180610          SpLen = %LEN(AwMSgDta);
015500180610          ApTyp = '*DIAG';
015600180610          ApQue = '*';
015700180610          SpStk = *Zero;
015800180610          SpKy = *Zeros;
015900180610          SpErr = *Zeros;
016000180514
016100180514          CallP QMHSNDPM(AwMsgID
016200180514                 :AwMsgF
016300180514                 :AwMsgDta
016400180514                 :SpLen
016500180514                 :apTyp
016600180514                 :apQue
016700180514                 :SpStk
016800180514                 :SpKy
016900180514                 :spErr);
017000180514
017100180514       EndSr;
017200180514       //-------------------------------------------------------------------------
017300180514       // ClrMsg: Clear Message Subfile
017400180514       //-------------------------------------------------------------------------
017500180514       BegSr ClrMsg;
017600180514
017700180514          SpStk1 = '*';
017800180514          SpCsc = *Zero;
017900180514          apMsk = *Blanks;
018000180514          apMsr = '*ALL';
018100180514          spErc = *Zero;
018200180514
018300180514          CallP QMHRMVPM(SpStk1
018400180514                 :SpCsc
018500180514                 :apMsk
018600180514                 :apMsr
018700180514                 :spErc);
018800180514
018900180514       EndSr;
