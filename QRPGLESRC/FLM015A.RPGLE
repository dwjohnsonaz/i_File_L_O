000100180523       Ctl-Opt DFTNAME(FLM015A) NOMAIN ;
000200180523       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180523       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180523       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/2024');
000500180523       // Generate IBM i SQL source member
000600180523       // Prototypes
000700180523      /Copy QRPGLESRC,FLT001
000800180523       Dcl-PR SysCmd                Int(10:0) ExtProc('system');
000900180523         Cmd                   Pointer Value Options(*String);
001000180523       End-PR;
001100180523
001200180523       Dcl-PR CreateSqlSrc extpgm('QSQGNDDL') ;
001300180523         *N  char(583) const ;
001400180523         *N   int(10) const ;
001500180523         *N  char(8) const ;
001600180523         *N  char(256) ;
001700180523       End-PR;
001800180523       // Data structures
001900180609       Dcl-DS FLP015DS EXTNAME('FLP015') Qualified INZ END-DS;
002000180523       Dcl-DS InputTemplate qualified ;
002100180523         InFile char(258) ;
002200180523         InLibrary char(258) ;
002300180523         InFileType char(10) inz('TABLE') ;
002400180523         OutSourceFile char(10) ;
002500180523         OutLibrary char(10) ;
002600180523         OutMember char(10) ;
002700180523         SeverityLevel uns(10) inz(30) ;
002800180523         *n char(16) inz('10ISO ISO SYS.00') ;
002900180523         MessageLevel uns(10) inz(0) ;
003000180523         *n char(3) inz('111') ;
003100180523       End-DS ;
003200180523       Dcl-DS ErrorDs qualified ;
003300180523         Size uns(10) inz(%size(ErrorDs)) ;
003400180523         ReturnedSize uns(10) ;
003500180523         Id char(7) ;
003600180523         *n char(1) inz(x'00') ;
003700180523         Data char(240) ;
003800180523       End-DS ;
003900180523       // Stand Alone Fields
004000180524       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
004100180523       Dcl-S Cmd                   Char(256) ;
004200180523       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
004300180523       Dcl-S EOJ                   Char(2) ;
004400180523       //*--------------------------------------------------------------------
004500180523       Dcl-Proc FLM015A EXPORT;
004600180523         Dcl-PI FLM015A             Char(2);
004700180523           FL15DSIN                 Char(435) ;
004800180523           ADDUPD                   Char(1);
004900180523         End-PI ;
005000180524         CpfMsgId = *Blanks;
005100180523         FLP015DS = FL15DSIN ; // Format the passed data
005200180523         // Add the SRCLIB/QSQLSRC Member to the source physical file
005300180524         If ADDUPD = '1' ;
005400180523           cmd = 'ADDPFM FILE(' + %TRIM(FLP015DS.FL1511) +
005500180524                 '/QSQLSRC) MBR(' + %TRIM(FLP015DS.FL1514) + ')' +
005600180524                 ' TEXT(' + Ap + %Trim(FLP015DS.FL1505) + Ap +
005700180524                 ') SRCTYPE(SQL)' ;
005800180523           CallP  SysCmd(Cmd);
005900180523           If CpfMsgId <> *Blanks ;
006000180523           EndIf;
006100180523         EndIf;
006200180523
006300180523       InputTemplate.InFile = FLP015DS.FL1503 ;
006400180523       InputTemplate.InLibrary = FLP015DS.FL1502 ;
006500180523       InputTemplate.OutSourceFile = 'QSQLSRC' ;
006600180524       InputTemplate.OutLibrary = FLP015DS.FL1511 ;
006700180523       InputTemplate.OutMember = FLP015DS.FL1514 ;
006800180523
006900180523       CreateSqlSrc(InputTemplate:%len(InputTemplate):
007000180523                       'SQLR0100':ErrorDs) ;
007100180523         Return EOJ ;
007200180523       End-Proc ;
