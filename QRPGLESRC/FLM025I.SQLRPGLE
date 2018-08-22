000100180607       Ctl-Opt DFTNAME(FLM025I) NOMAIN ;
000200180514       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180514       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180514       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180607       // Generate JSON .jsn schema script
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
002301180725         WHVARL      Char(1)  ;   // Variable length field
002400180524       End-Ds;
002500180607       Dcl-DS FLP025DS EXTNAME('FLP025') Qualified INZ END-DS;
002600180514       // Stand Alone Fields
002700180524       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
002800180607       // Numberic current date for file name
002900180607       Dcl-S ccyymmdd              Packed(8:0) ;
003000180607       // Character current date for file name
003100180607       Dcl-S ccyymmddc             Char(8) ;
003200180531       Dcl-S Chr        Char(1) Inz(X'6B'); // user selected delimiter
003300180528       Dcl-S Cma        Char(1) Inz(X'6B'); // comma ','
003400180528       Dcl-S CsrSel                Char(256); // SQL Cursor Def.
003500180528       Dcl-S CrLf       Char(2) Inz(X'0d25') ;
003600180528       Dcl-S CsvLine               Char(128) ;
003700180607       Dcl-S Data       Char(512) Inz ;
003800180514       Dcl-S EOJ                   Char(2) ;
003900180607       Dcl-S Errcd               Packed(5:0) Inz ;
004000180607       // File name sent
004100180607       Dcl-S FileName              Char(32);
004200180607       Dcl-S FType                 Char(3) Inz('jsn') ;
004300180607       Dcl-S InFileUsage           Char(10) Inz;
004400180607       Dcl-S InPath                Char(512) Inz;
004401180607       Dcl-S JSONLine               Char(128) ;
004500180530       Dcl-S LongPath              Char(90) ;
004600180524       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
004700180607       // Current time for file name
004800180607       Dcl-S Now                   Time INZ(*Sys) ;
004900180607       Dcl-S Option                Char(1) Inz;
005000180607       Dcl-S OutEOF@Read           Char(1) Inz;
005100180607       Dcl-S OutRC                  Int(10:0) Inz;
005200180528       Dcl-S P                      Int(5) ;
005201180607       Dcl-S Pos                    Int(5) Inz ;
005300180607       Dcl-S Qm         Char(1) Inz(X'7F'); // quotation mark '"'
005400180526       Dcl-S Rc                     Ind ;
005500180607       Dcl-S SavFileDesc            Int(10:0) Inz;
005600180607       Dcl-S Status                Char(1) Inz;
005700180526       Dcl-S TextIn                Char(10) Inz('FLPEXCEL') ;
005800180526       Dcl-S TextLib               Char(10) Inz('DJDATA') ;
005900180607       // Numeric time for file name
006000180607       Dcl-S Time                Packed(6:0) ;
006100180607       // Character time for file name
006200180607       Dcl-S TimeC                 Char(6)  ;
006300180607       // Current date for file name
006400180607       Dcl-S Today                 Date(*ISO) Inz(*Sys) ;
006500180524       Dcl-S Tot_Fields          Int(10) ;
006600180514       //*--------------------------------------------------------------------
006700180607       Dcl-Proc FLM025I EXPORT;
006800180607         Dcl-PI FLM025I              Char(2);
006900180607           FL25DSIN                 Char(285) ;
007000180526           ADDUPD                   Char(1);
007100180514         End-PI ;
007200180526         Exec Sql Set Option Commit = *None; // manage commitment control
007300180524         //---------------------------------------------------------------------
007400180524         // Get the fields for the file layout
007500180607         FLP025DS = FL25DSIN ; // Format the passed data
007600180607         // Get the file layout for the selected table
007700180524         ExSR CrtCursor ;
007800180524         CallP OpenFLD() ;
007900180524         Rc = FetchMultFLD();
008000180524         CallP CloseFLD() ;
008100180531         If Tot_Fields > *Zero ; // If fields were found process the file layout
008200180607           ExSR CrtIFSfile ; // Create the stream file on the IFS
008201180607           JSONLine = *Blanks ;
008202180607           // JSON heading 1
008203180607           JSONLINE = ' {' + CrLf ;
008204180607           ExSR WriteIFS;
008206180607           // JSON heading 2
008207180607           JSONLINE = *Blanks ;
008208180607           POS = 3;
008209180607           %SubSt(JSONLINE:Pos) = %Trim(FLP025DS.FL2506) + Cma + CrLf ;
008210180607           ExSR WriteIFS;
008213180607           // JSON heading 3
008214180607           JSONLINE = *Blanks ;
008215180607           POS = 3;
008216180607           %SubSt(JSONLINE:Pos) = Qm + 'title' + Qm + ': ' + Qm +
008217180607             %Trim(FLP025DS.FL2507) + Qm + Cma + CrLf ;
008218180607           ExSR WriteIFS;
008221180607           // JSON heading 4
008222180607           JSONLINE = *Blanks ;
008223180607           POS = 3;
008224180607           %SubSt(JSONLINE:Pos) = Qm + 'description' + Qm + ': ' + Qm +
008225180607                 %Trim(FLP025DS.FL2505) + Qm + Cma +CrLf ;
008226180607           ExSR WriteIFS;
008229180607           // JSON heading 5
008230180607           JSONLINE = *Blanks ;
008231180607           POS = 3;
008232180607           %SubSt(JSONLINE:Pos)   = Qm + 'type' + Qm + ': ' + Qm + 'Object' +
008233180607             Qm + Cma + CrLf ;
008234180607           ExSR WriteIFS;
008237180607           // JSON heading 6
008238180607           JSONLINE = *Blanks ;
008239180607           POS = 3;
008241180607           JSONLINE = ' }' + CrLf ;
008242180607           ExSR WriteIFS;
008245180607           // JSON heading 7
008246180607           JSONLINE = *Blanks;
008247180607           JSONLINE =  Qm + 'properties' + Qm + ': ' + '{' + CrLf ;
008248180607           ExSR WriteIFS;
008252180607
010200180531           For P = 1  to Tot_Fields;
010201180607             JSONLine = *Blanks ;
010202180607             Pos = 5 ;
010203180607               Select ;
010204180607                 When FIELDSDS(P).WHFLDT = 'A' ;
010205180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
010206180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010207180607                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:string"/>' +
010208180607                     CrLf;
010209180607                   Else;
010210180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010211180607                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:string"/>' +
010212180607                     CrLf;
010213180607                   EndIf;
010214180607                 When FIELDSDS(P).WHFLDT = 'B' ;
010215180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
010216180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010217180607                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:int"/>' +
010218180607                     CrLf ;
010219180607                   Else;
010220180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010221180607                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:int"/>' +
010222180607                     CrLf ;
010223180607                   EndIf;
010224180607                 When FIELDSDS(P).WHFLDT = 'I' ;
010225180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
010226180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010227180607                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:integer"/>' +
010228180607                     CrLf ;
010229180607                   Else;
010230180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010231180607                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:integer"/>' +
010232180607                     CrLf ;
010233180607                   EndIf ;
010234180607                 When FIELDSDS(P).WHFLDT = 'L' ;
010235180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
010236180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010237180607                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:date"/>' +
010238180607                     CrLf ;
010239180607                   Else;
010240180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010241180607                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:date"/>' +
010242180607                     CrLf ;
010243180607                   EndIf;
010244180607                 When FIELDSDS(P).WHFLDT = 'P' ;
010245180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
010246180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010247180607                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:decimal"/>' +
010248180607                     CrLf ;
010249180607                   Else;
010250180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010251180607                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:decimal"/>' +
010252180607                     CrLf ;
010253180607                   EndIf;
010254180607                 When FIELDSDS(P).WHFLDT = 'S' ;
010255180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
010256180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010257180607                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:decimal"/>' +
010258180607                     CrLf ;
010259180607                   Else;
010260180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010261180607                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:decimal"/>' +
010262180607                     CrLf ;
010263180607                   EndIf;
010264180607                 When FIELDSDS(P).WHFLDT = 'Z' ;
010265180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
010266180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010267180607                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:datetime"/>' +
010268180607                     CrLf ;
010269180607                   Else;
010270180607                     %Subst(JSONLine:Pos) = '<xs:element name=' + Ap +
010271180607                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:datetime"/>' +
010272180607                     CrLf ;
010273180607                   EndIf;
010274180607               EndSl;
010275180607             ExSR WriteIFS ;
010277180607           EndFor;
010278180607           JSONLINE = *Blanks;
010279180607           Pos = 3 ;
010280180607           %Subst(JSONLINE:Pos) = '}' + CrLf ;
010287180607           ExSR WriteIFS ;
011600180607         // Close the IFS file ;
011700180607             ExSR CloseIFS ;
011800180607         EndIf ;
011900180524         Return EOJ;
012000180524       //*--------------------------------------------------------
012100180524       //* Create the Fields SQL cursor
012200180524       //*--------------------------------------------------------
012300180524       BegSr CrtCursor;
012400180524
012500180524          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
012600180725                   'WHFTXT, WHNULL, WHCHD1, WHCHD2, WHALIS, WHVARL ' +
012700180528                   'From   FIELDS  Where WHFILE = ' + Ap +
012800180607                   %Trim(FLP025DS.FL2503) + Ap + ' For Read Only ' ;
012900180524
013000180607       EndSr;
013100180526       //*--------------------------------------------------------
013200180607       //* Create the IFS stream file
013300180526       //*--------------------------------------------------------
013400180607       BegSr CrtIFSfile;
013500180607         Option = 'O' ;
013600180607         Status = *Blank ;
013700180607         Errcd = *Zero;
013800180607         Data = *Blanks ;
013900180607         ccyymmdd = %dec(%char(Today:*iso0):8:0) ;
014000180607         CCYYMMDDC = %EditC(CCYYMMDD:'X') ;
014100180607         Time = %dec(%char(Now:*HMS0):6:0) ;
014200180607         TimeC = %EditC(Time:'X') ;
014201180607         If FLP025DS.FL2509 <> *Blanks;
014202180607           FTYPE = FLP025DS.FL2509 ;
014203180607         EndIf;
014300180607         FileName = *Blanks;
014400180607         FileName = %Trim(FLP025DS.FL2507) +
014500180607              CCYYMMDDC + TimeC + '.' + FTYPE ;
014600180607         InPath = %Trim(FLP025DS.FL2508) + '/' +
014700180607                  %Trim(FileName) ;
014800180607         InFileUsage = '*REPLACE' ;
014900180607         SavFileDesc = *Zeros;
015000180607         OutRC = *Zeros ;
015100180607         OutEof@Read = *Blank;
015200180607         ExSR CallIFSIO ;
015300180526       EndSr;
015400180607       //*--------------------------------------------------------
015500180607       //* Write a record to the IFS stream file
015600180607       //*--------------------------------------------------------
015700180607       BegSr WriteIFS;
015800180607         Option = 'W' ;
015900180607         Status = *Blank;
016000180607         Errcd = *Zero ;
016100180607         Data = *Blanks;
016200180607         Data = JSONLine;
016300180607         OutRC = *Zeros ;
016400180607         OutEof@Read = *Blank;
016500180607         ExSR CallIFSIO ;
016600180607       EndSr;
016700180607       //*--------------------------------------------------------
016800180607       //* Close the IFS stream file
016900180607       //*--------------------------------------------------------
017000180607       BegSr CloseIFS;
017100180607         Option = 'C' ;
017200180607         Status = *Blank;
017300180607         Errcd = *Zero ;
017400180607         Data = *Blanks;
017500180607         OutRC = *Zeros ;
017600180607         OutEof@Read = *Blank;
017700180607         ExSR CallIFSIO ;
017800180607       EndSr;
017900180607       //*-----------------------------------------------------------
018000180607       //* Call IFS_IO routine
018100180526       //*--------------------------------------------------------
018200180607       BegSR CallIFSIO;
018300180607
018400180607         CallP IFS_IO(Option
018500180607                       :Status
018600180607                       :Errcd
018700180607                       :Data
018800180607                       :InPath
018900180607                       :InfileUsage
019000180607                       :SavFileDesc
019100180607                       :OutRC
019200180607                       :OutEof@Read) ;
019300180607
019400180607       EndSr;
019500180607       //*--------------------------------------------------------
019600180607       End-Proc FLM025I ;
019700180524       //--------------------------------------------------------
019800180524       //  closeFLD - Close the call file cursor
019900180524       //--------------------------------------------------------
020000180524       Dcl-Proc closeFLD;
020100180524
020200180524       Dcl-PI closeFLD;
020300180524       End-PI;
020400180524
020500180524          Exec SQL close FLDCursor;
020600180524
020700180524       End-Proc closeFLD;
020800180524       //--------------------------------------------------------
020900180524       //  fetchMultFLD - read all the fields/Columns
021000180524       //--------------------------------------------------------
021100180524       Dcl-Proc fetchMultFLD;
021200180524
021300180524       Dcl-PI fetchMultFLD         Ind;
021400180524       End-PI;
021500180524
021600180524          Exec SQL
021700180524              fetch next from FLDCursor
021800180524              For :Mult_Fields rows
021900180524              into :FieldsDS;
022000180524          //
022100180524          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
022200180524          //
022300180524          If SQLSTT < '020000';
022400180524             Return *ON;
022500180524          Else;
022600180524             Return *OFF;
022700180524          EndIf;
022800180524          //
022900180524
023000180524       End-Proc fetchMultFLD;
023100180524       //---------------------------------------------------------------------
023200180524       //  openFLD  - Open a cursor to read the Fields/Columns
023300180524       //---------------------------------------------------------------------
023400180524       Dcl-Proc openFLD;
023500180524
023600180524       Dcl-PI openFLD;
023700180524       End-PI;
023800180524          Exec SQL prepare wkStatement from :CsrSel ;
023900180524          // *
024000180524          Exec SQL declare FLDCursor cursor for wkStatement ;
024100180524          // *
024200180524          Exec SQL open FLDCursor ;
024300180524          // *
024400180524          // *
024500180524       End-Proc openFLD;
