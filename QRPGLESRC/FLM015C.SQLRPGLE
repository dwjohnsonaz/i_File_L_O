       Ctl-Opt DFTNAME(FLM015C) ;
       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
       // Maintain Excel conversion controls
       Dcl-F FLD015C        WORKSTN USROPN ;
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
       Dcl-DS FLP015CDS EXTNAME('FLP015C') Qualified INZ END-DS;
       Dcl-DS SDS PSDS Qualified ;   // Remember to use SDS. !
         PGMNAM  Char(10)  Pos(1);
        End-DS;
       // Stand Alone Fields
       Dcl-S AddIt                  Ind  Inz ;
       Dcl-S AwMSgId               Char(7);
       Dcl-S AwMSgF                Char(20);
       Dcl-S AwMSgDta              Char(256);
       Dcl-S Ap                    Char(1) Inz(X'7D'); // apostrophe '''
       Dcl-S apMsk                 Char(4);
       Dcl-S apMsr                 Char(10);
       Dcl-S apTyp                 Char(10);
       Dcl-S apQue                 Char(10);
       Dcl-S CmdStr                Char(1024) Inz;
       DCL-S CpfMsgID              CHAR(7)  Import('_EXCP_MSGID') ;
       Dcl-S ErrorOn               Ind  INZ('0');
       Dcl-S HMSPATH               Char(90);
       Dcl-S HMYSPATH              Char(90);
       Dcl-S HORPATH               Char(90);
       Dcl-S NewPath               Char(90);
       Dcl-s OldPath               Char(90);
       Dcl-S Scrn#                  Int(5) Inz(1) ;
       Dcl-S spLen                  Int(10:0);
       Dcl-S spStk                  Int(10:0);
       Dcl-S spKy                   Int(10:0);
       Dcl-S spErr                  Int(10:0);
       Dcl-S spStk1                Char(10);
       Dcl-S spCsc                  Int(10:0);
       Dcl-S spErc                  Int(10:0);
       Dcl-S TempPath      Char(78) Inz('/DJIBMi/TableCV/csv') ;

       Exec Sql Set Option Commit = *None; // manage commitment control
       If Not %Open(FLD015C) ;
         Open FLD015C ;
       EndIf;
       // Get the record to work on
       Exec SQL
          Select * Into :FLP015CDS from FLP015C ;
       // Check for Insert/Update
       If FLP015CDS.FL15CINDEX = *Zero;
         ADDIT = *ON ;
         PKEYYN = *Blanks ;
         DROPYN = *Blanks ;
         SCHEMA = *Blanks;
         SRCLIB = *Blanks;
         MSPATH = *Blanks;
         MYSPATH = *Blanks;
         ORPATH = *Blanks;
       Else;
         ADDIT = *OFF ;
         PKEYYN = FLP015CDS.FL15C01 ;
         DROPYN = FLP015CDS.FL15C02 ;
         SCHEMA = FLP015CDS.FL15C03 ;
         SRCLIB = FLP015CDS.FL15C04 ;
         MSPATH = FLP015CDS.FL15C05 ;
         MYSPATH = FLP015CDS.FL15C06 ;
         ORPATH = FLP015CDS.FL15C07 ;
         HMSPATH = MSPATH;
         HMYSPATH = MYSPATH;
         HORPATH = ORPATH ;
       Endif;
       Dow Scrn# = 1 ;
         If ErrorOn = *ON;
           Write MsgCtl;
         EndIf;
         ExFMT Scrn01 ;
         If ErrorOn = *ON ;
           ExSR ClrMsg;
           ErrorOn = *OFF;
         EndIf;
         Select;
           When *IN01 = *ON ;
           When *IN03 = *ON ;
             Scrn# = *Zero;
             Leave;
           When *IN05 = *ON ;
             ExSR Edit01;
             If ErrorOn = *Off;
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
         Close FLD015C ;
         *INLR = *ON ;
       EndIf;
          //*------------------------------------------------------------------
          //* EDIT01 - Edit Screen 01
          //*------------------------------------------------------------------
          BegSR Edit01 ;
            If MSPATH <> *Blanks AND %SubSt(MSPATH:1:1) <> '/' ;
              If ErrorOn = *OFF;
                ErrorOn = *ON;
              EndIf;
              AwMsgDta = *Blanks;
              AwMsgDta = 'Sequal Server IFS Path must start with ' +
                         Ap + '/'+ Ap ;
              ExSR SendMsg;
            EndIf;
            If MYSPATH <> *Blanks AND %SubSt(MYSPATH:1:1) <> '/' ;
              If ErrorOn = *OFF;
                ErrorOn = *ON;
              EndIf;
              AwMsgDta = *Blanks;
              AwMsgDta = 'My SQL IFS Path must start with ' + Ap + '/'+ Ap ;
              ExSR SendMsg;
            EndIf;
            If ORPATH <> *Blanks AND %SubSt(ORPATH:1:1) <> '/' ;
              If ErrorOn = *OFF;
                ErrorOn = *ON;
              EndIf;
              AwMsgDta = *Blanks;
              AwMsgDta = 'Oracle IFS Path must start with ' + Ap + '/'+ Ap ;
              ExSR SendMsg;
            EndIf;
          EndSr;
          //*------------------------------------------------------------------
          //* AddIt - Add an new source member
          //*------------------------------------------------------------------
          BegSR Add01 ;
            Exec SQL
              Insert Into FLP015C
                    (FL15C01, FL15C02, FL15C03, FL15C04, FL15C05, FL15C06,
                     FL15C07 )
             Values (:PKEYYN, :DROPYN, :SCHEMA, :SRCLIB, :MSPATH,
                     :MYSPATH, :ORPATH ) ;
            If MSPATH <> *Blanks;
              NewPath = MSPATH;
              OldPath = HMSPATH;
              ExSR SetPath;
            EndIf;
            If MYSPATH <> *Blanks;
              NewPath = MYSPATH;
              OldPath = HMYSPATH;
              ExSR SetPath;
            EndIf;
            If ORPATH <> *Blanks;
              NewPath = ORPATH;
              OldPath = HORPATH;
              ExSR SetPath;
            EndIf;
          EndSR ;
           //
          //*------------------------------------------------------------------
          //* UpdateIt - Update the SQL record
          //*------------------------------------------------------------------
          BegSR Upd01 ;
            Exec SQL
              Update FLP015C
                Set(FL15C01, FL15C02, FL15C03, FL15C04, FL15C05, FL15C06,
                    FL15C07 )
                  = (:PKEYYN, :DROPYN, :SCHEMA, :SRCLIB, :MSPATH,
                     :MYSPATH, :ORPATH )
                Where FL15CINDEX = :FLP015CDS.FL15CINDEX ;
            If MSPATH <> *Blanks;
              NewPath = MSPATH;
              OldPath = HMSPATH;
              ExSR SetPath;
            EndIf;
            If MYSPATH <> *Blanks;
              NewPath = MYSPATH;
              OldPath = HMYSPATH;
              ExSR SetPath;
            EndIf;
            If ORPATH <> *Blanks;
              NewPath = ORPATH;
              OldPath = HORPATH;
              ExSR SetPath;
            EndIf;
          EndSR ;
       //-------------------------------------------------------------------------
       // SetPath: Set the IFS Path
       //-------------------------------------------------------------------------
       BegSr SetPath;
         If NewPath <> *Blanks;
           If OldPath <> *Blanks AND OldPath <> NewPath;
             // Remove old path
             CmdStr = *Blanks ;
             CmdStr = 'RMVLNK ' + Ap + %Trim(OLDPATH) + Ap ;
             SystemCmd(CmdStr);
             If CpfMsgID <> *Blanks; // Handle error messages here
             EndIf;
             // Set up the new path
             CmdStr = *Blanks ;
             CmdStr = 'MD ' + Ap + %Trim(NEWPATH) + Ap ;
             SystemCmd(CmdStr);
             If CpfMsgID <> *Blanks; // Handle error messages here
             EndIf;
           EndIf;
           If OLDPATH = *Blanks;
             // Set up the new path
             CmdStr = *Blanks ;
             CmdStr = 'MD ' + Ap + %Trim(NEWPATH) + Ap ;
             SystemCmd(CmdStr);
             If CpfMsgID <> *Blanks; // Handle error messages here
             EndIf;
           EndIf;
         EndIf;
       EndSr;
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
