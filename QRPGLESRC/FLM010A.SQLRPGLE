000100180514       Ctl-Opt DFTNAME(FLM010) NOMAIN ;
000200180514       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180514       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180514       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180514       // Generate Excel/.csv file
000600180514       // Prototypes
000700180514      /Copy QRPGLESRC,FLT001
000800180524       // SQL processing subprocedures
000900180524       Dcl-PR CloseFLD  End-PR;
001000180524       Dcl-PR FetchMultFLD  Ind End-PR;
001100180524       Dcl-PR OpenFLD  End-PR;
001200180524       // Data Sets for processing
001300180524       Dcl-DS FieldsDS Qualified Dim( 1000 ) ;
001400180524         WHNAME      Char(10) ;   // Record Format
001500180524         WHFLDI      Char(10) ;   // Internal Field Name
001600180524         WHFLDT      Char(1)  ;   // Field Type
001700180524         WHFLDB      Zoned(5:0) ; // Field Length in bytes
001800180524         WHFLDP      Zoned(2:0) ; // Field Decimal Positions
001900180524         WHFTXT      Char(50) ;   // Field text desrciption
002000180524         WHNULL      Char(1)  ;   // Field Null Y/N
002100180524         WHCHD1      Char(20) ;   // Field Col. Hdg. 1
002200180524         WHCHD2      Char(20) ;   // Field Col. Hdg. 2
002300180524         WHALIS      Char(32) ;   // SQL Alias field
002400180524       End-Ds;
002500180526       Dcl-DS FLP010DS EXTNAME('FLP010') Qualified INZ END-DS;
002600180514       // Stand Alone Fields
002700180524       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
002701180531       Dcl-S Chr        Char(1) Inz(X'6B'); // user selected delimiter
002800180528       Dcl-S Cma        Char(1) Inz(X'6B'); // comma ','
002900180528       Dcl-S CsrSel                Char(256); // SQL Cursor Def.
003000180528       Dcl-S CrLf       Char(2) Inz(X'0d25') ;
003100180528       Dcl-S CsvLine               Char(128) ;
003200180528       Dcl-S Qm         Char(1) Inz(X'7F'); // quotation mark '"'
003300180514       Dcl-S EOJ                   Char(2) ;
003400180528       Dcl-S FType                 Char(3) Inz('csv') ;
003500180530       Dcl-S LongPath              Char(90) ;
003600180524       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
003700180528       Dcl-S P                      Int(5) ;
003800180526       Dcl-S Rc                     Ind ;
003900180526       Dcl-S TextIn                Char(10) Inz('FLPEXCEL') ;
004000180526       Dcl-S TextLib               Char(10) Inz('DJDATA') ;
004100180524       Dcl-S Tot_Fields          Int(10) ;
004200180514       //*--------------------------------------------------------------------
004300180528       Dcl-Proc FLM010A EXPORT;
004400180528         Dcl-PI FLM010A              Char(2);
004500180528           FL10DSIN                 Char(176) ;
004600180526           ADDUPD                   Char(1);
004700180514         End-PI ;
004800180526         Exec Sql Set Option Commit = *None; // manage commitment control
004900180524         //---------------------------------------------------------------------
005000180524         // Get the fields for the file layout
005100180526         FLP010DS = FL10DSIN ; // Format the passed data
005200180528
005300180524         ExSR CrtCursor ;
005400180524         CallP OpenFLD() ;
005500180524         Rc = FetchMultFLD();
005600180524         CallP CloseFLD() ;
005700180531         If Tot_Fields > *Zero ; // If fields were found process the file layout
005800180531           ExSR CrtScriptT ; // Create the table to hold the new script
005801180531           If FLP010DS.FL1007 <> *Blanks;
005802180531             Chr = FLP010DS.FL1007;
005803180531           Else;
005804180531             Chr = Cma ;
005805180531           EndIf;
005901180531           If FLP010DS.FL1002 = 'Y' ;
005902180531             CsvLine = *Blanks ;
006000180531               CSVLINE = Qm + 'Field' + Qm + Chr +
006100180531                         Qm + 'Type' + Qm + Chr +
006200180531                         Qm + 'Length' + Qm + Chr +
006300180531                         Qm + 'Dec' + Qm + Chr +
006400180531                         Qm + 'Description' + Qm + Chr +
006500180531                         Qm + 'N/C' + Qm + Chr +
006600180531                         Qm + 'Colum H 1' + Qm + Chr +
006700180531                         Qm + 'Colum H 2' + Qm + Chr +
006800180531                         Qm + 'Alias' + Qm + CrLf ;
006900180531             Exec SQL
007000180531               Insert Into FLPEXCEL (FLEXC01) Values(:CSVLINE) ;
007001180531           EndIf;
007100180531           For P = 1  to Tot_Fields;
007200180528             CsvLine = *Blanks ;
007300180531             CSVLINE = Qm + %Trim(FieldsDS(P).WHFLDI) + Qm + Chr +
007400180531                       Qm + %Trim(FieldsDS(P).WHFLDT) + Qm + Chr +
007500180531                       %EditC(FieldsDS(P).WHFLDB:'Z') + Chr +
007600180531                       %EditW(FieldsDS(P).WHFLDP:'0 ') + Chr +
007700180531                       Qm + %Trim(FieldsDS(P).WHFTXT) + Qm + Chr +
007800180531                       Qm + FieldsDS(P).WHNULL + Qm + Chr +
007900180531                       Qm + %Trim(FieldsDS(P).WHCHD1) + Qm + Chr +
008000180531                       Qm + %Trim(FieldsDS(P).WHCHD2) + Qm + Chr +
008100180528                       Qm + %Trim(FieldsDS(P).WHALIS) + Qm + CrLf ;
008200180531             Exec SQL
008300180531               Insert Into FLPEXCEL (FLEXC01) Values(:CSVLINE) ;
008400180526           EndFor;
008500180530           LongPath = FLP010DS.FL1001 ;
008600180528           EOJ = FLM050(FLP010DS.FL1004
008700180528                        :FLP010DS.FL1005
008800180528                        :TEXTLIB
008900180528                        :TEXTIN
009000180530                        :LongPath
009100180526                        :FTYPE) ;
009200180524         EndIf;
009300180524         Return EOJ;
009400180524       //*--------------------------------------------------------
009500180524       //* Create the Fields SQL cursor
009600180524       //*--------------------------------------------------------
009700180524       BegSr CrtCursor;
009800180524
009900180524          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
010000180524                   'WHFTXT, WHNULL, WHCHD1, WHCHD2, WHALIS ' +
010100180528                   'From   FIELDS  Where WHFILE = ' + Ap +
010200180528                   %Trim(FLP010DS.FL1005) + Ap + ' For Read Only ' ;
010300180524
010400180524       EndSr;
010500180526       //*--------------------------------------------------------
010600180526       //* Create the script table
010700180526       //*--------------------------------------------------------
010800180526       BegSr CrtScriptT;
010900180526
011000180529         Exec SQL
011100180529           DROP TABLE DJDATA.FLPEXCEL ;
011200180526         Exec SQL
011300180529           CREATE TABLE DJDATA.FLPEXCEL (
011400180528           Script_Text FOR FLEXC01 CHAR(128) NOT NULL DEFAULT '') ;
011500180526         Exec SQL
011600180526           LABEL ON TABLE DJDATA.FLPEXCEL
011700180526                 IS 'File Layout Excel Script' ;
011800180526         Exec SQL
011900180526           LABEL ON COLUMN DJDATA.FLPEXCEL (
012000180526             FLEXC01 TEXT IS 'EXCEL SCRIPT ROWS') ;
012100180526         Exec SQL
012200180526            LABEL ON COLUMN DJDATA.FLPEXCEL (
012300180526             FLEXC01 IS 'Excel script') ;
012400180526
012500180526       EndSr;
012600180526       //*--------------------------------------------------------
012700180528       End-Proc FLM010A ;
012800180524       //--------------------------------------------------------
012900180524       //  closeFLD - Close the call file cursor
013000180524       //--------------------------------------------------------
013100180524       Dcl-Proc closeFLD;
013200180524
013300180524       Dcl-PI closeFLD;
013400180524       End-PI;
013500180524
013600180524          Exec SQL close FLDCursor;
013700180524
013800180524       End-Proc closeFLD;
013900180524       //--------------------------------------------------------
014000180524       //  fetchMultFLD - read all the fields/Columns
014100180524       //--------------------------------------------------------
014200180524       Dcl-Proc fetchMultFLD;
014300180524
014400180524       Dcl-PI fetchMultFLD         Ind;
014500180524       End-PI;
014600180524
014700180524          Exec SQL
014800180524              fetch next from FLDCursor
014900180524              For :Mult_Fields rows
015000180524              into :FieldsDS;
015100180524          //
015200180524          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
015300180524          //
015400180524          If SQLSTT < '020000';
015500180524             Return *ON;
015600180524          Else;
015700180524             Return *OFF;
015800180524          EndIf;
015900180524          //
016000180524
016100180524       End-Proc fetchMultFLD;
016200180524       //---------------------------------------------------------------------
016300180524       //  openFLD  - Open a cursor to read the Fields/Columns
016400180524       //---------------------------------------------------------------------
016500180524       Dcl-Proc openFLD;
016600180524
016700180524       Dcl-PI openFLD;
016800180524       End-PI;
016900180524          Exec SQL prepare wkStatement from :CsrSel ;
017000180524          // *
017100180524          Exec SQL declare FLDCursor cursor for wkStatement ;
017200180524          // *
017300180524          Exec SQL open FLDCursor ;
017400180524          // *
017500180524          // *
017600180524       End-Proc openFLD;
