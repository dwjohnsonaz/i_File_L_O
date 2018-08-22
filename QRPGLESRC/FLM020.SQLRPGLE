000100180514       Ctl-Opt DFTNAME(flm020) NOMAIN ;
000200180514       Ctl-Opt DEBUG OPTION(*NODEBUGIO: *SRCSTMT);
000300180514       Ctl-Opt CCSID(*CHAR:*JOBRUN) ALWNULL(*USRCTL);
000400180514       Ctl-Opt COPYRIGHT('SHandB, LLC 2017/1024');
000500180514       // Generate XML script
000501180529       Dcl-F FLD020         WORKSTN USROPN ;
000600180514       // Prototypes
000601180529       //***************************************************************
000602180529       //            Prototype for QMHSNDPM-Sedn the message
000603180529       //****************************************************************
000604180529       Dcl-PR QMHSNDPM             ExtPgm('QMHSNDPM');
000605180529          AwMSgId                  Char(7);
000606180529          AwMSgF                   Char(20);
000607180529          AwMSgDta                 Char(256);
000608180529          spLen                     Int(10:0);
000609180529          apTyp                    Char(10);
000610180529          apQue                    Char(10);
000611180529          spStk                     Int(10:0);
000612180529          spKy                      Int(10:0);
000613180529          spErr                     Int(10:0);
000614180529       End-PR;
000615180529       //***************************************************************
000616180529       //            Prototype for QMHRMVPM-Clear the message
000617180529       //****************************************************************
000618180529       Dcl-PR QMHRMVPM             ExtPgm('QMHRMVPM');
000619180529          spStk1                   Char(10);
000620180529          spCsc                     Int(10:0);
000621180529          apMsk                    Char(4);
000622180529          apMsr                    Char(10);
000623180529          spErc                     Int(10:0);
000624180529       End-PR;
000625180529       Dcl-PR SysCmd                Int(10:0) ExtProc('system');
000626180529         Cmd                   Pointer Value Options(*String);
000627180529       End-PR;
000700180514      /Copy QRPGLESRC,FLT001
000701180529      // Data Structures
000702180529       Dcl-DS FLP020DS EXTNAME('FLP020') Qualified INZ END-DS;
000703180612       Dcl-DS FLP020CDS EXTNAME('FLP020C') Qualified INZ END-DS;
000704180529       Dcl-DS SDS PSDS Qualified ;   // Remember to use SDS. !
000705180529         PGMNAM  Char(10)  Pos(1);
000706180529       End-DS;
000707180529       // Stand Alone Fields
000708180529       Dcl-S ADDONE                 Ind ;
000709180529       Dcl-S AwMSgId               Char(7);
000710180529       Dcl-S AwMSgF                Char(20);
000711180529       Dcl-S AwMSgDta              Char(256);
000712180529       Dcl-S apMsk                 Char(4);
000713180529       Dcl-S apMsr                 Char(10);
000714180529       Dcl-S apTyp                 Char(10);
000715180529       Dcl-S apQue                 Char(10);
000716180529       Dcl-S Cmd                   Char(256) ;
000717180529       Dcl-S CpfMsgId              Char(7) import('_EXCP_MSGID');
000718180529       Dcl-S EOJ                   Char(2) ;
000719180529       Dcl-S ErrorON                Ind    ;
000720180529       Dcl-S Scrn#                  Int(5:0) Inz(1) ;
000721180529       Dcl-S spLen                  Int(10:0);
000722180529       Dcl-S spStk                  Int(10:0);
000723180529       Dcl-S spKy                   Int(10:0);
000724180529       Dcl-S spErr                  Int(10:0);
000725180529       Dcl-S spStk1                Char(10);
000726180529       Dcl-S spCsc                  Int(10:0);
000727180529       Dcl-S spErc                  Int(10:0);
000728180529       Dcl-S SystemName            Char(10);
000733180529       //*--------------------------------------------------------------------
001100180514       Dcl-Proc flm020 EXPORT;
001200180514
001300180514         Dcl-PI flm020               Char(2);
001400180514           FILEIN                   Char(10);
001500180514           LIBIN                    Char(10);
001600180514           FMTIN                    Char(10);
001700180514         End-PI ;
001763180529
001764180529         Exec Sql Set Option Commit = *None; // manage commitment control
001765180529         Exec SQL values current server into :systemName; // Set system name
001766180529         If Not %Open(FLD020) ; // Open the display file
001767180529           Open FLD020 ;
001768180529         EndIf;
001769180529         PROGRAM = SDS.PGMNAM ; // for error message subfile
001774180529         Scrn# = 1 ;
001775180529         ExSR ChkExist ;
001776180529         If AddOne = *OFF;
001777180529           ExSR Update01;
001778180529         Else;
001779180529           ExSR Add01;
001780180529         EndIf;
001781180529         Dow Scrn# = 1 ;
001782180529           If ErrorOn = *On ;
001783180529             Write MSGCTL ;
001784180529           EndIf ;
001785180529           ExFMT SCRN01 ;
001786180529           Select ;
001787180529           When *IN01 = *ON ;
001788180529           When *IN05 = *ON ;
001789180529             ExSR Edit01 ;
001790180529             If ErrorOn = *OFF ;
001791180529               If AddOne = *ON ;
001792180529                 ExSR AddIt ;
001793180529                 EOJ = 'AD' ;
001794180529                 Scrn# = *Zero ;
001795180529               Else;
001796180529                 ExSR UpdateIt ;
001797180529                 EOJ = 'UD' ;
001798180529                 Scrn# = *Zero;
001799180529               EndIf;
001800180529               Clear FLP020DS;
001801180529             Exec SQL
001802180529             Select * Into :FLP020DS
001803180529                    from FLP020
001804180529                    Where FL2001 = :SystemName AND FL2002 = :LIBIN
001805180529                          AND FL2003 = :FILEIN ;
001806180529              EOJ = FLM020A(FLP020DS:ADDONE);
001807180529             EndIf;
001808180529
001809180529           When *IN12 = *ON ;
001810180529             EOJ = '12' ;
001811180529             Scrn# = *Zero ;
001812180529           Other;
001813180529             ExSR Edit01 ;
001814180529           EndSL;
001815180529         EndDo;
001816180529         If Scrn# = *Zero ;
001817180529           Close FLD020 ;
001818180529           Return EOJ ;
001819180529         EndIf ;
001820180529         //*---------------------------------------------------------------------
001821180529         //* Checking for an existing transfer request
001822180529         //*---------------------------------------------------------------------
001823180529         BegSR ChkExist;
001824180529           Exec SQL
001825180529             Select * Into :FLP020DS
001826180529                    from FLP020
001827180529                    Where FL2001 = :SystemName AND FL2002 = :LIBIN
001828180529                          AND FL2003 = :FILEIN ;
001829180529         If FLP020DS.FL2001 = *Blanks;
001830180529           ADDONE = *ON;
001831180529         Else;
001832180529           ADDONE = *OFF;
001833180529         EndIf;
001834180529         EndSR;
001835180529          //*------------------------------------------------------------------
001836180529          //* Add01 - Populate the screen with new data
001837180529          //*------------------------------------------------------------------
001838180529          BegSR Add01 ;
001839180529           //
001840180529           DBSCTBL = %Trim(SystemName) + '/' +
001841180529                     %Trim(LIBIN) + '/' +
001842180529                     %Trim(FILEIN) ;
001843180529         Exec SQL
001844180529           Select ATTXT Into :DESCR
001845180529                  from FILES
001846180529                  Where ATFILE = :FILEIN AND ATLIB = :LIBIN ;
001847180612         Exec Sql
001848180612           Select * Into :FLP020CDS From FLP020C ;
001849180529            FORMAT = *Blanks ;
001850180612            XMLHEAD1 = FLP020CDS.FL20C01 ;
001851180612            XMLHEAD2 = FLP020CDS.FL20C02 ;
001852180530            XMLNAME = *Blank ;
001853180612            XMLPATH = FLP020CDS.FL20C03 ;
001854180612            FEXTN = FLP020CDS.FL20C04 ;
001855180529         EndSR;
001856180529          //*------------------------------------------------------------------
001857180529          //* Update01 - Populate the screen with update data
001858180529          //*------------------------------------------------------------------
001859180529          BegSR Update01 ;
001860180529            //
001863180529            DBSCTBL = %Trim(FLP020DS.FL2001) + '/' +
001864180529                      %Trim(FLP020DS.FL2002) + '/' +
001865180529                      %Trim(FLP020DS.FL2003) ;
001866180529            FORMAT = FLP020DS.FL2004 ;
001872180529            DESCR = FLP020DS.FL2005 ;
001873180612            If FLP020DS.FL2006 = *BLanks
001874180612              Or FLP020DS.FL2007 = *BLanks
001875180612              Or FLP020DS.FL2009 = *Blanks
001876180612              Or FLP020DS.FL2010 = *Blanks ;
001877180612              Exec SQL
001878180612                Select * Into :FLP020CDS From FLP020C ;
001879180612            EndIf;
001880180612            // If the previous update forgot some columns
001882180529            If FLP020DS.FL2006 = *Blanks;
001883180612              XMLHEAD1 = FLP020CDS.FL20C01 ;
001884180529            Else;
001885180530              XMLHEAD1 = FLP020DS.FL2006 ;
001886180529            EndIf;
001887180530            If FLP020DS.FL2007 = *Blanks;
001888180612              XMLHEAD2 = FLP020CDS.FL20C02 ;
001889180530            Else;
001890180530              XMLHEAD2 = FLP020DS.FL2007 ;
001891180530            EndIf;
001892180530            XMLNAME = FLP020DS.FL2008 ;
001893180530            If FLP020DS.FL2009 = *Blanks;
001894180612              XMLPATH = FLP020CDS.FL20C03 ;
001895180530            Else ;
001896180530              XMLPATH = FLP020DS.FL2009 ;
001897180530            EndIf;
001898180530            If FLP020DS.FL2010 = *Blanks;
001899180612              FEXTN = FLP020CDS.FL20C04 ;
001900180530            Else;
001901180530              FEXTN = FLP020DS.FL2010 ;
001902180530            EndIf;
001903180612
001904180529          EndSR ;
001905180529          //*------------------------------------------------------------------
001906180529          //* Edit01 - Edit the input fields in SCRN01
001907180529          //*------------------------------------------------------------------
001908180529          BegSR Edit01 ;
001909180529            ExSR ClrMsg;
001910180529            CpfMsgId = *Blanks;
001911180529            ErrorON = *OFF ;
001912180529          EndSR;
001913180529          //*------------------------------------------------------------------
001914180529          //* AddIt - Add an new source member
001915180529          //*------------------------------------------------------------------
001916180529          BegSR AddIt ;
001917180529            Exec SQL
001918180529              Insert Into FLP020
001919180529                    (FL2001, FL2002, FL2003, FL2004, FL2005, FL2006, FL2007,
001920180530                     FL2008, FL2009, FL2010 )
001921180530             Values (:SystemName, :LIBIN, :FILEIN, :FORMAT, :DESCR, :XMLHEAD1,
001922180530                     :XMLHEAD2, :XMLNAME, :XMLPATH, :FEXTN ) ;
001923180529
001924180529          EndSR ;
001925180529           //
001926180529          //*------------------------------------------------------------------
001927180529          //* UpdateIt - Update the SQL record
001928180529          //*------------------------------------------------------------------
001929180529          BegSR UpdateIt ;
001930180529            Exec SQL
001931180529              Update FLP020
001932180530                Set(FL2005, FL2006, FL2007, FL2008, FL2009, FL2010)
001933180530                 = (:DESCR, :XMLHEAD1, :XMLHEAD2, :XMLNAME, :XMLPATH , :FEXTN)
001934180529                Where FL20INDEX = :FLP020DS.FL20INDEX ;
001935180529
001936180529          EndSR ;
001937180529       //-------------------------------------------------------------------------
001938180529       // SendMsg: Send to Message Subfile
001939180529       //-------------------------------------------------------------------------
001940180529       BegSr SendMsg;
001941180529
001942180529          AwMsgF = 'QCPFMSG   *LIBL     ';
001943180529          SpLen = %LEN(AwMSgDta);
001944180529          ApTyp = '*DIAG';
001945180529          ApQue = '*';
001946180529          SpStk = *Zero;
001947180529          SpKy = *Zeros;
001948180529          SpErr = *Zeros;
001949180529
001950180529          CallP QMHSNDPM(AwMsgID
001951180529                 :AwMsgF
001952180529                 :AwMsgDta
001953180529                 :SpLen
001954180529                 :apTyp
001955180529                 :apQue
001956180529                 :SpStk
001957180529                 :SpKy
001958180529                 :spErr);
001959180529
001960180529       EndSr;
001961180529       //-------------------------------------------------------------------------
001962180529       // ClrMsg: Clear Message Subfile
001963180529       //-------------------------------------------------------------------------
001964180529       BegSr ClrMsg;
001965180529
001966180529          SpStk1 = '*';
001967180529          SpCsc = *Zero;
001968180529          apMsk = *Blanks;
001969180529          apMsr = '*ALL';
001970180529          spErc = *Zero;
001971180529
001972180529          CallP QMHRMVPM(SpStk1
001973180529                 :SpCsc
001974180529                 :apMsk
001975180529                 :apMsr
001976180529                 :spErc);
001977180529
001978180529       EndSr;
001979180529       //-------------------------------------------------------------------------
001980180529       End-Proc ;
