       Ctl-Opt DFTNAME(FLM020C) ;
       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
       // Maintain XML conversion controls
       Dcl-F FLD025C        WORKSTN USROPN ;
       //***************************************************************
       //            Prototype for QMHSNDPM-Sedn the message
       //****************************************************************
       Dcl-PR QMHSNDPM             ExtPgm('QMHSNDPM');
          AwMSgId                  Char(7);
          AwMSgF                   Char(20);
          AwMSgDta                 Char(256);
          spLen                     Int(10:0);
          apTyp                    Char(10);
          apQue                    Char(10);
          spStk                     Int(10:0);
          spKy                      Int(10:0);
          spErr                     Int(10:0);
       End-PR;
       //***************************************************************
       //            Prototype for QMHRMVPM-Clear the message
       //****************************************************************
       Dcl-PR QMHRMVPM             ExtPgm('QMHRMVPM');
          spStk1                   Char(10);
          spCsc                     Int(10:0);
          apMsk                    Char(4);
          apMsr                    Char(10);
          spErc                     Int(10:0);
       End-PR;
       Dcl-PR SystemCmd             Int(10:0) ExtProc('system');
         Cmd                   Pointer Value Options(*String);
       End-PR;
      // Data Structures
       Dcl-DS FLP025CDS EXTNAME('FLP025C') Qualified INZ END-DS;
       Dcl-DS SDS PSDS Qualified ;   // Remember to use SDS. !
         PGMNAM  Char(10)  Pos(1);
        End-DS;
       // Stand Alone Fields
       Dcl-S AddIt         Ind  Inz ;
       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
       Dcl-S AwMSgId               Char(7);
       Dcl-S AwMSgF                Char(20);
       Dcl-S AwMSgDta              Char(256);
       Dcl-S apMsk                 Char(4);
       Dcl-S apMsr                 Char(10);
       Dcl-S apTyp                 Char(10);
       Dcl-S apQue                 Char(10);
       DCL-S CmdStr                CHAR(1024) INZ ;
       DCL-S CpfMsgID              CHAR(7)  Import('_EXCP_MSGID') ;
       Dcl-S ErrorOn               Ind  INZ('0');
       Dcl-S HJSONPATH             Char(90);
       Dcl-S Scrn#         Int(5) Inz(1) ;
       Dcl-S spLen                  Int(10:0);
       Dcl-S spStk                  Int(10:0);
       Dcl-S spKy                   Int(10:0);
       Dcl-S spErr                  Int(10:0);
       Dcl-S spStk1                Char(10);
       Dcl-S spCsc                  Int(10:0);
       Dcl-S spErc                  Int(10:0);
       Dcl-S TempPath      Char(78) Inz('/DJIBMi/TableCV/csv') ;

       Exec Sql Set Option Commit = *None; // manage commitment control
       If Not %Open(FLD025C) ;
         Open FLD025C ;
       EndIf;
       // Get the record to work on
       Exec SQL
          Select * Into :FLP025CDS from FLP025C ;
       // Check for Insert/Update
       If FLP025CDS.FL25CINDEX = *Zero;
         ADDIT = *ON ;
         JSONHEAD = *Blanks ;
         JSONPATH = *Blanks ;
         FEXTN = *Blanks;
       Else;
         ADDIT = *OFF ;
         JSONHEAD = FLP025CDS.FL25C01 ;
         JSONPATH = FLP025CDS.FL25C02 ;
         FEXTN = FLP025CDS.FL25C03 ;
         HJSONPATH = JSONPATH;
       Endif;
       Dow Scrn# = 1 ;
         If ErrorOn =  *ON;
           Write MsgCtl;
         EndIf;
         ExFMT Scrn01 ;
         If ErrorOn = *ON;
           ExSR ClrMsg;
           ErrorOn = *Off;
         EndIf;
         Select;
           When *IN01 = *ON ;
           When *IN03 = *ON ;
             Scrn# = *Zero;
             Leave;
           When *IN05 = *ON ;
             ExSR Edit01;
             If ErrorOn = *OFF;
             If AddIt = *ON ;
               ExSR ADD01 ;
             Else;
               ExSR UPD01 ;
             EndIf;
             Scrn# = *Zero;
           EndIf;
         Other;
           ExSR Edit01;
         EndSl;
       EndDo ;
       If Scrn# = *Zero ;
         Close FLD025C ;
         *INLR = *ON ;
       EndIf;
       //*------------------------------------------------------------------
       //* Edit for errors on screen 01
       //*------------------------------------------------------------------
       BegSR Edit01;
         If JSONPATH <> *Blanks AND %SubSt(JSONPATH:1:1) <> '/' ;
            If ErrorOn = *OFF;
              ErrorOn = *ON;
            EndIf;
            AwMsgDta = *Blanks;
            AwMsgDta = 'IFS Location must start with ' + Ap + '/'+ Ap ;
            ExSR SendMsg;
         EndIf;
       EndSr;
          //*------------------------------------------------------------------
          //* AddIt - Add an new source member
          //*------------------------------------------------------------------
          BegSR Add01 ;

            Exec SQL
              Insert Into FLP025C
                     (FL25C01, FL25C02, FL25C03)
             Values (:JSONHEAD, :JSONPATH, :FEXTN) ;
             If JSONPATH <> *Blanks;
              // Set up the new path
                CmdStr = *Blanks ;
                CmdStr = 'MD ' + Ap + %Trim(JSONPATH) + Ap ;
                SystemCmd(CmdStr);
                If CpfMsgID <> *Blanks; // Handle error messages here
                EndIf;
            EndIf;
          EndSR ;
           //
          //*------------------------------------------------------------------
          //* UpdateIt - Update the SQL record
          //*------------------------------------------------------------------
          BegSR Upd01 ;

            Exec SQL
              Update FLP025C
                Set(FL25C01, FL25C02, FL25C03 )
                  = (:JSONHEAD, :JSONPATH, :FEXTN)

                Where FL25CINDEX = :FLP025CDS.FL25CINDEX ;
            If JSONPATH <> *Blanks;
              If HJSONPATH <> *Blanks AND HJSONPATH <> JSONPATH;
                // Remove old path
                CmdStr = *Blanks ;
                CmdStr = 'RMVLNK ' + Ap + %Trim(HJSONPATH) + Ap ;
                SystemCmd(CmdStr);
                If CpfMsgID <> *Blanks; // Handle error messages here
                EndIf;
                // Set up the new path
                CmdStr = *Blanks ;
                CmdStr = 'MD ' + Ap + %Trim(JSONPATH) + Ap ;
                SystemCmd(CmdStr);
                If CpfMsgID <> *Blanks; // Handle error messages here
                EndIf;
              EndIf;
              If HJSONPATH = *Blanks;
                // Set up the new path
                CmdStr = *Blanks ;
                CmdStr = 'MD ' + Ap + %Trim(JSONPATH) + Ap ;
                SystemCmd(CmdStr);
                If CpfMsgID <> *Blanks; // Handle error messages here
                EndIf;
              EndIf;
            EndIf;
          EndSR ;
       //-------------------------------------------------------------------------
       // SendMsg: Send to Message Subfile
       //-------------------------------------------------------------------------
       BegSr SendMsg;

          AwMsgF = 'QCPFMSG   *LIBL     ';
          SpLen = %LEN(AwMSgDta);
          ApTyp = '*DIAG';
          ApQue = '*';
          SpStk = *Zero;
          SpKy = *Zeros;
          SpErr = *Zeros;

          CallP QMHSNDPM(AwMsgID
                 :AwMsgF
                 :AwMsgDta
                 :SpLen
                 :apTyp
                 :apQue
                 :SpStk
                 :SpKy
                 :spErr);

       EndSr;
       //-------------------------------------------------------------------------
       // ClrMsg: Clear Message Subfile
       //-------------------------------------------------------------------------
       BegSr ClrMsg;

          SpStk1 = '*';
          SpCsc = *Zero;
          apMsk = *Blanks;
          apMsr = '*ALL';
          spErc = *Zero;

          CallP QMHRMVPM(SpStk1
                 :SpCsc
                 :apMsk
                 :apMsr
                 :spErc);

       EndSr;
       //-------------------------------------------------------------------------
