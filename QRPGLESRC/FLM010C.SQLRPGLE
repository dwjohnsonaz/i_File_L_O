       Ctl-Opt DFTNAME(FLM010C) ;
       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
       // Maintain Excel conversion controls
       Dcl-F FLD010C        WORKSTN USROPN ;
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
       Dcl-DS FLP010CDS EXTNAME('FLP010C') Qualified INZ END-DS;
       Dcl-DS SDS PSDS Qualified ;   // Remember to use SDS. !
         PGMNAM  Char(10)  Pos(1);
        End-DS;
       // Stand Alone Fields
       Dcl-S AddIt         Ind  Inz ;
       Dcl-S AwMSgId               Char(7);
       Dcl-S AwMSgF                Char(20);
       Dcl-S AwMSgDta              Char(256);
       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
       Dcl-S apMsk                 Char(4);
       Dcl-S apMsr                 Char(10);
       Dcl-S apTyp                 Char(10);
       Dcl-S apQue                 Char(10);
       DCL-S CmdStr                CHAR(1024) INZ ;
       DCL-S CpfMsgID              CHAR(7)  Import('_EXCP_MSGID') ;
       Dcl-S ErrorOn               Ind  INZ('0');
       Dcl-S HIFSPATH              Char(90);
       Dcl-S Scrn#                 Int(5) Inz(1) ;
       Dcl-S spLen                  Int(10:0);
       Dcl-S spStk                  Int(10:0);
       Dcl-S spKy                   Int(10:0);
       Dcl-S spErr                  Int(10:0);
       Dcl-S spStk1                Char(10);
       Dcl-S spCsc                  Int(10:0);
       Dcl-S spErc                  Int(10:0);

       Dcl-S TempPath      Char(78) Inz('/DJIBMi/TableCV/csv') ;

       Exec Sql Set Option Commit = *None; // manage commitment control
       If Not %Open(FLD010C) ;
         Open FLD010C ;
       EndIf;
       // Get the record to work on
       Exec SQL
          Select * Into :FLP010CDS from FLP010C ;
       // Check for Insert/Update
       If FLP010CDS.FL10CINDEX = *Zero;
         ADDIT = *ON ;
         GENEXD = *Blanks ;
         EXHTEXT = *Blanks ;
         GENCOLH = *Blanks;
         COLSEP = *Blanks;
         CONVDATE = *Blanks;
         CONVTIME = *Blanks;
         CONVTS = *Blanks;
         CONVNUM = *BLanks ;
         IFSPATH = *Blanks;
       Else;
         ADDIT = *OFF ;
         GENEXD = FLP010CDS.FL10C01 ;
         EXHTEXT = FLP010CDS.FL10C02 ;
         GENCOLH = FLP010CDS.FL10C03 ;
         COLSEP = FLP010CDS.FL10C04 ;
         CONVDATE = FLP010CDS.FL10C05 ;
         CONVTIME = FLP010CDS.FL10C06 ;
         CONVTS = FLP010CDS.FL10C07 ;
         CONVNUM = FLP010CDS.FL10C08 ;
         IFSPATH = FLP010CDS.FL10C09 ;
         HIFSPATH = IFSPATH;
       Endif;
       CpfMsgID = *Blanks;
       Dow Scrn# = 1 ;
         If ErrorOn = *On;
           Write MsgCtl;
         EndIf;
         ExFMT Scrn01 ;
         If ErrorOn = *On;
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
         EndSl;
       EndDo ;
       If Scrn# = *Zero ;
         Close FLD010C ;
         *INLR = *ON ;
       EndIf;
          //*------------------------------------------------------------------
          //* Edit for errors on screen 01
          //*------------------------------------------------------------------
          BegSR Edit01;
            If IFSPATH <> *Blanks AND %SubSt(IFSPATH:1:1) <> '/' ;
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
              Insert Into FLP010C
                    (FL10C01, FL10C02, FL10C03, FL10C04, FL10C05, FL10C06,
                     FL10C07, FL10C08, FL10C09)
             Values (:GENEXD, :EXHTEXT, :GENCOLH, :COLSEP,
                     :CONVDATE, :CONVTIME, :CONVTS, :CONVNUM, :IFSPATH ) ;
            If IFSPATH <> *Blanks;
              // Set up the new path
              CmdStr = *Blanks ;
              CmdStr = 'MD ' + Ap + %Trim(IFSPATH) + Ap ;
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
              Update FLP010C
                Set(FL10C01, FL10C02, FL10C03, FL10C04, FL10C05, FL10C06,
                    FL10C07, FL10C08, FL10C09 )
                  = (:GENEXD, :EXHTEXT, :GENCOLH, :COLSEP,
                     :CONVDATE, :CONVTIME, :CONVTS, :CONVNUM, :IFSPATH )
                Where FL10CINDEX = :FLP010CDS.FL10CINDEX ;
            If IFSPATH <> *Blanks;
              If HIFSPATH <> *Blanks AND HIFSPATH <> IFSPATH;
                // Remove old path
                CmdStr = *Blanks ;
                CmdStr = 'RMVLNK ' + Ap + %Trim(HIFSPATH) + Ap ;
                SystemCmd(CmdStr);
                If CpfMsgID <> *Blanks; // Handle error messages here
                EndIf;
                // Set up the new path
                CmdStr = *Blanks ;
                CmdStr = 'MD ' + Ap + %Trim(IFSPATH) + Ap ;
                SystemCmd(CmdStr);
                If CpfMsgID <> *Blanks; // Handle error messages here
                EndIf;
              EndIf;
              If HIFSPATH = *Blanks;
                // Set up the new path
                CmdStr = *Blanks ;
                CmdStr = 'MD ' + Ap + %Trim(IFSPATH) + Ap ;
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
