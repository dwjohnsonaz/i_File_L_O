000100180610       Ctl-Opt DFTNAME(FLM015S) NOMAIN ;
000200180522       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180522       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180522       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180607       // Generate a MS Sequel Server create script
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
005901180610       Dcl-S Sc                    Char(1) Inz(X'5E') ; // Semi-colon ';'
006000180610       Dcl-S Sp                    Char(1) Inz(X'40') ; // Space ' '
006100180607       Dcl-S Status                Char(1) Inz;
006200180607       Dcl-S TextIn                Char(10) Inz('FLPEXCEL') ;
006300180607       Dcl-S TextLib               Char(10) Inz('DJDATA') ;
006400180607       // Numeric time for file name
006500180607       Dcl-S Time                Packed(6:0) ;
006600180607       // Character time for file name
006700180607       Dcl-S TimeC                 Char(6)  ;
006800180607       // Current date for file name
006900180607       Dcl-S Today                 Date(*ISO) Inz(*Sys) ;
007000180607       Dcl-S Tot_Fields          Int(10) ;
007100180607       //*--------------------------------------------------------------------
007200180609       Dcl-Proc FLM015S EXPORT;
007300180609         Dcl-PI FLM015S              Char(2);
007400180607           FL15DSIN                 Char(435) ;
007500180607           ADDUPD                   Char(1);
007600180607         End-PI ;
007700180607         Exec Sql Set Option Commit = *None; // manage commitment control
007800180607         //---------------------------------------------------------------------
007900180607         // Get the fields for the file layout
008000180607         FLP015DS = FL15DSIN ; // Format the passed data
008100180607         // Get the file layout for the selected table
008200180607         ExSR CrtCursor ;
008300180607         CallP OpenFLD() ;
008400180607         Rc = FetchMultFLD();
008500180607         CallP CloseFLD() ;
008600180607         If Tot_Fields > *Zero ; // If fields were found process the file layout
008700180607           ExSR CrtIFSfile ; // Create the stream file on the IFS
008701180610           // Get the last column in the table
008702180610           LastCol = FIELDSDS(Tot_Fields).WHFLDI;
008800180609           // Write drop table instruction
008900180609           If flp015DS.FL1508 = 'Y';
009000180609             DTALine = *Blanks ;
009100180609             DTALine = '/* Drop the ' + %Trim(FLP015DS.FL1513) + ' table */' +
009200180609                       CrLf;
009300180609             ExSR WriteIFS;
009400180609             DTALine = *Blanks ;
009500180609             DTALine = '/* DROP ' + %Trim(FLP015DS.FL1513) + ' */' + CrLf;
009600180609             ExSR WriteIFS;
009700180609           EndIf;
009800180609           // Write the creat table line
009900180609           DTALine = *Blanks ;
010000180609           DTALine = '/* Create the ' + %Trim(FLP015DS.FL1513) + ' table */' +
010100180609                     CrLf;
010200180609           ExSR WriteIFS ;
010300180609           DTALine = ' CREATE ' + %Trim(FLP015DS.FL1513) + Sp + Op + CrLf ;
010400180609           ExSR WriteIFS ;
010500180609           // SQL Generate an identity column
010600180609           If FLP015DS.FL1506 = 'Y' ;
010700180609             DTALine = *Blanks ;
010701180610             Pos = 5 ;
010800180610             %Subst(DTALine:Pos) = %Trim(FLP015DS.FL1507) +
010900180610                       ' INT GENERATED ALWAYS ' + 'AS IDENTITY ' + CrLf ;
011100180609             ExSR WriteIFS;
011101180610             Pos = 10 ;
011102180610             DTALine = *Blanks;
011103180610             %Subst(DTALine:Pos) = '(START WITH 1 , INCREMENT BY 1) ' +
011106180610                       'NOT NULL ,' + CrLf ;
011107180610             ExSR WriteIFS;
011200180609           EndIf;
011300180607           For P = 1  to Tot_Fields;
011400180607             DTALine = *Blanks ;
011500180607             Pos = 5 ;
011600180607               Select ;
011700180607                 When FIELDSDS(P).WHFLDT = 'A' ;
011701180725                   If FIELDSDS(P).WHVARL = 'Y';
011702180725                     FIELDSDS(P).WHFLDB = FIELDSDS(P).WHFLDB - 2;
011703180725                   EndIf;
011800180607                   If FIELDSDS(P).WHALIS <> *Blanks ;
011900180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
012000180609                     Sp + 'CHAR(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) ;
012100180607                   Else;
012200180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
012300180609                     Sp + 'CHAR(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
012400180609                     Cp ;
012500180609                   EndIf;
012600180607                 When FIELDSDS(P).WHFLDT = 'B' ;
012700180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
012800180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
012900180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
013000180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDB:'   0 ')) + Cp ;
013100180609                   Else;
013200180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
013300180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
013400180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDB:'   0 ')) + Cp ;
013500180609                   EndIf;
013600180607                 When FIELDSDS(P).WHFLDT = 'I' ;
013700180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
013800180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
013900180609                       Sp + 'INT(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) + Cp;
014000180609                   Else;
014100180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
014200180609                       Sp + 'INT(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) + Cp;
014300180609                   EndIf;
014400180607                 When FIELDSDS(P).WHFLDT = 'L' ;
014500180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
014600180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
014700180609                       Sp + 'DATE' ;
014800180609                   Else;
014900180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
015000180609                       Sp + 'DATE' ;
015100180609                   EndIf ;
015200180607                 When FIELDSDS(P).WHFLDT = 'P' ;
015300180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
015400180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
015500180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
015600180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDP:'0 ')) + Cp ;
015700180609                   Else;
015800180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
015900180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
016000180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDP:'0 ')) + Cp ;
016100180609                   EndIf;
016200180607                 When FIELDSDS(P).WHFLDT = 'S' ;
016300180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
016400180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
016500180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
016600180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDB:'   0 ')) + Cp ;
016700180609                   Else;
016800180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
016900180609                       Sp + 'DEC(' + %Trim(%EditC(FIELDSDS(P).WHFLDB:'Z')) +
017000180609                       Cma + %Trim(%EditW(FIELDSDS(P).WHFLDB:'   0 ')) + Cp ;
017100180609                   EndIf;
017200180607                 When FIELDSDS(P).WHFLDT = 'Z' ;
017300180609                   If FIELDSDS(P).WHALIS <> *Blanks ;
017400180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHALIS) + Sp +
017500180609                       Sp + 'TIMESTAMP' ;
017600180609                   Else;
017700180609                     %Subst(DTALine:Pos) = %Trim(FIELDSDS(P).WHFLDI) + Sp +
017800180609                       Sp + 'TIMESTAMP' ;
017900180609                   EndIf;
018000180609                EndSl;
018100180609             // Set up the NULL/NOT NULL flag and add the comma
018200180609             If FIELDSDS(P).WHNULL = 'Y' ;
018300180610               %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + 'NULL' ;
018500180609             Else;
018600180610               %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + 'NOT NULL' ;
018800180609             EndIf;
018801180610             // Check for last column
018802180610             If FIELDSDS(P).WHFLDI <> LastCol ;
018803180610               %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + Cma + CrLf ;
018805180610             // Check for last column without primary key
018806180610             Else;
018807180610               Select ;
018808180610                 When FIELDSDS(P).WHFLDI = LastCol and FLP015DS.FL1506 <> 'Y';
018809180610                   %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + Cp + Sp + Sc +
018810180610                       CrLf ;
018811180610                 When FIELDSDS(P).WHFLDI = LastCol and FLP015DS.FL1506 = 'Y';
018812180610                   %Subst(DTALine:Pos) = %Trim(DTALine) + Sp + Cma + CrLf ;
018813180610               EndSL;
018814180610             EndIf;
018900180607             ExSR WriteIFS ;
019000180609             EndFor;
019100180609         // Check for Primary Key ;
019101180610           If FLP015DS.FL1506 = 'Y' ;
019102180609             DTALine = *Blanks ;
019103180609             %Subst(DTALine:Pos) = 'Primary Key(' + %Trim(FLP015DS.FL1507) +
019104180610             Cp + Cp + Sp + Sc + CrLf ;
019105180610             ExSR WriteIFS ;
019109180609           EndIf;
019900180607         // Close the IFS file ;
020000180607             ExSR CloseIFS ;
020100180607         EndIf ;
020200180607         Return EOJ;
020300180607       //*--------------------------------------------------------
020400180607       //* Create the Fields SQL cursor
020500180607       //*--------------------------------------------------------
020600180607       BegSr CrtCursor;
020700180607
020800180607          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
020900180725                   'WHFTXT, WHNULL, WHCHD1, WHCHD2, WHALIS, WHVARL ' +
021000180607                   'From   FIELDS  Where WHFILE = ' + Ap +
021100180609                   %Trim(FLP015DS.FL1503) + Ap + ' For Read Only ' ;
021200180607
021300180607       EndSr;
021400180607       //*--------------------------------------------------------
021500180607       //* Create the IFS stream file
021600180607       //*--------------------------------------------------------
021700180607       BegSr CrtIFSfile;
021800180607         Option = 'O' ;
021900180607         Status = *Blank ;
022000180607         Errcd = *Zero;
022100180607         Data = *Blanks ;
022200180607         ccyymmdd = %dec(%char(Today:*iso0):8:0) ;
022300180607         CCYYMMDDC = %EditC(CCYYMMDD:'X') ;
022400180607         Time = %dec(%char(Now:*HMS0):6:0) ;
022500180607         TimeC = %EditC(Time:'X') ;
022600180607         FileName = *Blanks;
022700180610         FileName = %Trim(FLP015DS.FL1513) +
022800180607              CCYYMMDDC + TimeC + '.' + FTYPE ;
022900180609         InPath = %Trim(FLP015DS.FL1516) + '/' +
023000180607                  %Trim(FileName) ;
023100180607         InFileUsage = '*REPLACE' ;
023200180607         SavFileDesc = *Zeros;
023300180607         OutRC = *Zeros ;
023400180607         OutEof@Read = *Blank;
023500180607         ExSR CallIFSIO ;
023600180607       EndSr;
023700180607       //*--------------------------------------------------------
023800180607       //* Write a record to the IFS stream file
023900180607       //*--------------------------------------------------------
024000180607       BegSr WriteIFS;
024100180607         Option = 'W' ;
024200180607         Status = *Blank;
024300180607         Errcd = *Zero ;
024400180607         Data = *Blanks;
024500180607         Data = DTALine;
024600180607         OutRC = *Zeros ;
024700180607         OutEof@Read = *Blank;
024800180607         ExSR CallIFSIO ;
024900180607       EndSr;
025000180607       //*--------------------------------------------------------
025100180607       //* Close the IFS stream file
025200180607       //*--------------------------------------------------------
025300180607       BegSr CloseIFS;
025400180607         Option = 'C' ;
025500180607         Status = *Blank;
025600180607         Errcd = *Zero ;
025700180607         Data = *Blanks;
025800180607         OutRC = *Zeros ;
025900180607         OutEof@Read = *Blank;
026000180607         ExSR CallIFSIO ;
026100180607       EndSr;
026200180607       //*-----------------------------------------------------------
026300180607       //* Call IFS_IO routine
026400180607       //*--------------------------------------------------------
026500180607       BegSR CallIFSIO;
026600180607
026700180607         CallP IFS_IO(Option
026800180607                       :Status
026900180607                       :Errcd
027000180607                       :Data
027100180607                       :InPath
027200180607                       :InfileUsage
027300180607                       :SavFileDesc
027400180607                       :OutRC
027500180607                       :OutEof@Read) ;
027600180607
027700180607       EndSr;
027800180607       //*--------------------------------------------------------
027900180609       End-Proc FLM015S ;
028000180607       //--------------------------------------------------------
028100180607       //  closeFLD - Close the call file cursor
028200180607       //--------------------------------------------------------
028300180607       Dcl-Proc closeFLD;
028400180607
028500180607       Dcl-PI closeFLD;
028600180607       End-PI;
028700180607
028800180607          Exec SQL close FLDCursor;
028900180607
029000180607       End-Proc closeFLD;
029100180607       //--------------------------------------------------------
029200180607       //  fetchMultFLD - read all the fields/Columns
029300180607       //--------------------------------------------------------
029400180607       Dcl-Proc fetchMultFLD;
029500180607
029600180607       Dcl-PI fetchMultFLD         Ind;
029700180607       End-PI;
029800180607
029900180607          Exec SQL
030000180607              fetch next from FLDCursor
030100180607              For :Mult_Fields rows
030200180607              into :FieldsDS;
030300180607          //
030400180607          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
030500180607          //
030600180607          If SQLSTT < '020000';
030700180607             Return *ON;
030800180607          Else;
030900180607             Return *OFF;
031000180607          EndIf;
031100180607          //
031200180607
031300180607       End-Proc fetchMultFLD;
031400180607       //---------------------------------------------------------------------
031500180607       //  openFLD  - Open a cursor to read the Fields/Columns
031600180607       //---------------------------------------------------------------------
031700180607       Dcl-Proc openFLD;
031800180607
031900180607       Dcl-PI openFLD;
032000180607       End-PI;
032100180607          Exec SQL prepare wkStatement from :CsrSel ;
032200180607          // *
032300180607          Exec SQL declare FLDCursor cursor for wkStatement ;
032400180607          // *
032500180607          Exec SQL open FLDCursor ;
032600180607          // *
032700180607          // *
032800180607       End-Proc openFLD;
