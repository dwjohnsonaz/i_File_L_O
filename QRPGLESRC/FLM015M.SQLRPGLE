000100180610       Ctl-Opt DFTNAME(FLM015M) NOMAIN ;
000200180522       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180522       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180522       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180610       // Generate a My/SQL create script
000600180522       // Prototypes
000700180522      /Copy QRPGLESRC,FLT001
000800180607       // SQL processing subprocedures
000900180607       Dcl-PR CloseFLD  End-PR;
001000180607       Dcl-PR FetchMultFLD  Ind End-PR;
001100180607       Dcl-PR OpenFLD  End-PR;
001200180607       // Data Sets for processing
001300180607       Dcl-DS FieldsDS Qualified Dim( 1000 ) ;
001400180607         WHNAME      Char(10) ;   // Record Format
001500180607         WHFLDI      Char(10) ;   // Internal Field Name
001600180607         WHFLDT      Char(1)  ;   // Field Type
001700180607         WHFLDB      Zoned(5:0) ; // Field Length in bytes
001800180607         WHFLDP      Zoned(2:0) ; // Field Decimal Positions
001900180607         WHFTXT      Char(50) ;   // Field text desrciption
002000180607         WHNULL      Char(1)  ;   // Field Null Y/N
002100180607         WHCHD1      Char(20) ;   // Field Col. Hdg. 1
002200180607         WHCHD2      Char(20) ;   // Field Col. Hdg. 2
002300180607         WHALIS      Char(32) ;   // SQL Alias field
002301180725         WHVARL      Char(1)  ;   // Variable length field
002400180607       End-Ds;
002500180607       Dcl-DS FLP015DS EXTNAME('FLP015') Qualified INZ END-DS;
002600180607       // Stand Alone Fields
002700180607       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
002800180607       // Numberic current date for file name
002900180607       Dcl-S ccyymmdd              Packed(8:0) ;
003000180607       // Character current date for file name
003100180607       Dcl-S ccyymmddc             Char(8) ;
003200180607       Dcl-S Chr        Char(1) Inz(X'6B'); // user selected delimiter
003300180607       Dcl-S Cma        Char(1) Inz(X'6B'); // comma ','
003400180609       Dcl-S Cp                    Char(1) Inz(X'5D'); // Close parenthesis '('
003500180607       Dcl-S CsrSel                Char(256); // SQL Cursor Def.
003600180607       Dcl-S CrLf       Char(2) Inz(X'0d25') ;
003700180607       Dcl-S CsvLine               Char(128) ;
003800180607       Dcl-S Data       Char(512) Inz ;
003900180607       Dcl-S DTALine               Char(128) ;
004000180607       Dcl-S EOJ                   Char(2) ;
004100180607       Dcl-S Errcd               Packed(5:0) Inz ;
004200180607       // File name sent
004300180607       Dcl-S FileName              Char(32);
004400180609       Dcl-S FType                 Char(3) Inz('sql') ;
004500180607       Dcl-S InFileUsage           Char(10) Inz;
004600180607       Dcl-S InPath                Char(512) Inz;
004601180610       Dcl-S LastCol               Char(10) Inz;
004700180607       Dcl-S LongPath              Char(90) ;
004800180607       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
004900180607       // Current time for file name
005000180607       Dcl-S Now                   Time INZ(*Sys) ;
005100180609       Dcl-S Op                    Char(1) Inz(X'4D'); // Open parenthesis '('
005200180607       Dcl-S Option                Char(1) Inz;
005300180607       Dcl-S OutEOF@Read           Char(1) Inz;
005400180607       Dcl-S OutRC                  Int(10:0) Inz;
005500180607       Dcl-S P                      Int(5) ;
005600180607       Dcl-S Pos                    Int(5) Inz ;
005700180607       Dcl-S Qm         Char(1) Inz(X'7F'); // quotation mark '"'
005800180607       Dcl-S Rc                     Ind ;
005900180607       Dcl-S SavFileDesc            Int(10:0) Inz;
006000180610       Dcl-S Sc                    Char(1) Inz(X'5E') ; // Semi-colon ';'
006100180610       Dcl-S Sp                    Char(1) Inz(X'40') ; // Space ' '
006200180607       Dcl-S Status                Char(1) Inz;
006300180607       Dcl-S TextIn                Char(10) Inz('FLPEXCEL') ;
006400180607       Dcl-S TextLib               Char(10) Inz('DJDATA') ;
006500180607       // Numeric time for file name
006600180607       Dcl-S Time                Packed(6:0) ;
006700180607       // Character time for file name
006800180607       Dcl-S TimeC                 Char(6)  ;
006900180607       // Current date for file name
007000180607       Dcl-S Today                 Date(*ISO) Inz(*Sys) ;
007100180607       Dcl-S Tot_Fields          Int(10) ;
007200180607       //*--------------------------------------------------------------------
007300180610       Dcl-Proc FLM015M EXPORT;
007400180610         Dcl-PI FLM015M              Char(2);
007500180607           FL15DSIN                 Char(435) ;
007600180607           ADDUPD                   Char(1);
007700180607         End-PI ;
007800180607         Exec Sql Set Option Commit = *None; // manage commitment control
007900180607         //---------------------------------------------------------------------
008000180607         // Get the fields for the file layout
008100180610         FLP015DS = FL15DSIN ; // Format the data passed in
008200180607         // Get the file layout for the selected table
008300180607         ExSR CrtCursor ;
008400180607         CallP OpenFLD() ;
008500180607         Rc = FetchMultFLD();
008600180607         CallP CloseFLD() ;
008700180607         If Tot_Fields > *Zero ; // If fields were found process the file layout
008800180607           ExSR CrtIFSfile ; // Create the stream file on the IFS
008801180610           // Find the last column name
008802180610           LastCol = FIELDSDS(Tot_Fields).WHFLDI ;
008900180609           // Write drop table instruction
009000180609           If flp015DS.FL1508 = 'Y';
009100180609             DTALine = *Blanks ;
009200180609             DTALine = '/* Drop the ' + %Trim(FLP015DS.FL1513) + ' table */' +
009300180609                       CrLf;
009400180609             ExSR WriteIFS;
009500180609             DTALine = *Blanks ;
009600180609             DTALine = '/* DROP ' + %Trim(FLP015DS.FL1513) + ' */' + CrLf;
009700180609             ExSR WriteIFS;
009800180609           EndIf;
009900180609           // Write the creat table line
010000180609           DTALine = *Blanks ;
010100180609           DTALine = '/* Create the ' + %Trim(FLP015DS.FL1513) + ' table */' +
010200180609                     CrLf;
010300180609           ExSR WriteIFS ;
010400180609           DTALine = ' CREATE ' + %Trim(FLP015DS.FL1513) + Sp + Op + CrLf ;
010500180609           ExSR WriteIFS ;
010600180610          If FLP015DS.FL1506 = 'Y' ;
010601180610             DTALine = *Blanks ;
010602180610             Pos = 5 ;
010603180610             %Subst(DTALine:Pos) = %Trim(FLP015DS.FL1507) +
010604180610                       ' INT GENERATED ALWAYS ' + 'AS IDENTITY ' + CrLf ;
010605180610             ExSR WriteIFS;
010606180610             Pos = 10 ;
010607180610             DTALine = *Blanks;
010608180610             %Subst(DTALine:Pos) = '(START WITH 1 , INCREMENT BY 1) ' +
010609180610                       'NOT NULL ,' + CrLf ;
010610180610             ExSR WriteIFS;
010611180610           EndIf;
011400180607           For P = 1  to Tot_Fields;
011500180607             DTALine = *Blanks ;
011600180607             Pos = 5 ;
011700180607               Select ;
011800180607                 When FIELDSDS(P).WHFLDT = 'A' ;
011801180725                   If FIELDSDS(P).WHVARL = 'Y';
011802180725                     FIELDSDS(P).WHFLDB = FIELDSDS(P).WHFLDB - 2;
011803180725                   EndIf;
011900180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
012000180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
012100180609                     Sp + 'CHAR(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) ;
012200180607                   Else;
012300180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
012400180609                     Sp + 'CHAR(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
012500180609                     Cp ;
012600180609                   EndIf;
012700180607                 When FIELDSDS(P).WHFLDT = 'B' ;
012800180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
012900180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
013000180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
013100180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDB:'   0 ')) + Cp ;
013200180609                   Else;
013300180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
013400180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
013500180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDB:'   0 ')) + Cp ;
013600180609                   EndIf;
013700180607                 When FIELDSDS(P).WHFLDT = 'I' ;
013800180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
013900180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
014000180609                       Sp + 'INT(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) + Cp;
014100180609                   Else;
014200180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
014300180609                       Sp + 'INT(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) + Cp;
014400180609                   EndIf;
014500180607                 When FIELDSDS(P).WHFLDT = 'L' ;
014600180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
014700180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
014800180609                       Sp + 'DATE' ;
014900180609                   Else;
015000180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
015100180609                       Sp + 'DATE' ;
015200180609                   EndIf ;
015300180607                 When FIELDSDS(P).WHFLDT = 'P' ;
015400180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
015500180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
015600180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
015700180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDP:'0 ')) + Cp ;
015800180609                   Else;
015900180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
016000180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
016100180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDP:'0 ')) + Cp ;
016200180609                   EndIf;
016300180607                 When FIELDSDS(P).WHFLDT = 'S' ;
016400180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
016500180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
016600180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
016700180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDB:'   0 ')) + Cp ;
016800180609                   Else;
016900180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
017000180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
017100180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDB:'   0 ')) + Cp ;
017200180609                   EndIf;
017300180607                 When FIELDSDS(P).WHFLDT = 'Z' ;
017400180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
017500180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
017600180609                       Sp + 'TIMESTAMP' ;
017700180609                   Else;
017800180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
017900180609                       Sp + 'TIMESTAMP' ;
018000180609                   EndIf;
018001180610
018100180609                EndSl;
018200180609             // Set up the NULL/NOT NULL flag and add the comma
018300180610             If FIELDSDS(P).WHNULL = 'Y' ;
018301180610               %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + 'NULL' ;
018302180610             Else;
018303180610               %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + 'NOT NULL' ;
018304180610             EndIf;
018305180610             // Check for last column
018306180610             If FIELDSDS(P).WHFLDI <> LastCol ;
018307180610               %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + Cma + CrLf ;
018308180610             // Check for last column without primary key
018309180610             Else;
018310180610               Select ;
018311180610                 When FIELDSDS(P).WHFLDI = LastCol and FLP015DS.FL1506 <> 'Y';
018312180610                   %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + Cp + Sp + Sc +
018313180610                       CrLf ;
018314180610                 When FIELDSDS(P).WHFLDI = LastCol and FLP015DS.FL1506 = 'Y';
018315180610                   %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + Cma + CrLf ;
018316180610               EndSL;
018317180610             EndIf;
018318180610             ExSR WriteIFS ;
018319180610             EndFor;
019200180609         // Check for Primary Key ;
019300180610           If FLP015DS.FL1506 = 'Y' ;
019400180609             DTALine = *Blanks ;
019500180609             %Subst(DTALine:Pos) = 'Primary Key(' + %Trim(FLP015DS.FL1507) +
019600180609             Cp + Cp + Sp + Sc ;
019601180610             ExSR WriteIFS ;
020000180609           EndIf;
020200180607         // Close the IFS file ;
020300180607             ExSR CloseIFS ;
020400180607         EndIf ;
020500180607         Return EOJ;
020600180607       //*--------------------------------------------------------
020700180607       //* Create the Fields SQL cursor
020800180607       //*--------------------------------------------------------
020900180607       BegSr CrtCursor;
021000180607
021100180607          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
021200180725                   'WHFTXT, WHNULL, WHCHD1, WHCHD2, WHALIS, WHVARL ' +
021300180607                   'From   FIELDS  Where WHFILE = ' + Ap +
021400180609                   %Trim(FLP015DS.FL1503) + Ap + ' For Read Only ' ;
021500180607
021600180607       EndSr;
021700180607       //*--------------------------------------------------------
021800180607       //* Create the IFS stream file
021900180607       //*--------------------------------------------------------
022000180607       BegSr CrtIFSfile;
022100180607         Option = 'O' ;
022200180607         Status = *Blank ;
022300180607         Errcd = *Zero;
022400180607         Data = *Blanks ;
022500180607         ccyymmdd = %dec(%char(Today:*iso0):8:0) ;
022600180607         CCYYMMDDC = %EditC(CCYYMMDD:'X') ;
022700180607         Time = %dec(%char(Now:*HMS0):6:0) ;
022800180607         TimeC = %EditC(Time:'X') ;
022900180607         FileName = *Blanks;
023000180610         FileName = %Trim(FLP015DS.FL1513) +
023100180607              CCYYMMDDC + TimeC + '.' + FTYPE ;
023200180610         InPath = %Trim(FLP015DS.FL1518) + '/' +
023300180607                  %Trim(FileName) ;
023400180607         InFileUsage = '*REPLACE' ;
023500180607         SavFileDesc = *Zeros;
023600180607         OutRC = *Zeros ;
023700180607         OutEof@Read = *Blank;
023800180607         ExSR CallIFSIO ;
023900180607       EndSr;
024000180607       //*--------------------------------------------------------
024100180607       //* Write a record to the IFS stream file
024200180607       //*--------------------------------------------------------
024300180607       BegSr WriteIFS;
024400180607         Option = 'W' ;
024500180607         Status = *Blank;
024600180607         Errcd = *Zero ;
024700180607         Data = *Blanks;
024800180607         Data = DTALine;
024900180607         OutRC = *Zeros ;
025000180607         OutEof@Read = *Blank;
025100180607         ExSR CallIFSIO ;
025200180607       EndSr;
025300180607       //*--------------------------------------------------------
025400180607       //* Close the IFS stream file
025500180607       //*--------------------------------------------------------
025600180607       BegSr CloseIFS;
025700180607         Option = 'C' ;
025800180607         Status = *Blank;
025900180607         Errcd = *Zero ;
026000180607         Data = *Blanks;
026100180607         OutRC = *Zeros ;
026200180607         OutEof@Read = *Blank;
026300180607         ExSR CallIFSIO ;
026400180607       EndSr;
026500180607       //*-----------------------------------------------------------
026600180607       //* Call IFS_IO routine
026700180607       //*--------------------------------------------------------
026800180607       BegSR CallIFSIO;
026900180607
027000180607         CallP IFS_IO(Option
027100180607                       :Status
027200180607                       :Errcd
027300180607                       :Data
027400180607                       :InPath
027500180607                       :InfileUsage
027600180607                       :SavFileDesc
027700180607                       :OutRC
027800180607                       :OutEof@Read) ;
027900180607
028000180607       EndSr;
028100180607       //*--------------------------------------------------------
028200180610       End-Proc FLM015M ;
028300180607       //--------------------------------------------------------
028400180607       //  closeFLD - Close the call file cursor
028500180607       //--------------------------------------------------------
028600180607       Dcl-Proc closeFLD;
028700180607
028800180607       Dcl-PI closeFLD;
028900180607       End-PI;
029000180607
029100180607          Exec SQL close FLDCursor;
029200180607
029300180607       End-Proc closeFLD;
029400180607       //--------------------------------------------------------
029500180607       //  fetchMultFLD - read all the fields/Columns
029600180607       //--------------------------------------------------------
029700180607       Dcl-Proc fetchMultFLD;
029800180607
029900180607       Dcl-PI fetchMultFLD         Ind;
030000180607       End-PI;
030100180607
030200180607          Exec SQL
030300180607              fetch next from FLDCursor
030400180607              For :Mult_Fields rows
030500180607              into :FieldsDS;
030600180607          //
030700180607          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
030800180607          //
030900180607          If SQLSTT < '020000';
031000180607             Return *ON;
031100180607          Else;
031200180607             Return *OFF;
031300180607          EndIf;
031400180607          //
031500180607
031600180607       End-Proc fetchMultFLD;
031700180607       //---------------------------------------------------------------------
031800180607       //  openFLD  - Open a cursor to read the Fields/Columns
031900180607       //---------------------------------------------------------------------
032000180607       Dcl-Proc openFLD;
032100180607
032200180607       Dcl-PI openFLD;
032300180607       End-PI;
032400180607          Exec SQL prepare wkStatement from :CsrSel ;
032500180607          // *
032600180607          Exec SQL declare FLDCursor cursor for wkStatement ;
032700180607          // *
032800180607          Exec SQL open FLDCursor ;
032900180607          // *
033000180607       End-Proc openFLD;
