000100180526       Ctl-Opt DFTNAME(FLM050) NOMAIN ;
000200180526       // Move script file to IFS stream file
000300180526      /Copy QRPGLESRC,FLT001
000400180526       Dcl-PR SysCmd                Int(10:0) ExtProc('system');
000500180526         Cmd                   Pointer Value Options(*String);
000600180526       End-PR;
000700180526       Dcl-DS *N;
000800180526          TimeDate                Zoned(12:0);
000900180526          HHMMSS                   Char(6) OVERLAY(TimeDate);
001000180526          MMDDYY                   Char(6) OVERLAY(TimeDate:7);
001100180526       End-DS;
001200180526       // Stand alone fields ........................................
001300180526       // apostrophe
001400180526       Dcl-S Ap                    Char(1) INZ(X'7D');
001401180526       // Numberic current date for file name
001500180526       Dcl-S ccyymmdd              Packed(8:0) ;
001501180526       // Character current date for file name
001600180526       Dcl-S ccyymmddc             Char(8) ;
001700180526       // the command
001800180526       Dcl-S CMD                   Char(10) INZ('CPYTOIMPF');
001801180528       // the command string
001802180528       Dcl-S CMDStr                Char(1024) Inz ;
001900180526       // close parentheses
002000180526       Dcl-S Cp                    Char(1) INZ(')');
002001180526       // Error message ID for SysCmd
002100180526       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
002200180526       // Data format parameter
002300180526       Dcl-S DTAFMT                Char(20);
002301180526       // Token passed between processes
002400180526       Dcl-S EOJ                   Char(2);
002500180526       // File name sent
002600180526       Dcl-S FileName              Char(32);
002700180526       // CL From File
002800180526       Dcl-S FromFile              Char(32) ;
002900180526       // Stream file member option
003000180526       Dcl-S MBROPT                Char(20);
003001180526       // Current time for file name
003100180526       Dcl-S Now                   Time INZ(*Sys) ;
003200180526       // open parentheses
003300180526       Dcl-S Op                    Char(1) INZ('(');
003400180526       // PDF file name
003500180526       Dcl-S PDFname               Char(50) INZ(*Blanks);
003600180526       // plus sign
003700180526       Dcl-S Pl                    Char(1) INZ('+');
003800180526       // period
003900180526       Dcl-S Prd                   Char(1) INZ('.');
004000180526       // Record Delemeter
004100180526       Dcl-S RCDDLM                Char(20);
004200180526       // space
004300180526       Dcl-S Sp                    Char(1) INZ(' ');
004400180526       // Stream File Code Page
004500180526       Dcl-S StmfCodPag            Char(25);
004600180526       // Spool number parameter
004700180526       Dcl-S STMFOPT               Char(20);
004800180526       // Text string
004900180526       Dcl-S Text                  Char(512);
004901180526       // Numeric time for file name
005000180526       Dcl-S Time                Packed(6:0) ;
005001180526       // Character time for file name
005100180526       Dcl-S TimeC                 Char(6)  ;
005101180526       // Current date for file name
005200180526       Dcl-S Today                 Date(*ISO) Inz(*Sys) ;
005300180526       // To format parameter
005400180526       Dcl-S Tofmt                 Char(20);
005500180526       // To STMF parameter
005600180526       Dcl-S Tostmf                Char(85);
005700180526       // Modified currrent Dept.
005800180526       Dcl-S UseCDP                Char(2);
005900180526       // FROMFILE PARM
006000180526       Dcl-S X                   Packed(1:0);
006100180526       //----------------------------------------------------------------------
006200180526       Dcl-Proc FLM050  Export ;
006300180526         Dcl-PI FLM050 Char(2) ;
006400180526           LIBRIN      Char(10) ;
006500180526           FILEIN      Char(10) ;
006600180526           TXTLIB      Char(10) ;
006700180526           TEXTIN      Char(10) ;
006800180528           PATHIN      Char(78) ;
006900180526           FTYPE       Char(3) ;
007000180526         End-Pi;
007100180526         CpfMsgID = *BLanks;
007200180526         Fromfile = 'FROMFILE' + Op + %Trim(TXTLIB) + '/' + %Trim(TEXTIN) + Cp ;
007300180526         // To file name
007400180528         ccyymmdd = %dec(%char(Today:*iso0):8:0) ;
007500180526         CCYYMMDDC = %EditC(CCYYMMDD:'X') ;
007600180528         Time = %dec(%char(Now:*HMS0):6:0) ;
007700180526         TimeC = %EditC(Time:'X') ;
007800180526         FileName = *Blanks;
007900180526         FileName = %Trim(FILEIN) +
008000180526              CCYYMMDDC + TimeC + '.' + FTYPE ;
008100180526         // TOSTMF PARM
008200180526         Tostmf = ('TOSTMF' + Op + Ap +
008300180526              %Trimr(PATHIN)  + '/' + %Trim(FileName) +
008400180526              Ap + CP);
008500180526         // Member option
008600180526         Mbropt = ('MBROPT' + Op + '*REPLACE' + Cp);
008700180526         // Code Page ID
008800180526         StmfCodPag = ('STMFCODPAG' + Op +
008900180526              '*PCASCII' + Cp);
009000180526         // Record Delemeter
009100180526         RcdDlm = ('RCDDLM' + Op + '*CRLF' + Cp);
009200180526         // Data format
009300180526         DtaFmt = ('DTAFMT' + Op + '*FIXED' + Cp);
009400180526         // TEXT
009500180526         Clear Text;
009600180526         CpfMsgID = *Blanks ;
009700180528         CMDStr = (CMD + Sp + %TrimR(Fromfile) + Sp +
009800180526               %TrimR(Tostmf) + Sp + %TrimR(MbrOpt) +
009900180526               SP + %TrimR(StmfCodpag) + Sp +
010000180526               %TrimR(RcdDlm)+ Sp + %TrimR(DtaFmt));
010100180529         // Move the script file to the IFS
010200180528         CallP SysCmd(CmdStr) ;
010300180526         If CpfMsgID <> *Blanks ;
010400180526         EndIf;
010500180526         Return EOJ;
010600180526       End-Proc;
