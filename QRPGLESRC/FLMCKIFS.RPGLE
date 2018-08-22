000100180612       Ctl-Opt DFTNAME(FLMCKIFS) BNDDIR('FLB001') ;
000200180612       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180612       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180612       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180612       // Test for valid path to the IFS
000600180612       // Prototypes
000700180612      /Copy QRPGLESRC,FLT001
000800180612       // Stand Alone Fields
000900180612       Dcl-S Ap         Char(1) Inz(X'7D'); // apostrophe '''
001000180612       // Numberic current date for file name
001100180612       Dcl-S ccyymmdd              Packed(8:0) ;
001200180612       // Character current date for file name
001300180612       Dcl-S ccyymmddc             Char(8) ;
001400180612       Dcl-S Chr        Char(1) Inz(X'6B'); // user selected delimiter
001500180612       Dcl-S Cma        Char(1) Inz(X'6B'); // comma ','
001600180612       Dcl-S Cp                    Char(1) Inz(X'5D'); // Close parenthesis '('
001700180612       Dcl-S CsrSel                Char(256); // SQL Cursor Def.
001800180612       Dcl-S CrLf       Char(2) Inz(X'0d25') ;
001900180612       Dcl-S CsvLine               Char(128) ;
002000180612       Dcl-S Data       Char(512) Inz ;
002100180612       Dcl-S DTALine               Char(128) ;
002200180612       Dcl-S EOJ                   Char(2) ;
002300180612       Dcl-S Errcd               Packed(5:0) Inz ;
002400180612       // File name sent
002500180612       Dcl-S FileName              Char(32);
002600180612       Dcl-S FType                 Char(3) Inz('sql') ;
002700180612       Dcl-S InFileUsage           Char(10) Inz;
002800180612       Dcl-S InPath                Char(512) Inz;
002900180612       Dcl-S LastCol               Char(10) Inz;
003000180612       Dcl-S LongPath              Char(90) ;
003100180612       Dcl-S Mult_Fields            Int(5) Inz( 1000 );
003200180612       // Current time for file name
003300180612       Dcl-S Now                   Time INZ(*Sys) ;
003400180612       Dcl-S Op                    Char(1) Inz(X'4D'); // Open parenthesis '('
003500180612       Dcl-S Option                Char(1) Inz;
003600180612       Dcl-S OutEOF@Read           Char(1) Inz;
003700180612       Dcl-S OutRC                  Int(10:0) Inz;
003800180612       Dcl-S P                      Int(5) ;
003900180612       Dcl-S Pos                    Int(5) Inz ;
004000180612       Dcl-S Qm         Char(1) Inz(X'7F'); // quotation mark '"'
004100180612       Dcl-S Rc                     Ind ;
004200180612       Dcl-S SavFileDesc            Int(10:0) Inz;
004300180612       Dcl-S Sc                    Char(1) Inz(X'5E') ; // Semi-colon ';'
004400180612       Dcl-S Sp                    Char(1) Inz(X'40') ; // Space ' '
004500180612       Dcl-S Status                Char(1) Inz;
004501180612       Dcl-S TempPath              Char(50) ;
004600180612       Dcl-S TextIn                Char(10) Inz('FLPEXCEL') ;
004700180612       Dcl-S TextLib               Char(10) Inz('DJDATA') ;
004800180612       // Numeric time for file name
004900180612       Dcl-S Time                Packed(6:0) ;
005000180612       // Character time for file name
005100180612       Dcl-S TimeC                 Char(6)  ;
005200180612       // Current date for file name
005300180612       Dcl-S Today                 Date(*ISO) Inz(*Sys) ;
005400180612       Dcl-S Tot_Fields          Int(10) ;
005402180612        TempPath = 'DJIBMI/TABLECV' ;
005403180612        ExSR CrtIFSfile;
005404180612        *INLR = *ON ;
005500180612       //*--------------------------------------------------------
005600180612       //* Create the IFS stream file
005700180612       //*--------------------------------------------------------
005800180612       BegSr CrtIFSfile;
005900180612         Option = 'O' ;
006000180612         Status = *Blank ;
006100180612         Errcd = *Zero;
006200180612         Data = *Blanks ;
007000180612         InPath = %Trim(TempPath) ;
007200180612         InFileUsage = '*REPLACE' ;
007300180612         SavFileDesc = *Zeros;
007400180612         OutRC = *Zeros ;
007500180612         OutEof@Read = *Blank;
007600180612         ExSR CallIFSIO ;
007700180612       EndSr;
007801180612       //*-----------------------------------------------------------
007802180612       //* Call IFS_IO routine
007803180612       //*--------------------------------------------------------
007804180612       BegSR CallIFSIO;
007805180612
007806180612         CallP IFS_IO(Option
007807180612                       :Status
007808180612                       :Errcd
007809180612                       :Data
007810180612                       :InPath
007811180612                       :InfileUsage
007812180612                       :SavFileDesc
007813180612                       :OutRC
007814180612                       :OutEof@Read) ;
007815180612
007816180612       EndSr;
007817180612       //*--------------------------------------------------------
