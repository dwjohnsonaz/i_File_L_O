000100180530       Ctl-Opt DFTNAME(FLM025A) NOMAIN ;
000200180514       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180514       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180514       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180529       // Generate XML .xml table
000600180514       // Prototypes
000700180514      /Copy QRPGLESRC,FLT001
000800180529       // SQL processing subprocedures
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
002500180530       Dcl-DS FLP025DS EXTNAME('FLP025') Qualified INZ END-DS;
002600180514       // Stand Alone Fields
002700180524       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
002800180528       Dcl-S Cma        Char(1) Inz(X'6B'); // comma ','
002801180530       Dcl-S Cln        Char(1) Inz(X'7A'); // colon
002900180528       Dcl-S CsrSel                Char(256); // SQL Cursor Def.
003000180528       Dcl-S CrLf       Char(2) Inz(X'0d25') ;
003100180528       Dcl-S Qm         Char(1) Inz(X'7F'); // quotation mark '"'
003200180514       Dcl-S EOJ                   Char(2) ;
003300180530       Dcl-S FType                 Char(3) ;
003400180524       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
003500180528       Dcl-S P                      Int(5) ;
003600180529       Dcl-S Pos                    Int(5) ;
003700180526       Dcl-S Rc                     Ind ;
003701180530       Dcl-S Smc        Char(1) Inz(X'5E'); // semi-colon
003800180530       Dcl-S TextIn                Char(10) Inz('FLPJSON') ;
003900180526       Dcl-S TextLib               Char(10) Inz('DJDATA') ;
004000180524       Dcl-S Tot_Fields          Int(10) ;
004100180530       Dcl-S JSONLINE               Char(128) ;
004200180514       //*--------------------------------------------------------------------
004300180530       Dcl-Proc FLM025A EXPORT;
004400180530         Dcl-PI FLM025A              Char(2);
004500180530           FL25DSIN                  Char(285) ;
004600180529           ADDUPD                    Char(1);
004700180514         End-PI ;
004800180526         Exec Sql Set Option Commit = *None; // manage commitment control
004900180524         //---------------------------------------------------------------------
005000180524         // Get the fields for the file layout
005100180530         FLP025DS = FL25DSIN ; // Format the passed data
005200180528
005300180524         ExSR CrtCursor ;
005400180524         CallP OpenFLD() ;
005500180524         Rc = FetchMultFLD();
005600180524         CallP CloseFLD() ;
005700180524         If Tot_Fields > *Zero ; // If fields were found process the file layout
005800180526           ExSR CrtScriptT ; // Create the table to hold the new script
005900180530           JSONLINE = *Blanks ;
006000180530           // JSON heading 1
006001180531           JSONLINE = ' {' + CrLf ;
006002180531           Exec SQL
006003180531             Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
006004180531           // JSON heading 2
006005180531           JSONLINE = *Blanks ;
006006180531           POS = 3;
006100180531           %SubSt(JSONLINE:Pos) = %Trim(FLP025DS.FL2506) + Cma + CrLf ;
006200180528           Exec SQL
006300180530             Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
006400180531           // JSON heading 3
006500180530           JSONLINE = *Blanks ;
006501180531           POS = 3;
006502180531           %SubSt(JSONLINE:Pos) = Qm + 'title' + Qm + ': ' + Qm +
006503180531             %Trim(FLP025DS.FL2507) + Qm + Cma + CrLf ;
006504180531           Exec SQL
006505180531             Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
006506180531           // JSON heading 4
006507180531           JSONLINE = *Blanks ;
006508180531           POS = 3;
006509180531           %SubSt(JSONLINE:Pos) = Qm + 'description' + Qm + ': ' + Qm +
006510180531                 %Trim(FLP025DS.FL2505) + Qm + Cma +CrLf ;
006511180531           Exec SQL
006512180531             Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
006513180531           // JSON heading 5
006514180531           JSONLINE = *Blanks ;
006515180531           POS = 3;
006600180531           %SubSt(JSONLINE:Pos)   = Qm + 'type' + Qm + ': ' + Qm + 'Object' +
006601180531             Qm + Cma + CrLf ;
006700180529           Exec SQL
006800180530             Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
006801180531           // JSON heading 6
006802180531           JSONLINE = *Blanks ;
006803180531           POS = 3;
006804180531           JSONLINE = ' }' + CrLf ;
006805180531           Exec SQL
006806180531             Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
006900180531           // JSON heading 7
007000180530           JSONLINE = *Blanks;
007200180530           JSONLINE =  Qm + 'properties' + Qm + ': ' + '{' + CrLf ;
007400180529           Exec SQL
007500180530             Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
007600180529           //------------------------------------------------------------------
007700180528           For P = 1  to Tot_Fields;
007800180530             JSONLINE = *Blanks ;
007900180530             Pos = 5 ;
007901180530             Select ;
008000180530               When FIELDSDS(P).WHFLDT = 'A' ;
008001180530                 If FIELDSDS(P).WHALIS <> *Blanks ;
008200180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHALIS) + Qm +
008300180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'String' + Qm + '}' +
008301180530                 Cma + CrLf ;
008401180530               Else;
008402180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHFLDI) + Qm +
008403180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'String' + Qm + '}' +
008404180530                 Cma + CrLf ;
008801180530               EndIf;
008802180530               When FIELDSDS(P).WHFLDT = 'B' ;
008803180530                 If FIELDSDS(P).WHALIS <> *Blanks ;
008804180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHALIS) + Qm +
008805180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'integer' + Qm + '}' +
008806180530                 Cma + CrLf ;
008807180530               Else;
008808180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHFLDI) + Qm +
008809180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'integer' + Qm + '}' +
008810180530                 Cma + CrLf ;
008811180530               EndIf;
008812180530               When FIELDSDS(P).WHFLDT = 'I' ;
008813180530                 If FIELDSDS(P).WHALIS <> *Blanks ;
008814180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHALIS) + Qm +
008815180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'integer' + Qm + '}' +
008816180530                 Cma + CrLf ;
008817180530               Else;
008818180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHFLDI) + Qm +
008819180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'integer' + Qm + '}' +
008820180530                 Cma + CrLf ;
008821180530               EndIf;
008822180530               When FIELDSDS(P).WHFLDT = 'L' ;
008823180530                 If FIELDSDS(P).WHALIS <> *Blanks ;
008824180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHALIS) + Qm +
008825180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'String' + Qm + '}' +
008826180530                 Cma + CrLf ;
008827180530               Else;
008828180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHFLDI) + Qm +
008829180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'String' + Qm + '}' +
008830180530                 Cma + CrLf ;
008831180530               EndIf;
008832180530               When FIELDSDS(P).WHFLDT = 'P' ;
008833180530                 If FIELDSDS(P).WHALIS <> *Blanks ;
008834180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHALIS) + Qm +
008835180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'number' + Qm + '}' +
008836180530                 Cma + CrLf ;
008837180530               Else;
008838180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHFLDI) + Qm +
008839180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'number' + Qm + '}' +
008840180530                 Cma + CrLf ;
008841180530               EndIf;
008842180530               When FIELDSDS(P).WHFLDT = 'S' ;
008843180530                 If FIELDSDS(P).WHALIS <> *Blanks ;
008844180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHALIS) + Qm +
008845180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'number' + Qm + '}' +
008846180530                 Cma + CrLf ;
008847180530               Else;
008848180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHFLDI) + Qm +
008849180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'number' + Qm + '}' +
008850180530                 Cma + CrLf ;
008851180530               EndIf;
008852180530               When FIELDSDS(P).WHFLDT = 'Z' ;
008853180530                 If FIELDSDS(P).WHALIS <> *Blanks ;
008854180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHALIS) + Qm +
008855180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'String' + Qm + '}' +
008856180530                 Cma + CrLf ;
008857180530               Else;
008858180530                 %Subst(JSONLINE:Pos) = Qm + %Trim(FIELDSDS(P).WHFLDI) + Qm +
008859180530                 ': {' + Qm + 'type' + Qm + ': ' + Qm + 'String' + Qm + '}' +
008860180530                 Cma + CrLf ;
008861180530               EndIf;
008862180530             EndSL;
011000180530             Exec SQL
011100180530               Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
011200180526           EndFor;
011300180530           JSONLINE = *Blanks;
011400180530           Pos = 3 ;
011500180530           %Subst(JSONLINE:Pos) = '}' + CrLf ;
011600180530           Exec SQL
011700180530             Insert Into FLPJSON (FLJSN01) Values(:JSONLINE) ;
011701180530
012300180530           If FLP025DS.FL2509 = *Blanks;
012400180530             FTYPE = 'jsn' ;
012500180530           Else ;
012600180530             FTYPE = FLP025DS.FL2509 ;
012700180530           EndIf;
012800180530           EOJ = FLM050(FLP025DS.FL2502
012900180530                        :FLP025DS.FL2503
013000180528                        :TEXTLIB
013100180528                        :TEXTIN
013200180530                        :FLP025DS.FL2508
013300180526                        :FTYPE) ;
013400180524         EndIf;
013500180524         Return EOJ;
013600180524       //*--------------------------------------------------------
013700180524       //* Create the Fields SQL cursor
013800180524       //*--------------------------------------------------------
013900180524       BegSr CrtCursor;
014000180524
014100180524          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
014200180524                   'WHFTXT, WHNULL, WHCHD1, WHCHD2, WHALIS ' +
014300180530                   'From FIELDS  Where WHFILE = ' + Ap +
014400180530                   %Trim(FLP025DS.FL2503) + Ap + ' For Read Only ' ;
014500180524
014600180524       EndSr;
014700180526       //*--------------------------------------------------------
014800180526       //* Create the script table
014900180526       //*--------------------------------------------------------
015000180526       BegSr CrtScriptT;
015100180526
015200180529         Exec SQL
015300180530           DROP TABLE DJDATA.FLPJSON ;
015400180526         Exec SQL
015500180530           CREATE TABLE DJDATA.FLPJSON (
015600180530           Script_Text FOR FLJSN01 CHAR(128) NOT NULL DEFAULT '') ;
015700180526         Exec SQL
015800180530           LABEL ON TABLE DJDATA.FLPJSON
015900180530                 IS 'JSON Schema Script' ;
016000180526         Exec SQL
016100180530           LABEL ON COLUMN DJDATA.FLPJSON (
016200180530             FLJSN01 TEXT IS 'JSON SCRIPT ROWS') ;
016300180526         Exec SQL
016400180530            LABEL ON COLUMN DJDATA.FLPJSON (
016500180530             FLJSN01 IS 'JSON script') ;
016600180526
016700180526       EndSr;
016800180526       //*--------------------------------------------------------
016900180530       End-Proc FLM025A ;
017000180524       //--------------------------------------------------------
017100180524       //  closeFLD - Close the call file cursor
017200180524       //--------------------------------------------------------
017300180524       Dcl-Proc closeFLD;
017400180524
017500180524       Dcl-PI closeFLD;
017600180524       End-PI;
017700180524
017800180524          Exec SQL close FLDCursor;
017900180524
018000180524       End-Proc closeFLD;
018100180524       //--------------------------------------------------------
018200180524       //  fetchMultFLD - read all the fields/Columns
018300180524       //--------------------------------------------------------
018400180524       Dcl-Proc fetchMultFLD;
018500180524
018600180524       Dcl-PI fetchMultFLD         Ind;
018700180524       End-PI;
018800180524
018900180524          Exec SQL
019000180524              fetch next from FLDCursor
019100180524              For :Mult_Fields rows
019200180524              into :FieldsDS;
019300180524          //
019400180524          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
019500180524          //
019600180524          If SQLSTT < '020000';
019700180524             Return *ON;
019800180524          Else;
019900180524             Return *OFF;
020000180524          EndIf;
020100180524          //
020200180524
020300180524       End-Proc fetchMultFLD;
020400180524       //---------------------------------------------------------------------
020500180524       //  openFLD  - Open a cursor to read the Fields/Columns
020600180524       //---------------------------------------------------------------------
020700180524       Dcl-Proc openFLD;
020800180524
020900180524       Dcl-PI openFLD;
021000180524       End-PI;
021100180524          Exec SQL prepare wkStatement from :CsrSel ;
021200180524          // *
021300180524          Exec SQL declare FLDCursor cursor for wkStatement ;
021400180524          // *
021500180524          Exec SQL open FLDCursor ;
021600180524          // *
021700180524          // *
021800180524       End-Proc openFLD;
