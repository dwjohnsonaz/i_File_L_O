     ?** Prototypes - FLT001
     ?*====  FLC001C - Delete Files after processing   ====
       DCL-PR FLC001C  END-PR ;
     ?*====  FLC001O - File layout CL processing   ====
       DCL-PR FLC001O ;
         FILE     Char(10);
         LIBR     Char(10);
       END-PR;
     ?*====  FLM002 - File/Table layout print   ====
       DCL-PR FLM002  CHAR(2);
         *N       Char(10);
         *N       Char(10);
         *N       Char(10);
         *N     Packed(2);
         *N       Char(1);
       END-PR;
     ?*====  FLM003 - File/Table layout display   ====
       DCL-PR FLM003  CHAR(2);
         *N       Char(10);
         *N       Char(10);
         *N       Char(10);
       END-PR;
     ?*====  FLM010 - Excel/.csv selections  ====
     ?*
       DCL-PR FLM010  CHAR(2);
         *N       Char(10);
         *N       Char(10);
         *N       Char(10);
       END-PR;
     ?*====  FLM010A- Excel/.csv file Sys   ====
       DCL-PR FLM010A CHAR(2);
         *N       Char(176) ;
         *N       Char(1);
       END-PR;
     ?*====  FLM010B- Excel/.csv file IFS   ====
       DCL-PR FLM010B CHAR(2);
         *N       Char(176) ;
         *N       Char(1);
       END-PR;
     ?*====  FLM010I - Excel/.csv file Sys   ====
       DCL-PR FLM010I CHAR(2);
         *N       Char(176) ;
         *N       Char(1);
       END-PR;
     ?*====  FLM015 - SQL Table in QSQLSRC   ====
       DCL-PR FLM015  CHAR(2);
         *N       Char(10);
         *N       Char(10);
         *N       Char(10);
       END-PR;
     ?*====  FLM015A - DB2 SQL Table in QSQLSRC   ====
       DCL-PR FLM015A  CHAR(2);
         *N       Char(435) ;
         *N       Char(1) ;
       END-PR;
     ?*====  FLM015A1 - DB2 SQL Table in QSQLSRC   ====
       DCL-PR FLM015A1  CHAR(2);
         *N       Char(435) ;
         *N       Char(1) ;
       END-PR;
     ?*====  FLM015M - Miranda script   ====
       DCL-PR FLM015M  CHAR(2);
         *N       Char(435) ;
         *N       Char(1) ;
       END-PR;
     ?*====  FLM015O - Oracle script   ====
       DCL-PR FLM015O  CHAR(2);
         *N       Char(435) ;
         *N       Char(1) ;
       END-PR;
     ?*====  FLM015S - DB2 MS Sequel script   ====
       DCL-PR FLM015S  CHAR(2);
         *N       Char(435) ;
         *N       Char(1) ;
       END-PR;
     ?*====  FLM020 - XML Table script IFS   ====
       DCL-PR FLM020  CHAR(2);
         *N       Char(10);
         *N       Char(10);
         *N       Char(10);
       END-PR;
     ?*====  FLM020A- XML/.xls IFS file  ====
       DCL-PR FLM020A CHAR(2);
         *N       Char(375) ;
         *N       Char(1);
       END-PR;
     ?*====  FLM020I- XML/.xls IFS file  ====
       DCL-PR FLM020I CHAR(2);
         *N       Char(375) ;
         *N       Char(1);
       END-PR;
     ?*====  FLM025 - JSON Table script IFS   ====
       DCL-PR FLM025  CHAR(2);
         *N       Char(10);
         *N       Char(10);
         *N       Char(10);
       END-PR;
     ?*====  FLM025A- JSON/.jsn IFS file  ====
       DCL-PR FLM025A CHAR(2);
         *N       Char(285) ;
         *N       Char(1);
       END-PR;
     ?*====  FLM025I- JSON/.jsn IFS file  ====
       DCL-PR FLM025I CHAR(2);
         *N       Char(285) ;
         *N       Char(1);
       END-PR;
     ?*====  FLM050 - Transfer a script to the IFS   ====
       DCL-PR FLM050   CHAR(2);
         *N       Char(10);
         *N       Char(10);
         *N       Char(10);
         *N       Char(10);
         *N       Char(90) ;
         *N       Char(3) ;
       END-PR ;
     ?*====  FLM400 - Pop-Up Library/File/Field Selection  ====
       DCL-PR FLM400   CHAR(82);
       END-PR ;
       Dcl-DS FLM400DS              Len(82);
          FILELIB                  Char(10) ;
          FILENAM                  Char(10) ;
          FILEFMT                  Char(10) ;
          FILEFNAME                Char(10) ;
          FILEFNAL                 Char(32) ;
          FILETYPE                 Char(1) ;
          FILEFLEN                Zoned(5:0);
          FILEFDP                 Zoned(2:0);
          FILEEOJ                  Char(2);
       End-DS;
     ?*====  FLM405 - Pop-Up Library/File/Field Display  ====
       DCL-PR FLM405  Char(2);
       END-PR ;
       // Prototype for DspError subprocedure
     ?*====  IFS_IO - DspError subprodecure   ====
       Dcl-PR DspError   ;
         *N       Char(10) Const;
       End-PR;
     ?*====  IFS_IO - Create/Write data to the IFS   ====
       DCL-PR IFS_IO ;
         *N                        Char(1) ;
         *N                        Char(1) ;
         *N                      Packed(5:0) ;
         *N                        Char(512) ;
         *N                        Char(128) Options(*NoPass) ;
         *N                        Char(10) Options(*NoPass) ;
         *N                         Int(10) Options(*NoPass) ;
         *N                         Int(10) Options(*NoPass) ;
         *N                        Char(1) Options(*NoPass) ;
       End-PR ;
