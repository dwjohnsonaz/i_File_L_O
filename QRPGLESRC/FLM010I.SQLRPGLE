000100180607       Ctl-Opt DFTNAME(FLM010I) NOMAIN ;
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
002301180725         WHVARL      Char(1)  ;   // Variable length field
002400180524       End-Ds;
002500180526       Dcl-DS FLP010DS EXTNAME('FLP010') Qualified INZ END-DS;
002501180612       Dcl-DS FLP010CDS EXTNAME('FLP010C') Qualified INZ END-DS;
002600180514       // Stand Alone Fields
002700180524       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
002701180607       // Numberic current date for file name
002702180607       Dcl-S ccyymmdd              Packed(8:0) ;
002703180607       // Character current date for file name
002704180607       Dcl-S ccyymmddc             Char(8) ;
002800180531       Dcl-S Chr        Char(1) Inz(X'6B'); // user selected delimiter
002900180528       Dcl-S Cma        Char(1) Inz(X'6B'); // comma ','
003000180528       Dcl-S CsrSel                Char(256); // SQL Cursor Def.
003100180528       Dcl-S CrLf       Char(2) Inz(X'0d25') ;
003200180528       Dcl-S CsvLine               Char(128) ;
003201180607       Dcl-S Data       Char(512) Inz ;
003400180514       Dcl-S EOJ                   Char(2) ;
003401180607       Dcl-S Errcd               Packed(5:0) Inz ;
003402180607       // File name sent
003403180607       Dcl-S FileName              Char(32);
003500180528       Dcl-S FType                 Char(3) Inz('csv') ;
003501180607       Dcl-S InFileUsage           Char(10) Inz;
003502180607       Dcl-S InPath                Char(512) Inz;
003600180530       Dcl-S LongPath              Char(90) ;
003700180524       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
003701180607       // Current time for file name
003702180607       Dcl-S Now                   Time INZ(*Sys) ;
003703180607       Dcl-S Option                Char(1) Inz;
003704180607       Dcl-S OutEOF@Read           Char(1) Inz;
003705180607       Dcl-S OutRC                  Int(10:0) Inz;
003800180528       Dcl-S P                      Int(5) ;
003801180607       Dcl-S Qm         Char(1) Inz(X'7F'); // quotation mark '"'
003900180526       Dcl-S Rc                     Ind ;
003901180607       Dcl-S SavFileDesc            Int(10:0) Inz;
003902180607       Dcl-S Status                Char(1) Inz;
004000180526       Dcl-S TextIn                Char(10) Inz('FLPEXCEL') ;
004100180526       Dcl-S TextLib               Char(10) Inz('DJDATA') ;
004101180607       // Numeric time for file name
004102180607       Dcl-S Time                Packed(6:0) ;
004103180607       // Character time for file name
004104180607       Dcl-S TimeC                 Char(6)  ;
004105180607       // Current date for file name
004106180607       Dcl-S Today                 Date(*ISO) Inz(*Sys) ;
004200180524       Dcl-S Tot_Fields          Int(10) ;
004300180514       //*--------------------------------------------------------------------
004400180607       Dcl-Proc FLM010I EXPORT;
004500180607         Dcl-PI FLM010I              Char(2);
004600180528           FL10DSIN                 Char(176) ;
004700180526           ADDUPD                   Char(1);
004800180514         End-PI ;
004900180526         Exec Sql Set Option Commit = *None; // manage commitment control
005000180524         //---------------------------------------------------------------------
005100180524         // Get the fields for the file layout
005200180526         FLP010DS = FL10DSIN ; // Format the passed data
005300180607         // Get the file layout for the selected table
005400180524         ExSR CrtCursor ;
005500180524         CallP OpenFLD() ;
005600180524         Rc = FetchMultFLD();
005700180524         CallP CloseFLD() ;
005800180531         If Tot_Fields > *Zero ; // If fields were found process the file layout
005900180607           ExSR CrtIFSfile ; // Create the stream file on the IFS
005901180612           Exec SQL
005902180612             Select * INTO :FLP010CDS From FLP010C ;
006000180531           If FLP010DS.FL1007 <> *Blanks;
006100180531             Chr = FLP010DS.FL1007;
006200180531           Else;
006300180531             Chr = Cma ;
006400180531           EndIf;
006401180612           If FLP010CDS.FL10C01 = 'Y' ;
006402180612             CsvLine = *Blanks ;
006403180612               CSVLINE = Qm + 'Description: ' + %Trim(FLP010CDS.FL10C02) + Qm +
006404180612                 CrLf ;
006405180612             ExSR WriteIFS;
006406180612           EndIf;
006500180531           If FLP010DS.FL1002 = 'Y' ;
006600180531             CsvLine = *Blanks ;
006700180531               CSVLINE = Qm + 'Field' + Qm + Chr +
006800180531                         Qm + 'Type' + Qm + Chr +
006900180531                         Qm + 'Length' + Qm + Chr +
007000180531                         Qm + 'Dec' + Qm + Chr +
007100180531                         Qm + 'Description' + Qm + Chr +
007200180531                         Qm + 'N/C' + Qm + Chr +
007300180531                         Qm + 'Colum H 1' + Qm + Chr +
007400180531                         Qm + 'Colum H 2' + Qm + Chr +
007500180531                         Qm + 'Alias' + Qm + CrLf ;
007600180607         // Execute IFS_IO write here
007601180607             ExSR WriteIFS ;
007602180607           EndIf;
007700180531           For P = 1  to Tot_Fields;
007800180528             CsvLine = *Blanks ;
007801180725             If FieldsDS(P).WHFLDT = 'A' ;
007802180725               If FieldsDS(P).WHVARL = 'Y' ;
007804180725                 FieldsDS(P).WHFLDT = 'V';
007805180725                 FieldsDS(P).WHFLDB = FieldsDS(P).WHFLDB - 2;
007806180725               EndIf;
007807180725             EndIf;
007900180531             CSVLINE = Qm + %Trim(FieldsDS(P).WHFLDI) + Qm + Chr +
008000180531                       Qm + %Trim(FieldsDS(P).WHFLDT) + Qm + Chr +
008100180531                       %EditC(FieldsDS(P).WHFLDB:'Z') + Chr +
008200180531                       %EditW(FieldsDS(P).WHFLDP:'0 ') + Chr +
008300180531                       Qm + %Trim(FieldsDS(P).WHFTXT) + Qm + Chr +
008400180531                       Qm + FieldsDS(P).WHNULL + Qm + Chr +
008500180531                       Qm + %Trim(FieldsDS(P).WHCHD1) + Qm + Chr +
008600180531                       Qm + %Trim(FieldsDS(P).WHCHD2) + Qm + Chr +
008700180528                       Qm + %Trim(FieldsDS(P).WHALIS) + Qm + CrLf ;
008800180607         // Execute IFS_IO write here
008801180607             ExSR WriteIFS ;
008900180526           EndFor;
008901180607         // Close the IFS file ;
008902180607             ExSR CloseIFS ;
008903180607         EndIf ;
009000180524         Return EOJ;
009100180524       //*--------------------------------------------------------
009200180524       //* Create the Fields SQL cursor
009300180524       //*--------------------------------------------------------
009400180524       BegSr CrtCursor;
009500180524
009600180524          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
009700180725                   'WHFTXT, WHNULL, WHCHD1, WHCHD2, WHALIS, WHVARL ' +
009800180528                   'From   FIELDS  Where WHFILE = ' + Ap +
009900180528                   %Trim(FLP010DS.FL1005) + Ap + ' For Read Only ' ;
010000180524
010100180607       EndSr;
010200180526       //*--------------------------------------------------------
010300180607       //* Create the IFS stream file
010400180526       //*--------------------------------------------------------
010500180607       BegSr CrtIFSfile;
010501180607         Option = 'O' ;
010502180607         Status = *Blank ;
010503180607         Errcd = *Zero;
010504180607         Data = *Blanks ;
010505180607         ccyymmdd = %dec(%char(Today:*iso0):8:0) ;
010506180607         CCYYMMDDC = %EditC(CCYYMMDD:'X') ;
010507180607         Time = %dec(%char(Now:*HMS0):6:0) ;
010508180607         TimeC = %EditC(Time:'X') ;
010509180607         FileName = *Blanks;
010510180607         FileName = %Trim(FLP010DS.FL1005) +
010511180607              CCYYMMDDC + TimeC + '.' + FTYPE ;
010512180607         InPath = %Trim(FLP010DS.FL1001) + '/' +
010513180607                  %Trim(FileName) ;
010514180607         InFileUsage = '*REPLACE' ;
010515180607         SavFileDesc = *Zeros;
010516180607         OutRC = *Zeros ;
010517180607         OutEof@Read = *Blank;
010518180607         ExSR CallIFSIO ;
010800180526       EndSr;
010801180607       //*--------------------------------------------------------
010802180607       //* Write a record to the IFS stream file
010803180607       //*--------------------------------------------------------
010804180607       BegSr WriteIFS;
010805180607         Option = 'W' ;
010806180607         Status = *Blank;
010807180607         Errcd = *Zero ;
010808180607         Data = *Blanks;
010809180607         Data = CSVLine;
010810180607         OutRC = *Zeros ;
010811180607         OutEof@Read = *Blank;
010812180607         ExSR CallIFSIO ;
010814180607       EndSr;
010815180607       //*--------------------------------------------------------
010816180607       //* Close the IFS stream file
010817180607       //*--------------------------------------------------------
010818180607       BegSr CloseIFS;
010819180607         Option = 'C' ;
010820180607         Status = *Blank;
010821180607         Errcd = *Zero ;
010822180607         Data = *Blanks;
010824180607         OutRC = *Zeros ;
010825180607         OutEof@Read = *Blank;
010826180607         ExSR CallIFSIO ;
010827180607       EndSr;
010828180607       //*-----------------------------------------------------------
010829180607       //* Call IFS_IO routine
010900180526       //*--------------------------------------------------------
010901180607       BegSR CallIFSIO;
010902180607
010903180607         CallP IFS_IO(Option
010904180607                       :Status
010905180607                       :Errcd
010906180607                       :Data
010907180607                       :InPath
010908180607                       :InfileUsage
010909180607                       :SavFileDesc
010910180607                       :OutRC
010911180607                       :OutEof@Read) ;
010912180607
010913180607       EndSr;
010914180607       //*--------------------------------------------------------
011000180607       End-Proc FLM010I ;
011100180524       //--------------------------------------------------------
011200180524       //  closeFLD - Close the call file cursor
011300180524       //--------------------------------------------------------
011400180524       Dcl-Proc closeFLD;
011500180524
011600180524       Dcl-PI closeFLD;
011700180524       End-PI;
011800180524
011900180524          Exec SQL close FLDCursor;
012000180524
012100180524       End-Proc closeFLD;
012200180524       //--------------------------------------------------------
012300180524       //  fetchMultFLD - read all the fields/Columns
012400180524       //--------------------------------------------------------
012500180524       Dcl-Proc fetchMultFLD;
012600180524
012700180524       Dcl-PI fetchMultFLD         Ind;
012800180524       End-PI;
012900180524
013000180524          Exec SQL
013100180524              fetch next from FLDCursor
013200180524              For :Mult_Fields rows
013300180524              into :FieldsDS;
013400180524          //
013500180524          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
013600180524          //
013700180524          If SQLSTT < '020000';
013800180524             Return *ON;
013900180524          Else;
014000180524             Return *OFF;
014100180524          EndIf;
014200180524          //
014300180524
014400180524       End-Proc fetchMultFLD;
014500180524       //---------------------------------------------------------------------
014600180524       //  openFLD  - Open a cursor to read the Fields/Columns
014700180524       //---------------------------------------------------------------------
014800180524       Dcl-Proc openFLD;
014900180524
015000180524       Dcl-PI openFLD;
015100180524       End-PI;
015200180524          Exec SQL prepare wkStatement from :CsrSel ;
015300180524          // *
015400180524          Exec SQL declare FLDCursor cursor for wkStatement ;
015500180524          // *
015600180524          Exec SQL open FLDCursor ;
015700180524          // *
015800180524          // *
015900180524       End-Proc openFLD;
