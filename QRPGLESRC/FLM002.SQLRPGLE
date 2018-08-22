000100180508       Ctl-Opt DFTNAME(FLM002) NOMAIN ;
000200171016       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300171016       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400171016       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180508       // Generate File/Table layouts
000600180510       //Dcl-F FILES                  USROPN;
000700180508       //Dcl-F FIELDSI                Keyed USROPN;
000800180508       //Dcl-F KEYF                   USROPN;
000900180510       Dcl-F FLO002 Printer OflInd(*IN99) USROPN ;
001000080228       // Prototypes
001100080228      /Copy QRPGLESRC,FLT001
001200180508      /Copy QRPGLESRC,UTT001
001300180514       Dcl-PR SysCmd                Int(10:0) ExtProc('system');
001400180513         Cmd                   Pointer Value Options(*String);
001500180513       End-PR;
001600171016       // SQL processing subprocedures
001700180508       Dcl-PR CloseFLD  End-PR;
001800180509       Dcl-PR CloseKEY  End-PR;
001900180508       Dcl-PR FetchMultFLD  Ind;
002000171016       End-PR;
002100180509       Dcl-PR FetchMultKEY  Ind;
002200180509       End-PR;
002300180508       Dcl-PR OpenFLD  End-PR;
002400180509       Dcl-PR OpenKEY  End-PR;
002500180508       // Data Sets for processing
002600180508       Dcl-DS FieldsDS Qualified Dim( 1000 ) ;
002700180508         WHNAME      Char(10) ;   // Record Format
002800180508         WHFLDI      Char(10) ;   // Internal Field Name
002900180508         WHFLDT      Char(1)  ;   // Field Type
003000180508         WHFLDB      Zoned(5:0) ; // Field Length in bytes
003100180508         WHFLDP      Zoned(2:0) ; // Field Decimal Positions
003200180510         WHFTXT      Char(50) ;   // Field text desrciption
003300180509         WHNULL      Char(1)  ;   // Field Null Y/N
003400180509         WHALIS      Char(32) ;   // SQL Alias field
003401180712         WHVARL      Char(1)  ;   // Variable length field
003500180508       End-Ds;
003600180509       Dcl-DS KeysDS Qualified Dim( 10 ) ;
003700180509         APFILE      Char(10) ;   // Record Format
003800180509         APLIB       Char(10) ;   // Library Name
003900180514         APSYSN      Char(8)  ;   // System Name
004000180514         APUNIQ      Char(1)  ;   // Key field Name Unique Y/N
004100180509         APKEYF      Char(10) ;   // Key field Name
004200180514         APKEYN    Packed(3)  ;   // Key field Name seq. No.
004300180509       End-Ds;
004400170730       // Stand Alone Fields
004500180510       // Character - apostrophe
004600180510       Dcl-C AP         const(X'7D'); // apostrophe '''
004700170730       Dcl-S BEGIN                 Char(1);
004800170730       Dcl-S BYTES               Packed(5:0);
004900180510       Dcl-S CLO64                 Char(64) ;
005000180510       Dcl-S CMD                   Char(256) ;
005100180510       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
005200171016       Dcl-S CsrSel                Char(256);                               // SQL Cursor Def.
005300180508       Dcl-S Decimal                Ind ;
005400170730       Dcl-S EOJ                   Char(2);
005500170730       Dcl-S EPOS                Packed(4:0);
005600180509       Dcl-S EvenP                  Ind ;
005700180508       Dcl-S First                  Ind Inz('1') ;
005800170730       Dcl-S FTXT30                Char(30);
005900170730       Dcl-S KEYYN                 Char(1);
006000170730       Dcl-S LIBOBJ                Char(21);
006100180510       Dcl-S LOLEN                 Int(10) Inz(21) ;
006200170730       Dcl-S LO01                  Char(11);
006300180509       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
006400180509       Dcl-S Mult_Keys              Int(5) Inz( 10 );
006500170730       Dcl-S NULLYN                Char(3);
006600170730       Dcl-S NUM                 Packed(2:0);
006700180509       Dcl-S ODDEVEN               Char(1) Inz('O');
006800180508       Dcl-S P                     Int(5) ;
006900180510       Dcl-S PAGENO                Int(5) ;
007000170730       Dcl-S Q                     Char(1);
007100170730       Dcl-S RB4                   Char(1) DIM(21);
007200180510       Dcl-S Rc                    Ind ;
007300170730       Dcl-S RELREC              Packed(7:0) INZ(1);
007400180509       Dcl-S REMAIN              Int(10) ;
007500170730       Dcl-S RESULT              Packed(7:0);
007600170730       Dcl-S SPOS                Packed(4:0);
007700180510       Dcl-S TESTI               Int(5) ;
007800170730       Dcl-S TIME                Packed(6:0);
007900180509       Dcl-S Tot_Fields          Int(10) ;
008000180509       Dcl-S Tot_Keys            Int(10) ;
008001180712       Dcl-S VarLen              Ind Inz('0');
008002180712       Dcl-S VarAdj              Int(10:0) Inz;
008100170730       Dcl-S X                   Packed(2:0);
008200170730       Dcl-S Y                   Packed(2:0);
008300180510       //*--------------------------------------------------------------------
008400080228       Dcl-Proc FLM002 EXPORT;
008500180510
008600170322       Dcl-PI FLM002               Char(2);
008700170730          FILEIN                   Char(10);
008800170730          LIBIN                    Char(10);
008900170730          RFMTIN                   Char(10);
009000180517          COPYS                  Packed(2);
009100170322          DUPLEX                   Char(1);
009200170322       End-PI;
009300000000       //---------------------------------------------------------------------
009400180509       //* Get the fields for the file layout
009500180510       ExSR CrtCursor ;
009600180508       CallP OpenFLD() ;
009700180508       Rc = FetchMultFLD();
009800180509       CallP CloseFLD() ;
009900180509       If Tot_Fields > *Zero ; // If fields were found process the file layout
009901180725         *IN99 = *OFF;
010000180510         Exec SQL
010100180510           Select ATTXT Into :ATTXTP
010200180510                  from FILES
010300180510                  Where ATFILE = :FILEIN AND ATLIB = :LIBIN ;
010400180510         //* Set up the three Library/Member display fields
010500180510         EvalR RLO = %TrimR(LIBIN) + '/' + %TrimR(FILEIN) ;  // right adj.
010600180510         LLO = %Trim(LIBIN) + '/' + %Trim(FILEIN) ; // Left adj.
010700180510         CLO64 = LLO;
010800180510         CLO = NamCtr(CLO64:LOLEN) ; // Center
010900180510         FORMATN = FieldsDS(1).WHNAME ;
011000180510         PAGENO = 1;
011100180510         SPOS = *ZERO;
011200180510         EPOS = *ZERO;
011300180517         ExSR OpenFLO002 ;
011400180510         Write HEADO1;  // Write the ODD page # Header
011500180510         Write HEADO2;  // Write file description line
011600180510         Write HEADO3;  // Write the field/column headings
011700180510         For P = 1 to Tot_Fields ;
011701180712           VarLen = *OFF;
011800180509           // Check for numeric fields
011900180509           If FieldsDS(P).WHFLDT = 'B'
012000180509           or FieldsDS(P).WHFLDT = 'I'
012100180509           or FieldsDS(P).WHFLDT = 'P'
012200180510           or FieldsDS(P).WHFLDT = 'S'
012300180509           or FieldsDS(P).WHFLDT = 'U';
012400180513              WHFLDPC = %EditW(FieldsDS(P).WHFLDP:'0 ') ;
012500180509           Else;
012600180509              WHFLDPC = *Blanks;
012700180509           EndIf;
012801180712           If FieldsDS(P).WHFLDT = 'A' ;
012802180712             If FieldsDS(P).WHVARL = 'Y' ;
012803180712               VarLen = *ON ;
012804180712               WHFLDT = 'V';
012807180712             EndIf;
012808180712           EndIf;
012900180509           FTXT30 = FieldsDS(P).WHFTXT;  // Feld description
013000180509           BYTES = BYTES + FieldsDS(P).WHFLDB; // Keep track of total bytes
013100180509           If FieldsDS(P).WHNULL = 'Y'; //* TEST FOR NULL CAPABLE FIELD
013200180510             NULLYN = 'N/C';
013300180509           Else;
013400180510             NULLYN = *Blanks;
013500180509           EndIf;
013600180509           //* TEST FOR EVEN NUMBER OF BYTES IN A PACKED FIELD
013700180510           If EvenP = *OFF and FieldsDS(P).WHFLDT = 'P';
013800180509             If FieldsDS(P).WHFLDB <> *ZERO;
013900180509               Remain = %Rem(FieldsDS(P).WHFLDB:2) ;
014000180509               If Remain = *Zero ;
014100180509                 EvenP = *ON;
014200180509               EndIf;
014300180509             EndIf;
014400180509           EndIf;
014500180509           // GET FROM/TO LOCATION
014600180509           If SPOS = *ZERO;
014700180513              EPOS = FieldsDS(P).WHFLDB;
014800180509              SPOS = 1;
014900180509           Else;
015000180509              SPOS = EPOS + 1;
015100180513              EPOS = EPOS + FieldsDS(P).WHFLDB;
015200180509           EndIf;
015300180509           // Capture printer fields
015400180510           WHFLDI = FieldsDS(P).WHFLDI;
015401180712           If VarLen = *ON ;
015500180712             WHFLDT = 'V' ;
015501180712           Else;
015502180712             WHFLDT = FieldsDS(P).WHFLDT;
015503180712           EndIf;
015504180712           // Get the Length
015505180712           If VarLen = *ON;
015506180712             WHFLDB = fieldsDS(P).WHFLDB - 2 ;
015508180712           Else;
015509180712             WHFLDB = fieldsDS(P).WHFLDB ;
015510180712           EndIf;
015700180509           If ODDEVEN = 'O' ; // Write using odd page number format
015800180509             Write DetailO ;
015900180510             If FieldsDS(P).WHALIS <> *Blanks; // Write SQL alias name
016000180513               WHALIS = 'SQL Col: ' + FieldsDS(P).WHALIS ;
016100180509               Write DetailOS ;
016200180509             EndIf;
016300180509           Else ; // Write using even page number format
016400180509             Write DetailE ;
016500180510             If FieldsDS(P).WHALIS <> *Blanks; // Write SQL alias name
016600180513               WHALIS = 'SQL Col: ' + FieldsDS(P).WHALIS ;
016700180509               Write DetailES ;
016800180509             EndIf ;
016900180509           EndIf ;
017000180509           If *IN99 = *ON and P < Tot_Fields ;
017100180514             ExSR WriteHDG ;
017200180514             *IN99 = *OFF ;
017300180514           EndIf;
017400170730             //
017500180509          EndFor;
017600180510          //* Write key information
017700180509         ExSR KeyCursor ;
017800180509         CallP OpenKEY() ;
017900180509         Rc = FetchMultKEY();
018000180509         CallP CloseKEY() ;
018100180509         If Tot_Keys > *Zero ; // If keys were found process the Key List
018200180514           IF *IN99 = *ON ;
018300180514             ExSR WriteHDG ;
018400180514             *IN99 = *OFF ;
018500180514           EndIf ;
018600180514           If KeysDS(1).APUNIQ = 'Y' ;
018700180514             UNIQYN = 'Unique';
018800180514           Else;
018900180514             UNIQYN = 'Arrival';
019000180514           EndIf;
019100180514           Write KEYHED ;
019200180514           For P = 1 to Tot_Keys ;
019300180514             APKEYF = KeysDS(P).APKEYF ;
019400180514             Write KEYDET ;
019500180509           EndFor ;
019600180514         Endif ;
019700180514         If Bytes > *Zero ;
019800180514           FileSize = 'There are ' + %Trim(%EditC(Bytes:'Z')) +
019900180514                      ' bytes in the table.' ;
020000180514           Write TOTAL1 ;
020100180514         EndIf;
020200180514         If EvenP = *ON ;
020300180514           Warning = '*** Warning - This File/Table contains even numbered ' +
020400180514                     'packed fields ***' ;
020500180514           Write WARN01 ;
020600180514         EndIf;
020700180510         ExSR CloseFLO002 ;
020800180509       EndIf ;
020900180509       Return EOJ ;
021000180510       //*--------------------------------------------------------
021100180510       //* Open FLO002 - open the printer file
021200180510       //*--------------------------------------------------------
021300180510       BegSR OpenFLO002;
021400180510         // Override the printer file if necessary
021500180510         If DUPLEX = 'Y' ;
021600180517         Cmd = 'OVRPRTF FILE(FLO002) PAGRTT(0) DUPLEX(*YES) ' +
021700180517                 'COPIES(' + %Trim(%EditC(COPYS:'Z')) + ')' ;
021800180513           CallP SysCmd(Cmd) ;
021900180517         Else;
022000180517           If Copys > 1 ;
022100180517             Cmd = 'OVRPRTF FILE(FLO002) PAGRTT(0) ' +
022200180517                   'COPIES(' + %Trim(%EditC(COPYS:'Z')) + ')' ;
022300180517           EndIf;
022400180510         EndIf ;
022500180510
022600180510         Open FLO002;
022700180510
022800180510       EndSR ;
022900180510       //*--------------------------------------------------------
023000180514       //* Close FLO002 - close the printer file
023100180510       //*--------------------------------------------------------
023200180510       BegSR CloseFLO002;
023300180510
023400180510         // Delete the printer file override if necessary
023500180510         If Duplex = 'Y' ;
023600180513           Cmd = 'DLTOVR FILE(FLO002) '  ;
023700180513           CallP SysCmd(Cmd) ;
023800180510         EndIf ;
023900180510
024000180510         Close FLO002;
024100180510
024200180510       EndSR ;
024300180514       //*--------------------------------------------------------
024400180514       //* Write page headings
024500180514       //*--------------------------------------------------------
024600180514       BegSR WriteHdg ;
024700180514             PAGENO = PAGENO + 1;
024800180514             If Duplex = 'Y';
024900180514               Remain = %Rem(PAGENO:2) ;
025000180514               If Remain = *ZERO;
025100180514                 ODDEVEN = 'E' ;
025200180514               Else;
025300180514                 ODDEVEN = 'O' ;
025400180514               EndIf;
025500180514             EndIf;
025600180514             // Write HEDINGS;
025700180514             If ODDEVEN = 'O' ;
025800180514               Write HEADO1;  // Write the Odd page # Headers
025900180514               Write HEADO2;  // Write file description line
026000180514               Write HEADO3;  // Write the field/column headings
026100180514             Else;
026200180514               Write HEADE1;  // Write the Even page # Header
026300180514               Write HEADE2;  // Write file description line
026400180514               Write HEADE3;  // Write the field/column headings
026500180514             EndIf;
026600180514       EndSR ;
026700180508       //*--------------------------------------------------------
026800180509       //* Create the Fields SQL cursor
026900180508       //*--------------------------------------------------------
027000180508       BegSr CrtCursor;
027100180508
027200180509          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
027300180712                   'WHFTXT, WHNULL, WHALIS, WHVARL ' +
027400180508                   'From FIELDS  Where WHFILE = ' + Ap + FileIN + Ap +
027500180508                   'For Read Only ' ;
027600180508
027700180508       EndSr;
027800180509       //*--------------------------------------------------------
027900180509       //* Create the SQL Keys Cursor
028000180509       //*--------------------------------------------------------
028100180509       BegSr KeyCursor;
028200180514
028300180514          CsrSel = 'Select APFILE, APLIB, APSYSN, APUNIQ, APKEYF, APKEYN ' +
028400180509                   'From KEYF ' +
028500180509                   'Where APFILE = ' + Ap + FileIN + Ap +
028600180509                   'For Read Only'  ;
028700180509
028800180509       EndSr;
028900180508       //*--------------------------------------------------------
029000170730       End-Proc FLM002;
029100180508       //--------------------------------------------------------
029200180508       //  closeFLD - Close the call file cursor
029300180508       //--------------------------------------------------------
029400180508       Dcl-Proc closeFLD;
029500180508
029600180508       Dcl-PI closeFLD;
029700180508       End-PI;
029800180508
029900180509          Exec SQL close FLDCursor;
030000180508
030100180508       End-Proc closeFLD;
030200180508       //--------------------------------------------------------
030300180509       //  fetchMultFLD - read all the fields/Columns
030400180508       //--------------------------------------------------------
030500180508       Dcl-Proc fetchMultFLD;
030600180508
030700180508       Dcl-PI fetchMultFLD         Ind;
030800180508       End-PI;
030900180508
031000180508          Exec SQL
031100180509              fetch next from FLDCursor
031200180509              For :Mult_Fields rows
031300180509              into :FieldsDS;
031400180508          //
031500180509          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
031600180508          //
031700180508          If SQLSTT < '020000';
031800180508             Return *ON;
031900180508          Else;
032000180508             Return *OFF;
032100180508          EndIf;
032200180508          //
032300180508
032400180508       End-Proc fetchMultFLD;
032500180508       //---------------------------------------------------------------------
032600180509       //  openFLD  - Open a cursor to read the Fields/Columns
032700180508       //---------------------------------------------------------------------
032800180508       Dcl-Proc openFLD;
032900180508
033000180508       Dcl-PI openFLD;
033100180508       End-PI;
033200180508          Exec SQL prepare wkStatement from :CsrSel ;
033300180508          // *
033400180509          Exec SQL declare FLDCursor cursor for wkStatement ;
033500180508          // *
033600180509          Exec SQL open FLDCursor ;
033700180508          // *
033800180508          // *
033900180508       End-Proc openFLD;
034000180509       //--------------------------------------------------------
034100180509       //  closeKEY - Close the key file cursor
034200180509       //--------------------------------------------------------
034300180509       Dcl-Proc closeKEY;
034400180509
034500180509       Dcl-PI closeKEY;
034600180509       End-PI;
034700180509
034800180509          Exec SQL close KeyCursor;
034900180509
035000180509       End-Proc closeKEY;
035100180509       //--------------------------------------------------------
035200180509       //  fetchMultLKEY- read all the Key fields
035300180509       //--------------------------------------------------------
035400180509       Dcl-Proc fetchMultKEY;
035500180509
035600180509       Dcl-PI fetchMultKEY         Ind;
035700180509       End-PI;
035800180509
035900180509          Exec SQL
036000180509              fetch next from KeyCursor
036100180509              For :Mult_Keys rows
036200180509              into :KeysDS;
036300180509          //
036400180509          Exec SQL Get Diagnostics :Tot_Keys = ROW_COUNT ;
036500180509          //
036600180509          If SQLSTT < '020000';
036700180509             Return *ON;
036800180509          Else;
036900180509             Return *OFF;
037000180509          EndIf;
037100180509          //
037200180509
037300180510       End-Proc fetchMultKEY;
037400180509       //---------------------------------------------------------------------
037500180510       //  openKEY  - Open a cursor to read the Key records
037600180509       //---------------------------------------------------------------------
037700180510       Dcl-Proc openKEY;
037800180509
037900180510       Dcl-PI openKEY;
038000180509       End-PI;
038100180509          Exec SQL prepare wkStatekey from :CsrSel ;
038200180509          // *
038300180509          Exec SQL declare KeyCursor cursor for wkStatekey ;
038400180509          // *
038500180509          Exec SQL open KeyCursor ;
038600180509          // *
038700180509          // *
038800180510       End-Proc openKEY;
