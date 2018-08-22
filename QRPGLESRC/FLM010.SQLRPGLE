000100180514       Ctl-Opt DFTNAME(FLM010) NOMAIN ;
000200180514       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180514       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180514       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180514       // Generate Excel/.csv file
000600180528       // Select SQL source member generation
000700180528       Dcl-F FLD010         WORKSTN USROPN ;
000800180514       // Prototypes
000900180514      /Copy QRPGLESRC,FLT001
001000180528       //***************************************************************
001100180528       //            Prototype for QMHSNDPM-Sedn the message
001200180528       //****************************************************************
001300180528       Dcl-PR QMHSNDPM             ExtPgm('QMHSNDPM');
001400180528          AwMSgId                  Char(7);
001500180528          AwMSgF                   Char(20);
001600180528          AwMSgDta                 Char(256);
001700180528          spLen                     Int(10:0);
001800180528          apTyp                    Char(10);
001900180528          apQue                    Char(10);
002000180528          spStk                     Int(10:0);
002100180528          spKy                      Int(10:0);
002200180528          spErr                     Int(10:0);
002300180528       End-PR;
002400180528       //***************************************************************
002500180528       //            Prototype for QMHRMVPM-Clear the message
002600180528       //****************************************************************
002700180528       Dcl-PR QMHRMVPM             ExtPgm('QMHRMVPM');
002800180528          spStk1                   Char(10);
002900180528          spCsc                     Int(10:0);
003000180528          apMsk                    Char(4);
003100180528          apMsr                    Char(10);
003200180528          spErc                     Int(10:0);
003300180528       End-PR;
003400180528       Dcl-PR SysCmd                Int(10:0) ExtProc('system');
003500180528         Cmd                   Pointer Value Options(*String);
003600180528       End-PR;
003700180528      // Data Structures
003800180528       Dcl-DS FLP010DS EXTNAME('FLP010') Qualified INZ END-DS;
003801180612       Dcl-DS FLP010CDS EXTNAME('FLP010C') Qualified INZ END-DS;
003900180528       Dcl-DS SDS PSDS Qualified ;   // Remember to use SDS. !
004000180528         PGMNAM  Char(10)  Pos(1);
004100180528        End-DS;
004200180528       // Stand Alone Fields
004300180528       Dcl-S ADDONE                 Ind ;
004400180528       Dcl-S AwMSgId               Char(7);
004500180528       Dcl-S AwMSgF                Char(20);
004600180528       Dcl-S AwMSgDta              Char(256);
004700180528       Dcl-S apMsk                 Char(4);
004800180528       Dcl-S apMsr                 Char(10);
004900180528       Dcl-S apTyp                 Char(10);
005000180528       Dcl-S apQue                 Char(10);
005100180528       Dcl-S Cmd                   Char(256) ;
005200180528       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
005300180528       Dcl-S EOJ                   Char(2) ;
005400180528       Dcl-S ErrorON                Ind    ;
005500180528       Dcl-S Scrn#                  Int(5:0) Inz(1) ;
005600180528       Dcl-S spLen                  Int(10:0);
005700180528       Dcl-S spStk                  Int(10:0);
005800180528       Dcl-S spKy                   Int(10:0);
005900180528       Dcl-S spErr                  Int(10:0);
006000180528       Dcl-S spStk1                Char(10);
006100180528       Dcl-S spCsc                  Int(10:0);
006200180528       Dcl-S spErc                  Int(10:0);
006300180528       Dcl-S SystemName            Char(10);
006301180529       Dcl-S TempPath              Char(78) Inz('/DJIBMi/TableCV/csv');
006400180528       //*--------------------------------------------------------------------
006500180528       Dcl-Proc FLM010 EXPORT;
006600180528         Dcl-PI FLM010               Char(2);
006700180528           FILEIN                   Char(10);
006800180528           LIBIN                    Char(10);
006900180528           FMTIN                    Char(10);
007000180528         End-PI ;
007100180528
007200180528         Exec Sql Set Option Commit = *None; // manage commitment control
007300180528         Exec SQL values current server into :systemName; // Set system name
007400180528         If Not %Open(FLD010) ; // Open the display file
007500180528           Open FLD010 ;
007600180528         EndIf;
007700180528         PROGRAM = SDS.PGMNAM ; // for error message subfile
007800180528         Scrn# = 1 ;
007900180528         ExSR ChkExist ;
008000180528         If AddOne = *OFF;
008100180528           ExSR Update01;
008200180528         Else;
008300180528           ExSR Add01;
008400180528         EndIf;
008500180528         Dow Scrn# = 1 ;
008600180528           If ErrorOn = *On ;
008700180528             Write MSGCTL ;
008800180528           EndIf ;
008900180528           ExFMT SCRN01 ;
009000180528           Select ;
009100180528           When *IN01 = *ON ;
009200180528           When *IN05 = *ON ;
009300180528             ExSR Edit01 ;
009400180528             If ErrorOn = *OFF ;
009500180528               If AddOne = *ON ;
009600180528                 ExSR AddIt ;
009700180528                 EOJ = 'AD' ;
009800180528                 Scrn# = *Zero ;
009900180528               Else;
010000180528                 ExSR UpdateIt ;
010100180528                 EOJ = 'UD' ;
010200180528                 Scrn# = *Zero;
010300180528               EndIf;
010400180528               Clear FLP010DS;
010500180528             Exec SQL
010600180528             Select * Into :FLP010DS
010700180528                    from FLP010
010800180528                    Where FL1003 = :SystemName AND FL1004 = :LIBIN
010900180528                          AND FL1005 = :FILEIN ;
010901180607           // EOJ = FLM010A(FLP010DS:ADDONE);
010902180607              EOJ = FLM010I(FLP010DS:ADDONE);
011000180528             EndIf;
011200180528           When *IN12 = *ON ;
011300180528             EOJ = '12' ;
011400180528             Scrn# = *Zero ;
011500180528           Other;
011600180528             ExSR Edit01 ;
011700180528           EndSL;
011800180528         EndDo;
011900180528         If Scrn# = *Zero ;
012000180528           Close FLD010 ;
012100180528           Return EOJ ;
012200180528         EndIf ;
012300180528         //*---------------------------------------------------------------------
012400180528         //* Checking for an existing transfer request
012500180528         //*---------------------------------------------------------------------
012600180528         BegSR ChkExist;
012700180528           Exec SQL
012800180528             Select * Into :FLP010DS
012900180528                    from FLP010
013000180528                    Where FL1003 = :SystemName AND FL1004 = :LIBIN
013100180528                          AND FL1005 = :FILEIN ;
013200180528         If FLP010DS.FL1003 = *Blanks;
013300180528           ADDONE = *ON;
013400180528         Else;
013500180528           ADDONE = *OFF;
013600180528         EndIf;
013700180528         EndSR;
013800180528          //*------------------------------------------------------------------
013900180528          //* Add01 - Populate the screen with new data
014000180528          //*------------------------------------------------------------------
014100180528          BegSR Add01 ;
014200180528           //
014300180528           DBSCTBL = %Trim(SystemName) + '/' +
014400180528                     %Trim(LIBIN) + '/' +
014500180528                     %Trim(FILEIN) ;
014600180528         Exec SQL
014700180528           Select ATTXT Into :DESCR
014800180528                  from FILES
014900180528                  Where ATFILE = :FILEIN AND ATLIB = :LIBIN ;
014901180612         Exec SQL
014902180612           Select * Into :FLP010CDS From FLP010C ;
015000180528            FORMAT = *Blanks ;
015100180612            GENEXH = FLP010CDS.FL10C03 ;
015200180612            EXCOLSEP = FLP010CDS.FL10C04 ;
015300180612            CONVDATE = FLP010CDS.FL10C06 ;
015400180612            CONVTIME = FLP010CDS.FL10C07 ;
015500180612            CONVTS = FLP010CDS.FL10C08 ;
015600180612            CONVNUM = FLP010CDS.FL10C05 ;
015700180612            EXCELPATH = FLP010CDS.FL10C09 ;
015800180528         EndSR;
015900180528          //*------------------------------------------------------------------
016000180528          //* Update01 - Populate the screen with update data
016100180528          //*------------------------------------------------------------------
016200180528          BegSR Update01 ;
016300180528            //
016301180529            If FLP010DS.FL1001 = *Blanks;
016302180529              EXCELPATH = TempPath;
016303180529            Else ;
016304180529              EXCELPATH = FLP010DS.FL1001 ;
016305180529            EndIf;
016500180528            GENEXH = FLP010DS.FL1002 ;
016600180528            DBSCTBL = %Trim(FLP010DS.FL1003) + '/' +
016700180528                      %Trim(FLP010DS.FL1004) + '/' +
016800180528                      %Trim(FLP010DS.FL1005) ;
016900180528            FORMAT = FLP010DS.FL1006 ;
017000180528            EXCOLSEP = FLP010DS.FL1007 ;
017100180528            CONVNUM = FLP010DS.FL1008 ;
017200180528            CONVDATE = FLP010DS.FL1009 ;
017300180528            CONVTIME = FLP010DS.FL1010 ;
017400180528            CONVTS = FLP010DS.FL1011 ;
017500180528            DESCR = FLP010DS.FL1012 ;
017600180528          EndSR ;
017700180528          //*------------------------------------------------------------------
017800180528          //* Edit01 - Edit the input fields in SCRN01
017900180528          //*------------------------------------------------------------------
018000180528          BegSR Edit01 ;
018100180528            ExSR ClrMsg;
018200180528            CpfMsgId = *Blanks;
018300180528            ErrorON = *OFF ;
018400180528          EndSR;
018500180528          //*------------------------------------------------------------------
018600180528          //* AddIt - Add an new source member
018700180528          //*------------------------------------------------------------------
018800180528          BegSR AddIt ;
018900180528            Exec SQL
019000180528              Insert Into FLP010
019100180528                    (FL1001, FL1002, FL1003, FL1004, FL1005, FL1006, FL1007,
019200180528                     FL1008, FL1009, FL1010, FL1011, FL1012 )
019300180528             Values (:ExcelPath, :GENEXH, :SystemName, :LIBIN, :FILEIN,
019400180528                     :FORMAT, :EXCOLSEP, :CONVNUM, :CONVDATE, :CONVTIME,
019500180528                     :CONVTS, :DESCR ) ;
019600180528
019700180528          EndSR ;
019800180528           //
019900180528          //*------------------------------------------------------------------
020000180528          //* UpdateIt - Update the SQL record
020100180528          //*------------------------------------------------------------------
020200180528          BegSR UpdateIt ;
020300180528            Exec SQL
020400180528              Update FLP010
020500180528                Set(FL1001, FL1002, FL1006, FL1007, FL1008, FL1009, FL1010,
020600180528                    FL1011, FL1012 )
020700180528                  = (:ExcelPath, :GENEXH, :FORMAT, :EXCOLSEP, :CONVNUM,
020800180528                     :CONVDATE, :CONVTIME, :CONVTS, :DESCR )
020900180528                Where FL10INDEX = :FLP010DS.FL10INDEX ;
021000180528
021100180528          EndSR ;
021200180528       //-------------------------------------------------------------------------
021300180528       // SendMsg: Send to Message Subfile
021400180528       //-------------------------------------------------------------------------
021500180528       BegSr SendMsg;
021600180528
021700180528          AwMsgF = 'QCPFMSG   *LIBL     ';
021800180528          SpLen = %LEN(AwMSgDta);
021900180528          ApTyp = '*DIAG';
022000180528          ApQue = '*';
022100180528          SpStk = *Zero;
022200180528          SpKy = *Zeros;
022300180528          SpErr = *Zeros;
022400180528
022500180528          CallP QMHSNDPM(AwMsgID
022600180528                 :AwMsgF
022700180528                 :AwMsgDta
022800180528                 :SpLen
022900180528                 :apTyp
023000180528                 :apQue
023100180528                 :SpStk
023200180528                 :SpKy
023300180528                 :spErr);
023400180528
023500180528       EndSr;
023600180528       //-------------------------------------------------------------------------
023700180528       // ClrMsg: Clear Message Subfile
023800180528       //-------------------------------------------------------------------------
023900180528       BegSr ClrMsg;
024000180528
024100180528          SpStk1 = '*';
024200180528          SpCsc = *Zero;
024300180528          apMsk = *Blanks;
024400180528          apMsr = '*ALL';
024500180528          spErc = *Zero;
024600180528
024700180528          CallP QMHRMVPM(SpStk1
024800180528                 :SpCsc
024900180528                 :apMsk
025000180528                 :apMsr
025100180528                 :spErc);
025200180528
025300180528       EndSr;
025400180528       //-------------------------------------------------------------------------
025500180528       End-Proc ;
