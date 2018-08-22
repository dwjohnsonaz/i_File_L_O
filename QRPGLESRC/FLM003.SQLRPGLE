000100180513       Ctl-Opt DFTNAME(FLM003) NOMAIN ;
000200171016       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300171016       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400171016       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180513       // Display File/Table layouts
000600180516       DCL-F FLD003 WORKSTN(*EXT) SFILE(SFL01:XRRNS1)
000700180516                                  SFILE(SFL02:XRRNS2) USROPN ;
000800080228       // Prototypes
000900080228      /Copy QRPGLESRC,FLT001
001000180508      /Copy QRPGLESRC,UTT001
001100180712       Dcl-PR SysCmd           Int(10:0) ExtProc('system');
001200180513         Cmd                   Pointer Value Options(*String);
001300180513       End-PR;
001400171016       // SQL processing subprocedures
001500180508       Dcl-PR CloseFLD  End-PR;
001600180509       Dcl-PR CloseKEY  End-PR;
001700180508       Dcl-PR FetchMultFLD  Ind;
001800171016       End-PR;
001900180509       Dcl-PR FetchMultKEY  Ind;
002000180509       End-PR;
002100180508       Dcl-PR OpenFLD  End-PR;
002200180509       Dcl-PR OpenKEY  End-PR;
002300180508       // Data Sets for processing
002400180508       Dcl-DS FieldsDS Qualified Dim( 1000 ) ;
002500180508         WHNAME      Char(10) ;   // Record Format
002600180508         WHFLDI      Char(10) ;   // Internal Field Name
002700180508         WHFLDT      Char(1)  ;   // Field Type
002800180508         WHFLDB      Zoned(5:0) ; // Field Length in bytes
002900180508         WHFLDP      Zoned(2:0) ; // Field Decimal Positions
003000180510         WHFTXT      Char(50) ;   // Field text desrciption
003100180509         WHNULL      Char(1)  ;   // Field Null Y/N
003200180509         WHALIS      Char(32) ;   // SQL Alias field
003300180712         WHVARL      Char(1)  ;   // Variable length field
003400180508       End-Ds;
003500180509       Dcl-DS KeysDS Qualified Dim( 10 ) ;
003600180509         APFILE      Char(10) ;   // Record Format
003700180509         APLIB       Char(10) ;   // Library Name
003800180517         APSYSN      Char(8)  ;   // System Name
003900180509         APUNIQ      Char(1)  ;   // Key field Name Unique Y/N
004000180517         APKEYF      Char(10) ;   // Key field Name
004100180517         APKEYN    Packed(3)  ;   // Key field Name seq. No.
004200180509       End-Ds;
004300180514       Dcl-DS DisplayDS  ; // The display line
004400180513         NULLYN      Char(3)  Pos(2) ;
004500180514         ATTR1       Char(1)  Pos(8)  INZ(X'22') ;
004600180514         WHFLDI      Char(10) Pos(9) ;
004700180514         ATTR2       Char(1)  Pos(20) INZ(X'20') ;
004800180514         FTXT30      Char(30) Pos(21) ;
004900180513         WHFLDT      Char(1)  Pos(54) ;
005000180513         WHFLDB      Char(5)  Pos(57) ;
005100180514         WHFLDPC     Char(2)  Pos(63) ;
005200180514         SPOSC       Char(4)  Pos(69) ;
005300180514         EPOSC       Char(4)  Pos(75) ;
005400180514         DisplayD    Char(79) Pos(1) ;
005500180513       End-DS;
005600170730       // Stand Alone Fields
005700180510       // Character - apostrophe
005800180510       Dcl-C AP         const(X'7D'); // apostrophe '''
005900180514       Dcl-C Green      const(X'20'); // color atribute Green
006000180514       Dcl-C White      const(X'22'); // color atribute White
006100180514       Dcl-S AliasDsp              Char(75) ;
006200180514       Dcl-S APFILE                Char(10) ;   // Record Format
006300170730       Dcl-S BEGIN                 Char(1);
006400170730       Dcl-S BYTES               Packed(5:0);
006500180510       Dcl-S CLO64                 Char(64) ;
006600180510       Dcl-S CMD                   Char(256) ;
006700180510       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
006800171016       Dcl-S CsrSel                Char(256);                               // SQL Cursor Def.
006900180508       Dcl-S Decimal                Ind ;
007000170730       Dcl-S DUPLEX                Char(1);
007100170730       Dcl-S EOJ                   Char(2);
007200170730       Dcl-S EPOS                Packed(4:0);
007300180509       Dcl-S EvenP                  Ind ;
007400180508       Dcl-S First                  Ind Inz('1') ;
007500170730       Dcl-S KEYYN                 Char(1);
007600170730       Dcl-S LIBOBJ                Char(21);
007700180510       Dcl-S LOLEN                 Int(10) Inz(21) ;
007800170730       Dcl-S LO01                  Char(11);
007900180509       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
008000180509       Dcl-S Mult_Keys              Int(5) Inz( 10 );
008100170730       Dcl-S NUM                 Packed(2:0);
008200180509       Dcl-S ODDEVEN               Char(1) Inz('O');
008300180508       Dcl-S P                     Int(5) ;
008400180510       Dcl-S PAGENO                Int(5) ;
008500170730       Dcl-S Q                     Char(1);
008600170730       Dcl-S RB4                   Char(1) DIM(21);
008700180510       Dcl-S Rc                    Ind ;
008800170730       Dcl-S RELREC              Packed(7:0) INZ(1);
008900180509       Dcl-S REMAIN              Int(10) ;
009000170730       Dcl-S RESULT              Packed(7:0);
009100180513       Dcl-S SFL01IND            Ind ;
009200180516       Dcl-S SFL02IND            Ind ;
009300170730       Dcl-S SPOS                Packed(4:0);
009400180510       Dcl-S TESTI               Int(5) ;
009500170730       Dcl-S TIME                Packed(6:0);
009600180509       Dcl-S Tot_Fields          Int(10) ;
009700180509       Dcl-S Tot_Keys            Int(10) ;
009800180712       Dcl-S VarLen              Ind Inz('0');
009801180712       Dcl-S VarAdj              Int(10:0) Inz;
009900170730       Dcl-S X                   Packed(2:0);
010000170730       Dcl-S Y                   Packed(2:0);
010100180510       //*--------------------------------------------------------------------
010200180513       Dcl-Proc FLM003 EXPORT;
010300180510
010400180514         Dcl-PI FLM003               Char(2);
010500180514           FILEIN                   Char(10);
010600180514           LIBIN                    Char(10);
010700180514           RFMTIN                   Char(10);
010800180514         End-PI;
010900180514         //---------------------------------------------------------------------
011000180514         //* Get the fields for the file layout
011100180514         ExSR CrtCursor ;
011200180514         CallP OpenFLD() ;
011300180514         Rc = FetchMultFLD();
011400180514         CallP CloseFLD() ;
011500180514         If Tot_Fields > *Zero ; // If fields were found process the file layout
011600180514           Exec SQL
011700180514             Select ATTXT Into :ATTXTP
011800180514                    from FILES
011900180514                    Where ATFILE = :FILEIN AND ATLIB = :LIBIN ;
012000180514           //* Set up the Library/Member display field
012100180514           CLO64 = %Trim(LIBIN) + '/' + %Trim(FILEIN) ;
012200180514           CLO = NamCtr(CLO64:LOLEN) ; // Center
012300180514           FORMATN = FieldsDS(1).WHNAME ;
012400180514           SPOS = *ZERO;
012500180514           EPOS = *ZERO;
012600180514           //---------------------------------------------
012700180514           If Not %Open(FLD003) ; // Open display file
012800180514             Open FLD003 ;
012900180514           EndIf;
013000180514           ExSR BuildSFL01 ; // Build the display
013100180514           DoW SFL01IND = *ON ;
013200180514             XRRNS1 = 1;
013300180514             Write Heading;
013400180514             *IN27 = *ON;
013500180514             *IN28 = *ON;
013600180514             ExFmt CTL01 ;
013700180514             *IN27 = *OFF;
013800180514             *IN28 = *OFF;
013900180514             Error = *Blanks ;
014000180514             Select ;
014100180514             When *IN01 = *ON;
014200180514             When *IN06 = *ON;
014300180514               ExSR KeyCursor ;
014400180514               CallP OpenKEY() ;
014500180514               Rc = FetchMultKEY();
014600180514               CallP CloseKEY() ;
014700180514               If Tot_Keys > *Zero ; // If keys were found process the Key List
014800180516                 ExSR BuildSFL02;
014900180516               Else;
015000180516                 Error = 'No Key fields found' ;
015100180516               EndIf;
015200180606             When *IN05 = *ON;
015300180524               SFL01IND = *OFF;
015400180524               EOJ = 'CV' ;
015500180514             When *IN09 = *ON;
015600180517               DUPLEX = 'N';
015700180517               COPYS = 1;
015800180517               ExFMT WIN01;
015900180517               If *IN12 = *OFF;
016000180517                 EOJ = FLM002(FILEIN:LIBIN:RFMTIN:COPYS:DUPLEX);
016100180517                 Error = 'Layout for ' + %Trim(FILEIN) + '/' + %Trim(LIBIN) +
016200180517                         ' has printed' ;
016300180517               EndIf;
016400180514             When *IN12 = *ON ;
016500180514               SFL01IND = *OFF;
016600180514               EOJ = '12' ;
016700180514             EndSl;
016800180514           EndDo;
016900180514         EndIf ;
017000180514         Close FLD003 ;
017100180514         Return EOJ ;
017200180508       //*--------------------------------------------------------
017300180509       //* Create the Fields SQL cursor
017400180508       //*--------------------------------------------------------
017500180508       BegSr CrtCursor;
017600180508
017700180509          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
017800180712                   'WHFTXT, WHNULL, WHALIS, WHVARL ' +
017900180508                   'From FIELDS  Where WHFILE = ' + Ap + FileIN + Ap +
018000180508                   'For Read Only ' ;
018100180508
018200180508       EndSr;
018300180509       //*--------------------------------------------------------
018400180509       //* Create the SQL Keys Cursor
018500180509       //*--------------------------------------------------------
018600180509       BegSr KeyCursor;
018700180509
018800180517          CsrSel = 'Select APFILE, APLIB, APSYSN, APUNIQ, APKEYF, APKEYN ' +
018900180509                   'From KEYF ' +
019000180509                   'Where APFILE = ' + Ap + FileIN + Ap +
019100180509                   'For Read Only'  ;
019200180509
019300180509       EndSr;
019400180513       //*--------------------------------------------------------
019500180513       //* Build Subfile 01
019600180513       //*--------------------------------------------------------
019700180513       BegSr BuildSFL01;
019800180513         XRRNS1 = *Zero;
019900180513         *IN29 = *ON;
020000180513         Write CTL01;
020100180513         *IN29 = *OFF ;
020200180519         BYTES = *Zero;
020300180513         For P = 1 to Tot_Fields ;
020400180513           Clear DisplayDS ;
020500180513           If FieldsDS(P).WHNULL = 'Y'; //* TEST FOR NULL CAPABLE FIELD
020600180513             NULLYN = 'N/C';
020700180513           Else;
020800180513             NULLYN = *Blanks;
020900180513           EndIf;
021000180514           ATTR1 = White;
021100180513           WHFLDI = FieldsDS(P).WHFLDI;  // Field/Column name
021200180514           ATTR2 = Green;
021300180513           FTXT30 = FieldsDS(P).WHFTXT;  // Field/Column description
021400180513           WHFLDT = FieldsDS(P).WHFLDT;  // Field/Column data type
021500180513           // Check for numeric fields
021600180513           If FieldsDS(P).WHFLDT = 'B'
021700180513           or FieldsDS(P).WHFLDT = 'I'
021800180513           or FieldsDS(P).WHFLDT = 'P'
021900180513           or FieldsDS(P).WHFLDT = 'S'
022000180513           or FieldsDS(P).WHFLDT = 'U';
022100180513              WHFLDPC = %EditW(FieldsDS(P).WHFLDP:'0 ') ;
022200180513           Else;
022300180513              WHFLDPC = *Blanks;
022400180513           EndIf;
022500180513
022600180712           If FieldsDS(P).WHFLDT = 'A' ;
022700180712             If FieldsDS(P).WHVARL = 'Y' ;
022800180712               VarLen = *ON ;
022900180712               WHFLDT = 'V';
023000180712             Else;
023100180712               VarLen = *OFF;
023101180712             EndIf;
023200180712           EndIf;
023300180513           BYTES = BYTES + FieldsDS(P).WHFLDB; // Keep track of total bytes
023400180513           //* TEST FOR EVEN NUMBER OF BYTES IN A PACKED FIELD
023500180513           If EvenP = *OFF and FieldsDS(P).WHFLDT = 'P';
023600180513             If FieldsDS(P).WHFLDB <> *ZERO;
023700180513               Remain = %Rem(FieldsDS(P).WHFLDB:2) ;
023800180513               If Remain = *Zero ;
023900180513                 EvenP = *ON;
024000180513               EndIf;
024100180513             EndIf;
024200180513           EndIf;
024300180530           // Get the Length
024400180712           If VarLen = *ON;
024401180712             VarAdj = fieldsDS(P).WHFLDB - 2 ;
024500180712             EvalR WHFLDB = %Trim(%EditC(VarAdj:'Z')) ;
024600180712           Else;
024700180712             WHFLDB = %EditC(FieldsDS(P).WHFLDB:'Z') ;
024800180712           EndIf;
024900180513           // GET FROM/TO LOCATION
025000180513           If SPOS = *ZERO;
025100180513              EPOS = FieldsDS(P).WHFLDB;
025200180513              SPOS = 1;
025300180513           Else;
025400180513              SPOS = EPOS + 1;
025500180513              EPOS = EPOS + FieldsDS(P).WHFLDB;
025600180513           EndIf;
025700180514           SPOSC = %EditC(SPOS:'Z') ;
025800180514           EPOSC = %EditC(EPOS:'Z') ;
025900180514           SF01Data = DisplayD  ;
026000180513           XRRNS1 += 1;
026100180513           Write SFL01 ;
026200180514            If FieldsDS(P).WHALIS <> *Blanks; // Write SQL alias name
026300180514              AliasDSP = *Blanks;
026400180514              %SubSt(AliasDsp:9) = 'SQL Col:' + White + FieldsDS(P).WHALIS ;
026500180514              SF01Data = AliasDsp ;
026600180514              XRRNS1 += 1;
026700180514              Write SFL01 ;
026800180514            EndIf ;
026900180712           EndFor;
027000180513          SFL01IND = *ON ;
027100180513       EndSr;
027200180516       //*--------------------------------------------------------
027300180516       //* Build Subfile 02
027400180516       //*--------------------------------------------------------
027500180516       BegSr BuildSFL02;
027600180516         XRRNS2 = *Zero;
027700180516         *IN29 = *ON;
027800180516         Write CTL02;
027900180516         *IN29 = *OFF ;
028000180516         If KeysDS(1).APUNIQ = 'Y' ;
028100180516           UNIQYN = 'Unique';
028200180516         Else;
028300180516           UNIQYN = 'Arrival';
028400180516         EndIf;
028500180516         XRRNS2 = *Zero;
028600180516         For P = 1 to Tot_Keys ;
028700180516           SF02Data = KeysDS(P).APKEYF ;
028800180516           XRRNS2 += 1;
028900180516           Write SFL02 ;
029000180516         EndFor ;
029100180516         SFL02IND = *ON;
029200180516         Dow SFL02IND = *ON;
029300180516           XRRNS2 = 1;
029400180517           Write WIN02;
029500180516           *IN27 = *ON ;
029600180516           *IN28 = *ON ;
029700180516           ExFmt Ctl02;
029800180516           *IN27 = *OFF;
029900180516           *IN28 = *OFF;
030000180516           Select ;
030100180516           When *IN01 = *ON;
030200180516           When *IN12 = *ON;
030300180516             SFL02IND = *OFF;
030400180516           EndSL;
030500180516         EndDo;
030600180516       EndSR;
030700180508       //*--------------------------------------------------------
030800180513       End-Proc FLM003;
030900180508       //--------------------------------------------------------
031000180508       //  closeFLD - Close the call file cursor
031100180508       //--------------------------------------------------------
031200180508       Dcl-Proc closeFLD;
031300180508
031400180508       Dcl-PI closeFLD;
031500180508       End-PI;
031600180508
031700180509          Exec SQL close FLDCursor;
031800180508
031900180508       End-Proc closeFLD;
032000180508       //--------------------------------------------------------
032100180509       //  fetchMultFLD - read all the fields/Columns
032200180508       //--------------------------------------------------------
032300180508       Dcl-Proc fetchMultFLD;
032400180508
032500180508       Dcl-PI fetchMultFLD         Ind;
032600180508       End-PI;
032700180508
032800180508          Exec SQL
032900180509              fetch next from FLDCursor
033000180509              For :Mult_Fields rows
033100180509              into :FieldsDS;
033200180508          //
033300180509          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
033400180508          //
033500180508          If SQLSTT < '020000';
033600180508             Return *ON;
033700180508          Else;
033800180508             Return *OFF;
033900180508          EndIf;
034000180508          //
034100180508
034200180508       End-Proc fetchMultFLD;
034300180508       //---------------------------------------------------------------------
034400180509       //  openFLD  - Open a cursor to read the Fields/Columns
034500180508       //---------------------------------------------------------------------
034600180508       Dcl-Proc openFLD;
034700180508
034800180508       Dcl-PI openFLD;
034900180508       End-PI;
035000180508          Exec SQL prepare wkStatement from :CsrSel ;
035100180508          // *
035200180509          Exec SQL declare FLDCursor cursor for wkStatement ;
035300180508          // *
035400180509          Exec SQL open FLDCursor ;
035500180508          // *
035600180508          // *
035700180508       End-Proc openFLD;
035800180509       //--------------------------------------------------------
035900180509       //  closeKEY - Close the key file cursor
036000180509       //--------------------------------------------------------
036100180509       Dcl-Proc closeKEY;
036200180509
036300180509       Dcl-PI closeKEY;
036400180509       End-PI;
036500180509
036600180509          Exec SQL close KeyCursor;
036700180509
036800180509       End-Proc closeKEY;
036900180509       //--------------------------------------------------------
037000180509       //  fetchMultLKEY- read all the Key fields
037100180509       //--------------------------------------------------------
037200180509       Dcl-Proc fetchMultKEY;
037300180509
037400180509       Dcl-PI fetchMultKEY         Ind;
037500180509       End-PI;
037600180509
037700180509          Exec SQL
037800180509              fetch next from KeyCursor
037900180509              For :Mult_Keys rows
038000180509              into :KeysDS;
038100180509          //
038200180509          Exec SQL Get Diagnostics :Tot_Keys = ROW_COUNT ;
038300180509          //
038400180509          If SQLSTT < '020000';
038500180509             Return *ON;
038600180509          Else;
038700180509             Return *OFF;
038800180509          EndIf;
038900180509          //
039000180509
039100180510       End-Proc fetchMultKEY;
039200180509       //---------------------------------------------------------------------
039300180510       //  openKEY  - Open a cursor to read the Key records
039400180509       //---------------------------------------------------------------------
039500180510       Dcl-Proc openKEY;
039600180509
039700180510       Dcl-PI openKEY;
039800180509       End-PI;
039900180509          Exec SQL prepare wkStatekey from :CsrSel ;
040000180509          // *
040100180509          Exec SQL declare KeyCursor cursor for wkStatekey ;
040200180509          // *
040300180509          Exec SQL open KeyCursor ;
040400180509          // *
040500180509          // *
040600180510       End-Proc openKEY;
