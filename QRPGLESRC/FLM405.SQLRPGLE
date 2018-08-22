       Ctl-Opt DFTNAME(FLM405) fixnbr(*INPUTPACKED:*ZONED) NOMAIN;
       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
       // Pop-Up File/Table - Field/Column selections
       Dcl-F FLD405  WORKSTN SFILE(SFL01:XRRNS1) INDDS(WsInd) USROPN ;
       //-------- Prototypes ---------*
      /Copy QRPGLESRC,FLT001
      /Copy QRPGLESRC,UTT001
       Dcl-Pr ScreenSize   ExtProc('QsnRtvMod');
         ScreenSize    Char(1);
         llHandle       Int(10:0) Options(*OMIT) Const;
         error         Char(16) Options(*Varsize);
       End-Pr;
       Dcl-PR SysCmd           Int(10:0) ExtProc('system');
         Cmd                   Pointer Value Options(*String);
       End-PR;
       // SQL processing subprocedures
       Dcl-PR CloseFLD  End-PR;
       Dcl-PR FetchMultFLD  Ind;
       End-PR;
       Dcl-PR OpenFLD  End-PR;

       Dcl-PR QCMDEXC                  ExtPgm('QCMDEXC');
          *N                       Char(32702) options(*varsize) const;
          *N                     Packed(15:5) const;
       End-PR;
       // Data Sets for processing
       Dcl-DS FieldsDS Qualified Dim( 1000 ) ;
         WHNAME      Char(10) ;   // Record Format
         WHFLDI      Char(10) ;   // Internal Field Name
         WHFLDT      Char(1)  ;   // Field Type
         WHFLDB      Zoned(5:0) ; // Field Length in bytes
         WHFLDP      Zoned(2:0) ; // Field Decimal Positions
         WHFTXT      Char(50) ;   // Field text desrciption
         WHNULL      Char(1)  ;   // Field Null Y/N
         WHALIS      Char(32) ;   // SQL Alias field
         WHVARL      Char(1)  ;   // Variable length field
       End-Ds;
       Dcl-DS WSInd ;
         IN01        Ind Pos(01);
         IN03        Ind Pos(03);
         IN12        Ind Pos(12);
         LgScrn      Ind Pos(20) ;
         IN27        Ind Pos(27);
         IN28        Ind Pos(28);
         IN29        Ind Pos(29);
       End-DS;
       // Character - apostrophe
       Dcl-C AP         const(X'7D'); // apostrophe '''
       Dcl-C Green      const(X'20'); // color atribute Green
       Dcl-C White      const(X'22'); // color atribute White
       //----- Stand Alone Fields -----*
       Dcl-S AliasDsp              Char(75) ;
       Dcl-S APFILE                Char(10) ;   // Record Format
       Dcl-S BEGIN                 Char(1);
       Dcl-S BYTES               Packed(5:0);
       Dcl-S CLO64                 Char(64) ;
       Dcl-S Cmd                   Char(32702) ;
       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
       Dcl-S CsrSel                Char(256);                // SQL Cursor Def.
       Dcl-S Decimal                Ind ;
       Dcl-S EOJ                   Char(2);
       Dcl-S EPOS                Packed(4:0);
       Dcl-S ErrDS                 Char(16) Inz( *AllX'00' ) ;
       Dcl-S ErrorOn                IND ;
       Dcl-S First                  Ind Inz('1') ;
       Dcl-S KEYYN                 Char(1);
       Dcl-S Length              Packed(15:5) ;
       Dcl-S LIBOBJ                Char(21);
       Dcl-S LOLEN                 Int(10) Inz(21) ;
       Dcl-S LO01                  Char(11);
       Dcl-S Mode                  Char(1);
       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
       Dcl-S NUM                 Packed(2:0);
       Dcl-S ODDEVEN               Char(1) Inz('O');
       Dcl-S P                     Int(5) ;
       Dcl-S PAGENO                Int(5) ;
       Dcl-S Q                     Char(1);
       Dcl-S RB4                   Char(1) DIM(21);
       Dcl-S Rc                    Ind ;
       Dcl-S REMAIN              Int(10) ;
       Dcl-S RESULT              Packed(7:0);
       Dcl-S SFL01IND            Ind ;
       Dcl-S SPOS                Packed(4:0);
       Dcl-S TESTI               Int(5) ;
       Dcl-S TIME                Packed(6:0);
       Dcl-S Tot_Fields          Int(10) ;
       Dcl-S Tot_Keys            Int(10) ;
       Dcl-S VarLen              Ind Inz('0');
       Dcl-S VarAdj              Int(10:0) Inz;
       Dcl-S X                   Packed(2:0);
       Dcl-S Y                   Packed(2:0);
       Dcl-S Scrn#                  Int(3:0) Inz(1) ;
       //*--------------------------------------------------------------------
       Dcl-Proc FLM405 Export ;
         Dcl-PI FLM405 Char(2) ;
         End-PI;
         ScreenSize(mode: *OMIT : Errds);
           If Mode = '4';
             LgScrn = *ON;
           Else;
             LgScrn = *OFF;
           EndIf;
       //---------------------------------------------------------------------
       // Process Lib/File selection
       If Not %Open(FLD405);
         Open FLD405;
       EndIf;
       Scrn# = 1;
       FLLIB = *Blanks;
       FLFILE = *Blanks;
       FLFORMAT = *Blanks;
       DoW Scrn# = 1;
         Exfmt WIND02;
         ErrorOn = *Off;
         Error = *Blanks;
         If IN03 = *ON ;
           Scrn# = *Zero;
           Leave;
         EndIf;
         ExSR Edit01;
         If ErrorOn = *OFF ;
           Scrn# = 2 ;
         EndIf;
       EndDo;
       // Get fields to display
       DoW Scrn# = 2;
         Callp FLC001O(FLFILE:FLLIB) ;
         Exec SQL
           Select ATTXT Into :ATTXTP
                  from FILES
                  Where ATFILE = :FLFILE AND ATLIB = :FLLIB ;
         ExSR CrtCursor ;
         CallP OpenFLD() ;
         Rc = FetchMultFLD();
         CallP CloseFLD() ;
         If Tot_Fields > *Zero ; // If fields were found process the file layout
           FLFORMAT = FieldsDS(1).WHNAME ;
           ExSR BuildSFL01 ; // Build the display
           DoW SFL01IND = *ON ;
             XRRNS1 = 1;
             Write WIND01;
             IN27 = *ON;
             IN28 = *ON;
             ExFmt CTL01 ;
             IN27 = *OFF;
             IN28 = *OFF;
             Error = *Blanks ;
             Select ;
             When IN01 = *ON;
             When IN03 = *ON ;
               SFL01IND = *OFF;
               FILEEOJ = '03' ;
               Scrn# = *Zero;
               Leave;
             EndSl;
           EndDo;
         Else;
           Scrn# = *Zero;
           EOJ = 'NA' ;
         EndIf;
       EndDo;
       If Scrn# = *Zero;
         CallP FLC001C() ;
         Close FLD405;
         Return EOJ ;
       EndIf;
       //*------------------------------------------------------------------
       //* Edit01 - Edit the input fields in SCRN01
       //*------------------------------------------------------------------
       BegSR Edit01 ;
         ErrorON = *OFF ;
         cmd = 'CHKOBJ OBJ('+ %trim(FLLIB) +')' +
              ' OBJTYPE(*LIB)';
         CallP(E) qcmdexc(cmd: %len(cmd));
         If %error;
           ErrorOn = *ON;
           Error = 'Library ' + %TRIM(FLLIB) + ' Not Found' ;
           LeaveSR;
         EndIf;
         Cmd = 'CHKOBJ OBJ(' + %Trim(FLLIB) + '/' + %Trim(FLFILE) + ') ' +
               'OBJTYPE(*FILE)' ;
         CallP(E) qcmdexc(cmd: %len(cmd));
         If %error;
           ErrorOn = *ON;
           Error = 'File ' + %TRIM(FLLIB) + '/' + %Trim(FLFILE) +
                     ' not found' ;
           LeaveSR;
         EndIf;
       EndSR;
       //*--------------------------------------------------------
       //* Build Subfile 01
       //*--------------------------------------------------------
       BegSr BuildSFL01;
         XRRNS1 = *Zero;
         IN29 = *ON;
         Write CTL01;
         IN29 = *OFF ;
         For P = 1 to Tot_Fields ;
           SF1FIELD = FieldsDS(P).WHFLDI ;  // Field/Column name
           SF1DESCR = FieldsDS(P).WHFTXT;  // Field/Column description
           SF1TYPE = FieldsDS(P).WHFLDT;  // Field/Column data type
           // Check for numeric fields
           If FieldsDS(P).WHFLDT = 'B'
           or FieldsDS(P).WHFLDT = 'I'
           or FieldsDS(P).WHFLDT = 'P'
           or FieldsDS(P).WHFLDT = 'S'
           or FieldsDS(P).WHFLDT = 'U';
              SF1DEC = %EditW(FieldsDS(P).WHFLDP:'0 ') ;
           Else;
              SF1DEC = *Blanks;
           EndIf;
           If FieldsDS(P).WHFLDT = 'A' ;
             If FieldsDS(P).WHVARL = 'Y' ;
               VarLen = *ON ;
               SF1TYPE = 'V';
             Else;
               VarLen = *OFF;
             EndIf;
           EndIf;
           // Get the Length
           If VarLen = *ON;
             VarAdj = fieldsDS(P).WHFLDB - 2 ;
             EvalR SF1LEN = %Trim(%EditC(VarAdj:'Z')) ;
           Else;
             SF1Len = %EditC(FieldsDS(P).WHFLDB:'Z') ;
           EndIf;
           // GET FROM/TO LOCATION
           XRRNS1 += 1;
           Write SFL01 ;
           EndFor;
          SFL01IND = *ON ;
       EndSr;
       //*--------------------------------------------------------
       //* Create the Fields SQL cursor
       //*--------------------------------------------------------
       BegSr CrtCursor;

          CsrSel = 'Select WHNAME, WHFLDI, WHFLDT, WHFLDB, WHFLDP, ' +
                   'WHFTXT, WHNULL, WHALIS, WHVARL ' +
                   'From FIELDS  Where WHFILE = ' + Ap + FLFILE + Ap +
                   'For Read Only ' ;

       EndSr;
       //*--------------------------------------------------------
       End-Proc FLM405;
       //--------------------------------------------------------
       //  closeFLD - Close the call file cursor
       //--------------------------------------------------------
       Dcl-Proc closeFLD;

       Dcl-PI closeFLD;
       End-PI;

          Exec SQL close FLDCursor;

       End-Proc closeFLD;
       //--------------------------------------------------------
       //  fetchMultFLD - read all the fields/Columns
       //--------------------------------------------------------
       Dcl-Proc fetchMultFLD;

       Dcl-PI fetchMultFLD         Ind;
       End-PI;

          Exec SQL
              fetch next from FLDCursor
              For :Mult_Fields rows
              into :FieldsDS;
          //
          Exec SQL Get Diagnostics :Tot_Fields = ROW_COUNT ;
          //
          If SQLSTT < '020000';
             Return *ON;
          Else;
             Return *OFF;
          EndIf;
          //

       End-Proc fetchMultFLD;
       //---------------------------------------------------------------------
       //  openFLD  - Open a cursor to read the Fields/Columns
       //---------------------------------------------------------------------
       Dcl-Proc openFLD;

       Dcl-PI openFLD;
       End-PI;
          Exec SQL prepare wkStatement from :CsrSel ;
          // *
          Exec SQL declare FLDCursor cursor for wkStatement ;
          // *
          Exec SQL open FLDCursor ;
          // *
          // *
       End-Proc openFLD;
