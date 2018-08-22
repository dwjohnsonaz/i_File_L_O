000100000000       // ERRPROTO from IFSSRC in RPGISCOOL
000200000000       //---------------------------------------------------------------------
000300000000       // The information contained in this document has not been submitted
000400000000       // to any formal IBM test and is distributed AS IS.  The use of this
000500000000       // information or the implementation of any of these techniques is a
000600000000       // customer responsibility and depends on the customer's ability to
000700000000       // evaluate and integrate them into the customer's operational
000800000000       // environment.  See Special Notices in redbook SG24-5402 for more.
000900000000       //---------------------------------------------------------------------
001000000000
001100000000       // Prototype for DspError subprocedure
001200000000       Dcl-PR DspError                 Extproc('DspError');
001300000000          text                     Char(10) Const;
001300000000       End-PR;
001400000000
001500000000       // Prototype for __errno() and strerror()
001600000000       //    From the ILE C for AS/400 Run-Time Library Reference
001700000000       Dcl-PR GetErrNo          Pointer Extproc('__errno');
001700000000       End-PR;
001800000000
001900000000       Dcl-PR StrError          Pointer ExtProc('strerror');
002000000000          errorNo                   Int(10:0) Value;
002000000000       End-PR;
