000100180529       Ctl-Opt DFTNAME(FLM020A) NOMAIN ;
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
002500180529       Dcl-DS FLP020DS EXTNAME('FLP020') Qualified INZ END-DS;
002600180514       // Stand Alone Fields
002700180524       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
002800180528       Dcl-S Cma        Char(1) Inz(X'6B'); // comma ','
002900180528       Dcl-S CsrSel                Char(256); // SQL Cursor Def.
003000180528       Dcl-S CrLf       Char(2) Inz(X'0d25') ;
003100180528       Dcl-S Qm         Char(1) Inz(X'7F'); // quotation mark '"'
003200180514       Dcl-S EOJ                   Char(2) ;
003300180530       Dcl-S FType                 Char(3) ;
003400180524       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
003500180528       Dcl-S P                      Int(5) ;
003501180529       Dcl-S Pos                    Int(5) ;
003600180526       Dcl-S Rc                     Ind ;
003700180529       Dcl-S TextIn                Char(10) Inz('FLPXML') ;
003800180526       Dcl-S TextLib               Char(10) Inz('DJDATA') ;
003900180524       Dcl-S Tot_Fields          Int(10) ;
004000180529       Dcl-S XMLLine               Char(128) ;
004100180514       //*--------------------------------------------------------------------
004200180529       Dcl-Proc FLM020A EXPORT;
004300180529         Dcl-PI FLM020A              Char(2);
004400180530           FL20DSIN                  Char(375) ;
004500180529           ADDUPD                    Char(1);
004600180514         End-PI ;
004700180526         Exec Sql Set Option Commit = *None; // manage commitment control
004800180524         //---------------------------------------------------------------------
004900180524         // Get the fields for the file layout
005000180529         FLP020DS = FL20DSIN ; // Format the passed data
005100180528
005200180524         ExSR CrtCursor ;
005300180524         CallP OpenFLD() ;
005400180524         Rc = FetchMultFLD();
005500180524         CallP CloseFLD() ;
005600180524         If Tot_Fields > *Zero ; // If fields were found process the file layout
005700180526           ExSR CrtScriptT ; // Create the table to hold the new script
005800180529           XMLLine = *Blanks ;
005801180529           // XML heading 1
005900180529           XMLLINE = %Trim(FLP020DS.FL2006) + CrLf ;
006800180528           Exec SQL
006900180529             Insert Into FLPXML (FLXML01) Values(:XMLLINE) ;
006901180529           // XML heading 2
006902180529           XMLLine = *Blanks ;
006903180530           XMLLine = %Trim(FLP020DS.FL2007) + CrLf ;
006905180529           Exec SQL
006906180529             Insert Into FLPXML (FLXML01) Values(:XMLLINE) ;
006907180529           // XML heading 3
006908180529           XMLLine = *Blanks;
006909180530           Pos = 3 ;
006910180530           %Subst(XMLline:Pos) = '<xs:element name=' + Ap +
006911180530             %Trim(FLP020DS.FL2008) + Ap + '>' + CrLf ;
006913180529           Exec SQL
006914180529             Insert Into FLPXML (FLXML01) Values(:XMLLINE) ;
006915180529           //------------------------------------------------------------------
007000180528           For P = 1  to Tot_Fields;
007001180530             XMLLine = *Blanks ;
007002180530             Pos = 5 ;
007103180530               Select ;
007104180530                 When FIELDSDS(P).WHFLDT = 'A' ;
007105180530                   If FIELDSDS(P).WHALIS <> *Blanks ;
007106180530                     %Subst(XMLline:Pos) = '<xs:element name=' + Ap +
007107180530                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:string"/>' +
007108180530                     CrLf;
007109180530                   Else;
007110180530                     %Subst(XMLline:Pos) = '<xs:element name=' + Ap +
007111180530                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:string"/>' +
007112180530                     CrLf;
007113180530                   EndIf;
007114180530                 When FIELDSDS(P).WHFLDT = 'B' ;
007115180530                   If FIELDSDS(P).WHALIS <> *Blanks ;
007116180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007117180530                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:int"/>' +
007118180530                     CrLf ;
007119180530                   Else;
007120180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007121180530                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:int"/>' +
007122180530                     CrLf ;
007123180530                   EndIf;
007124180530                 When FIELDSDS(P).WHFLDT = 'I' ;
007125180530                   If FIELDSDS(P).WHALIS <> *Blanks ;
007126180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007127180530                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:integer"/>' +
007128180530                     CrLf ;
007129180530                   Else;
007130180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007131180530                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:integer"/>' +
007132180530                     CrLf ;
007133180530                   EndIf ;
007134180530                 When FIELDSDS(P).WHFLDT = 'L' ;
007135180530                   If FIELDSDS(P).WHALIS <> *Blanks ;
007136180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007137180530                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:date"/>' +
007138180530                     CrLf ;
007139180530                   Else;
007140180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007141180530                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:date"/>' +
007142180530                     CrLf ;
007143180530                   EndIf;
007144180530                 When FIELDSDS(P).WHFLDT = 'P' ;
007145180530                   If FIELDSDS(P).WHALIS <> *Blanks ;
007146180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007147180530                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:decimal"/>' +
007148180530                     CrLf ;
007149180530                   Else;
007150180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007151180530                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:decimal"/>' +
007152180530                     CrLf ;
007153180530                   EndIf;
007154180530                 When FIELDSDS(P).WHFLDT = 'S' ;
007155180530                   If FIELDSDS(P).WHALIS <> *Blanks ;
007156180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007157180530                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:decimal"/>' +
007158180530                     CrLf ;
007159180530                   Else;
007160180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007161180530                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:decimal"/>' +
007162180530                     CrLf ;
007163180530                   EndIf;
007164180530                 When FIELDSDS(P).WHFLDT = 'Z' ;
007165180530                   If FIELDSDS(P).WHALIS <> *Blanks ;
007166180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007167180530                     %Trim(FIELDSDS(P).WHALIS) + Ap + ' type="xs:datetime"/>' +
007168180530                     CrLf ;
007169180530                   Else;
007170180530                     %Subst(XMLLine:Pos) = '<xs:element name=' + Ap +
007171180530                     %Trim(FIELDSDS(P).WHFLDI) + Ap + ' type="xs:datetime"/>' +
007172180530                     CrLf ;
007173180530                   EndIf;
007174180530               EndSl;
008100180530             Exec SQL
008200180530               Insert Into FLPXML (FLXML01) Values(:XMLLINE) ;
008300180526           EndFor;
008301180530           XMLLine = *Blanks;
008302180530           Pos = 3 ;
008303180530           %Subst(XMLline:Pos) = '</xs:element>' + CrLf ;
008304180530           Exec SQL
008305180530             Insert Into FLPXML (FLXML01) Values(:XMLLINE) ;
008306180530           XMLLine = *Blanks;
008307180530           XMLLine = '</xs:schema>' + CrLf ;
008308180530           Exec SQL
008309180530             Insert Into FLPXML (FLXML01) Values(:XMLLINE) ;
008310180530
008311180530           If FLP020DS.FL2010 = *Blanks;
008312180530             FTYPE = 'xsd' ;
008313180530           Else ;
008314180530             FTYPE = FLP020DS.FL2010 ;
008315180530           EndIf;
008400180530           EOJ = FLM050(FLP020DS.FL2002
008500180530                        :FLP020DS.FL2003
008600180528                        :TEXTLIB
008700180528                        :TEXTIN
008800180530                        :FLP020DS.FL2009
008900180526                        :FTYPE) ;
009000180524         EndIf;
009100180524         Return EOJ;
009200180524       //*--------------------------------------------------------
009300180524       //* Create the Fields SQL cursor
009400180524       //*--------------------------------------------------------
009500180524       BegSr CrtCursor;
009600180524
009700180524          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
009800180524                   'WHFTXT, WHNULL, WHCHD1, WHCHD2, WHALIS ' +
009900180530                   'From FIELDS  Where WHFILE = ' + Ap +
010000180530                   %Trim(FLP020DS.FL2003) + Ap + ' For Read Only ' ;
010100180524
010200180524       EndSr;
010300180526       //*--------------------------------------------------------
010400180526       //* Create the script table
010500180526       //*--------------------------------------------------------
010600180526       BegSr CrtScriptT;
010700180526
010800180529         Exec SQL
010900180529           DROP TABLE DJDATA.FLPXML ;
011000180526         Exec SQL
011100180529           CREATE TABLE DJDATA.FLPXML (
011200180529           Script_Text FOR FLXML01 CHAR(128) NOT NULL DEFAULT '') ;
011300180526         Exec SQL
011400180529           LABEL ON TABLE DJDATA.FLPXML
011500180529                 IS 'XML Schema Script' ;
011600180526         Exec SQL
011700180529           LABEL ON COLUMN DJDATA.FLPXML (
011800180529             FLXML01 TEXT IS 'XML SCRIPT ROWS') ;
011900180526         Exec SQL
012000180529            LABEL ON COLUMN DJDATA.FLPXML (
012100180529             FLXML01 IS 'XML script') ;
012200180526
012300180526       EndSr;
012400180526       //*--------------------------------------------------------
012500180529       End-Proc FLM020A ;
012600180524       //--------------------------------------------------------
012700180524       //  closeFLD - Close the call file cursor
012800180524       //--------------------------------------------------------
012900180524       Dcl-Proc closeFLD;
013000180524
013100180524       Dcl-PI closeFLD;
013200180524       End-PI;
013300180524
013400180524          Exec SQL close FLDCursor;
013500180524
013600180524       End-Proc closeFLD;
013700180524       //--------------------------------------------------------
013800180524       //  fetchMultFLD - read all the fields/Columns
013900180524       //--------------------------------------------------------
014000180524       Dcl-Proc fetchMultFLD;
014100180524
014200180524       Dcl-PI fetchMultFLD         Ind;
014300180524       End-PI;
014400180524
014500180524          Exec SQL
014600180524              fetch next from FLDCursor
014700180524              For :Mult_Fields rows
014800180524              into :FieldsDS;
014900180524          //
015000180524          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
015100180524          //
015200180524          If SQLSTT < '020000';
015300180524             Return *ON;
015400180524          Else;
015500180524             Return *OFF;
015600180524          EndIf;
015700180524          //
015800180524
015900180524       End-Proc fetchMultFLD;
016000180524       //---------------------------------------------------------------------
016100180524       //  openFLD  - Open a cursor to read the Fields/Columns
016200180524       //---------------------------------------------------------------------
016300180524       Dcl-Proc openFLD;
016400180524
016500180524       Dcl-PI openFLD;
016600180524       End-PI;
016700180524          Exec SQL prepare wkStatement from :CsrSel ;
016800180524          // *
016900180524          Exec SQL declare FLDCursor cursor for wkStatement ;
017000180524          // *
017100180524          Exec SQL open FLDCursor ;
017200180524          // *
017300180524          // *
017400180524       End-Proc openFLD;
