000100180514       Ctl-Opt DFTNAME(FLM025) NOMAIN ;
000200180514       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180514       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180514       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180514       // Generate JSON script
000502180530       Dcl-F FLD025         WORKSTN USROPN ;
000503180530       // Prototypes
000504180530       //***************************************************************
000505180530       //            Prototype for QMHSNDPM-Sedn the message
000506180530       //****************************************************************
000507180530       Dcl-PR QMHSNDPM             ExtPgm('QMHSNDPM');
000508180530          AwMSgId                  Char(7);
000509180530          AwMSgF                   Char(20);
000510180530          AwMSgDta                 Char(256);
000511180530          spLen                     Int(10:0);
000512180530          apTyp                    Char(10);
000513180530          apQue                    Char(10);
000514180530          spStk                     Int(10:0);
000515180530          spKy                      Int(10:0);
000516180530          spErr                     Int(10:0);
000517180530       End-PR;
000518180530       //***************************************************************
000519180530       //            Prototype for QMHRMVPM-Clear the message
000520180530       //****************************************************************
000521180530       Dcl-PR QMHRMVPM             ExtPgm('QMHRMVPM');
000522180530          spStk1                   Char(10);
000523180530          spCsc                     Int(10:0);
000524180530          apMsk                    Char(4);
000525180530          apMsr                    Char(10);
000526180530          spErc                     Int(10:0);
000527180530       End-PR;
000528180530       Dcl-PR SysCmd                Int(10:0) ExtProc('system');
000529180530         Cmd                   Pointer Value Options(*String);
000530180530       End-PR;
000531180530      /Copy QRPGLESRC,FLT001
000532180530      // Data Structures
000533180530       Dcl-DS FLP025DS EXTNAME('FLP025') Qualified INZ END-DS;
000534180612       Dcl-DS FLP025CDS EXTNAME('FLP025C') Qualified INZ END-DS;
000535180530       Dcl-DS SDS PSDS Qualified ;   // Remember to use SDS. !
000536180530         PGMNAM  Char(10)  Pos(1);
000537180530       End-DS;
000538180530       // Stand Alone Fields
000539180530       Dcl-S ADDONE                 Ind ;
000540180530       Dcl-S AwMSgId               Char(7);
000541180530       Dcl-S AwMSgF                Char(20);
000542180530       Dcl-S AwMSgDta              Char(256);
000543180530       Dcl-S apMsk                 Char(4);
000544180530       Dcl-S apMsr                 Char(10);
000545180530       Dcl-S apTyp                 Char(10);
000546180530       Dcl-S apQue                 Char(10);
000547180530       Dcl-S Cmd                   Char(256) ;
000548180530       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
000549180530       Dcl-S EOJ                   Char(2) ;
000550180530       Dcl-S ErrorON                Ind    ;
000551180530       Dcl-S Scrn#                  Int(5:0) Inz(1) ;
000552180530       Dcl-S spLen                  Int(10:0);
000553180530       Dcl-S spStk                  Int(10:0);
000554180530       Dcl-S spKy                   Int(10:0);
000555180530       Dcl-S spErr                  Int(10:0);
000556180530       Dcl-S spStk1                Char(10);
000557180530       Dcl-S spCsc                  Int(10:0);
000558180530       Dcl-S spErc                  Int(10:0);
000559180530       Dcl-S SystemName            Char(10);
001000180514       //*--------------------------------------------------------------------
001100180514       Dcl-Proc FLM025 EXPORT;
001300180514         Dcl-PI FLM025               Char(2);
001400180514           FILEIN                   Char(10);
001500180514           LIBIN                    Char(10);
001600180514           FMTIN                    Char(10);
001700180514         End-PI ;
001701180530
001702180530         Exec Sql Set Option Commit = *None; // manage commitment control
001703180530         Exec SQL values current server into :systemName; // Set system name
001704180530         If Not %Open(FLD025) ; // Open the display file
001705180530           Open FLD025 ;
001706180530         EndIf;
001707180530         PROGRAM = SDS.PGMNAM ; // for error message subfile
001711180530         Scrn# = 1 ;
001712180530         ExSR ChkExist ;
001713180530         If AddOne = *OFF;
001714180530           ExSR Update01;
001715180530         Else;
001716180530           ExSR Add01;
001717180530         EndIf;
001718180530         Dow Scrn# = 1 ;
001719180530           If ErrorOn = *On ;
001720180530             Write MSGCTL ;
001721180530           EndIf ;
001722180530           ExFMT SCRN01 ;
001723180530           Select ;
001724180530           When *IN01 = *ON ;
001725180530           When *IN05 = *ON ;
001726180530             ExSR Edit01 ;
001727180530             If ErrorOn = *OFF ;
001728180530               If AddOne = *ON ;
001729180530                 ExSR AddIt ;
001730180530                 EOJ = 'AD' ;
001731180530                 Scrn# = *Zero ;
001732180530               Else;
001733180530                 ExSR UpdateIt ;
001734180530                 EOJ = 'UD' ;
001735180530                 Scrn# = *Zero;
001736180530               EndIf;
001737180530               Clear FLP025DS;
001738180530             Exec SQL
001739180530             Select * Into :FLP025DS
001740180530                    from FLP025
001741180530                    Where FL2501 = :SystemName AND FL2502 = :LIBIN
001742180530                          AND FL2503 = :FILEIN ;
001743180607            //EOJ = FLM025A(FLP025DS:ADDONE);
001744180607              EOJ = FLM025I(FLP025DS:ADDONE);
001745180530             EndIf;
001746180530           When *IN12 = *ON ;
001747180530             EOJ = '12' ;
001748180530             Scrn# = *Zero ;
001749180530           Other;
001750180530             ExSR Edit01 ;
001751180530           EndSL;
001752180530         EndDo;
001753180530         If Scrn# = *Zero ;
001754180530           Close FLD025 ;
001755180530           Return EOJ ;
001756180530         EndIf ;
001757180530         //*---------------------------------------------------------------------
001758180530         //* Checking for an existing transfer request
001759180530         //*---------------------------------------------------------------------
001760180530         BegSR ChkExist;
001761180530           Exec SQL
001762180530             Select * Into :FLP025DS
001763180530                    from FLP025
001764180530                    Where FL2501 = :SystemName AND FL2502 = :LIBIN
001765180530                          AND FL2503 = :FILEIN ;
001766180530         If FLP025DS.FL2501 = *Blanks;
001767180530           ADDONE = *ON;
001768180530         Else;
001769180530           ADDONE = *OFF;
001770180530         EndIf;
001771180530         EndSR;
001772180530          //*------------------------------------------------------------------
001773180530          //* Add01 - Populate the screen with new data
001774180530          //*------------------------------------------------------------------
001775180530          BegSR Add01 ;
001776180530           //
001777180530           DBSCTBL = %Trim(SystemName) + '/' +
001778180530                     %Trim(LIBIN) + '/' +
001779180530                     %Trim(FILEIN) ;
001780180530         Exec SQL
001781180530           Select ATTXT Into :DESCR
001782180530                  from FILES
001783180530                  Where ATFILE = :FILEIN AND ATLIB = :LIBIN ;
001784180612         Exec SQL
001785180612           Select * Into :FLP025CDS From FLP025C ;
001786180530            FORMAT = *Blanks ;
001787180612            JSONHEAD = FLP025CDS.FL25C01  ;
001788180530            JSONNAME = *Blank ;
001789180612            JSONPATH = FLP025CDS.FL25C02 ;
001790180612            FEXTN = FLP025CDS.FL25C03 ;
001791180530         EndSR;
001792180530          //*------------------------------------------------------------------
001793180530          //* Update01 - Populate the screen with update data
001794180530          //*------------------------------------------------------------------
001795180530          BegSR Update01 ;
001796180530            //
001797180530            DBSCTBL = %Trim(FLP025DS.FL2501) + '/' +
001798180530                      %Trim(FLP025DS.FL2502) + '/' +
001799180530                      %Trim(FLP025DS.FL2503) ;
001800180530            FORMAT = FLP025DS.FL2504 ;
001801180530            DESCR = FLP025DS.FL2505 ;
001802180612            If FLP025DS.FL2506 = *Blanks
001803180612              Or FLP025DS.FL2507 = *Blanks
001804180612              Or FLP025DS.FL2508 = *Blanks ;
001805180612              Exec SQL
001806180612                Select * Into :FLP025CDS From FLP025C ;
001808180612            EndIf;
001809180530            If FLP025DS.FL2506 = *Blanks;
001810180612              JSONHEAD = FLP025CDS.FL25C01 ;
001811180530            Else;
001812180530              JSONHEAD = FLP025DS.FL2506 ;
001813180530            EndIf;
001814180530            JSONNAME = FLP025DS.FL2507 ;
001815180530            If FLP025DS.FL2508 = *Blanks;
001816180612              JSONPATH = FLP025CDS.FL25C02 ;
001817180530            Else ;
001818180530              JSONPATH = FLP025DS.FL2508 ;
001819180530            EndIf;
001820180530            If FLP025DS.FL2509 = *Blanks;
001821180612              FEXTN = FLP025CDS.FL25C03 ;
001822180530            Else;
001823180530              FEXTN = FLP025DS.FL2509 ;
001824180530            EndIf;
001825180530          EndSR ;
001826180530          //*------------------------------------------------------------------
001827180530          //* Edit01 - Edit the input fields in SCRN01
001828180530          //*------------------------------------------------------------------
001829180530          BegSR Edit01 ;
001830180530            ExSR ClrMsg;
001831180530            CpfMsgId = *Blanks;
001832180530            ErrorON = *OFF ;
001833180530          EndSR;
001834180530          //*------------------------------------------------------------------
001835180530          //* AddIt - Add an new source member
001836180530          //*------------------------------------------------------------------
001837180530          BegSR AddIt ;
001838180530            Exec SQL
001839180530              Insert Into FLP025
001840180530                    (FL2501, FL2502, FL2503, FL2504, FL2505, FL2506, FL2507,
001841180530                     FL2508, FL2509 )
001842180530             Values (:SystemName, :LIBIN, :FILEIN, :FORMAT, :DESCR, :JSONHEAD,
001843180530                     :JSONNAME, :JSONPATH, :FEXTN ) ;
001844180530
001845180530          EndSR ;
001846180530           //
001847180530          //*------------------------------------------------------------------
001848180530          //* UpdateIt - Update the SQL record
001849180530          //*------------------------------------------------------------------
001850180530          BegSR UpdateIt ;
001851180530            Exec SQL
001852180530              Update FLP025
001853180530                Set(FL2505, FL2506, FL2507, FL2508, FL2509)
001854180530                 = (:DESCR, :JSONHEAD, :JSONNAME, :JSONPATH, :FEXTN)
001855180530                Where FL25INDEX = :FLP025DS.FL25INDEX ;
001856180530
001857180530          EndSR ;
001858180530       //-------------------------------------------------------------------------
001859180530       // SendMsg: Send to Message Subfile
001860180530       //-------------------------------------------------------------------------
001861180530       BegSr SendMsg;
001862180530
001863180530          AwMsgF = 'QCPFMSG   *LIBL     ';
001864180530          SpLen = %LEN(AwMSgDta);
001865180530          ApTyp = '*DIAG';
001866180530          ApQue = '*';
001867180530          SpStk = *Zero;
001868180530          SpKy = *Zeros;
001869180530          SpErr = *Zeros;
001870180530
001871180530          CallP QMHSNDPM(AwMsgID
001872180530                 :AwMsgF
001873180530                 :AwMsgDta
001874180530                 :SpLen
001875180530                 :apTyp
001876180530                 :apQue
001877180530                 :SpStk
001878180530                 :SpKy
001879180530                 :spErr);
001880180530
001881180530       EndSr;
001882180530       //-------------------------------------------------------------------------
001883180530       // ClrMsg: Clear Message Subfile
001884180530       //-------------------------------------------------------------------------
001885180530       BegSr ClrMsg;
001886180530
001887180530          SpStk1 = '*';
001888180530          SpCsc = *Zero;
001889180530          apMsk = *Blanks;
001890180530          apMsr = '*ALL';
001891180530          spErc = *Zero;
001892180530
001893180530          CallP QMHRMVPM(SpStk1
001894180530                 :SpCsc
001895180530                 :apMsk
001896180530                 :apMsr
001897180530                 :spErc);
001898180530
001899180530       EndSr;
001900180530       //-------------------------------------------------------------------------
001901180514       End-Proc ;
