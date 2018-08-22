000100180514       Ctl-Opt DFTNAME(FLM015) NOMAIN ;
000200180514       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180514       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180514       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180522       // Select SQL source member generation
000600180520       Dcl-F FLD015         WORKSTN USROPN ;
000700180514       // Prototypes
000800180520       //***************************************************************
000900180520       //            Prototype for QMHSNDPM-Sedn the message
001000180520       //****************************************************************
001100180520       Dcl-PR QMHSNDPM             ExtPgm('QMHSNDPM');
001200180520          AwMSgId                  Char(7);
001300180520          AwMSgF                   Char(20);
001400180520          AwMSgDta                 Char(256);
001500180520          spLen                     Int(10:0);
001600180520          apTyp                    Char(10);
001700180520          apQue                    Char(10);
001800180520          spStk                     Int(10:0);
001900180520          spKy                      Int(10:0);
002000180520          spErr                     Int(10:0);
002100180520       End-PR;
002200180520       //***************************************************************
002300180520       //            Prototype for QMHRMVPM-Clear the message
002400180520       //****************************************************************
002500180520       Dcl-PR QMHRMVPM             ExtPgm('QMHRMVPM');
002600180520          spStk1                   Char(10);
002700180520          spCsc                     Int(10:0);
002800180520          apMsk                    Char(4);
002900180520          apMsr                    Char(10);
003000180520          spErc                     Int(10:0);
003100180520       End-PR;
003200180514      /Copy QRPGLESRC,FLT001
003300180523       Dcl-PR SysCmd                Int(10:0) ExtProc('system');
003400180523         Cmd                   Pointer Value Options(*String);
003500180523       End-PR;
003600180520      // Data Structures
003700180612       Dcl-DS FLP015DS EXTNAME('FLP015') Qualified INZ END-DS;
003701180612       Dcl-DS FLP015CDS EXTNAME('FLP015C') Qualified INZ END-DS;
003800180520       Dcl-DS SDS PSDS Qualified ;   // Remember to use SDS. !
003900180520         PGMNAM  Char(10)  Pos(1);
004000180520        End-DS;
004100180514       // Stand Alone Fields
004200180520       Dcl-S ADDONE                 Ind ;
004300180520       Dcl-S AwMSgId               Char(7);
004400180520       Dcl-S AwMSgF                Char(20);
004500180520       Dcl-S AwMSgDta              Char(256);
004600180520       Dcl-S apMsk                 Char(4);
004700180520       Dcl-S apMsr                 Char(10);
004800180520       Dcl-S apTyp                 Char(10);
004900180520       Dcl-S apQue                 Char(10);
005000180523       Dcl-S Cmd                   Char(256) ;
005100180523       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
005200180514       Dcl-S EOJ                   Char(2) ;
005300180520       Dcl-S ErrorON                Ind    ;
005400180521       Dcl-S Scrn#                  Int(5:0) Inz(1) ;
005500180520       Dcl-S spLen                  Int(10:0);
005600180520       Dcl-S spStk                  Int(10:0);
005700180520       Dcl-S spKy                   Int(10:0);
005800180520       Dcl-S spErr                  Int(10:0);
005900180520       Dcl-S spStk1                Char(10);
006000180520       Dcl-S spCsc                  Int(10:0);
006100180520       Dcl-S spErc                  Int(10:0);
006200180520       Dcl-S SystemName            Char(10);
006300180514       //*--------------------------------------------------------------------
006400180514       Dcl-Proc FLM015 EXPORT;
006500180514         Dcl-PI FLM015               Char(2);
006600180514           FILEIN                   Char(10);
006700180514           LIBIN                    Char(10);
006800180514           FMTIN                    Char(10);
006900180514         End-PI ;
007000180521
007100180521         Exec Sql Set Option Commit = *None; // manage commitment control
007200180521         Exec SQL values current server into :systemName; // Set system name
007300180521         If Not %Open(FLD015) ; // Open the display file
007400180520           Open FLD015 ;
007500180520         EndIf;
007600180521         PROGRAM = SDS.PGMNAM ; // for error message subfile
007700180523         Scrn# = 1 ;
007800180520         ExSR ChkExist ;
007900180521         If AddOne = *OFF;
008000180521           ExSR Update01;
008100180520         Else;
008200180521           ExSR Add01;
008300180520         EndIf;
008400180521         Dow Scrn# = 1 ;
008500180521           If ErrorOn = *On ;
008600180521             Write MSGCTL ;
008700180521           EndIf ;
008800180521           ExFMT SCRN01 ;
008900180521           Select ;
009000180521           When *IN01 = *ON ;
009100180523           When *IN05 = *ON ;
009200180523             ExSR Edit01 ;
009300180523             If ErrorOn = *OFF ;
009400180523               If AddOne = *ON ;
009500180523                 ExSR AddIt ;
009600180523                 EOJ = 'AD' ;
009700180523                 Scrn# = *Zero ;
009800180523               Else;
009900180523                 ExSR UpdateIt ;
010000180523                 EOJ = 'UD' ;
010100180523                 Scrn# = *Zero;
010200180523               EndIf;
010300180523               Clear FLP015DS;
010400180523             Exec SQL
010500180523             Select * Into :FLP015DS
010600180523                    from FLP015
010700180523                    Where FL1501 = :SystemName AND FL1502 = :LIBIN
010800180523                          AND FL1503 = :FILEIN ;
010900180522
011000180523               If DB2 = 'Y' ;  // DB2 source member
011100180524                 EOJ = FLM015A(FLP015DS:ADDONE);
011200180523               EndIf;
011300180523
011400180523               If SQLSVR = 'Y' ; // MS Sequel Server script
011500180609                 EOJ = FLM015S(FLP015DS:ADDONE);
011600180523               EndIf;
011700180523
011800180523               If MYSQL = 'Y' ; // Miranda srcipt
011900180609                 EOJ = FLM015M(FLP015DS:ADDONE);
012000180523               EndIf;
012100180523
012200180523               If ORACLE = 'Y' ; // Oracle script
012300180609                 EOJ = FLM015O(FLP015DS:ADDONE);
012400180523               EndIf;
012500180523             EndIf;
012600180522
012700180521           When *IN12 = *ON ;
012800180521             EOJ = '12' ;
012900180521             Scrn# = *Zero ;
013000180523           Other;
013100180523             ExSR Edit01 ;
013200180521           EndSL;
013300180521         EndDo;
013400180521         If Scrn# = *Zero ;
013500180521           Close FLD015 ;
013600180521           Return EOJ ;
013700180521         EndIf ;
013800180520         //*---------------------------------------------------------------------
013900180520         //* Checking for an existing transfer request
014000180520         //*---------------------------------------------------------------------
014100180520         BegSR ChkExist;
014200180520           Exec SQL
014300180520             Select * Into :FLP015DS
014400180520                    from FLP015
014500180522                    Where FL1501 = :SystemName AND FL1502 = :LIBIN
014600180522                          AND FL1503 = :FILEIN ;
014700180522         If FLP015DS.FL1501 = *Blanks;
014800180520           ADDONE = *ON;
014900180520         Else;
015000180520           ADDONE = *OFF;
015100180520         EndIf;
015200180520         EndSR;
015300180521          //*------------------------------------------------------------------
015400180521          //* Add01 - Populate the screen with new data
015500180521          //*------------------------------------------------------------------
015600180521          BegSR Add01 ;
015700180521           //
015800180521           DBSCTBL = %Trim(SystemName) + '/' +
015900180521                     %Trim(LIBIN) + '/' +
016000180521                     %Trim(FILEIN) ;
016100180521         Exec SQL
016200180521           Select ATTXT Into :DESCR
016300180521                  from FILES
016400180521                  Where ATFILE = :FILEIN AND ATLIB = :LIBIN ;
016401180612
016402180612         Exec SQL
016403180612           Select * Into :FLP015CDS From FLP015C ;
016404180612
016500180521            FORMAT = *Blanks ;
016600180612            PKEYYN = FLP015CDS.FL15C01 ;
016700180612            PKEYNAM = *Blanks ;
016800180612            DROPYN = FLP015CDS.FL15C02 ;
016900180521            DB2 = *Blanks ;
017000180612            SCHEMA = FLP015CDS.FL15C03 ;
017100180612            SRCLIB = FLP015CDS.FL15C04 ;
017200180521            REPLYN = *Blanks ;
017300180521            SQLTBL = *Blanks ;
017400180521            PKEYSN = *Blanks ;
017500180521            SQLSVR = *Blanks ;
017600180612            MSPATH = FLP015CDS.FL15C05 ;
017700180521            MYSQL =  *Blanks ;
017800180612            MYSPATH = FLP015CDS.FL15C06 ;
017900180521            ORACLE = *Blanks ;
018000180612            ORPATH = FLP015CDS.FL15C07 ;
018100180521         EndSR;
018200180521          //*------------------------------------------------------------------
018300180521          //* Update01 - Populate the screen with update data
018400180521          //*------------------------------------------------------------------
018500180521          BegSR Update01 ;
018600180521            //
018700180521            DBSCTBL = %Trim(FLP015DS.FL1501) + '/' +
018800180521                      %Trim(FLP015DS.FL1502) + '/' +
018900180521                      %Trim(FLP015DS.FL1503) ;
019000180521            FORMAT = FLP015DS.FL1504 ;
019100180521            DESCR = FLP015DS.FL1505 ;
019200180521            PKEYYN = FLP015DS.FL1506 ;
019300180521            PKEYNAM = FLP015DS.FL1507 ;
019400180521            DROPYN = FLP015DS.FL1508 ;
019500180521            DB2 = FLP015DS.FL1509 ;
019600180521            SCHEMA = FLP015DS.FL1510 ;
019700180523            SRCLIB = FLP015DS.FL1511 ;
019800180523            REPLYN = FLP015DS.FL1512 ;
019900180523            SQLTBL = FLP015DS.FL1513 ;
020000180523            PKEYSN = FLP015DS.FL1514 ;
020100180523            SQLSVR = FLP015DS.FL1515 ;
020200180523            MSPATH = FLP015DS.FL1516 ;
020300180523            MYSQL =  FLP015DS.FL1517 ;
020400180523            MYSPATH = FLP015DS.FL1518 ;
020500180523            ORACLE = FLP015DS.FL1519 ;
020600180523            ORPATH = FLP015DS.FL1520 ;
020700180521          EndSR ;
020800180520          //*------------------------------------------------------------------
020900180520          //* Edit01 - Edit the input fields in SCRN01
021000180520          //*------------------------------------------------------------------
021100180520          BegSR Edit01 ;
021200180521            ExSR ClrMsg;
021300180523            CpfMsgId = *Blanks;
021400180520            ErrorON = *OFF ;
021500180610            If DB2 = 'Y' ;
021600180523            // Check to make sure the Schema (library) is valid
021700180523            cmd = 'CHKOBJ OBJ('+ %trim(SCHEMA) + ')' +
021800180523                 ' OBJTYPE(*LIB)';
021900180523            CallP  SysCmd(Cmd);
022000180523            If CpfMsgId <> *Blanks ;
022100180610              ErrorOn = *ON;
022200180610              AwMSgDta= *Blanks;
022300180610              AwMSgDta= 'Schema ' + %TRIM(SCHEMA) + ' Not Found' ;
022400180610              Exsr SendMsg;
022500180610            EndIf;
022600180610            // Check to see if the source library is valid
022700180610            CpfMsgId = *Blanks;
022800180610            Cmd = 'CHKOBJ OBJ(' + %Trim(SRCLIB) + ') OBJTYPE(*LIB) ' ;
022900180610            CallP  SysCmd(Cmd);
023000180610            If CpfMsgId <> *Blanks ;
023100180610              ErrorOn = *ON;
023200180610              AwMSgDta= *Blanks;
023300180610              AwMSgDta= 'The source library ' + %Trim(SRCLIB) +
023400180610                        ' is not valid' ;
023500180610              Exsr SendMsg;
023600180610            EndIf;
023700180523            // Check to see if the source library and QSQLSRC are valid
023800180523            CpfMsgId = *Blanks;
023900180523            Cmd = 'CHKOBJ OBJ(' + %Trim(SRCLIB) + '/QSQLSRC) OBJTYPE(*FILE)' ;
024000180523            CallP  SysCmd(Cmd);
024100180523            If CpfMsgId <> *Blanks ;
024200180610              ErrorOn = *ON;
024300180610              AwMSgDta= *Blanks;
024400180610              AwMSgDta= 'Source physical file QSQLSRC does not exist in '  +
024500180610                        %Trim(SRCLIB) ;
024600180610              Exsr SendMsg;
024700180610            EndIf;
024800180610            // Check to see if the SQL source member already exists
024900180610            CpfMsgId = *Blanks;
025000180610            Cmd = 'CHKOBJ OBJ(' + %Trim(SRCLIB) + '/QSQLSRC) OBJTYPE(*FILE) ' +
025100180610                  'MBR(' + %Trim(PKEYSN) + ')' ;
025200180610            CallP  SysCmd(Cmd);
025300180610            If CpfMsgId = *Blanks ;
025400180610              If REPLYN <> 'Y';
025500180610                ErrorOn = *ON;
025600180610                AwMSgDta= *Blanks;
025700180610                AwMSgDta= 'Member ' + %TRIM(PKEYSN) + ' in ' + %Trim(SRCLIB) +
025800180610                          '/QSQLSRC already exists - use Replace Y' ;
025900180610                Exsr SendMsg;
026000180523              EndIf ;
026100180523            Else;
026200180523              REPLYN = *Blank;
026300180610            EndIf;
026400180610          EndIf;
026500180520          EndSR;
026600180521          //*------------------------------------------------------------------
026700180521          //* AddIt - Add an new source member
026800180521          //*------------------------------------------------------------------
026900180521          BegSR AddIt ;
027000180521            Exec SQL
027100180521              Insert Into FLP015
027200180521                    (FL1501, FL1502, FL1503, FL1504, FL1505, FL1506, FL1507,
027300180523                     FL1508, FL1509, FL1510, FL1511, FL1512, FL1513,
027400180523                     FL1514, FL1515, FL1516, FL1517, FL1518, FL1519, FL1520)
027500180521             Values (:SystemName, :LibIn, :FILEIN, :Format, :DESCR, :PKEYYN,
027600180523                     :PKEYNAM, :DROPYN, :DB2, :SCHEMA, :SRCLIB, :REPLYN,
027700180523                     :SQLTBL, :PKEYSN, :SQLSVR, :MSPATH, :MYSQL, :MYSPATH,
027800180523                     :ORACLE, :ORPATH ) ;
027900180522
028000180521          EndSR ;
028100180521           //
028200180521          //*------------------------------------------------------------------
028300180521          //* UpdateIt - Update the SQL record
028400180521          //*------------------------------------------------------------------
028500180521          BegSR UpdateIt ;
028600180521            Exec SQL
028700180521              Update FLP015
028800180521                Set( FL1505, FL1506, FL1507, FL1508, FL1509, FL1510, FL1511,
028900180521                     FL1512, FL1513, FL1514, FL1515, FL1516, FL1517,
029000180523                     FL1518, FL1519, FL1520 )
029100180521                  =  (:DESCR, :PKEYYN, :PKEYNAM, :DROPYN, :DB2, :SCHEMA,
029200180523                      :SRCLIB, :REPLYN, :SQLTBL, :PKEYSN, :SQLSVR, :MSPATH,
029300180523                      :MYSQL, :MYSPATH, :ORACLE, :ORPATH )
029400180521                Where FL15INDEX = :FLP015DS.FL15INDEX ;
029500180521
029600180521          EndSR ;
029700180520       //-------------------------------------------------------------------------
029800180520       // SendMsg: Send to Message Subfile
029900180520       //-------------------------------------------------------------------------
030000180520       BegSr SendMsg;
030100180520
030200180520          AwMsgF = 'QCPFMSG   *LIBL     ';
030300180520          SpLen = %LEN(AwMSgDta);
030400180520          ApTyp = '*DIAG';
030500180520          ApQue = '*';
030600180520          SpStk = *Zero;
030700180520          SpKy = *Zeros;
030800180520          SpErr = *Zeros;
030900180520
031000180520          CallP QMHSNDPM(AwMsgID
031100180520                 :AwMsgF
031200180520                 :AwMsgDta
031300180520                 :SpLen
031400180520                 :apTyp
031500180520                 :apQue
031600180520                 :SpStk
031700180520                 :SpKy
031800180520                 :spErr);
031900180520
032000180520       EndSr;
032100180520       //-------------------------------------------------------------------------
032200180520       // ClrMsg: Clear Message Subfile
032300180520       //-------------------------------------------------------------------------
032400180520       BegSr ClrMsg;
032500180520
032600180520          SpStk1 = '*';
032700180520          SpCsc = *Zero;
032800180520          apMsk = *Blanks;
032900180520          apMsr = '*ALL';
033000180520          spErc = *Zero;
033100180520
033200180520          CallP QMHRMVPM(SpStk1
033300180520                 :SpCsc
033400180520                 :apMsk
033500180520                 :apMsr
033600180520                 :spErc);
033700180520
033800180520       EndSr;
033900180520       //-------------------------------------------------------------------------
034000180514       End-Proc ;
