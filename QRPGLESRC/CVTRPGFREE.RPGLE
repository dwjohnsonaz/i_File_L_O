000100180201       Ctl-Opt Debug
000200180201               Option( *ShowCpy: *SrcStmt: *NoDebugIO );
000300180201             //DftActGrp( *No ) ActGrp( *Caller )
000400180201
000500180201       //-------------------------------------------------------------------------------------------
000600180201       // Program Name. . . . . : CVTRPGFREE
000700180201       // Program Description . : Convert RPGILE Source Member to Free-form
000800180201       // Date Created. . . . . : 30/04/2015
000900180201       // Programmer. . . . . . : Ewarwoowar
001000180201       //-------------------------------------------------------------------------------------------
001100180201       // SYNOPSIS :
001200180201       // - Reads through an RPGILE source member and reformats the contents.
001300180201       //-------------------------------------------------------------------------------------------
001400180201      /Eject
001500180201       //-------------------------------------------------------------------------------------------
001600180201       // F I L E S
001700180201       //-------------------------------------------------------------------------------------------
001800180201       Dcl-F QRPGLESRC              EXTMBR(@pFromMbr)
001900180201                                    EXTFILE('QTEMP/QRPGLESRC')
002000180201                                    RENAME(QRPGLESRC:SRCREC)
002100180201                                    USROPN;
002200180201
002300180201       Dcl-F QRPGLESRC2             Usage(*OUTPUT) EXTMBR(@pToMbr)
002400180201                                    EXTFILE('QTEMP/QRPGLESRC2')
002500180201                                    RENAME(QRPGLESRC2:OUTREC)
002600180201                                    USROPN;
002700180201
002800180201       Dcl-F CVTRPGFRP1     PRINTER USROPN
002900180201                                    OFLIND(overFlow);
003000180201
003100180201       //-------------------------------------------------------------------------------------------
003200180201       // P R O C E D U R E   I N T E R F A C E
003300180201       //-------------------------------------------------------------------------------------------
003400180201
003500180201       Dcl-PR CVTRPGFREE               EXTPGM('CVTRPGFREE');
003600180201          @pShutDown               Char(1) CONST;
003700180201          @pFromFile               Char(10) CONST;
003800180201          @pFromLib                Char(10) CONST;
003900180201          @pFromMember             Char(10) CONST;
004000180201          @pToFile                 Char(10) CONST;
004100180201
004200180201          @pToLib                  Char(10) CONST;
004300180201          @pToMbr                  Char(10) CONST;
004400180201          @pIndComment             Char(1) CONST;
004500180201          @pRetBlnkCmt             Char(1) CONST;
004600180201          @pDirectives             Char(1) CONST;
004700180201       End-PR;
004800180201
004900180201       Dcl-PI CVTRPGFREE;
005000180201          @pShutDown               Char(1) CONST;
005100180201          @pFromFile               Char(10) CONST;
005200180201          @pFromLib                Char(10) CONST;
005300180201          @pFromMbr                Char(10) CONST;
005400180201          @pToFile                 Char(10) CONST;
005500180201          @pToLib                  Char(10) CONST;
005600180201          @pToMbr                  Char(10) CONST;
005700180201          @pIndComment             Char(1) CONST;
005800180201          @pRetBlnkCmt             Char(1) CONST;
005900180201          @pDirectives             Char(1) CONST;
006000180201       End-PI;
006100180201
006200180201       //-------------------------------------------------------------------------------------------
006300180201       // P R O T O T Y P E   I N T E R F A C E S
006400180201       //-------------------------------------------------------------------------------------------
006500180201       Dcl-PR GetDeclarationType;
006600180201          @pDeclType               Char( 2 );
006700180201          @pSavedName              Char( 80 );
006800180201          @pDeclLine                        Like(SRCSEQ);
006900180201       End-PR;
007000180201
007100180201       //-------------------------------------------------------------------------------------------
007200180201       // N A M E D   C O N S T A N T S
007300180201       //-------------------------------------------------------------------------------------------
007400180201       Dcl-C LO                        'abcdefghijklmnopqrstuvwxyz';
007500180201       Dcl-C UP                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
007600180201       Dcl-C VALIDSPECS                'HFDCP';
007700180201
007800180201       //-------------------------------------------------------------------------------------------
007900180201       // D A T A   S T R U C T U R E S
008000180201       //-------------------------------------------------------------------------------------------
008100180201
008200180201       Dcl-DS SourceData;
008300180201          SRCDTA                   Char(100);
008400180201          prefix                   Char(5) OVERLAY(SRCDTA:1);
008500180201          lineType                 Char(1) OVERLAY(SRCDTA:6);
008600180201          directive                Char(10) OVERLAY(SRCDTA:7);
008700180201          codeLine                 Char(93) OVERLAY(SRCDTA:8);
008800180201          fullLine                 Char(94) OVERLAY(SRCDTA:7);
008900180201
009000180201          condNot                  Char(1) OVERLAY(SRCDTA:9);
009100180201          condInd                  Char(2) OVERLAY(SRCDTA:10);
009200180201          factor1                  Char(14) OVERLAY(SRCDTA:12);
009300180201          opCode                   Char(10) OVERLAY(SRCDTA:26);
009400180201          factor2                  Char(14) OVERLAY(SRCDTA:36);
009500180201          result                   Char(14) OVERLAY(SRCDTA:50);
009600180201          len                      Char(5) OVERLAY(SRCDTA:64);
009700180201          dec                      Char(2) OVERLAY(SRCDTA:69);
009800180201          hi                       Char(2) OVERLAY(SRCDTA:71);
009900180201          lw                       Char(2) OVERLAY(SRCDTA:73);
010000180201          eq                       Char(2) OVERLAY(SRCDTA:75);
010100180201          comment                  Char(20) OVERLAY(SRCDTA:81);
010200180201
010300180201          extFactor2               Char(45) OVERLAY(SRCDTA:36);
010400180201
010500180201          nonPrefix                Char(95) OVERLAY(SRCDTA:6);
010600180201
010700180201          procType                 Char(1) OVERLAY(SRCDTA:24);
010800180201          procKeyWords             Char(37) OVERLAY(SRCDTA:44);
010900180201
011000180201          declName                 Char(15) OVERLAY(SRCDTA:7);
011100180201          declExt                  Char(1) OVERLAY(SRCDTA:22);
011200180201          declPrefix               Char(1) OVERLAY(SRCDTA:23);
011300180201          declType                 Char(2) OVERLAY(SRCDTA:24);
011400180201          declSuffix               Char(1) OVERLAY(SRCDTA:26);
011500180201          declFrom                 Char(7) OVERLAY(SRCDTA:26);
011600180201          declLen                  Char(7) Overlay(SRCDTA:33);
011700180201          declAttr                 Char(1) Overlay(SRCDTA:40);
011800180201          declScale                Char(3) Overlay(SRCDTA:41);
011900180201          declKeyWords             Char(37) OVERLAY(SRCDTA:44);
012000180201          declOptions              Char(73) Overlay(SRCDTA:7);
012100180201
012200180201          FileSpec                 Char(100) Overlay(SRCDTA:1);
012300180201          fileName                 Char(10) Overlay(FileSpec:7);
012400180201          fileUsage                Char(1) Overlay(FileSpec:17);
012500180201          fileDesig                Char(1) Overlay(FileSpec:18);
012600180201          fileAdd                  Char(1) Overlay(FileSpec:20);
012700180201          fileExternal             Char(1) Overlay(FileSpec:22);
012800180201          fileKeyed                Char(1) Overlay(FileSpec:34);
012900180201          fileDevice               Char(7) Overlay(FileSpec:36);
013000180201          fileKeywords             Char(37) Overlay(FileSpec:44);
013100180201       End-DS;
013200180201
013300180201       // Display file indicators ------------------------------------------------------------------
013400180201       Dcl-DS IndicatorDS;
013500180201        // 01-30: Function keys
013600180201        // 31-59: Conditioning indicators (error)
013700180201        // 60-89: Conditioning indicators (non-error)
013800180201        // 90-99: General indicators
013900180201       // Report file indicators -------------------------------------------------------------------
014000180201        // 01-79: Conditioning indicators (non-error)
014100180201          cndIndicators             Ind Pos(01) DIM(79);
014200180201        // 80-89: Report control
014300180201          overFlow                  Ind Pos(80);
014400180201        // 90-99: General indicators
014500180201          errorInd                  Ind Pos(99) INZ(*OFF);                  // Global error
014600180201       End-DS;
014700180201
014800180201       Dcl-DS DCLPR                    QUALIFIED;
014900180201          decl                     Char(7) INZ('Dcl-PR ');
015000180201          procName                 Char(16);
015100180201          type                     Char(9);
015200180201          definition               Char(37);
015300180201          comment                  Char(23);
015400180201          fieldName                Char(23) Pos(4);
015500180201       End-DS;
015600180201
015700180201       Dcl-DS DCLP                     QUALIFIED;                           // Test comment
015800180201          decl                     Char(9) INZ('Dcl-Proc ');
015900180201          definition               Char(61);
016000180201          comment                  Char(23);
016100180201       End-DS;
016200180201
016300180201       Dcl-DS DCLS                     QUALIFIED;
016400180201          decl                     Char(6) INZ('Dcl-S ');
016500180201          fieldName                Char(17);
016600180201          type                     Char(9);
016700180201          definition               Char(37);
016800180201          comment                  Char(23);
016900180201       End-DS;
017000180201
017100180201       Dcl-DS DCLF                     QUALIFIED;
017200180201          decl                     Char(6) INZ('Dcl-F ');
017300180201          fileName                 Char(15);
017400180201          device                   Char(8);
017500180201          definition               Char(44);
017600180201          comment                  Char(23) Pos(70);
017700180201       End-DS;
017800180201
017900180201       Dcl-DS DCLH                     QUALIFIED;
018000180201          decl                     Char(8) INZ('Ctl-Opt ');
018100180201          options                  Char(62);
018200180201          comment                  Char(23);
018300180201       End-DS;
018400180201
018500180201       //-------------------------------------------------------------------------------------------
018600180201       // S T A N D - A L O N E   V A R I A B L E S
018700180201       //-------------------------------------------------------------------------------------------
018800180201       // Template variables (required - do not alter).
018900180201       Dcl-S cfgCommitControl                                               // Test comment
019000180201                                   Char(7) INZ('*SLAVE ');                  // *MASTER/*SLAVE
019100180201       Dcl-S cfgCloseDown          Char(1) INZ('N');                        // Close down program?
019200180201       Dcl-S initialCall           Char(1) INZ(*Blank);
019300180201
019400180201       // End of Template variables (required - do not alter).
019500180201       //-------------------------------------------------------------------------------------------
019600180201       Dcl-S @opCodeUP             Char(10) DIM(66) PERRCD(1) CTDATA;
019700180201       Dcl-S @opCodeLO             Char(10) DIM(66) ALT(@opCodeUP);
019800180201       Dcl-S @declUP               Char(10) DIM(12) PERRCD(1) CTDATA;
019900180201       Dcl-S @declLO               Char(10) DIM(12) ALT(@declUP);
020000180201       Dcl-S @comments             Char(92) DIM(3) CTDATA;
020100180201       Dcl-S x                   Packed(3:0);
020200180201       Dcl-S y                   Packed(3:0);
020300180201       Dcl-S i                   Packed(3:0);
020400180201       Dcl-S j                   Packed(3:0);
020500180201       Dcl-S blanks                Char(30) INZ(*Blanks);
020600180201       Dcl-S maxIndent           Packed(3:0) INZ(15);
020700180201       Dcl-S movedDefs                 LIKE(result) DIM(999);
020800180201       Dcl-S moveDef                Ind INZ(*Off);
020900180201
021000180201       Dcl-S fromFileLib           Char(21);
021100180201       Dcl-S toFileLib             Char(21);
021200180201
021300180201       Dcl-S operator              Char(10);
021400180201       Dcl-S operatorEnd         Packed(3:0);
021500180201       Dcl-S newOperator        VarChar(10);
021600180201       Dcl-S nonConvRsn                LIKE(codeLine);
021700180201
021800180201       Dcl-S inCode                 Ind INZ(*Off);
021900180201       Dcl-S inArrayData            Ind INZ(*Off);
022000180201       Dcl-S inComment              Ind INZ(*Off);
022100180201       Dcl-S inDeclaration          Ind INZ(*Off);
022200180201       Dcl-S inPrototype            Ind INZ(*Off);
022300180201       Dcl-S inInterface            Ind INZ(*Off);
022400180201       Dcl-S inDatastructure
022500180201                                    Ind INZ(*Off);
022600180201       Dcl-S inExtProc              Ind INZ(*Off);
022700180201       Dcl-S endDS                  Ind INZ(*Off);
022800180201       Dcl-S inDirective            Ind INZ(*Off);
022900180201       Dcl-S inFreeFormat           Ind INZ(*On);
023000180201       Dcl-S inDeclProc             Ind INZ(*Off);
023100180201       Dcl-S indent                 Ind INZ(*Off);
023200180201       Dcl-S inSpan                 Ind INZ(*Off);
023300180201       Dcl-S inCase                 Ind INZ(*Off);
023400180201       Dcl-S convert                Ind INZ(*Off);
023500180201       Dcl-S unindent               Ind INZ(*Off);
023600180201       Dcl-S defsMoved              Ind INZ(*Off);
023700180201       Dcl-S dropLine               Ind INZ(*Off);
023800180201       Dcl-S codeStart                 LIKE(SRCSEQ) INZ(0);
023900180201       Dcl-S endLine                   LIKE(SRCSEQ) INZ(0);                 // Close struct here.
024000180201       Dcl-S endFound               Ind;
024100180201       Dcl-S endDeclType           Char(2);
024200180201
024300180201       Dcl-S savedLineType         Char(1);
024400180201
024500180201       Dcl-S increment           Packed(1:0) INZ(0);
024600180201       Dcl-S indentCount         Packed(3:0) INZ(0);
024700180201       Dcl-S indentSize          Packed(1:0) INZ(3);
024800180201       Dcl-S indentOffset        Packed(3:0) INZ(0);
024900180201       Dcl-S prevOffset          Packed(3:0) INZ(0);
025000180201       Dcl-S currOffset          Packed(3:0) INZ(0);
025100180201       Dcl-S lineEnd             Packed(3:0) INZ(0);
025200180201       Dcl-S mainlineIndent      Packed(3:0) INZ(1);
025300180201
025400180201       Dcl-S savedSRCDTA               LIKE(SRCDTA);
025500180201       Dcl-S sourceLine            Char(93);
025600180201       Dcl-S overflowLine       VarChar(92);
025700180201       Dcl-S workDirective         Char(10);
025800180201       Dcl-S workLineType          Char(1);
025900180201       Dcl-S workDeclType          Char(2);
026000180201       Dcl-S workDeclAttr          Char(1);
026100180201       Dcl-S workDeclName          Char(50);
026200180201       Dcl-S workDeclLine              LIKE(SRCSEQ);
026300180201       Dcl-S workDeclKeywords   VarChar(92);
026400180201
026500180201       Dcl-S tempDeclType          Char(2);
026600180201       Dcl-S tempDeclLine              LIKE(SRCSEQ);
026700180201       Dcl-S tempSavedName         Char(80);
026800180201
026900180201       Dcl-S workFileUsage         Char(1);
027000180201       Dcl-S workFileDesig         Char(1);
027100180201       Dcl-S workFileAdd           Char(1);
027200180201       Dcl-S workFileKeyed         Char(1);
027300180201       Dcl-S workFileDevice        Char(7);
027400180201       Dcl-S checkLength         Packed(3:0);
027500180201       Dcl-S workLength          Packed(7:0);
027600180201
027700180201       Dcl-S savedComment          Char(20);
027800180201       Dcl-S savedName             Char(80);
027900180201
028000180201       Dcl-S padResult              Ind INZ(*Off);
028100180201       Dcl-S padTarget                 LIKE(result);
028200180201
028300180201       Dcl-S scanString                LIKE(factor1);
028400180201       Dcl-S scanBase                  LIKE(factor2);
028500180201       Dcl-S scanLength            Char(10);
028600180201       Dcl-S scanStart             Char(10);
028700180201       Dcl-S scanNoResult           Ind INZ(*Off);
028800180201
028900180201       Dcl-S substLen              Char(10);
029000180201       Dcl-S substStart            Char(10);
029100180201
029200180201       Dcl-S setOff                 Ind INZ(*Off);
029300180201       Dcl-S setOffInd1            Char(2);
029400180201       Dcl-S setOffInd2            Char(2);
029500180201       Dcl-S setOffInd3            Char(2);
029600180201
029700180201       Dcl-S setOn                  Ind INZ(*Off);
029800180201       Dcl-S setOnInd1             Char(2);
029900180201       Dcl-S setOnInd2             Char(2);
030000180201       Dcl-S setOnInd3             Char(2);
030100180201
030200180201       Dcl-S xlateFrom                 LIKE(factor1);
030300180201       Dcl-S xlateTo                   LIKE(factor1);
030400180201       Dcl-S xlateBase                 LIKE(factor2);
030500180201       Dcl-S xlateStart            Char(10);
030600180201
030700180201       Dcl-S caseSubRoutine        Char(10);
030800180201       Dcl-S caseOperator          Char(4);
030900180201
031000180201       Dcl-S catFactor1                LIKE(factor1);
031100180201       Dcl-S catFactor2                LIKE(factor2);
031200180201       Dcl-S catCount            Packed(3:0) INZ(0);
031300180201       Dcl-S catBlanks                 LIKE(factor2);
031400180201
031500180201       Dcl-S durDuration               LIKE(factor2);
031600180201       Dcl-S durCode                   LIKE(factor2);
031700180201       Dcl-S durNewDate             Ind INZ(*Off);
031800180201
031900180201       Dcl-S inEval                 Ind INZ(*Off);
032000180201       Dcl-S evalOperator              Like(opCode);
032100180201       Dcl-S evalOffset          Packed(3:0);
032200180201
032300180201       Dcl-S inCallP                Ind INZ(*Off);
032400180201       Dcl-S callPOperator             Like(opCode);
032500180201       Dcl-S callPOffset         Packed(3:0);
032600180201
032700180201       Dcl-S inDo                   Ind INZ(*Off);
032800180201       Dcl-S doOperator                Like(opCode);
032900180201       Dcl-S doCompare             Char(2);
033000180201
033100180201       Dcl-S inIf                   Ind INZ(*Off);
033200180201       Dcl-S ifOperator                Like(opCode);
033300180201       Dcl-S ifCompare             Char(2);
033400180201
033500180201       Dcl-S inWhen                 Ind INZ(*Off);
033600180201       Dcl-S whenOperator              Like(opCode);
033700180201       Dcl-S whenCompare           Char(2);
033800180201
033900180201       Dcl-S inSQL                  Ind INZ(*Off);
034000180201
034100180201       Dcl-S forCount            Packed(3:0) INZ(0);
034200180201       Dcl-S forLevel            Packed(3:0) DIM(99);                          // Allow for 99
034300180201       Dcl-S forFactor1                LIKE(factor1);
034400180201       Dcl-S forFactor2                LIKE(factor2);
034500180201
034600180201       Dcl-S doCount             Packed(3:0) INZ(0);
034700180201       Dcl-S doLevel             Packed(3:0) DIM(99);                          // Allow for 99
034800180201
034900180201       Dcl-S slCount             Packed(3:0) INZ(0);
035000180201       Dcl-S slLevel             Packed(3:0) DIM(99);                          // Allow for 99
035100180201
035200180201       Dcl-S divFactor1                LIKE(factor1);
035300180201       Dcl-S divFactor2                LIKE(factor2);
035400180201
035500180201       Dcl-S ERRCheck               Ind INZ(*Off);
035600180201       Dcl-S ERRInd                Char(2);
035700180201
035800180201       Dcl-S foundCheck             Ind INZ(*Off);
035900180201       Dcl-S foundInd              Char(2);
036000180201
036100180201       Dcl-S NRFCheck               Ind INZ(*Off);
036200180201       Dcl-S NRFInd                Char(2);
036300180201       Dcl-S NRFFile                   LIKE(factor2);
036400180201
036500180201       Dcl-S EOFCheck               Ind INZ(*Off);
036600180201       Dcl-S EOFInd                Char(2);
036700180201       Dcl-S EOFFile                   LIKE(factor2);
036800180201
036900180201       Dcl-S HICheck                Ind INZ(*Off);
037000180201       Dcl-S HIInd                 Char(2);
037100180201       Dcl-S HiFactor1                 LIKE(factor1);
037200180201       Dcl-S HiFactor2                 LIKE(factor2);
037300180201
037400180201       Dcl-S LWCheck                Ind INZ(*Off);
037500180201       Dcl-S LWInd                 Char(2);
037600180201       Dcl-S LWFactor1                 LIKE(factor1);
037700180201       Dcl-S LWFactor2                 LIKE(factor2);
037800180201
037900180201       Dcl-S EQCheck                Ind INZ(*Off);
038000180201       Dcl-S EQInd                 Char(2);
038100180201       Dcl-S EQFactor1                 LIKE(factor1);
038200180201       Dcl-S EQFactor2                 LIKE(factor2);
038300180201
038400180201       Dcl-S equalCheck             Ind INZ(*Off);
038500180201       Dcl-S equalInd              Char(2);
038600180201
038700180201       Dcl-S countSource         Packed(7:0) INZ(0);
038800180201       Dcl-S countTarget         Packed(7:0) INZ(0);
038900180201       Dcl-S countEligible       Packed(7:0) INZ(0);
039000180201       Dcl-S countConv           Packed(7:0) INZ(0);
039100180201       Dcl-S countNotConv        Packed(7:0) INZ(0);
039200180201       Dcl-S countMoved          Packed(7:0) INZ(0);
039300180201
039400180201       //Dcl-S testb                   BinDec(2:0);
039500180201      /Eject
039600180201       //-------------------------------------------------------------------------------------------
039700180201       // Main Procedure
039800180201       //-------------------------------------------------------------------------------------------
039900180201          // Initialize
040000180201          Exsr subInitialise;
040100180201
040200180201          // Perform required function
040300180201          Exsr subUserFunction;
040400180201
040500180201          // Terminate the program.
040600180201          Exsr subExitProgram;
040700180201       //-------------------------------------------------------------------------------------------
040800180201
040900180201      /Eject
041000180201       //-------------------------------------------------------------------------------------------
041100180201       // USER: Perform required function.
041200180201       //-------------------------------------------------------------------------------------------
041300180201       BegSr subUserFunction;
041400180201
041500180201          // ** Code the necessary processing here.
041600180201          // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
041700180201
041800180201          // Read through the source member.
041900180201          Read SRCREC;
042000180201
042100180201          DoW not %eof(QRPGLESRC);
042200180201             countSource += 1;
042300180201
042400180201             Exsr subUserReformatLine;
042500180201
042600180201             Exsr subUserSetIndicators;
042700180201
042800180201             // Old-style SCAN without a result field.
042900180201             If scanNoResult;
043000180201                Clear nonPrefix;
043100180201
043200180201                codeLine = '// Old-style SCAN without a result!';
043300180201                Exsr subUserReformatLine;
043400180201                codeLine = 'EndIf;';
043500180201                Exsr subUserReformatLine;
043600180201
043700180201                scanNoResult = *Off;
043800180201             EndIf;
043900180201
044000180201             // If in a CAS statement, record the subroutine to call.
044100180201             If inCase and caseSubroutine <> *Blanks;
044200180201                codeLine = 'ExSr ' + %trim(caseSubRoutine) + ';';
044300180201                Exsr subUserReformatLine;
044400180201                caseSubRoutine = *Blanks;
044500180201             EndIf;
044600180201
044700180201             Read SRCREC;
044800180201          EndDo;
044900180201
045000180201          // Handle overflow.
045100180201          If overFlow;
045200180201
045300180201             // Print page headings.
045400180201             Z1#PAG += 1;
045500180201             Write Z1PAGHDG;
045600180201
045700180201             ZTFRFL = fromFileLib;
045800180201             ZTTOFL = toFileLib;
045900180201
046000180201             Write Z1TOPPAG;
046100180201
046200180201             overFlow = *Off;
046300180201          EndIf;
046400180201
046500180201          Z1FRMB = @pFromMbr;
046600180201          Z1TOMB = @pToMbr;
046700180201          Z1CTSC = countSource;
046800180201          Z1CTTG = countTarget;
046900180201          Z1CTEL = countEligible;
047000180201          Z1CTCV = countConv;
047100180201          Z1CTNV = countNotConv;
047200180201          Z1CTMV = countMoved;
047300180201          If countEligible = 0;
047400180201             Z1CNVR = 0;
047500180201          Else;
047600180201             Z1CNVR = countConv * 100 / countEligible;
047700180201          EndIf;
047800180201
047900180201          // Print detail format.
048000180201          Write Z1DETAIL;
048100180201
048200180201          // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
048300180201
048400180201       EndSr;
048500180201       //-------------------------------------------------------------------------------------------
048600180201
048700180201      /Eject
048800180201       //-------------------------------------------------------------------------------------------
048900180201       // Perform conversion/reformatting on the current line.
049000180201       //-------------------------------------------------------------------------------------------
049100180201       BegSr subUserReformatLine;
049200180201
049300180201          inDirective = *Off;
049400180201          inComment = *Off;
049500180201          increment = 0;
049600180201
049700180201          workDirective = %xlate(lo:up:directive);
049800180201          workLineType = %xlate(lo:up:lineType);
049900180201
050000180201          convert = *Off;
050100180201          nonConvRsn = *Blanks;
050200180201
050300180201          sourceLine = codeLine;     // Start with what is already there.
050400180201
050500180201          // Array data reached?
050600180201          If %subst(prefix:1:3) = '** '
050700180201          or %subst(SRCDTA:1:8) = '**CTDATA';
050800180201             inCode = *Off;
050900180201             inDeclaration = *Off;
051000180201             inArrayData = *On;
051100180201          EndIf;
051200180201
051300180201          If not inArrayData;
051400180201             //----------------------------------------------------------------------------------
051500180201             // Determine Line Type
051600180201             If workLineType = 'C';                  // C-Spec
051700180201                inCode = *On;
051800180201                //         ElseIf workLineType = 'P'               // P-Spec
051900180201                //             or %len(%trim(codeLine)) >= 4
052000180201                //            and %xlate(lo:up:%subst(%trim(codeLine):1:4)) = 'DCL-';
052100180201                //            inCode = *Off;
052200180201                //            defsMoved = *Off;
052300180201             ElseIf workLineType = 'P';              // P-Spec
052400180201                inCode = *Off;
052500180201                defsMoved = *Off;
052600180201             ElseIf workLineType = 'D';              // Declaration.
052700180201                inCode = *Off;
052800180201             ElseIf workLineType = 'H';              // Header spec.
052900180201                inCode = *Off;
053000180201             ElseIf workLineType = 'F';              // File spec.
053100180201                inCode = *Off;
053200180201             ElseIf workLineType = 'O';              // O-Spec
053300180201                inCode = *Off;
053400180201             ElseIf workLineType = 'I';              // I-Spec
053500180201                inCode = *On;
053600180201             ElseIf %check(validSpecs:workLineType) <> 0;    // Invalid spec type.
053700180201                workLineType = *Blanks;
053800180201                lineType = *Blank;                           // Clear it!
053900180201             EndIf;
054000180201
054100180201             If %trim(workDirective) = '/FREE';
054200180201                // In a free-format directive, so we must be in code too.
054300180201                If not inFreeFormat;
054400180201                   inDirective = *On;
054500180201                   inCode = *On;
054600180201                   inFreeFormat = *On;
054700180201                   lineType = ' ';
054800180201                   workLineType = ' ';
054900180201                   If @pDirectives = 'Y';
055000180201                      directive = '/Free';
055100180201                   Else;
055200180201                      dropLine = *On;
055300180201                   EndIf;
055400180201                Else;
055500180201                   dropLine = *On;   // Not needed.
055600180201                EndIf;
055700180201             ElseIf %trim(workDirective) = '/END-FREE';
055800180201                // At the end of a directive, so we can't be in free format any more.
055900180201                //inDirective = *On;
056000180201                //directive = '/End-Free';
056100180201                //inFreeFormat = *Off;
056200180201                dropLine = *On;
056300180201             ElseIf %trim(workDirective) = '/EJECT';
056400180201                inDirective = *On;
056500180201                lineType = ' ';
056600180201                workLineType = ' ';
056700180201             ElseIf %subst(workDirective:1:5) = '/COPY';
056800180201                inDirective = *On;
056900180201                lineType = ' ';
057000180201                workLineType = ' ';
057100180201             ElseIf %subst(workDirective:1:3) = '/IF';
057200180201                inDirective = *On;
057300180201                lineType = ' ';
057400180201                workLineType = ' ';
057500180201             ElseIf %subst(workDirective:1:6) = '/ENDIF';
057600180201                inDirective = *On;
057700180201                lineType = ' ';
057800180201                workLineType = ' ';
057900180201             ElseIf %subst(workDirective:1:7) = '/DEFINE';
058000180201                inDirective = *On;
058100180201                lineType = ' ';
058200180201                workLineType = ' ';
058300180201             ElseIf %subst(workDirective:1:6) = '/SPACE';
058400180201                inDirective = *On;
058500180201                lineType = ' ';
058600180201                workLineType = ' ';
058700180201             ElseIf %subst(workDirective:1:6) = '/TITLE';
058800180201                inDirective = *On;
058900180201                lineType = ' ';
059000180201                workLineType = ' ';
059100180201             ElseIf (%subst(workDirective:1:1) = '*'
059200180201                or %subst(workDirective:1:2) = '//')
059300180201                and (lineType = *Blank or inCode);
059400180201                //            and inCode;
059500180201                // This is a comment line.
059600180201                If @pIndComment <> 'Y' or workLineType = 'C';
059700180201                   inComment = *On;
059800180201                EndIf;
059900180201                If %subst(workDirective:1:2) = '//';
060000180201                   %subst(directive:1:2) = '  ';
060100180201                Else;
060200180201                   %subst(directive:1:1) = ' ';
060300180201                EndIf;
060400180201                If workLineType = 'C' or workLineType = 'D';
060500180201                   lineType = ' ';
060600180201                   workLineType = ' ';
060700180201                EndIf;
060800180201                // Retain blank comment markers?
060900180201                If @pRetBlnkCmt = 'N' and %len(%trim(codeLine)) = 0;
061000180201                   // Leave the line blank, devoid of any marker.
061100180201                Else;
061200180201                   codeLine = '//' + codeLine;
061300180201                EndIf;
061400180201             ElseIf %subst(workDirective:1:1) = '*';
061500180201                //            and workLineType = 'O';
061600180201                // Leave the line as it is.
061700180201                inComment = *On;
061800180201             ElseIf %len(%trim(codeLine)) = 0;
061900180201                // Just a 'spacer' line - keep it but drop the line type.
062000180201                lineType = ' ';
062100180201                workLineType = ' ';
062200180201             ElseIf %len(%trim(codeLine)) >= 2
062300180201                and %subst(%trim(codeLine):1:2) = '//'
062400180201                and (workLineType = *Blank or inCode);
062500180201                // This is a comment line.
062600180201                If @pIndComment <> 'Y' or workLineType = 'C';
062700180201                   inComment = *On;
062800180201                EndIf;
062900180201                // Retain blank comment markers?
063000180201                If @pRetBlnkCmt = 'N' and %len(%trim(%subst(codeLine:3)))
063100180201                                                  = 0;
063200180201                   // Leave the line blank, devoid of any marker.
063300180201                   codeLine = *Blanks;
063400180201                EndIf;
063500180201             ElseIf comment <> *Blanks
063600180201                and %len(%trim(%subst(codeLine:1:73))) = 0;
063700180201                // This is a blank line with a comment section.
063800180201                %subst(codeLine:71:2) = '//';
063900180201                inComment = *On;
064000180201             EndIf;
064100180201
064200180201             //----------------------------------------------------------------------------------
064300180201             // Convert fixed-format to free-format?
064400180201             If not inComment
064500180201             and not inDirective;
064600180201
064700180201                If workLineType = 'C';
064800180201                   countEligible += 1;
064900180201                   countNotConv += 1;
065000180201                   operator = %xlate(lo:up:opCode);
065100180201                   savedComment = comment;
065200180201
065300180201                   Exsr subUserConvertC_Spec;
065400180201
065500180201                   If not inComment and not convert
065600180201                   and not dropLine and nonConvRsn = *Blanks;
065700180201                      nonConvRsn = 'Conversion not currently supported.';
065800180201                   EndIf;
065900180201
066000180201                ElseIf workLineType = 'P';     // Procedure start/end.
066100180201                   countEligible += 1;
066200180201                   countNotConv += 1;
066300180201                   operator = *Blanks;
066400180201                   savedComment = comment;
066500180201
066600180201                   Exsr subUserConvertP_Spec;
066700180201
066800180201                   If not inComment and not convert
066900180201                   and not dropLine and nonConvRsn = *Blanks;
067000180201                      nonConvRsn = 'Conversion not currently supported.';
067100180201                   EndIf;
067200180201
067300180201                ElseIf workLineType = 'D';     // Declaration.
067400180201                   countEligible += 1;
067500180201                   countNotConv += 1;
067600180201                   savedComment = comment;
067700180201
067800180201                   Exsr subUserConvertD_Spec;
067900180201
068000180201                   If not inComment and not convert
068100180201                   and not dropLine and nonConvRsn = *Blanks;
068200180201                      //nonConvRsn = 'Conversion not currently supported.';
068300180201                   EndIf;
068400180201
068500180201                ElseIf workLineType = 'F';     // File.
068600180201                   countEligible += 1;
068700180201                   countNotConv += 1;
068800180201                   savedComment = comment;
068900180201
069000180201                   Exsr subUserConvertF_Spec;
069100180201
069200180201                   If not inComment and not convert
069300180201                   and not dropLine and nonConvRsn = *Blanks;
069400180201                      //nonConvRsn = 'Conversion not currently supported.';
069500180201                   EndIf;
069600180201
069700180201                ElseIf workLineType = 'H';     // Header.
069800180201                   countEligible += 1;
069900180201                   countNotConv += 1;
070000180201                   savedComment = comment;
070100180201
070200180201                   Exsr subUserConvertH_Spec;
070300180201
070400180201                   If not inComment and not convert
070500180201                   and not dropLine and nonConvRsn = *Blanks;
070600180201                      //nonConvRsn = 'Conversion not currently supported.';
070700180201                   EndIf;
070800180201
070900180201                ElseIf workLineType = 'O';     // Output spec
071000180201                   sourceLine = fullLine;
071100180201
071200180201                ElseIf workLineType = 'I';     // Input spec
071300180201                   sourceLine = fullLine;
071400180201
071500180201                ElseIf workLineType = ' ' and inCode;
071600180201                   inFreeFormat = *On;
071700180201                   // When in an IF we usually want subsequent lines to be pulled back to be
071800180201                   // in line with the 'If', but only if those lines start with either 'and'
071900180201                   // or 'or'.  Otherwise we retain the existing indentation by turning on
072000180201                   // inSpan.
072100180201                   If inIf and %len(%trim(codeLine)) >= 3
072200180201                   and %xlate(lo:up:%subst(%trim(codeLine):1:3)) <> 'AND'
072300180201                   and %xlate(lo:up:%subst(%trim(codeLine):1:3)) <> 'OR ';
072400180201                      inSpan = *On;
072500180201                   EndIf;
072600180201                   If inSpan;
072700180201                      currOffset = %check(' ':codeLine);  // Offset of the continuation line.
072800180201                   Else;
072900180201                      prevOffset = %check(' ':codeLine);  // Offset of the parent line.
073000180201                   EndIf;
073100180201                   sourceLine = %trim(codeLine);         // Free-format already, so trim it.
073200180201                Else;
073300180201                   inFreeFormat = *On;
073400180201                   sourceLine = %trimr(codeLine);        // None of the above, use the raw source
073500180201                EndIf;
073600180201
073700180201                // Converted?
073800180201                If convert;
073900180201                   countConv += 1;
074000180201                   countNotConv -= 1;
074100180201                   // Switch to free-format?
074200180201                   If not inFreeFormat and not inDeclaration;
074300180201                      If @pDirectives = 'Y';
074400180201                         savedSRCDTA = SRCDTA;
074500180201                         Clear SRCDTA;
074600180201                         directive = '/Free';
074700180201                         Exsr subUserWriteLine;
074800180201                         SRCDTA = savedSRCDTA;
074900180201                      EndIf;
075000180201                      inFreeFormat = *On;
075100180201                      directive = *Blanks;
075200180201                   EndIf;
075300180201                EndIf;
075400180201
075500180201                // Revert to fixed-format?
075600180201                If not convert and (lineType <> *Blanks
075700180201                or %subst(workDirective:1:5) = '/COPY');
075800180201                   //                or  %subst(prefix:1:3) = '** ');        // Array data reached
075900180201                   If inFreeFormat and not inDeclaration;
076000180201                      If @pDirectives = 'Y';
076100180201                         savedSRCDTA = SRCDTA;
076200180201                         Clear SRCDTA;
076300180201                         directive = '/End-Free';
076400180201                         Exsr subUserWriteLine;
076500180201                         SRCDTA = savedSRCDTA;
076600180201                      EndIf;
076700180201                      inFreeFormat = *Off;
076800180201                      If not inDirective;
076900180201                         directive = *Blanks;
077000180201                      EndIf;
077100180201                   EndIf;
077200180201                   // Record the reason for not converting?
077300180201                   If nonConvRsn <> *Blanks;
077400180201                      savedSRCDTA = SRCDTA;
077500180201                      Clear SRCDTA;
077600180201                      codeLine = '// >>>>> Not converted: ' + nonConvRsn;
077700180201                      Exsr subUserWriteLine;
077800180201                      SRCDTA = savedSRCDTA;
077900180201                   EndIf;
078000180201                   inSpan = *Off;
078100180201                EndIf;
078200180201             Else;
078300180201                // Use source exactly as is.
078400180201                sourceLine = codeLine;
078500180201             EndIf;
078600180201
078700180201             //----------------------------------------------------------------------------------
078800180201             // If we are in a code section, check if indent is affected at all.
078900180201             //         If not inDeclaration
079000180201             //         and not inDirective
079100180201             If not inDirective
079200180201             and not inComment
079300180201             and not dropLine;
079400180201                // Isolate the operator to check indentation against.
079500180201                //sourceLine = %trimr(codeLine);
079600180201                If inFreeFormat;
079700180201                   If %subst(sourceLine:1:2) = '//';            // Comment - no operator.
079800180201                      operator = *Blanks;
079900180201                   ElseIf inSQL;                                // Embedded SQL - no operator.
080000180201                      operator = *Blanks;
080100180201                   Else;
080200180201                      // Isolate the 'operator' (first word really).
080300180201                      operator = %trim(sourceLine);
080400180201                      operatorEnd = %scan(' ':%trim(operator)); // Look for end of first 'word'.
080500180201                      If operatorEnd = 0;
080600180201                         operatorEnd = %scan(';':operator);  // Only one word - is it an operator
080700180201                         If operatorEnd = 0;
080800180201                            operatorEnd = %scan('(':operator);  // Shouldn't match!
080900180201                         EndIf;
081000180201                      EndIf;
081100180201                      // If we have an operator, remove any attached extender code.
081200180201                      If operatorEnd > 0;
081300180201                         operator = %subst(operator:1:operatorEnd - 1);
081400180201                         // Exec SQL?
081500180201                         If %xlate(lo:up:operator) = 'EXEC';
081600180201                            If %scan('SQL':%xlate(lo:up:%trim(sourceLine)):6)
081700180201                                     > 0;
081800180201                               operator = 'Exec SQL';
081900180201                               inSQL = *On;
082000180201                            EndIf;
082100180201                         EndIf;
082200180201                         operatorEnd = %scan('(':operator);
082300180201                         If operatorEnd > 1;
082400180201                            operator = %subst(operator:1:operatorEnd - 1);
082500180201                         EndIf;
082600180201                      EndIf;
082700180201
082800180201                      If %lookup(%xlate(lo:up:operator):@opCodeUP) > 0
082900180201                      and not inDeclaration;
083000180201                         inCode = *On;
083100180201                      Else;
083200180201                         If %lookup(%xlate(lo:up:operator):@declUP) > 0;
083300180201                            // Declaration!
083400180201                         Else;
083500180201                            // Not an operator!
083600180201                            operator = *Blanks;
083700180201                            x = %scan('=':sourceLine);
083800180201                            If x > 0;   // Looks like an assignment.
083900180201                               operator = '=';
084000180201                               inCode = *On;
084100180201                               If workLineType = *Blank;
084200180201                                  sourceLine = %trim(sourceLine);
084300180201                               EndIf;
084400180201                            EndIf;
084500180201                         EndIf;
084600180201                      EndIf;
084700180201                   EndIf;
084800180201                Else;
084900180201                   If %subst(sourceLine:1:2) = '//';            // Comment - no operator.
085000180201                      operator = *Blanks;
085100180201                   Else;
085200180201                      operator = %xlate(lo:up:opCode);
085300180201                      If %subst(operator:1:4) <> 'EVAL'
085400180201                      and operator <> *Blanks;
085500180201                         // Strip out in-line definitions.
085600180201                         len = *Blanks;
085700180201                         dec = *Blanks;
085800180201                      EndIf;
085900180201                   EndIf;
086000180201                EndIf;
086100180201
086200180201                // Convert to upper case for check.
086300180201                operator = %xlate(lo:up:operator);
086400180201
086500180201                // Check for indentation level change.
086600180201                Select;
086700180201                   When workDirective = '/EXEC SQL';
086800180201                      increment = 1;
086900180201                      inSQL = *On;
087000180201                   When workDirective = '/END-EXEC';
087100180201                      unindent = *On;
087200180201                      increment = -1;
087300180201                      dropLine = *On;
087400180201                   When inSQL;
087500180201                      // Do nothing.
087600180201                   When %subst(operator:1:2) = 'IF';
087700180201                      increment = 1;
087800180201                      inIf = *On;
087900180201                   When %subst(operator:1:2) = 'DO';
088000180201                      increment = 1;
088100180201                      inDo = *On;
088200180201                      doCount += 1;
088300180201                      doLevel(doCount) = indentCount;
088400180201                   When operator = 'FOR';
088500180201                      increment = 1;
088600180201                      forCount += 1;
088700180201                      forLevel(forCount) = indentCount;
088800180201                   When operator = 'SELECT';
088900180201                      increment = 2;
089000180201                      slCount += 1;
089100180201                      slLevel(slCount) = indentCount;
089200180201                   When operator = 'BEGSR';
089300180201                      increment = 1;
089400180201                      mainlineIndent = 0;
089500180201                      indentCount = mainlineIndent;
089600180201                   When %subst(operator:1:4) = 'DCL-';
089700180201                      increment = 0;
089800180201                      mainlineIndent = 1;
089900180201                      indentCount = mainlineIndent;
090000180201                      defsMoved = *Off;
090100180201                   When %subst(operator:1:4) = 'END-';
090200180201                      increment = 0;
090300180201                      indentCount = mainlineIndent;
090400180201                   When operator = 'MONITOR';
090500180201                      increment = 1;
090600180201                   When operator = 'ENDSL';
090700180201                      unindent = *On;
090800180201                      increment = -2;
090900180201                      slCount -= 1;
091000180201                   When operator = 'ENDCS';
091100180201                      Operator = 'ENDIF';
091200180201                      unindent = *On;
091300180201                      increment = -1;
091400180201                   When operator = 'ENDDO';
091500180201                      unindent = *On;
091600180201                      increment = -1;
091700180201                      doCount -= 1;
091800180201                   When operator = 'ENDFOR';
091900180201                      unindent = *On;
092000180201                      increment = -1;
092100180201                      forCount -= 1;
092200180201                   When %subst(operator:1:3) = 'END';
092300180201                      unindent = *On;
092400180201                      increment = -1;
092500180201                   When %subst(operator:1:4) = 'ELSE'; // Unindent ELSE
092600180201                      unindent = *On;
092700180201                      indent = *On;
092800180201                      increment = -1;
092900180201                   When %subst(operator:1:2) = 'OR';   // Unindent OR
093000180201                      unindent = *On;
093100180201                      indent = *On;
093200180201                      increment = -1;
093300180201                   When %subst(operator:1:3) = 'AND';  // Unindent AND
093400180201                      unindent = *On;
093500180201                      indent = *On;
093600180201                      increment = -1;
093700180201                   When operator = 'ON-ERROR';         // Unindent On-Error
093800180201                      unindent = *On;
093900180201                      indent = *On;
094000180201                      increment = -1;
094100180201                   When %subst(operator:1:4) = 'WHEN' or inWhen;
094200180201                      unindent = *On;
094300180201                      indent = *On;
094400180201                      increment = -1;
094500180201                      inWhen = *On;
094600180201                   When inIF or inDo;                  // Keep conditions in line.
094700180201                      unindent = *On;
094800180201                      indent = *On;
094900180201                      increment = -1;
095000180201                   When operator = 'OTHER';             // Unindent Other
095100180201                      unindent = *On;
095200180201                      indent = *On;
095300180201                      increment = -1;
095400180201                   Other;
095500180201                      increment = 0;
095600180201                EndSl;
095700180201             ElseIf inDeclaration;
095800180201             EndIf;
095900180201
096000180201             //----------------------------------------------------------------------------------
096100180201             // Start of code?  If so, pause here and move all field definitions to D-specs.
096200180201             If inCode and not defsMoved;
096300180201                Exsr subUserMoveDefs;
096400180201             EndIf;
096500180201
096600180201             //----------------------------------------------------------------------------------
096700180201             // If we need to temporarily unindent, do so to the requested increment.
096800180201             If unindent;
096900180201                indentCount += increment;
097000180201                increment = 0;
097100180201                unindent = *Off;
097200180201             EndIf;
097300180201
097400180201             //----------------------------------------------------------------------------------
097500180201             // If we are in a code section and in free-format, perform reformatting.
097600180201             //If inCode and inFreeFormat and not inDirective
097700180201             If inFreeFormat
097800180201             and not inDirective
097900180201             and sourceLine <> *Blanks
098000180201             and not inComment
098100180201             and not dropLine;       //  and not inSpan
098200180201                // Derive reformatted opcode (if any)
098300180201                x = %lookup(operator:@opCodeUP);
098400180201                If x > 0;
098500180201                   newOperator = %trim(@opCodeLO(x));
098600180201                Else;
098700180201                   x = %lookup(operator:@declUP);
098800180201                   If x > 0;
098900180201                      newOperator = %trim(@declLO(x));
099000180201                   Else;
099100180201                      // Not a valid operator, check if this is a comment.
099200180201                      x = %scan('//':%trim(sourceLine));
099300180201                      If x = 1;
099400180201                         inComment = *On;
099500180201                         newOperator = '';
099600180201                         operator = *Blanks;
099700180201                      Else;
099800180201                         newOperator = '';
099900180201                      EndIf;
100000180201                   EndIf;
100100180201                EndIf;
100200180201
100300180201                // Use new opcode if it exists.
100400180201                If %len(newOperator) > 0;
100500180201                   If %len(%trim(sourceLine)) > %len(newOperator);
100600180201                      sourceLine = %trim(%subst(%trim(sourceLine)
100700180201                                       :%len(newOperator) + 1));
100800180201                   Else;
100900180201                      //                  sourceLine = %trim(%subst(%trim(sourceLine)
101000180201                      //                                   :%len(newOperator)));
101100180201                      sourceLine = *Blanks;
101200180201                   EndIf;
101300180201                   // Insert a spcace after operator if it's not the end of the line
101400180201                   // and there's no operation extender.
101500180201                   If %subst(sourceLine:1:1) <> ';'
101600180201                   and (%subst(sourceLine:1:1) <> '('
101700180201                     or %subst(sourceLine:1:1) = '('
101800180201                    and %subst(sourceLine:3:1) <> ')'
101900180201                    and %subst(sourceLine:4:1) <> ')');
102000180201                      sourceLine = ' ' + sourceLine;
102100180201                   EndIf;
102200180201                   sourceLine = newOperator + sourceLine;
102300180201                EndIf;
102400180201
102500180201                If inCode;
102600180201                   // Padding required?
102700180201                   If padResult;
102800180201                      savedSRCDTA = SRCDTA;
102900180201                      Clear codeLine;
103000180201                      %subst(codeLine:indentOffset)
103100180201                            = %trim(padTarget) + ' = *Blanks;';
103200180201                      Exsr subUserWriteLine;
103300180201                      SRCDTA = savedSRCDTA;
103400180201                      padResult = *Off;
103500180201                   EndIf;
103600180201
103700180201                   // Determine the indentation to use.
103800180201                   If indentCount > maxIndent;
103900180201                      indentOffset = maxIndent * indentSize + 1;
104000180201                   Else;
104100180201                      indentOffset = indentCount * indentSize + 1;
104200180201                   EndIf;
104300180201
104400180201                   // Adjust for continuation lines.
104500180201                   If inCallP and (%subst(operator:1:5) <> 'CALLP');
104600180201                      indentOffset += callPOffset;
104700180201                   ElseIf inEval and (%subst(operator:1:4) <> 'EVAL');
104800180201                      indentOffset += evalOffset;
104900180201                   ElseIf inSpan;
105000180201                      indentOffset = currOffset + (indentOffset - prevOffset);
105100180201                   EndIf;
105200180201
105300180201                   // Avoid losing code off of the right hand side (comments mainly).
105400180201                   If %len(%trimr(sourceLine)) + indentOffset > 93;
105500180201                      indentOffset = 93 - %len(%trim(sourceLine));
105600180201                   EndIf;
105700180201
105800180201                   // For code lines, check for overflow, and unindent accordingly if it does,
105900180201                   If not inComment;
106000180201                      lineEnd = %scan(';':%trimr(sourceLine));
106100180201                      If lineEnd = 0;   // Code already spans to next line.
106200180201                         lineEnd = %scan('//':sourceLine);
106300180201                         If lineEnd > 0;
106400180201                            lineEnd
106500180201                              = %len(%trimr(%subst(sourceLine:1:lineEnd-1)));
106600180201                         Else;
106700180201                            lineEnd = %len(%trimr(sourceLine));
106800180201                         EndIf;
106900180201                         If not inIf and not inDo and not inWhen;
107000180201                            inSpan = *On;
107100180201                         EndIf;
107200180201                      EndIf;
107300180201                   EndIf;
107400180201
107500180201                   // Cater for commented out code that extends into comments.
107600180201                   If indentOffset + lineEnd > 74;
107700180201                      //Exsr subUserWrapLine;
107800180201                      indentOffset -= ((indentOffset + lineEnd) - 74);
107900180201                   EndIf;
108000180201
108100180201                   // Ensure that we don't go back too far!
108200180201                   If indentOffset < 1;
108300180201                      indentOffset = 1;
108400180201                   EndIf;
108500180201
108600180201                   savedSRCDTA = SRCDTA;
108700180201                   Clear codeLine;
108800180201                   %subst(codeLine:indentOffset) = %trimr(sourceLine);
108900180201                   // Append an in-line comment?
109000180201                   If (convert or setOn or setOff)
109100180201                   and savedComment <> *Blanks;
109200180201                      %subst(codeLine:71) = '// ' + savedComment;
109300180201                      savedComment = *Blanks;
109400180201                   EndIf;
109500180201                   sourceLine = codeLine;
109600180201                   SRCDTA = savedSRCDTA;
109700180201                   EndIf;   // inCode
109800180201                EndIf;
109900180201             EndIf;
110000180201
110100180201             //----------------------------------------------------------------------------------
110200180201             // Output the formatted line (and any overflows that have occurred.
110300180201             If not dropLine;
110400180201                If convert;
110500180201                   Clear nonPrefix;
110600180201                EndIf;
110700180201                If inCode or inArrayData
110800180201                or lineType = *Blank or %subst(directive:1:1) = '*';
110900180201                   codeLine = %trimr(sourceLine);
111000180201                Else;
111100180201                   fullLine = %trimr(sourceLine);
111200180201                EndIf;
111300180201                Exsr subUserWriteLine;
111400180201
111500180201                // Overflow line?
111600180201                If overFlowLine <> *Blanks;
111700180201                   Clear codeLine;
111800180201                   %subst(codeLine:indentOffset) = %trimr(overflowLine);
111900180201                   overflowLine = *Blanks;
112000180201                   Exsr subUserWriteLine;
112100180201                EndIf;
112200180201             Else;
112300180201                dropLine = *Off;
112400180201             EndIf;
112500180201
112600180201             indentCount += increment;
112700180201
112800180201             // Following a WHEN or ON-ERROR or ELSE, code should be indented again.
112900180201             If indent;
113000180201                indentCount += 1;
113100180201                indent = *Off;
113200180201                // Following ENDSR, we should revert to mainline indentation.
113300180201             ElseIf operator = 'ENDSR';
113400180201                indentCount = mainlineIndent;
113500180201                inCode = *Off;
113600180201             EndIf;
113700180201
113800180201             // If spanning a line, check if the current line ends the span.
113900180201             If (inSpan or inIf or inDo or inWhen or inCallP or inEval
114000180201             or inSQL or inDeclaration)
114100180201             and not inComment;
114200180201                lineEnd = %scan(';':%trim(sourceLine));
114300180201                If lineEnd <> 0;
114400180201                   inSpan = *Off;
114500180201                   inIf = *Off;
114600180201                   inDo = *Off;
114700180201                   inWhen = *Off;
114800180201                   inCallP = *Off;
114900180201                   inEval = *Off;
115000180201                   inSQL = *Off;
115100180201                   inDeclaration = *Off;
115200180201                EndIf;
115300180201             EndIf;
115400180201
115500180201             //----------------------------------------------------------------------------------
115600180201             // Close off Prototype/Interface/Datastructure?
115700180201             If (inPrototype or inInterface or inDatastructure)
115800180201             and SRCSEQ = endLine;
115900180201                If not inDatastructure
116000180201                or inDatastructure and endDS;
116100180201                   savedSRCDTA = SRCDTA;
116200180201                   Clear SRCDTA;
116300180201                   codeLine = 'End-' + endDeclType + ';';
116400180201                   Exsr subUserWriteLine;
116500180201                   SRCDTA = savedSRCDTA;
116600180201                EndIf;
116700180201                inPrototype = *Off;
116800180201                inExtProc = *Off;
116900180201                inInterface = *Off;
117000180201                inDatastructure = *Off;
117100180201                inSpan = *Off;
117200180201                inDeclaration = *Off;
117300180201                inExtProc = *Off;
117400180201                workDeclName = *Blanks;
117500180201             EndIf;
117600180201
117700180201          EndSr;
117800180201       //-------------------------------------------------------------------------------------------
117900180201
118000180201      /Eject
118100180201       //-------------------------------------------------------------------------------------------
118200180201       // Convert the line to free-format?
118300180201       //-------------------------------------------------------------------------------------------
118400180201       BegSr subUserConvertC_Spec;
118500180201
118600180201          Select;
118700180201                // Keep blank lines.
118800180201             When codeLine = *Blanks;
118900180201                sourceLine = *Blanks;
119000180201                convert = *On;
119100180201
119200180201               //----------------------------------------------------------------------------------
119300180201                // EXEC SQL
119400180201             When workDirective = '/EXEC SQL' or inSQL;
119500180201                Exsr subUserCvt_EXEC_SQL;
119600180201
119700180201               //----------------------------------------------------------------------------------
119800180201                // END-EXEC
119900180201             When workDirective = '/END-EXEC';
120000180201                convert = *On;
120100180201
120200180201               //----------------------------------------------------------------------------------
120300180201                // Conditioning indicators
120400180201             When condInd <> *Blanks;
120500180201                nonConvRsn = 'Conditioning indicators are not currently '
120600180201                           + 'supported.';
120700180201
120800180201               //----------------------------------------------------------------------------------
120900180201                // ACQ.
121000180201             When %subst(operator:1:3) = 'ACQ';
121100180201                Exsr subUserCvt_ACQ;
121200180201
121300180201               //----------------------------------------------------------------------------------
121400180201                // ADDDUR.
121500180201             When %subst(operator:1:6) = 'ADDDUR';
121600180201                Exsr subUserCvt_ADDDUR;
121700180201
121800180201               //----------------------------------------------------------------------------------
121900180201                // ADD.
122000180201             When %subst(operator:1:3) = 'ADD';
122100180201                Exsr subUserCvt_ADD;
122200180201
122300180201               //----------------------------------------------------------------------------------
122400180201                // ALLOC.
122500180201             When %subst(operator:1:5) = 'ALLOC';
122600180201                Exsr subUserCvt_ALLOC;
122700180201
122800180201               //----------------------------------------------------------------------------------
122900180201                // BEGSR
123000180201             When operator = 'BEGSR';
123100180201                Exsr subUserCvt_BEGSR;
123200180201
123300180201               //----------------------------------------------------------------------------------
123400180201                // CALLP
123500180201             When %subst(operator:1:5) = 'CALLP' or inCallP;
123600180201                Exsr subUserCvt_CALLP;
123700180201
123800180201               //----------------------------------------------------------------------------------
123900180201                // CASxx
124000180201             When %subst(operator:1:3) = 'CAS';
124100180201                Exsr subUserCvt_CASxx;
124200180201
124300180201               //----------------------------------------------------------------------------------
124400180201                // CAT
124500180201             When %subst(operator:1:3) = 'CAT';
124600180201                Exsr subUserCvt_CAT;
124700180201
124800180201               //----------------------------------------------------------------------------------
124900180201                // CHAIN
125000180201             When %subst(operator:1:5) = 'CHAIN';
125100180201                Exsr subUserCvt_CHAIN;
125200180201
125300180201               //----------------------------------------------------------------------------------
125400180201                // CHECK
125500180201             When %subst(operator:1:5) = 'CHECK';
125600180201                Exsr subUserCvt_CHECKx;
125700180201
125800180201               //----------------------------------------------------------------------------------
125900180201                // CLEAR
126000180201             When %subst(operator:1:5) = 'CLEAR';
126100180201                Exsr subUserCvt_CLEAR;
126200180201
126300180201               //----------------------------------------------------------------------------------
126400180201                // CLOSE
126500180201             When %subst(operator:1:5) = 'CLOSE';
126600180201                Exsr subUserCvt_CLOSE;
126700180201
126800180201               //----------------------------------------------------------------------------------
126900180201                // COMMIT
127000180201             When %subst(operator:1:6) = 'COMMIT';
127100180201                Exsr subUserCvt_COMMIT;
127200180201
127300180201               //----------------------------------------------------------------------------------
127400180201                // COMP
127500180201             When operator = 'COMP';
127600180201                Exsr subUserCvt_COMP;
127700180201
127800180201               //----------------------------------------------------------------------------------
127900180201                // DEALLOC.
128000180201             When %subst(operator:1:7) = 'DEALLOC';
128100180201                Exsr subUserCvt_DEALLOC;
128200180201
128300180201               //----------------------------------------------------------------------------------
128400180201                // DEFINE
128500180201             When operator = 'DEFINE';
128600180201                dropLine = *On;
128700180201
128800180201               //----------------------------------------------------------------------------------
128900180201                // DELETE
129000180201             When %subst(operator:1:6) = 'DELETE';
129100180201                Exsr subUserCvt_DELETE;
129200180201
129300180201               //----------------------------------------------------------------------------------
129400180201                // DIV
129500180201             When %subst(operator:1:3) = 'DIV';
129600180201                Exsr subUserCvt_DIV;
129700180201
129800180201               //----------------------------------------------------------------------------------
129900180201                // DOxxx
130000180201             When %subst(operator:1:2) = 'DO'
130100180201             and (%subst(operator:3:3) = 'WEQ'
130200180201             or %subst(operator:3:2) = 'W '
130300180201             or %subst(operator:3:3) = 'WGT'
130400180201             or %subst(operator:3:3) = 'WLT'
130500180201             or %subst(operator:3:3) = 'WNE'
130600180201             or %subst(operator:3:3) = 'WGE'
130700180201             or %subst(operator:3:3) = 'WLE'
130800180201             or %subst(operator:3:2) = 'U '
130900180201             or %subst(operator:3:3) = 'UEQ'
131000180201             or %subst(operator:3:3) = 'UGT'
131100180201             or %subst(operator:3:3) = 'ULT'
131200180201             or %subst(operator:3:3) = 'UNE'
131300180201             or %subst(operator:3:3) = 'UGE'
131400180201             or %subst(operator:3:3) = 'ULE'
131500180201             or %subst(operator:3:3) = '   ')
131600180201             or inDo;
131700180201                Exsr subUserCvt_DO;
131800180201
131900180201               //----------------------------------------------------------------------------------
132000180201                // DSPLY
132100180201             When %subst(operator:1:5) = 'DSPLY';
132200180201                Exsr subUserCvt_DSPLY;
132300180201
132400180201               //----------------------------------------------------------------------------------
132500180201                // DUMP
132600180201             When %subst(operator:1:4) = 'DUMP';
132700180201                Exsr subUserCvt_DUMP;
132800180201
132900180201               //----------------------------------------------------------------------------------
133000180201                // ELSE
133100180201             When operator = 'ELSE';
133200180201                Exsr subUserCvt_ELSE;
133300180201
133400180201               //----------------------------------------------------------------------------------
133500180201                // ELSEIF
133600180201             When operator = 'ELSEIF';
133700180201                Exsr subUserCvt_ELSEIF;
133800180201
133900180201               //----------------------------------------------------------------------------------
134000180201                // ENDxx
134100180201             When %subst(operator:1:3) = 'END';
134200180201                Exsr subUserCvt_ENDxx;
134300180201
134400180201               //----------------------------------------------------------------------------------
134500180201                // EVALx
134600180201             When %subst(operator:1:4) = 'EVAL' or inEval;
134700180201                Exsr subUserCvt_EVALx;
134800180201
134900180201               //----------------------------------------------------------------------------------
135000180201                // EXCEPT
135100180201             When operator = 'EXCEPT';
135200180201                Exsr subUserCvt_EXCEPT;
135300180201
135400180201               //----------------------------------------------------------------------------------
135500180201                // EXFMT
135600180201             When %subst(operator:1:5) = 'EXFMT';
135700180201                Exsr subUserCvt_EXFMT;
135800180201
135900180201               //----------------------------------------------------------------------------------
136000180201                // EXSR
136100180201             When operator = 'EXSR';
136200180201                Exsr subUserCvt_EXSR;
136300180201
136400180201               //----------------------------------------------------------------------------------
136500180201                // EXTRCT
136600180201             When %subst(operator:1:6) = 'EXTRCT';
136700180201                Exsr subUserCvt_EXTRCT;
136800180201
136900180201               //----------------------------------------------------------------------------------
137000180201                // FEOD
137100180201             When %subst(operator:1:4) = 'FEOD';
137200180201                Exsr subUserCvt_FEOD;
137300180201
137400180201               //----------------------------------------------------------------------------------
137500180201                // FOR
137600180201             When operator = 'FOR';
137700180201                Exsr subUserCvt_FOR;
137800180201
137900180201               //----------------------------------------------------------------------------------
138000180201                // FORCE
138100180201             When operator = 'FORCE';
138200180201                Exsr subUserCvt_FORCE;
138300180201
138400180201               //----------------------------------------------------------------------------------
138500180201                // IFxx
138600180201             When %subst(operator:1:2) = 'IF' or inIf;
138700180201                Exsr subUserCvt_IF;
138800180201
138900180201               //----------------------------------------------------------------------------------
139000180201                // IN
139100180201             When %subst(operator:1:2) = 'IN';
139200180201                Exsr subUserCvt_IN;
139300180201
139400180201               //----------------------------------------------------------------------------------
139500180201                // ITER
139600180201             When operator = 'ITER';
139700180201                Exsr subUserCvt_ITER;
139800180201
139900180201               //----------------------------------------------------------------------------------
140000180201                // LEAVExx;
140100180201             When %subst(operator:1:5) = 'LEAVE';
140200180201                Exsr subUserCvt_LEAVE;
140300180201
140400180201               //----------------------------------------------------------------------------------
140500180201                // LOOKUP
140600180201             When operator = 'LOOKUP';
140700180201                Exsr subUserCvt_LOOKUP;
140800180201
140900180201               //----------------------------------------------------------------------------------
141000180201                // MOVEA
141100180201             When %subst(operator:1:5) = 'MOVEA';
141200180201                Exsr subUserCvt_MOVEA;
141300180201                LeaveSr;
141400180201
141500180201               //----------------------------------------------------------------------------------
141600180201                // MOVE/MOVEL
141700180201             When operator = 'MONITOR';
141800180201                Exsr subUserCvt_MONITOR;
141900180201
142000180201               //----------------------------------------------------------------------------------
142100180201                // MOVE/MOVEL
142200180201             When %subst(operator:1:4) = 'MOVE';
142300180201                Exsr subUserCvt_MOVE;
142400180201
142500180201               //----------------------------------------------------------------------------------
142600180201                // MULT.
142700180201             When %subst(operator:1:4) = 'MULT';
142800180201                Exsr subUserCvt_MULT;
142900180201
143000180201               //----------------------------------------------------------------------------------
143100180201                // MVR
143200180201             When operator = 'MVR';
143300180201                Exsr subUserCvt_MVR;
143400180201
143500180201               //----------------------------------------------------------------------------------
143600180201                // OCCUR (but not both set and get).
143700180201             When %subst(operator:1:5) = 'OCCUR';
143800180201                Exsr subUserCvt_OCCUR;
143900180201
144000180201               //----------------------------------------------------------------------------------
144100180201                // ON-ERROR
144200180201             When operator = 'ON-ERROR';
144300180201                Exsr subUserCvt_ON_ERROR;
144400180201
144500180201               //----------------------------------------------------------------------------------
144600180201                // OPEN
144700180201             When %subst(operator:1:4) = 'OPEN';
144800180201                Exsr subUserCvt_OPEN;
144900180201
145000180201               //----------------------------------------------------------------------------------
145100180201                // OTHER
145200180201             When operator = 'OTHER';
145300180201                Exsr subUserCvt_OTHER;
145400180201
145500180201               //----------------------------------------------------------------------------------
145600180201                // OUT
145700180201             When %subst(operator:1:3) = 'OUT';
145800180201                Exsr subUserCvt_OUT;
145900180201
146000180201               //----------------------------------------------------------------------------------
146100180201                // POST
146200180201             When %subst(operator:1:4) = 'POST';
146300180201                Exsr subUserCvt_POST;
146400180201
146500180201               //----------------------------------------------------------------------------------
146600180201                // READ
146700180201             When %subst(operator:1:4) = 'READ';
146800180201                Exsr subUserCvt_READ;
146900180201
147000180201               //----------------------------------------------------------------------------------
147100180201                // REL
147200180201             When %subst(operator:1:3) = 'REL';
147300180201                Exsr subUserCvt_REL;
147400180201
147500180201               //----------------------------------------------------------------------------------
147600180201                // RESET
147700180201             When %subst(operator:1:5) = 'RESET';
147800180201                Exsr subUserCvt_RESET;
147900180201
148000180201               //----------------------------------------------------------------------------------
148100180201                // RETURN
148200180201             When %subst(operator:1:6) = 'RETURN';
148300180201                Exsr subUserCvt_RETURN;
148400180201
148500180201               //----------------------------------------------------------------------------------
148600180201                // ROLBK
148700180201             When %subst(operator:1:5) = 'ROLBK';
148800180201                Exsr subUserCvt_ROLBK;
148900180201
149000180201               //----------------------------------------------------------------------------------
149100180201                // SCAN
149200180201             When operator = 'SCAN';
149300180201                Exsr subUserCvt_SCAN;
149400180201
149500180201               //----------------------------------------------------------------------------------
149600180201                // SELECT
149700180201             When operator = 'SELECT';
149800180201                Exsr subUserCvt_SELECT;
149900180201
150000180201               //----------------------------------------------------------------------------------
150100180201                // SETLL / SETGT
150200180201             When %subst(operator:1:5) = 'SETLL'
150300180201             or %subst(operator:1:5) = 'SETGT';
150400180201                Exsr subUserCvt_SETxx;
150500180201
150600180201               //----------------------------------------------------------------------------------
150700180201                // SETOFF
150800180201             When operator = 'SETOFF';
150900180201                Exsr subUserCvt_SETOFF;
151000180201
151100180201               //----------------------------------------------------------------------------------
151200180201                // SETON
151300180201             When operator = 'SETON';
151400180201                Exsr subUserCvt_SETON;
151500180201
151600180201               //----------------------------------------------------------------------------------
151700180201                // SHTDN
151800180201             When operator = 'SHTDN';
151900180201                Exsr subUserCvt_SHTDN;
152000180201
152100180201               //----------------------------------------------------------------------------------
152200180201                // SORTA.
152300180201             When %subst(operator:1:5) = 'SORTA';
152400180201                Exsr subUserCvt_SORTA;
152500180201
152600180201               //----------------------------------------------------------------------------------
152700180201                // SUBDUR.
152800180201             When %subst(operator:1:6) = 'SUBDUR';
152900180201                Exsr subUserCvt_SUBDUR;
153000180201
153100180201               //----------------------------------------------------------------------------------
153200180201                // SUBST.
153300180201             When %subst(operator:1:5) = 'SUBST';
153400180201                Exsr subUserCvt_SUBST;
153500180201
153600180201               //----------------------------------------------------------------------------------
153700180201                // SUB
153800180201             When %subst(operator:1:3) = 'SUB';
153900180201                Exsr subUserCvt_SUB;
154000180201
154100180201               //----------------------------------------------------------------------------------
154200180201                // TESTB
154300180201             When operator = 'TESTB';
154400180201
154500180201               //----------------------------------------------------------------------------------
154600180201                // TESTN
154700180201             When operator = 'TESTN';
154800180201
154900180201               //----------------------------------------------------------------------------------
155000180201                // TESTZ
155100180201             When operator = 'TESTZ';
155200180201
155300180201               //----------------------------------------------------------------------------------
155400180201                // TEST
155500180201             When %subst(operator:1:4) = 'TEST';
155600180201                Exsr subUserCvt_TEST;
155700180201
155800180201               //----------------------------------------------------------------------------------
155900180201                // TIME
156000180201             When operator = 'TIME';
156100180201                Exsr subUserCvt_TIME;
156200180201
156300180201               //----------------------------------------------------------------------------------
156400180201                // UPDATE
156500180201             When %subst(operator:1:6) = 'UPDATE';
156600180201                Exsr subUserCvt_UPDATE;
156700180201
156800180201               //----------------------------------------------------------------------------------
156900180201                // UNLOCK
157000180201             When %subst(operator:1:6) = 'UNLOCK';
157100180201                Exsr subUserCvt_UNLOCK;
157200180201
157300180201               //----------------------------------------------------------------------------------
157400180201                // WHENxx
157500180201             When %subst(operator:1:4) = 'WHEN' or inWhen;
157600180201                Exsr subUserCvt_WHEN;
157700180201
157800180201               //----------------------------------------------------------------------------------
157900180201                // WRITE
158000180201             When %subst(operator:1:5) = 'WRITE';
158100180201                Exsr subUserCvt_WRITE;
158200180201
158300180201               //----------------------------------------------------------------------------------
158400180201                // XLATE
158500180201             When %subst(operator:1:5) = 'XLATE';
158600180201                Exsr subUserCvt_XLATE;
158700180201
158800180201               //----------------------------------------------------------------------------------
158900180201                // Z-ADD (half-adjust not converted).
159000180201             When %subst(operator:1:5) = 'Z-ADD';
159100180201                Exsr subUserCvt_Z_ADD;
159200180201
159300180201               //----------------------------------------------------------------------------------
159400180201                // Z-SUB (half-adjust not converted).
159500180201             When %subst(operator:1:5) = 'Z-SUB';
159600180201                Exsr subUserCvt_Z_SUB;
159700180201          EndSl;
159800180201
159900180201       EndSr;
160000180201       //-------------------------------------------------------------------------------------------
160100180201
160200180201      /Eject
160300180201       //-------------------------------------------------------------------------------------------
160400180201       // Convert declaration to free-format.
160500180201       //-------------------------------------------------------------------------------------------
160600180201       BegSr subUserConvertD_Spec;
160700180201
160800180201          // Keep blank lines.
160900180201          If codeLine = *Blanks;
161000180201             sourceLine = *Blanks;
161100180201             convert = *On;
161200180201             LeaveSr;
161300180201          EndIf;
161400180201
161500180201          sourceLine = fullLine;
161600180201
161700180201          //      declType = %xlate(lo:up:declType);
161800180201          workDeclAttr = %xlate(lo:up:declAttr);
161900180201          workDeclKeywords = declKeywords;       // Use longer work field to cater for expansion.
162000180201
162100180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
162200180201
162300180201          //If not inDeclaration;
162400180201          If not inDeclaration or declName = *Blanks;
162500180201             If not inDeclaration;
162600180201                //Exsr subUserGetDeclarationType;
162700180201                GetDeclarationType(workDeclType:savedName:workDeclLine);
162800180201             EndIf;
162900180201
163000180201             //-------------------------------------------------------------------------
163100180201             // Stand-alone Field Definition.
163200180201             //-------------------------------------------------------------------------
163300180201             If workDeclType = 'S';      // Stand-alone field.
163400180201                inDeclaration = *On;
163500180201
163600180201                Clear DCLS;
163700180201
163800180201                // FROMFILE is not allowed.
163900180201                If %scan('FROMFILE':%xlate(lo:up:workDeclKeywords)) > 0;
164000180201                   inDeclaration = *Off;
164100180201                   nonConvRsn = 'FROMFILE not allowed in Free-Form';
164200180201                   convert = *Off;
164300180201                   LeaveSr;
164400180201                EndIf;
164500180201
164600180201                If savedName <> *Blanks;
164700180201                   DCLS.decl = 'Dcl-S ';
164800180201                   %subst(DCLS:7) = savedName;
164900180201                EndIf;
165000180201
165100180201                // Type.
165200180201                If workDeclAttr = *Blanks
165300180201                and DCLS.type = *Blanks;
165400180201                   If declLen = *Blanks;
165500180201                      // No definition (probably in keywords - e.g. LIKE()).
165600180201                   ElseIf declScale = *Blanks;
165700180201                      workDeclAttr = 'A';
165800180201                   Else;
165900180201                      If inDatastructure;
166000180201                         workDeclAttr = 'S';
166100180201                      Else;
166200180201                         workDeclAttr = 'P';
166300180201                      EndIf;
166400180201                   EndIf;
166500180201                EndIf;
166600180201
166700180201                If workDeclAttr = *Blanks;
166800180201                   // No definition (probably in keywords - e.g. LIKE()).
166900180201                ElseIf workDeclAttr = 'A';
167000180201                   x = %scan('VARYING':%xlate(lo:up:workDeclKeywords));
167100180201                   If x > 0;
167200180201                      DCLS.type = '  VarChar';
167300180201                      If x = 1;
167400180201                         workDeclKeywords = %subst(workDeclKeywords:x+7);
167500180201                      Else;
167600180201                         workDeclKeywords = %subst(workDeclKeywords:1:x-1)
167700180201                                      + %subst(workDeclKeywords:x+7);
167800180201                      EndIf;
167900180201                   Else;
168000180201                      DCLS.type = '     Char';
168100180201                   EndIf;
168200180201                ElseIf workDeclAttr = 'P';
168300180201                   DCLS.type = '   Packed';
168400180201                ElseIf workDeclAttr = 'D';
168500180201                   DCLS.type = '     Date';
168600180201                   x = %scan('DATFMT':%xlate(lo:up:workDeclKeywords));
168700180201                   If x > 0;
168800180201                      x = %scan('(':workDeclKeywords:x);
168900180201                      y = %scan(')':workDeclKeywords:x);
169000180201                      DCLS.definition = '('
169100180201                                + %subst(workDeclKeywords:x+1:y-x-1)
169200180201                                + ')';
169300180201                      workDeclKeywords = %subst(workDeclKeywords:y+1);
169400180201                   EndIf;
169500180201                ElseIf workDeclAttr = 'T';
169600180201                   DCLS.type = '     Time';
169700180201                   x = %scan('TIMFMT':%xlate(lo:up:workDeclKeywords));
169800180201                   If x > 0;
169900180201                      x = %scan('(':workDeclKeywords:x);
170000180201                      y = %scan(')':workDeclKeywords:x);
170100180201                      DCLS.definition = '('
170200180201                                + %subst(workDeclKeywords:x+1:y-x-1)
170300180201                                + ')';
170400180201                      workDeclKeywords = %subst(workDeclKeywords:y+1);
170500180201                   EndIf;
170600180201                ElseIf workDeclAttr = 'Z';
170700180201                   DCLS.type = 'TimeStamp';
170800180201                ElseIf workDeclAttr = 'I';
170900180201                   DCLS.type = '      Int';
171000180201                ElseIf workDeclAttr = 'S';
171100180201                   DCLS.type = '    Zoned';
171200180201                ElseIf workDeclAttr = 'N';
171300180201                   DCLS.type = '      Ind';
171400180201                ElseIf workDeclAttr = '*';
171500180201                   DCLS.type = '  Pointer';
171600180201                ElseIf workDeclAttr = 'B';
171700180201                   DCLS.type = '   BinDec';
171800180201                ElseIf workDeclAttr = 'G';
171900180201                   x = %scan('VARYING':%xlate(lo:up:workDeclKeywords));
172000180201                   If x > 0;
172100180201                      DCLS.type = ' VarGraph';
172200180201                      workDeclKeywords = %subst(workDeclKeywords:x+7);
172300180201                   Else;
172400180201                      DCLS.type = '    Graph';
172500180201                   EndIf;
172600180201                Else;
172700180201                   inDeclaration = *Off;
172800180201                   convert = *Off;
172900180201                   LeaveSr;
173000180201                EndIf;
173100180201
173200180201                // Attributes.
173300180201                If workDeclAttr <> '*'
173400180201                and workDeclAttr <> 'N'
173500180201                and workDeclAttr <> 'D'
173600180201                and workDeclAttr <> 'T'
173700180201                and workDeclAttr <> 'Z'
173800180201                and workDeclAttr <> *Blank
173900180201                and DCLS.type <> *Blanks;
174000180201                   DCLS.definition = '(' + %trim(declLen);
174100180201                   If declScale <> *Blanks;
174200180201                      DCLS.definition = %trimr(DCLS.definition)
174300180201                                      + ':' + %trim(declScale);
174400180201                   EndIf;
174500180201                   DCLS.definition = %trimr(DCLS.definition) + ')';
174600180201                EndIf;
174700180201
174800180201                // Keywords.
174900180201
175000180201                // Expand DTAARA?
175100180201                x = %scan('DTAARA(':%xlate(lo:up:workDeclKeywords));
175200180201                If x > 0;
175300180201                   i = %scan(')':workDeclKeywords:x+1);
175400180201                   If i > 0;
175500180201                      If %scan('''':%subst(workDeclKeywords:x+7:i-x-7)) = 0;
175600180201                         workDeclKeywords = %subst(workDeclKeywords:1:x+6)
175700180201                            + ''''
175800180201                       + %xlate(lo:up:%trim(%subst(workDeclKeywords:x+7:i-x-7)))
175900180201                            + ''''
176000180201                            + %subst(workDeclKeywords:i);
176100180201                      EndIf;
176200180201                   EndIf;
176300180201                EndIf;
176400180201
176500180201                // Terminate the line?
176600180201                If not inSpan;
176700180201                   If workDeclKeyWords = *Blanks;
176800180201                      DCLS.definition = %trimr(DCLS.definition) + ';';
176900180201                   Else;
177000180201                      workDeclKeywords = %trimr(workDeclKeywords) + ';';
177100180201                   EndIf;
177200180201                   inDeclaration = *Off;
177300180201                Else;
177400180201                   inSpan = *Off;
177500180201                EndIf;
177600180201
177700180201                // Have we encroached on the comments?
177800180201                x = %len(%trimr(DCLS.definition)) + %len(workDeclKeywords);
177900180201                If x >= 37;
178000180201                   x = x - %len(%trimr(DCLS.definition));
178100180201                   SplitLine(workDeclKeywords:overflowLine:x);
178200180201                   indentOffset = 37;
178300180201                EndIf;
178400180201
178500180201                If DCLS.definition = *Blanks and DCLS.type = *Blanks;
178600180201                   DCLS.definition = %trim(workDeclKeywords);
178700180201                Else;
178800180201                   DCLS.definition = %trimr(DCLS.definition) + ' '
178900180201                                   + %trim(workDeclKeywords);
179000180201                EndIf;
179100180201
179200180201                // Comment.
179300180201                If comment <> *Blanks;
179400180201                   If %subst(%trim(comment) + ' ':1:2) = '//';
179500180201                      DCLS.comment = '   ' + comment;
179600180201                   Else;
179700180201                      DCLS.comment = '// ' + comment;
179800180201                   EndIf;
179900180201                EndIf;
180000180201
180100180201                // Converted line...
180200180201                sourceLine = DCLS;
180300180201                If not inSpan;
180400180201                   savedName = *Blanks;
180500180201                EndIf;
180600180201
180700180201                //-------------------------------------------------------------------------
180800180201                // Constant Definition.
180900180201                //-------------------------------------------------------------------------
181000180201             ElseIf workDeclType = 'C';
181100180201                inDeclaration = *On;
181200180201
181300180201                Clear DCLS;
181400180201                If savedName <> *Blanks;
181500180201                   DCLS.decl = 'Dcl-C ';
181600180201                   %subst(DCLS:7) = %xlate(lo:up:savedName);
181700180201                EndIf;
181800180201
181900180201                // Keywords.
182000180201                If workDeclKeywords <> *Blanks;
182100180201                   If DCLS.definition = *Blanks;
182200180201                      DCLS.definition = %trim(workDeclKeywords);
182300180201                   Else;
182400180201                      DCLS.definition = %trimr(DCLS.definition) + ' '
182500180201                                      + %trim(workDeclKeywords);
182600180201                   EndIf;
182700180201                EndIf;
182800180201
182900180201                // Comment.
183000180201                If comment <> *Blanks;
183100180201                   If %subst(%trim(comment) + ' ':1:2) = '//';
183200180201                      DCLS.comment = '   ' + comment;
183300180201                   Else;
183400180201                      DCLS.comment = '// ' + comment;
183500180201                   EndIf;
183600180201                EndIf;
183700180201
183800180201                If not inSpan;
183900180201                   DCLS.definition = %trimr(DCLS.definition) + ';';
184000180201                   inDeclaration = *Off;
184100180201                Else;
184200180201                   inSpan = *Off;
184300180201                EndIf;
184400180201
184500180201                // Continuation of constant must start at left margin.
184600180201                If DCLS.decl = *Blanks;
184700180201                   DCLS = DCLS.definition;
184800180201                EndIf;
184900180201
185000180201                // Converted line...
185100180201                sourceLine = DCLS;
185200180201                If not inSpan;
185300180201                   savedName = *Blanks;
185400180201                EndIf;
185500180201
185600180201                //-------------------------------------------------------------------------
185700180201                // Prototype/Interface/Datastructure Definition.
185800180201                //-------------------------------------------------------------------------
185900180201             ElseIf workDeclType = 'PR'
186000180201                 or inPrototype
186100180201                 or workDeclType = 'PI'
186200180201                 or inInterface
186300180201                 or workDeclType = 'DS'
186400180201                 or inDatastructure;
186500180201                inDeclaration = *On;
186600180201                Clear DCLPR;
186700180201
186800180201                // Determine where to end the structure.
186900180201                If not inPrototype
187000180201                and not inInterface
187100180201                and not inDatastructure;
187200180201                   Exsr subUserGetEndLine;
187300180201                   If workDeclType = 'PR';
187400180201                      inPrototype = *On;
187500180201                   ElseIf workDeclType = 'PI';
187600180201                      inInterface = *On;
187700180201                   ElseIf workDeclType = 'DS';
187800180201                      inDatastructure = *On;
187900180201                      endDS = *On;
188000180201                   EndIf;
188100180201                   DCLPR.decl = 'Dcl-' + workDeclType;
188200180201                   If savedName = *Blanks;
188300180201                      savedName = '*N';
188400180201                   EndIf;
188500180201                   %subst(DCLPR:8) = savedName;
188600180201                   //DCLPR.procName = savedName;
188700180201                   endDeclType = workDeclType;
188800180201                   workDeclName = savedName;
188900180201                   If %scan('...':sourceLine) > 0;  // Long name!
189000180201                      workDeclAttr = *Blanks;
189100180201                   EndIf;
189200180201                Else;
189300180201                   If inPrototype
189400180201                   and savedName = *Blanks
189500180201                   and declType = *Blanks
189600180201                   and not inExtProc
189700180201                   and not inSpan;
189800180201                      savedName = '*N';
189900180201                   EndIf;
190000180201
190100180201                   If savedName <> '**';
190200180201                      DCLPR.fieldName = savedName;
190300180201                   EndIf;
190400180201                EndIf;
190500180201
190600180201                // Type.
190700180201                If workDeclAttr = *Blanks
190800180201                and DCLPR.type = *Blanks;
190900180201                   If declLen = *Blanks;
191000180201                      // No definition (probably in keywords - e.g. LIKE()).
191100180201                   ElseIf declScale = *Blanks;
191200180201                      workDeclAttr = 'A';
191300180201                   Else;
191400180201                      If inDatastructure;
191500180201                         workDeclAttr = 'S';
191600180201                      Else;
191700180201                         workDeclAttr = 'P';
191800180201                      EndIf;
191900180201                   EndIf;
192000180201                EndIf;
192100180201
192200180201                If workDeclAttr = *Blanks;
192300180201                   // No definition (probably in keywords - e.g. LIKE()).
192400180201                ElseIf workDeclAttr = 'A';
192500180201                   If DCLPR.decl = 'Dcl-DS';
192600180201                      If declLen <> *Blanks;
192700180201                         DCLPR.type = '      Len';
192800180201                      EndIf;
192900180201                   Else;
193000180201                      x = %scan('VARYING':%xlate(lo:up:workDeclKeywords));
193100180201                      If x > 0;
193200180201                         DCLPR.type = '  VarChar';
193300180201                         If x = 1;
193400180201                            workDeclKeywords = %subst(workDeclKeywords:x+7);
193500180201                         Else;
193600180201                            workDeclKeywords = %subst(workDeclKeywords:1:x-1)
193700180201                                         + %subst(workDeclKeywords:x+7);
193800180201                         EndIf;
193900180201                      Else;
194000180201                         DCLPR.type = '     Char';
194100180201                      EndIf;
194200180201                   EndIf;
194300180201                ElseIf workDeclAttr = 'P';
194400180201                   DCLPR.type = '   Packed';
194500180201                ElseIf workDeclAttr = 'D';
194600180201                   DCLPR.type = '     Date';
194700180201                   x = %scan('DATFMT':%xlate(lo:up:workDeclKeywords));
194800180201                   If x > 0;
194900180201                      x = %scan('(':workDeclKeywords:x);
195000180201                      y = %scan(')':workDeclKeywords:x);
195100180201                      DCLPR.definition = '('
195200180201                                + %subst(workDeclKeywords:x+1:y-x-1)
195300180201                                + ')';
195400180201                      workDeclKeywords = %subst(workDeclKeywords:y+1);
195500180201                   EndIf;
195600180201                ElseIf workDeclAttr = 'T';
195700180201                   DCLPR.type = '     Time';
195800180201                   x = %scan('TIMFMT':%xlate(lo:up:workDeclKeywords));
195900180201                   If x > 0;
196000180201                      x = %scan('(':workDeclKeywords:x);
196100180201                      y = %scan(')':workDeclKeywords:x);
196200180201                      DCLPR.definition = '('
196300180201                                + %subst(workDeclKeywords:x+1:y-x-1)
196400180201                                + ')';
196500180201                      workDeclKeywords = %subst(workDeclKeywords:y+1);
196600180201                   EndIf;
196700180201                ElseIf workDeclAttr = 'Z';
196800180201                   DCLPR.type = 'TimeStamp';
196900180201                ElseIf workDeclAttr = 'I';
197000180201                   DCLPR.type = '      Int';
197100180201                ElseIf workDeclAttr = 'S';
197200180201                   DCLPR.type = '    Zoned';
197300180201                ElseIf workDeclAttr = 'N';
197400180201                   DCLPR.type = '      Ind';
197500180201                ElseIf workDeclAttr = '*';
197600180201                   DCLPR.type = '  Pointer';
197700180201                ElseIf workDeclAttr = 'B';
197800180201                   DCLPR.type = '   BinDec';
197900180201                ElseIf workDeclAttr = 'G';
198000180201                   x = %scan('VARYING':%xlate(lo:up:workDeclKeywords));
198100180201                   If x > 0;
198200180201                      DCLPR.type = ' VarGraph';
198300180201                      workDeclKeywords = %subst(workDeclKeywords:x+7);
198400180201                   Else;
198500180201                      DCLPR.type = '    Graph';
198600180201                   EndIf;
198700180201                Else;
198800180201                   inDeclaration = *Off;
198900180201                   convert = *Off;
199000180201                   LeaveSr;
199100180201                EndIf;
199200180201
199300180201                // Attributes.
199400180201                If workDeclAttr <> '*'
199500180201                and workDeclAttr <> 'N'
199600180201                and workDeclAttr <> 'D'
199700180201                and workDeclAttr <> 'T'
199800180201                and workDeclAttr <> 'Z'
199900180201                and workDeclAttr <> *Blank
200000180201                and DCLPR.type <> *Blanks;
200100180201                   DCLPR.definition = '(';
200200180201                   If inDatastructure and declFrom <> *Blanks;
200300180201                      workLength = %dec(%trim(declLen):7:0)
200400180201                                 - %dec(%trim(declFrom):7:0) + 1;
200500180201                      If workDeclAttr = 'B';
200600180201                         workLength = workLength * 2;
200700180201                      ElseIf workDeclAttr = 'P';
200800180201                         workLength = (workLength * 2) - 1;
200900180201                      EndIf;
201000180201                      AdjustArrayLength(workLength);
201100180201                      DCLPR.definition = %trim(DCLPR.definition)
201200180201                                       + %char(workLength);
201300180201                   Else;
201400180201                      DCLPR.definition = %trim(DCLPR.definition)
201500180201                                       + %trim(declLen);
201600180201                   EndIf;
201700180201
201800180201                   If declScale <> *Blanks;
201900180201                      DCLPR.definition = %trimr(DCLPR.definition)
202000180201                                      + ':' + %trim(declScale);
202100180201                   EndIf;
202200180201                   DCLPR.definition = %trimr(DCLPR.definition) + ')';
202300180201                EndIf;
202400180201
202500180201                // From specified?
202600180201                If inDatastructure;
202700180201                   If declFrom <> *Blanks
202800180201                   and %scan('...':declOptions) = 0;
202900180201                      If %subst(declFrom:1:1) = '*';
203000180201                         workDeclKeywords = %trim(declFrom) + ' ';
203100180201                      Else;
203200180201                      workDeclKeywords = 'Pos(' + %trim(declFrom) + ') '
203300180201                                   + workDeclKeywords;
203400180201                      EndIf;
203500180201                   Else;
203600180201                      // Overlay specified using the base datastructure name?
203700180201                      // This is not permitted in free-form, so convert it to 'POS'.
203800180201                      x = %scan('OVERLAY(':%xlate(lo:up:workDeclKeywords));
203900180201                      If x > 0;
204000180201                         i = %scan(':':workDeclKeywords:x);
204100180201                         If i > 0;
204200180201                            If %trim(%xlate(lo:up
204300180201                                    :%subst(workDeclKeywords:x+8:i-x-8))) =
204400180201                               %xlate(lo:up:workDeclName);
204500180201                               j = %scan(')':workDeclKeywords:i);
204600180201                               If j > 0;
204700180201                                  If x = 1;
204800180201                                     workDeclKeywords
204900180201                                      = 'Pos('
205000180201                                     + %trim(%subst(workDeclKeywords:i+1:j-i-1))
205100180201                                     + %subst(workDeclKeywords:j);
205200180201                                  Else;
205300180201                                     workDeclKeywords
205400180201                                       = %trim(%subst(workDeclKeywords:1:x-1))
205500180201                                       + ' Pos('
205600180201                                     + %trim(%subst(workDeclKeywords:i+1:j-i-1))
205700180201                                     + %subst(workDeclKeywords:j);
205800180201                                  EndIf;
205900180201                               EndIf;
206000180201                            EndIf;
206100180201                         EndIf;
206200180201                      EndIf;
206300180201                   EndIf;
206400180201                   // Require End-DS?
206500180201                   x = %scan('LIKEDS(':%xlate(lo:up:workDeclKeywords));
206600180201                   If x = 0;
206700180201                      x = %scan('LIKEREC(':%xlate(lo:up:workDeclKeywords));
206800180201                   EndIf;
206900180201                   If x > 0;
207000180201                      // Nope.
207100180201                      endDS = *Off;
207200180201                   EndIf;
207300180201
207400180201                   // Datastructure type?
207500180201                   If declPrefix = 'S';       // Program Status
207600180201                      workDeclKeywords = 'PSDS ' + workDeclKeywords;
207700180201                      If savedName = DCLPR.procName;
207800180201                         %subst(savedName:16:1) = *Blank;
207900180201                      EndIf;
208000180201                      %subst(DCLPR.procName:16:1) = *Blank;
208100180201
208200180201                   ElseIf declPrefix = 'U';   // Dataarea
208300180201                      // If not already defined as a data area, do it now.
208400180201                      If %scan('DTAARA':%xlate(lo:up:workDeclKeywords)) = 0;
208500180201                         If declName = *Blanks;
208600180201                            workDeclKeywords = 'DTAARA(*AUTO) '
208700180201                                                         + workDeclKeywords;
208800180201                         Else;
208900180201                            workDeclKeywords = 'DTAARA ' + workDeclKeywords;
209000180201                         EndIf;
209100180201                      EndIf;
209200180201                      %subst(DCLPR.procName:16:1) = *Blank;
209300180201                   EndIf;
209400180201                EndIf;
209500180201
209600180201                // Keywords.
209700180201                If workDeclKeywords <> *Blanks;
209800180201                   // ExtProc name has extended to a second line.
209900180201                   If inExtProc;
210000180201                      // Continuation of name must start at left margin.
210100180201                      DCLPR = workDeclKeywords;
210200180201                      workDeclKeywords = *Blanks;
210300180201                      inExtProc = *Off;
210400180201                   EndIf;
210500180201
210600180201                   // Expand EXTNAME?
210700180201                   x = %scan('EXTNAME(':%xlate(lo:up:workDeclKeywords));
210800180201                   If x > 0;
210900180201                      i = %scan(')':workDeclKeywords:x+1);
211000180201                      If i > 0;
211100180201                         If %scan('''':%subst(workDeclKeywords:x+8:i-x-8)) = 0;
211200180201                            workDeclKeywords = %subst(workDeclKeywords:1:x+7)
211300180201                               + ''''
211400180201                       + %xlate(lo:up:%trim(%subst(workDeclKeywords:x+8:i-x-8)))
211500180201                               + ''''
211600180201                               + %subst(workDeclKeywords:i);
211700180201                         EndIf;
211800180201                      EndIf;
211900180201                   EndIf;
212000180201
212100180201                   // Expand DTAARA?
212200180201                   x = %scan('DTAARA(':%xlate(lo:up:workDeclKeywords));
212300180201                   If x > 0;
212400180201                      i = %scan(')':workDeclKeywords:x+1);
212500180201                      If i > 0;
212600180201                         If %scan('''':%subst(workDeclKeywords:x+7:i-x-7)) = 0;
212700180201                            workDeclKeywords = %subst(workDeclKeywords:1:x+6)
212800180201                               + ''''
212900180201                       + %xlate(lo:up:%trim(%subst(workDeclKeywords:x+7:i-x-7)))
213000180201                               + ''''
213100180201                               + %subst(workDeclKeywords:i);
213200180201                         EndIf;
213300180201                      EndIf;
213400180201                   EndIf;
213500180201
213600180201                   // EXTPROC?
213700180201                   x = %scan('EXTPROC(':%xlate(lo:up:workDeclKeywords));
213800180201                   If x > 0;
213900180201                      i = %scan(')':workDeclKeywords:x+1);
214000180201                      If i = 0;
214100180201                         // Name extends onto next line.
214200180201                         inExtProc = *On;
214300180201                      EndIf;
214400180201                   EndIf;
214500180201                EndIf;
214600180201
214700180201                // Terminate the line?
214800180201                If not inSpan;
214900180201                   If workDeclKeywords = *Blanks and DCLPR.type = *Blanks;
215000180201                      DCLPR.procName = %trimr(DCLPR.procName) + ';';
215100180201                   ElseIf workDeclKeywords = *Blanks;
215200180201                      DCLPR.definition = %trimr(DCLPR.definition) + ';';
215300180201                   Else;
215400180201                      workDeclKeywords = %trimr(workDeclKeywords) + ';';
215500180201                   EndIf;
215600180201                   inDeclaration = *Off;
215700180201                   savedName = *Blanks;
215800180201                Else;
215900180201                   inSpan = *Off;
216000180201                EndIf;
216100180201
216200180201                // Have we encroached on the comments?
216300180201                x = %len(%trimr(DCLPR.definition)) + %len(workDeclKeywords);
216400180201                If x >= 37;
216500180201                   x = x - %len(%trimr(DCLPR.definition));
216600180201                   SplitLine(workDeclKeywords:overflowLine:x);
216700180201                   indentOffset = 37;
216800180201                EndIf;
216900180201
217000180201                If DCLPR.definition = *Blanks and DCLPR.type = *Blanks;
217100180201                   DCLPR.definition = %trim(workDeclKeywords);
217200180201                Else;
217300180201                   DCLPR.definition = %trimr(DCLPR.definition) + ' '
217400180201                                   + %trim(workDeclKeywords);
217500180201                EndIf;
217600180201
217700180201                // Comment.
217800180201                If comment <> *Blanks;
217900180201                   If %subst(%trim(comment) + ' ':1:2) = '//';
218000180201                      DCLPR.comment = '   ' + comment;
218100180201                   Else;
218200180201                      DCLPR.comment = '// ' + comment;
218300180201                   EndIf;
218400180201                EndIf;
218500180201
218600180201                // Converted line...
218700180201                sourceLine = DCLPR;
218800180201                If not inSpan and savedName <> *Blanks;
218900180201                   savedName = '**';
219000180201                EndIf;
219100180201
219200180201                //-------------------------------------------------------------------------
219300180201                // Unsupported.
219400180201                //-------------------------------------------------------------------------
219500180201             Else;
219600180201                inDeclaration = *Off;
219700180201                convert = *Off;
219800180201                LeaveSr;
219900180201             EndIf;
220000180201
220100180201             //-------------------------------------------------------------------------
220200180201             // Second+ line of declaration.
220300180201             //-------------------------------------------------------------------------
220400180201          Else;
220500180201             Clear DCLS;
220600180201             DCLS.definition = %trim(workDeclKeywords);
220700180201             If not inSpan;
220800180201                DCLS.definition = %trim(DCLS.definition) + ';';
220900180201             EndIf;
221000180201             sourceLine = DCLS;
221100180201             inSpan = *Off;
221200180201          EndIf;
221300180201
221400180201          convert = *On;
221500180201
221600180201       EndSr;
221700180201       //-------------------------------------------------------------------------------------------
221800180201
221900180201      /Eject
222000180201       //-------------------------------------------------------------------------------------------
222100180201       // Convert file spec to free-format.
222200180201       //-------------------------------------------------------------------------------------------
222300180201       BegSr subUserConvertF_Spec;
222400180201
222500180201          // Keep blank lines.
222600180201          If codeLine = *Blanks;
222700180201             sourceLine = *Blanks;
222800180201             convert = *On;
222900180201             LeaveSr;
223000180201          EndIf;
223100180201
223200180201          sourceLine = fullLine;
223300180201
223400180201          workFileUsage  = %xlate(lo:up:fileUsage);
223500180201          workFileDesig  = %xlate(lo:up:fileDesig);
223600180201          workFileAdd    = %xlate(lo:up:fileAdd);
223700180201          workFileDevice = %xlate(lo:up:fileDevice);
223800180201          workFileKeyed  = %xlate(lo:up:fileKeyed);
223900180201
224000180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
224100180201
224200180201          If not inDeclaration;
224300180201
224400180201             // Validate whether this can be converted.
224500180201             If workFileUsage = 'I'
224600180201             and (workFileDesig = 'P'
224700180201             or workFileDesig = 'S'
224800180201             or workFileUsage = 'T')
224900180201
225000180201             or workFileUsage = 'O'
225100180201             and workFileAdd = 'A'
225200180201
225300180201             or workFileUsage = 'U'
225400180201             and (workFileDesig = 'P'
225500180201             or workFileDesig = 'S')
225600180201
225700180201             or workFileUsage = 'C'
225800180201             and workFileDesig = 'T';
225900180201
226000180201                // Not supported in free-form.
226100180201                inDeclaration = *Off;
226200180201                convert = *Off;
226300180201                nonConvRsn = 'File usage not supported in free-form';
226400180201                LeaveSr;
226500180201             EndIf;
226600180201
226700180201             savedName = %trim(fileName);
226800180201
226900180201             If %xlate(lo:up:fileExternal) = 'E';       // Externally-described file.
227000180201                inDeclaration = *On;
227100180201
227200180201                Clear DCLF;
227300180201                DCLF.decl = 'Dcl-F ';
227400180201                %subst(DCLF:7) = %xlate(lo:up:savedName);
227500180201
227600180201                // Set device type.
227700180201                If workFileDevice <> 'DISK';
227800180201                   DCLF.device = workFileDevice;
227900180201                EndIf;
228000180201
228100180201                // Set usage.
228200180201                If workFileUsage = 'I';
228300180201                   If workFileAdd = ' ';
228400180201                      If workFileDevice <> 'DISK'
228500180201                      and workFileDevice <> 'SEQ'
228600180201                      and workFileDevice <> 'SPECIAL';
228700180201                         DCLF.definition = '*INPUT';
228800180201                      EndIf;
228900180201                   Else;
229000180201                      DCLF.definition = '*INPUT:*OUTPUT';
229100180201                   EndIf;
229200180201                ElseIf workFileUsage = 'U';
229300180201                   If workFileAdd = ' ';
229400180201                      DCLF.definition = '*UPDATE:*DELETE';
229500180201                   Else;
229600180201                      DCLF.definition = '*UPDATE:*DELETE:*OUTPUT';
229700180201                   EndIf;
229800180201                ElseIf workFileUsage = 'O';
229900180201                   If workFileDevice <> 'PRINTER';
230000180201                      DCLF.definition = '*OUTPUT';
230100180201                   EndIf;
230200180201                ElseIf workFileUsage = 'C';
230300180201                   If workFileDevice <> 'WORKSTN';
230400180201                      DCLF.definition = '*INPUT:*OUTPUT';
230500180201                   EndIf;
230600180201                EndIf;
230700180201
230800180201                // Pad out usage.
230900180201                If DCLF.definition <> *Blanks;
231000180201                   DCLF.definition = 'Usage(' + %trim(DCLF.definition) + ')';
231100180201                EndIf;
231200180201
231300180201                // Keyed file?
231400180201                If workFileKeyed = 'K';
231500180201                   DCLF.definition = %trim(%trim(DCLF.definition)
231600180201                                           + ' ' + 'Keyed');
231700180201                EndIf;
231800180201
231900180201                If comment <> *Blanks;
232000180201                   If %subst(%trim(comment):1:2) = '//';
232100180201                      DCLF.comment = '   ' + comment;
232200180201                   Else;
232300180201                      DCLF.comment = '// ' + comment;
232400180201                   EndIf;
232500180201                EndIf;
232600180201
232700180201                // Keywords.
232800180201                If fileKeyWords <> *Blanks;
232900180201                   // Do we have room to insert the keywords here?
233000180201                   checkLength = %len(%trim(%trim(DCLF.definition)
233100180201                                           + ' ' + %trim(fileKeyWords))) + 1;
233200180201
233300180201                   If comment <> *Blanks;
233400180201                      checkLength += 3;
233500180201                   EndIf;
233600180201
233700180201                   If checkLength > %len(DCLF.definition);
233800180201                      // Not enoungh room for the keywords, so output the current line.
233900180201                      savedSRCDTA = SRCDTA;
234000180201                      lineType = *Blank;
234100180201                      directive = *Blanks;
234200180201                      codeLine = DCLF;
234300180201                      Exsr subUserWriteLine;
234400180201                      SRCDTA = savedSRCDTA;
234500180201                      // ...and move the keywords to their own line.
234600180201                      Clear DCLF;
234700180201                      DCLF.definition = fileKeywords;
234800180201                      savedComment = *Blanks;
234900180201                   Else;
235000180201                      DCLF.definition = %trim(%trim(DCLF.definition)
235100180201                                              + ' ' + %trim(fileKeyWords));
235200180201                   EndIf;
235300180201                EndIf;
235400180201
235500180201                If not inSpan;
235600180201                   DCLF.definition = %trimr(DCLF.definition) + ';';
235700180201                   inDeclaration = *Off;
235800180201                Else;
235900180201                   inSpan = *Off;
236000180201                EndIf;
236100180201
236200180201                // Converted line...
236300180201                sourceLine = DCLF;
236400180201
236500180201             Else;
236600180201                inDeclaration = *Off;
236700180201                convert = *Off;
236800180201                nonConvRsn = 'File not externally-described';
236900180201                LeaveSr;
237000180201             EndIf;
237100180201
237200180201          Else;                   // Second+ line of declaration
237300180201             Clear DCLF;
237400180201             DCLF.definition = %trim(fileKeyWords);
237500180201             If not inSpan;
237600180201                DCLF.definition = %trim(DCLF.definition) + ';';
237700180201             EndIf;
237800180201             sourceLine = DCLF;
237900180201             inSpan = *Off;
238000180201          EndIf;
238100180201
238200180201          convert = *On;
238300180201
238400180201       EndSr;
238500180201       //-------------------------------------------------------------------------------------------
238600180201
238700180201      /Eject
238800180201       //-------------------------------------------------------------------------------------------
238900180201       // Convert Header spec to free-format.
239000180201       //-------------------------------------------------------------------------------------------
239100180201       BegSr subUserConvertH_Spec;
239200180201
239300180201          // Keep blank lines.
239400180201          If codeLine = *Blanks;
239500180201             sourceLine = *Blanks;
239600180201             convert = *On;
239700180201             LeaveSr;
239800180201          EndIf;
239900180201
240000180201          sourceLine = codeLine;
240100180201
240200180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
240300180201
240400180201          If not inDeclaration;
240500180201             inDeclaration = *On;
240600180201
240700180201             Clear DCLH;
240800180201             DCLH.decl = 'Ctl-Opt ';
240900180201             DCLH.options = %trim(declOptions);
241000180201
241100180201             If comment <> *Blanks;
241200180201                If %subst(%trim(comment):1:2) = '//';
241300180201                   DCLH.comment = '   ' + comment;
241400180201                Else;
241500180201                   DCLH.comment = '// ' + comment;
241600180201                EndIf;
241700180201             EndIf;
241800180201
241900180201             If not inSpan;
242000180201                DCLH.options = %trimr(DCLH.options) + ';';
242100180201                inDeclaration = *Off;
242200180201             Else;
242300180201                inSpan = *Off;
242400180201             EndIf;
242500180201
242600180201             // Converted line...
242700180201             sourceLine = DCLH;
242800180201
242900180201          Else;                   // Second+ line of declaration
243000180201             Clear DCLH;
243100180201             DCLH.options = %trim(declOptions);
243200180201             If not inSpan;
243300180201                DCLH.options = %trim(DCLH.options) + ';';
243400180201             EndIf;
243500180201             sourceLine = DCLH;
243600180201             inSpan = *Off;
243700180201          EndIf;
243800180201
243900180201          convert = *On;
244000180201
244100180201       EndSr;
244200180201       //-------------------------------------------------------------------------------------------
244300180201
244400180201      /Eject
244500180201       //-------------------------------------------------------------------------------------------
244600180201       // Convert procedure declaration to free-format?
244700180201       //-------------------------------------------------------------------------------------------
244800180201       BegSr subUserConvertP_Spec;
244900180201
245000180201          // Keep blank lines.
245100180201          If codeLine = *Blanks;
245200180201             sourceLine = *Blanks;
245300180201             convert = *On;
245400180201             LeaveSr;
245500180201          EndIf;
245600180201
245700180201          sourceLine = fullLine;
245800180201
245900180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
246000180201
246100180201          If not inDeclaration;   // First line of procedure start/end.
246200180201             If not inDeclaration;
246300180201                //Exsr subUserGetDeclarationType;
246400180201                GetDeclarationType(workDeclType:savedName:workDeclLine);
246500180201             EndIf;
246600180201
246700180201             If workDeclType = 'B'       // Begin.
246800180201             or workDeclType = 'E'       // End.
246900180201             or declName <> *Blanks;
247000180201                inDeclaration = *On;
247100180201
247200180201                Clear DCLP;
247300180201                //            If savedName <> *Blanks;
247400180201                If workDeclType = 'B';
247500180201                   DCLP.decl = 'Dcl-Proc ';
247600180201                Else;
247700180201                   DCLP.decl = 'End-Proc ';
247800180201                EndIf;
247900180201                DCLP.definition = savedName;
248000180201                //            EndIf;
248100180201
248200180201                If procKeyWords <> *Blanks;
248300180201                   DCLP.definition = %trimr(DCLP.definition)
248400180201                                   + ' ' + %trim(procKeyWords);
248500180201                EndIf;
248600180201
248700180201                If comment <> *Blanks;
248800180201                   If %subst(%trim(comment):1:2) = '//';
248900180201                      DCLP.comment = '   ' + comment;
249000180201                   Else;
249100180201                      DCLP.comment = '// ' + comment;
249200180201                   EndIf;
249300180201                EndIf;
249400180201
249500180201                If not inSpan;
249600180201                   DCLP.definition = %trimr(DCLP.definition) + ';';
249700180201                   inDeclaration = *Off;
249800180201                Else;
249900180201                   inSpan = *Off;
250000180201                EndIf;
250100180201
250200180201                // Converted line...
250300180201                sourceLine = DCLP;
250400180201                savedName = *Blanks;
250500180201
250600180201             Else;
250700180201                inDeclaration = *Off;
250800180201                convert = *Off;
250900180201                LeaveSr;
251000180201             EndIf;
251100180201
251200180201          Else;                   // Second+ line of procedure start/end.
251300180201             Clear DCLP;
251400180201             DCLP.definition = %trim(declKeyWords);
251500180201             If not inSpan;
251600180201                DCLP.definition = %trimr(DCLP.definition) + ';';
251700180201             EndIf;
251800180201             sourceLine = DCLP;
251900180201             inSpan = *Off;
252000180201          EndIf;
252100180201
252200180201          convert = *On;
252300180201
252400180201       EndSr;
252500180201       //-------------------------------------------------------------------------------------------
252600180201
252700180201      /Eject
252800180201       //-------------------------------------------------------------------------------------------
252900180201       // Set Resulting Indicators.
253000180201       //-------------------------------------------------------------------------------------------
253100180201       BegSr subUserSetIndicators;
253200180201
253300180201          //-----------------------------------------------------------------------
253400180201          // Scan found.
253500180201          If foundCheck;
253600180201             Clear nonPrefix;
253700180201
253800180201             codeLine = '*IN' + foundInd + ' = %found();';
253900180201             Exsr subUserReformatLine;
254000180201
254100180201             foundCheck = *Off;
254200180201          EndIf;
254300180201
254400180201          //-----------------------------------------------------------------------
254500180201          // Error indicator check.
254600180201          If ERRCheck;
254700180201             Clear nonPrefix;
254800180201
254900180201             codeLine = '*IN' + ERRInd + ' = %error();';
255000180201             Exsr subUserReformatLine;
255100180201
255200180201             ERRCheck = *Off;
255300180201          EndIf;
255400180201
255500180201          //-----------------------------------------------------------------------
255600180201          // Record not found check.
255700180201          If NRFCheck;
255800180201             Clear nonPrefix;
255900180201
256000180201             codeLine = '*IN' + NRFInd + ' = not %found();';
256100180201             Exsr subUserReformatLine;
256200180201
256300180201             NRFCheck = *Off;
256400180201          EndIf;
256500180201
256600180201          //-----------------------------------------------------------------------
256700180201          // End of File check.
256800180201          If EOFCheck;
256900180201             Clear nonPrefix;
257000180201
257100180201             codeLine = '*IN' + EOFInd + ' = %eof();';
257200180201             Exsr subUserReformatLine;
257300180201
257400180201             EOFCheck = *Off;
257500180201          EndIf;
257600180201
257700180201          //-----------------------------------------------------------------------
257800180201          // Matching Key check.
257900180201          If equalCheck;
258000180201             Clear nonPrefix;
258100180201
258200180201             codeLine = '*IN' + equalInd + ' = %equal();';
258300180201             Exsr subUserReformatLine;
258400180201
258500180201             equalCheck = *Off;
258600180201          EndIf;
258700180201
258800180201          //-----------------------------------------------------------------------
258900180201          // Perform SETOFF / SETON Expansion.
259000180201          If setOff;
259100180201             Clear nonPrefix;
259200180201             If setOffInd1 <> *Blanks;
259300180201                codeLine = '*IN' + setOffInd1 + ' = *Off;';
259400180201                Exsr subUserReformatLine;
259500180201             EndIf;
259600180201             If setOffInd2 <> *Blanks;
259700180201                codeLine = '*IN' + setOffInd2 + ' = *Off;';
259800180201                Exsr subUserReformatLine;
259900180201             EndIf;
260000180201             If setOffInd3 <> *Blanks;
260100180201                codeLine = '*IN' + setOffInd3 + ' = *Off;';
260200180201                Exsr subUserReformatLine;
260300180201             EndIf;
260400180201             setOff = *Off;
260500180201          EndIf;
260600180201          If setOn;
260700180201             Clear nonPrefix;
260800180201             If setOnInd1 <> *Blanks;
260900180201                codeLine = '*IN' + setOnInd1 + ' = *On;';
261000180201                Exsr subUserReformatLine;
261100180201             EndIf;
261200180201             If setOnInd2 <> *Blanks;
261300180201                codeLine = '*IN' + setOnInd2 + ' = *On;';
261400180201                Exsr subUserReformatLine;
261500180201             EndIf;
261600180201             If setOnInd3 <> *Blanks;
261700180201                codeLine = '*IN' + setOnInd3 + ' = *On;';
261800180201                Exsr subUserReformatLine;
261900180201             EndIf;
262000180201             setOn = *Off;
262100180201          EndIf;
262200180201
262300180201          //-----------------------------------------------------------------------
262400180201          // Resulting indicators...
262500180201
262600180201          // Turn off all specified indicators first.
262700180201          If HICheck;
262800180201             Clear nonPrefix;
262900180201             codeLine = '*IN' + HIInd + ' = *Off;';
263000180201             Exsr subUserReformatLine;
263100180201          EndIf;
263200180201          If LWCheck;
263300180201             Clear nonPrefix;
263400180201             codeLine = '*IN' + LWInd + ' = *Off;';
263500180201             Exsr subUserReformatLine;
263600180201          EndIf;
263700180201          If EQCheck;
263800180201             Clear nonPrefix;
263900180201             codeLine = '*IN' + EQInd + ' = *Off;';
264000180201             Exsr subUserReformatLine;
264100180201          EndIf;
264200180201
264300180201          // And now turn on those specified accordingly.
264400180201
264500180201          // HI check.
264600180201          If HICheck;
264700180201             Clear nonPrefix;
264800180201
264900180201             codeLine = 'If ' + %trim(HIFactor1) + ' > '
265000180201                      + %trim(HIFactor2) + ';';
265100180201             Exsr subUserReformatLine;
265200180201             codeLine = '*IN' + HIInd + ' = *On;';
265300180201             Exsr subUserReformatLine;
265400180201             codeLine = 'EndIf;';
265500180201             Exsr subUserReformatLine;
265600180201
265700180201             HICheck = *Off;
265800180201          EndIf;
265900180201
266000180201          // LO check.
266100180201          If LWCheck;
266200180201             Clear nonPrefix;
266300180201
266400180201             codeLine = 'If ' + %trim(LWFactor1) + ' < '
266500180201                      + %trim(LWFactor2) + ';';
266600180201             Exsr subUserReformatLine;
266700180201             codeLine = '*IN' + LWInd + ' = *On;';
266800180201             Exsr subUserReformatLine;
266900180201             codeLine = 'EndIf;';
267000180201             Exsr subUserReformatLine;
267100180201
267200180201             LWCheck = *Off;
267300180201          EndIf;
267400180201
267500180201          // EQ check.
267600180201          If EQCheck;
267700180201             Clear nonPrefix;
267800180201
267900180201             codeLine = 'If ' + %trim(EQFactor1) + ' = '
268000180201                      + %trim(EQFactor2) + ';';
268100180201             Exsr subUserReformatLine;
268200180201             codeLine = '*IN' + EQInd + ' = *On;';
268300180201             Exsr subUserReformatLine;
268400180201             codeLine = 'EndIf;';
268500180201             Exsr subUserReformatLine;
268600180201
268700180201             EQCheck = *Off;
268800180201          EndIf;
268900180201
269000180201       EndSr;
269100180201       //-------------------------------------------------------------------------------------------
269200180201
269300180201      /Eject
269400180201       //-------------------------------------------------------------------------------------------
269500180201       // Convert ACQ.
269600180201       //-------------------------------------------------------------------------------------------
269700180201       BegSr subUserCvt_ACQ;
269800180201
269900180201          sourceLine = %trim(operator) + ' ' + %trim(factor1)
270000180201                     + ' ' + %trim(factor2) + ';';
270100180201
270200180201          // Set resulting indicators?
270300180201          If lw <> *Blanks;
270400180201             ERRCheck = *On;
270500180201             ERRInd = lw;
270600180201          EndIf;
270700180201
270800180201          convert = *On;
270900180201
271000180201       EndSr;
271100180201       //-------------------------------------------------------------------------------------------
271200180201
271300180201      /Eject
271400180201       //-------------------------------------------------------------------------------------------
271500180201       // Convert ADD.
271600180201       //-------------------------------------------------------------------------------------------
271700180201       BegSr subUserCvt_ADD;
271800180201
271900180201          // Half-adjust?
272000180201          x = %scan('H':operator:4);
272100180201          If x > 0;
272200180201             sourceLine = 'Eval(H)';
272300180201          Else;
272400180201             sourceLine = *Blanks;
272500180201          EndIf;
272600180201
272700180201          If factor1 = *Blanks;
272800180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
272900180201                        + ' = ' + %trim(result)
273000180201                        + ' + ' + %trim(factor2) +';';
273100180201          Else;
273200180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
273300180201                        + ' = ' + %trim(factor1)
273400180201                        + ' + ' + %trim(factor2) + ';';
273500180201          EndIf;
273600180201
273700180201          sourceLine = %trim(sourceLine);
273800180201
273900180201          convert = *On;
274000180201
274100180201       EndSr;
274200180201       //-------------------------------------------------------------------------------------------
274300180201
274400180201      /Eject
274500180201       //-------------------------------------------------------------------------------------------
274600180201       // Convert ADDDUR.
274700180201       //-------------------------------------------------------------------------------------------
274800180201       BegSr subUserCvt_ADDDUR;
274900180201
275000180201          // Split out duration and code.
275100180201          x = %scan(':':factor2);
275200180201          If x = 0;
275300180201             nonConvRsn =  'No duration code specified.';
275400180201             LeaveSr;
275500180201          EndIf;
275600180201
275700180201          durDuration = %trim(%subst(factor2:1:x-1));
275800180201          durCode     = %xlate(lo:up:%trim(%subst(factor2:x+1)));
275900180201
276000180201          Select;
276100180201             When durCode = '*Y' or durCode = '*YEARS';
276200180201                durCode = '%years';
276300180201             When durCode = '*M' or durCode = '*MONTHS';
276400180201                durCode = '%months';
276500180201             When durCode = '*D' or durCode = '*DAYS';
276600180201                durCode = '%days';
276700180201             When durCode = '*H' or durCode = '*HOURS';
276800180201                durCode = '%hours';
276900180201             When durCode = '*MN' or durCode = '*MINUTES';
277000180201                durCode = '%minutes';
277100180201             When durCode = '*S' or durCode = '*SECONDS';
277200180201                durCode = '%seconds';
277300180201             When durCode = '*MS' or durCode = '*MSECONDS';
277400180201                durCode = '%mseconds';
277500180201             Other;
277600180201                nonConvRsn = 'Invalid duration code specified.';
277700180201                LeaveSr;
277800180201          EndSl;
277900180201
278000180201          If factor1 = *Blanks;
278100180201             sourceLine = %trim(result) + ' = ' + %trim(result);
278200180201          Else;
278300180201             sourceLine = %trim(result) + ' = ' + %trim(factor1);
278400180201          EndIf;
278500180201
278600180201          sourceLine = %trimr(sourceLine) + ' + ' + %trim(durCode)
278700180201                     + '(' + %trim(durDuration) + ');';
278800180201
278900180201          // Set resulting indicators?
279000180201          If lw <> *Blanks;
279100180201             ERRCheck = *On;
279200180201             ERRInd = lw;
279300180201          EndIf;
279400180201
279500180201          convert = *On;
279600180201
279700180201       EndSr;
279800180201       //-------------------------------------------------------------------------------------------
279900180201
280000180201      /Eject
280100180201       //-------------------------------------------------------------------------------------------
280200180201       // Convert ALLOC.
280300180201       //-------------------------------------------------------------------------------------------
280400180201       BegSr subUserCvt_ALLOC;
280500180201
280600180201          sourceLine = %trim(result) + ' = %alloc(' + %trim(factor2) + ');';
280700180201
280800180201          // Set resulting indicators?
280900180201          If lw <> *Blanks;
281000180201             ERRCheck = *On;
281100180201             ERRInd = lw;
281200180201          EndIf;
281300180201
281400180201          convert = *On;
281500180201
281600180201       EndSr;
281700180201       //-------------------------------------------------------------------------------------------
281800180201
281900180201      /Eject
282000180201       //-------------------------------------------------------------------------------------------
282100180201       // Convert BEGSR.
282200180201       //-------------------------------------------------------------------------------------------
282300180201       BegSr subUserCvt_BEGSR;
282400180201
282500180201          sourceLine = 'BegSr ' + %trim(factor1) + ';';
282600180201
282700180201          convert = *On;
282800180201
282900180201       EndSr;
283000180201       //-------------------------------------------------------------------------------------------
283100180201
283200180201      /Eject
283300180201       //-------------------------------------------------------------------------------------------
283400180201       // Convert CALLP.
283500180201       //-------------------------------------------------------------------------------------------
283600180201       BegSr subUserCvt_CALLP;
283700180201
283800180201          // Returning for a multi-line CALLP - restore the original opcode.
283900180201          If inCallP;
284000180201             operator = callPOperator;
284100180201          EndIf;
284200180201
284300180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
284400180201
284500180201          If not inCallP;         // First line of CALLP.
284600180201             sourceLine = %trimr(operator) + ' ' + %trim(extFactor2);
284700180201             If not inSpan;
284800180201                sourceLine = %trim(sourceLine) + ';';
284900180201             Else;
285000180201                callPOffset = %len(%trim(operator)) + 2;
285100180201                inCallP = *On;
285200180201                inSpan = *Off;
285300180201             EndIf;
285400180201          Else;                   // Second+ line of CALLP.
285500180201             sourceLine = *Blanks;
285600180201             sourceLine = %trim(extFactor2);
285700180201             If not inSpan;
285800180201                sourceLine = %trimr(sourceLine) + ';';
285900180201                //            inCallP = *Off;
286000180201             EndIf;
286100180201             inSpan = *Off;
286200180201          EndIf;
286300180201
286400180201          // Multi-line CALLP?  Save the opcode.
286500180201          If inCallP;
286600180201             callPOperator = operator;
286700180201          Else;
286800180201             callPOperator = *Blanks;
286900180201          EndIf;
287000180201
287100180201          convert = *On;
287200180201
287300180201       EndSr;
287400180201       //-------------------------------------------------------------------------------------------
287500180201
287600180201      /Eject
287700180201       //-------------------------------------------------------------------------------------------
287800180201       // Convert CASxx.
287900180201       //-------------------------------------------------------------------------------------------
288000180201       BegSr subUserCvt_CASxx;
288100180201
288200180201          // Extract components.
288300180201          caseSubRoutine = %trim(result);
288400180201          caseOperator = %subst(operator:4:2);
288500180201
288600180201          // Determine comparator.
288700180201          If caseOperator = 'EQ';
288800180201             caseOperator = '=';
288900180201          ElseIf caseOperator = 'GT';
289000180201             caseOperator = '>';
289100180201          ElseIf caseOperator = 'LT';
289200180201             caseOperator = '<';
289300180201          ElseIf caseOperator = 'GE';
289400180201             caseOperator = '>=';
289500180201          ElseIf caseOperator = 'LE';
289600180201             caseOperator = '<=';
289700180201          ElseIf caseOperator = 'NE';
289800180201             caseOperator = '<>';
289900180201          Else;
290000180201             caseOperator = 'Else';
290100180201          EndIf;
290200180201
290300180201          // Build 'If' statement.
290400180201          If not inCase;
290500180201             sourceLine = 'If ' +  %trim(factor1) + ' '
290600180201                        + %trim(caseOperator) + ' ' + %trim(factor2)
290700180201                        + ';';
290800180201             inCase = *On;
290900180201          Else;
291000180201             If caseOperator = 'Else';
291100180201                sourceLine = 'Else;';
291200180201             Else;
291300180201                sourceLine = 'ElseIf ' +  %trim(factor1) + ' '
291400180201                           + %trim(caseOperator) + ' ' + %trim(factor2)
291500180201                           + ';';
291600180201             EndIf;
291700180201          EndIf;
291800180201
291900180201          // Do we need to set Resulting indicators?
292000180201          If hi <> *Blanks;
292100180201             HICheck = *On;
292200180201             HIInd = hi;
292300180201             HIFactor1 = %trim(factor1);
292400180201             HIFactor2 = %trim(factor2);
292500180201          EndIf;
292600180201          If lw <> *Blanks;
292700180201             LWCheck = *On;
292800180201             LWInd = lw;
292900180201             LWFactor1 = %trim(factor1);
293000180201             LWFactor2 = %trim(factor2);
293100180201          EndIf;
293200180201          If eq <> *Blanks;
293300180201             EQCheck = *On;
293400180201             EQInd = eq;
293500180201             EQFactor1 = %trim(factor1);
293600180201             EQFactor2 = %trim(factor2);
293700180201          EndIf;
293800180201
293900180201          convert = *On;
294000180201
294100180201       EndSr;
294200180201       //-------------------------------------------------------------------------------------------
294300180201
294400180201      /Eject
294500180201       //-------------------------------------------------------------------------------------------
294600180201       // Convert CAT.
294700180201       //-------------------------------------------------------------------------------------------
294800180201       BegSr subUserCvt_CAT;
294900180201
295000180201          // Pad the result?
295100180201          x = %scan('P':operator:4);
295200180201          If x = 0                                              // Not padding.
295300180201          and factor1 <> *Blanks                                // Factor1 specified.
295400180201          and %xlate(lo:up:factor1) <> %xlate(lo:hi:result);    // Factor1 not the same as result
295500180201             nonConvRsn =  'No padding specified, result unpredictable.';
295600180201             LeaveSr;    // Don't convert - too difficult to get right.
295700180201          EndIf;
295800180201
295900180201          // Drop the extender.
296000180201          operator = 'CAT';
296100180201
296200180201          // Determine first part of string.
296300180201          If factor1 = *Blanks;
296400180201             catFactor1 = %trim(result);
296500180201          Else;
296600180201             catFactor1 = %trim(factor1);
296700180201          EndIf;
296800180201
296900180201          // Determine number of blanks.
297000180201          x = %scan(':':factor2);
297100180201          If x = 0;   // No trimming required;
297200180201             catBlanks = *Blanks;
297300180201             catFactor2 = %trim(factor2);
297400180201          Else;
297500180201             catBlanks = %subst(factor2:x+1);
297600180201             catFactor2 = %subst(factor2:1:x-1);
297700180201          EndIf;
297800180201
297900180201          // Determine second part of String.
298000180201
298100180201          // Blanks zero?
298200180201          If catBlanks <> *blanks;
298300180201             Monitor;
298400180201                catCount = %dec(catBlanks:3:0);
298500180201             On-Error;
298600180201                LeaveSr; // Uses a field to vary the number of blanks - don't convert.
298700180201             EndMon;
298800180201          EndIf;
298900180201
299000180201          // Build the new line.
299100180201          If catBlanks = *Blanks;
299200180201             // No trimming.
299300180201             sourceLine = %trim(result) + ' = ' + %trim(catFactor1)
299400180201                        + ' + ' + %trim(catFactor2) + ';';
299500180201          ElseIf catCount = 0;
299600180201             // No spaces.
299700180201             sourceLine = %trim(result) + ' = %trimr(' + %trim(catFactor1)
299800180201                        + ') + %trim(' + %trim(catFactor2) + ');';
299900180201          ElseIf catCount > 25;
300000180201             LeaveSr; // Arbitrary upper limit - don't convert.
300100180201          Else;
300200180201             sourceLine = %trim(result) + ' = %trimr(' + %trim(catFactor1)
300300180201                        + ') + ''' + %str(%addr(blanks):catCount)
300400180201                        + ''' + %trim(' + %trim(catFactor2) + ');';
300500180201          EndIf;
300600180201
300700180201          // Set resulting indicators?
300800180201          If lw <> *Blanks;
300900180201             ERRCheck = *On;
301000180201             ERRInd = lw;
301100180201          EndIf;
301200180201
301300180201          convert = *On;
301400180201
301500180201       EndSr;
301600180201       //-------------------------------------------------------------------------------------------
301700180201
301800180201      /Eject
301900180201       //-------------------------------------------------------------------------------------------
302000180201       // Convert CHAIN.
302100180201       //-------------------------------------------------------------------------------------------
302200180201       BegSr subUserCvt_CHAIN;
302300180201
302400180201          sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
302500180201                     + %trim(factor2);
302600180201
302700180201          If result <> *Blanks;
302800180201             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
302900180201          Else;
303000180201             sourceLine = %trim(sourceLine)  + ';';
303100180201          EndIf;
303200180201
303300180201          // Set resulting indicators?
303400180201          If hi <> *Blanks;
303500180201             NRFCheck = *On;
303600180201             NRFInd = hi;
303700180201             NRFFile = %trim(factor2);
303800180201          EndIf;
303900180201          If lw <> *Blanks;
304000180201             ERRCheck = *On;
304100180201             ERRInd = lw;
304200180201          EndIf;
304300180201
304400180201          convert = *On;
304500180201
304600180201       EndSr;
304700180201       //-------------------------------------------------------------------------------------------
304800180201
304900180201      /Eject
305000180201       //-------------------------------------------------------------------------------------------
305100180201       // Convert CHECK.
305200180201       //-------------------------------------------------------------------------------------------
305300180201       BegSr subUserCvt_CHECKx;
305400180201
305500180201          // Don't convert of no result specified.
305600180201          If result = *Blanks;
305700180201             nonConvRsn = 'No result field specified.';
305800180201             LeaveSr;
305900180201          EndIf;
306000180201
306100180201          If %subst(operator:1:5) = 'CHECKR';
306200180201             operator = '%checkr(';
306300180201          Else;
306400180201             operator = '%check(';
306500180201          EndIf;
306600180201
306700180201          // Determine starting point.
306800180201          x = %scan(':':factor2);
306900180201
307000180201          // Build the new line.
307100180201          If x = 0;
307200180201             // No start specified.
307300180201             sourceLine = %trim(result) + ' = ' + %trim(operator)
307400180201                        + %trim(factor1) + ':' + %trim(factor2) + ');';
307500180201          Else;
307600180201             // Start from a specified point.
307700180201             sourceLine = %trim(result) + ' = ' + %trim(operator)
307800180201                        + %trim(factor1) + ':' + %subst(factor2:1:x-1)
307900180201                        + ':' + %trim(%subst(factor2:x+1))
308000180201                        + ');';
308100180201          EndIf;
308200180201
308300180201          // Set resulting indicators?
308400180201          If lw <> *Blanks;
308500180201             ERRCheck = *On;
308600180201             ERRInd = lw;
308700180201          EndIf;
308800180201          If eq <> *Blanks;
308900180201             HICheck = *On;
309000180201             HIInd = eq;
309100180201             HIFactor1 = result;
309200180201             HIFactor2 = '0';
309300180201          EndIf;
309400180201
309500180201          convert = *On;
309600180201
309700180201       EndSr;
309800180201       //-------------------------------------------------------------------------------------------
309900180201
310000180201      /Eject
310100180201       //-------------------------------------------------------------------------------------------
310200180201       // Convert CLEAR.
310300180201       //-------------------------------------------------------------------------------------------
310400180201       BegSr subUserCvt_CLEAR;
310500180201
310600180201          sourceLine = 'Clear ' + %trim(result) + ';';
310700180201
310800180201          convert = *On;
310900180201
311000180201       EndSr;
311100180201       //-------------------------------------------------------------------------------------------
311200180201
311300180201      /Eject
311400180201       //-------------------------------------------------------------------------------------------
311500180201       // Convert CLOSE.
311600180201       //-------------------------------------------------------------------------------------------
311700180201       BegSr subUserCvt_CLOSE;
311800180201
311900180201          sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
312000180201
312100180201          If lw <> *Blanks;
312200180201             ERRCheck = *On;
312300180201             ERRInd = lw;
312400180201          EndIf;
312500180201
312600180201          convert = *On;
312700180201
312800180201       EndSr;
312900180201       //-------------------------------------------------------------------------------------------
313000180201
313100180201      /Eject
313200180201       //-------------------------------------------------------------------------------------------
313300180201       // Convert COMMIT.
313400180201       //-------------------------------------------------------------------------------------------
313500180201       BegSr subUserCvt_COMMIT;
313600180201
313700180201          sourceLine = %trim(operator) + ' ' + %trim(factor1);
313800180201
313900180201          sourceLine = %trim(sourceLine)  + ';';
314000180201
314100180201          // Check indicators?
314200180201          If lw <> *Blanks;
314300180201             ERRCheck = *On;
314400180201             ERRInd = lw;
314500180201          EndIf;
314600180201
314700180201          convert = *On;
314800180201
314900180201       EndSr;
315000180201       //-------------------------------------------------------------------------------------------
315100180201
315200180201      /Eject
315300180201       //-------------------------------------------------------------------------------------------
315400180201       // Convert COMP.
315500180201       //-------------------------------------------------------------------------------------------
315600180201       BegSr subUserCvt_COMP;
315700180201
315800180201          // Set resulting indicators to check.
315900180201          If hi <> *Blanks;
316000180201             HICheck = *On;
316100180201             HIInd = hi;
316200180201             HIFactor1 = factor1;
316300180201             HIFactor2 = factor2;
316400180201          EndIf;
316500180201
316600180201          If lw <> *Blanks;
316700180201             LWCheck = *On;
316800180201             LWInd = lw;
316900180201             LWFactor1 = factor1;
317000180201             LWFactor2 = factor2;
317100180201          EndIf;
317200180201
317300180201          If eq <> *Blanks;
317400180201             EQCheck = *On;
317500180201             EQInd = eq;
317600180201             EQFactor1 = factor1;
317700180201             EQFactor2 = factor2;
317800180201          EndIf;
317900180201
318000180201          // Drop the current line.
318100180201          dropLine = *On;
318200180201          convert = *On;
318300180201
318400180201       EndSr;
318500180201       //-------------------------------------------------------------------------------------------
318600180201
318700180201      /Eject
318800180201       //-------------------------------------------------------------------------------------------
318900180201       // Convert DEALLOC.
319000180201       //-------------------------------------------------------------------------------------------
319100180201       BegSr subUserCvt_DEALLOC;
319200180201
319300180201          sourceLine = %trim(operator) + ' ' + %trim(result);
319400180201
319500180201          sourceLine = %trim(sourceLine)  + ';';
319600180201
319700180201          // Set resulting indicators?
319800180201          If lw <> *Blanks;
319900180201             ERRCheck = *On;
320000180201             ERRInd = lw;
320100180201          EndIf;
320200180201
320300180201          convert = *On;
320400180201
320500180201       EndSr;
320600180201       //-------------------------------------------------------------------------------------------
320700180201
320800180201      /Eject
320900180201       //-------------------------------------------------------------------------------------------
321000180201       // Convert DELETE.
321100180201       //-------------------------------------------------------------------------------------------
321200180201       BegSr subUserCvt_DELETE;
321300180201
321400180201          sourceLine = %trim(operator) + ' ' + %trim(factor2);
321500180201
321600180201          sourceLine = %trim(sourceLine)  + ';';
321700180201
321800180201          // Check indicators?
321900180201          If hi <> *Blanks;
322000180201             NRFCheck = *On;
322100180201             NRFInd = eq;
322200180201             NRFFile = %trim(factor2);
322300180201          EndIf;
322400180201          If lw <> *Blanks;
322500180201             ERRCheck = *On;
322600180201             ERRInd = lw;
322700180201          EndIf;
322800180201
322900180201          convert = *On;
323000180201
323100180201       EndSr;
323200180201       //-------------------------------------------------------------------------------------------
323300180201
323400180201      /Eject
323500180201       //-------------------------------------------------------------------------------------------
323600180201       // Convert DIV.
323700180201       //-------------------------------------------------------------------------------------------
323800180201       BegSr subUserCvt_DIV;
323900180201
324000180201          // Half-adjust?
324100180201          If %scan('H':operator:4) > 0;
324200180201             sourceLine = 'Eval(H) ';
324300180201          Else;
324400180201             sourceLine = *Blanks;
324500180201          EndIf;
324600180201
324700180201          If factor1 = *Blanks;
324800180201             divFactor1 = result;
324900180201             divFactor2 = factor2;
325000180201          Else;
325100180201             divFactor1 = factor1;
325200180201             divFactor2 = factor2;
325300180201          EndIf;
325400180201
325500180201          sourceLine = %trim( %trimr(sourceLine) + ' ' + %trim(result)
325600180201                     + ' = ' + %trim(divFactor1) + ' / '
325700180201                     + %trim(divFactor2) + ';');
325800180201
325900180201          convert = *On;
326000180201
326100180201       EndSr;
326200180201       //-------------------------------------------------------------------------------------------
326300180201
326400180201      /Eject
326500180201       //-------------------------------------------------------------------------------------------
326600180201       // Convert DO.
326700180201       //-------------------------------------------------------------------------------------------
326800180201       BegSr subUserCvt_DO;
326900180201
327000180201          If inDo;
327100180201             operator = doOperator;
327200180201          EndIf;
327300180201
327400180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
327500180201
327600180201          If operator = 'DOW'     // Use Extended Factor2.
327700180201          or operator = 'DOU';    // Use Extended Factor2.
327800180201             If not inDo;         // First line of DO.
327900180201                sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
328000180201                If not inSpan;
328100180201                   sourceLine = %trim(sourceLine) + ';';
328200180201                Else;
328300180201                   inDo = *On;
328400180201                   inSpan = *Off;
328500180201                EndIf;
328600180201             Else;                   // Second line of DO.
328700180201                sourceLine = *Blanks;
328800180201                //            %subst(sourceLine:40) = %trim(extFactor2);
328900180201                sourceLine = %trim(extFactor2);
329000180201                If not inSpan;
329100180201                   sourceLine = %trimr(sourceLine) + ';';
329200180201                   //               inDo = *Off;
329300180201                EndIf;
329400180201                inSpan = *Off;
329500180201             EndIf;
329600180201             doCompare = '!!';    // Just a regular DO.
329700180201          Else;
329800180201             // Fixed format.
329900180201             opCode = %xlate(lo:up:opCode);
330000180201             If not inDo;         // First line of DO.
330100180201                doCompare = %subst(opCode:4:2);
330200180201                sourceLine = %subst(opcode:1:3);
330300180201             Else;                // Second line of DO.
330400180201                If %subst(opCode:1:3) = 'AND';
330500180201                   doCompare = %subst(opCode:4:2);
330600180201                   sourceLine = 'And';
330700180201                Else;
330800180201                   doCompare = %subst(opCode:3:2);
330900180201                   sourceLine = 'Or';
331000180201                EndIf;
331100180201             EndIf;
331200180201
331300180201             If doCompare = 'EQ';
331400180201                doCompare = '=';
331500180201             ElseIf doCompare = 'GT';
331600180201                doCompare = '>';
331700180201             ElseIf doCompare = 'GE';
331800180201                doCompare = '>=';
331900180201             ElseIf doCompare = 'LT';
332000180201                doCompare = '<';
332100180201             ElseIf doCompare = 'LE';
332200180201                doCompare = '<=';
332300180201             ElseIf doCompare = 'NE';
332400180201                doCompare = '<>';
332500180201             ElseIf doCompare = '!!';
332600180201                // Do nothing.
332700180201                Else;    // Just DO - convert to FOR.
332800180201                If factor1 = *Blanks;
332900180201                   forFactor1 = '1';
333000180201                Else;
333100180201                   forFactor1 = factor1;
333200180201                EndIf;
333300180201                forFactor2 = factor2;
333400180201                factor1 = *Blanks;
333500180201                factor2 = *Blanks;
333600180201                doCompare = *Blanks;
333700180201                If result = *Blanks;
333800180201                   result = '???';
333900180201                EndIf;
334000180201                sourceLine = 'For ' + %trim(result) + ' = '
334100180201                           + %trim(forFactor1) + ' To '
334200180201                           + %trim(forFactor2);
334300180201             EndIf;
334400180201
334500180201             //         If doCompare = *Blanks;
334600180201         //            // Save current indentation level to match up to the associated ENDDO later.
334700180201             //            forCount += 1;
334800180201             //            forLevel(forCount) = indentCount;
334900180201             //         Else;
335000180201         //            // Save current indentation level to match up to the associated ENDDO later.
335100180201             //            doCount += 1;
335200180201             //            doLevel(doCount) = indentCount;
335300180201             //         EndIf;
335400180201
335500180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
335600180201                                + ' ' + %trim(doCompare) + ' '
335700180201                                + %trim(factor2);
335800180201             If not inSpan;
335900180201                sourceLine = %trimr(sourceLine) + ';';
336000180201                inDo = *Off;
336100180201             Else;
336200180201                inDo = *On;
336300180201                inSpan = *Off;
336400180201             EndIf;
336500180201          EndIf;
336600180201
336700180201          // If multi-line, retain the original opcode.
336800180201          If inDo;
336900180201             doOperator = operator;
337000180201          Else;
337100180201             doOperator = *Blanks;
337200180201          EndIf;
337300180201
337400180201          convert = *On;
337500180201
337600180201       EndSr;
337700180201       //-------------------------------------------------------------------------------------------
337800180201
337900180201      /Eject
338000180201       //-------------------------------------------------------------------------------------------
338100180201       // Convert DSPLY.
338200180201       //-------------------------------------------------------------------------------------------
338300180201       BegSr subUserCvt_DSPLY;
338400180201
338500180201          sourceLine = %trim(operator);
338600180201
338700180201          If factor1 <> *Blanks;
338800180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1);
338900180201             If factor2 <> *Blanks;
339000180201                sourceLine = %trimr(sourceLine) + ' ' + %trim(factor2);
339100180201             ElseIf result <> *Blanks;
339200180201                sourceLine = %trimr(sourceLine) + ' ''''';
339300180201             EndIf;
339400180201             If result <> *Blanks;
339500180201                sourceLine = %trimr(sourceLine) + ' ' + %trim(result);
339600180201             EndIf;
339700180201          EndIf;
339800180201
339900180201          sourceLine = %trimr(sourceLine) + ';';
340000180201
340100180201          // Set resulting indicators?
340200180201          If lw <> *Blanks;
340300180201             ERRCheck = *On;
340400180201             ERRInd = lw;
340500180201          EndIf;
340600180201
340700180201          convert = *On;
340800180201
340900180201       EndSr;
341000180201       //-------------------------------------------------------------------------------------------
341100180201
341200180201      /Eject
341300180201       //-------------------------------------------------------------------------------------------
341400180201       // Convert DUMP.
341500180201       //-------------------------------------------------------------------------------------------
341600180201       BegSr subUserCvt_DUMP;
341700180201
341800180201          If factor1 <> *Blanks;
341900180201             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ';';
342000180201          Else;
342100180201             sourceLine = %trim(operator) + ';';
342200180201          EndIf;
342300180201
342400180201          convert = *On;
342500180201
342600180201       EndSr;
342700180201       //-------------------------------------------------------------------------------------------
342800180201
342900180201      /Eject
343000180201       //-------------------------------------------------------------------------------------------
343100180201       // Convert ELSE.
343200180201       //-------------------------------------------------------------------------------------------
343300180201       BegSr subUserCvt_ELSE;
343400180201
343500180201          sourceLine = 'Else;';
343600180201
343700180201          convert = *On;
343800180201
343900180201       EndSr;
344000180201       //-------------------------------------------------------------------------------------------
344100180201
344200180201      /Eject
344300180201       //-------------------------------------------------------------------------------------------
344400180201       // Convert ELSEIF.
344500180201       //-------------------------------------------------------------------------------------------
344600180201       BegSr subUserCvt_ELSEIF;
344700180201
344800180201          sourceLine = 'ElseIf ' + %trim(factor2) + ';';
344900180201
345000180201          convert = *On;
345100180201
345200180201       EndSr;
345300180201       //-------------------------------------------------------------------------------------------
345400180201
345500180201      /Eject
345600180201       //-------------------------------------------------------------------------------------------
345700180201       // Convert ENDxx.
345800180201       //-------------------------------------------------------------------------------------------
345900180201       BegSr subUserCvt_ENDxx;
346000180201
346100180201          // Catch labels on ENDSR.
346200180201          If %trim(operator) = 'ENDSR';
346300180201             If %len(%trim(factor1)) > 0;
346400180201                nonConvRsn = 'Label on ENDSR is not supported in free-form';
346500180201                LeaveSr;
346600180201             EndIf;
346700180201          EndIf;
346800180201
346900180201          // Do we need to convert an ENDDO to ENDFOR?
347000180201          If %trim(operator) = 'ENDDO' or %trim(operator) = 'END';
347100180201             If forCount > 0;
347200180201                If forLevel(forCount) = indentCount - 1;
347300180201                   operator = 'ENDFOR' + ' ' + %trim(factor2);
347400180201                   If factor2 <> *Blanks;
347500180201                      savedSRCDTA = SRCDTA;
347600180201                      codeLine = '* CHECK: This is a converted ENDDO -'
347700180201                               + ' Please add ''BY'' to the corresponding'
347800180201                               + ' FOR';
347900180201                      Exsr subUserWriteLine;
348000180201                      SRCDTA = savedSRCDTA;
348100180201                   EndIf;
348200180201                EndIf;
348300180201             EndIf;
348400180201          EndIf;
348500180201
348600180201          // Convert END to ENDDO?
348700180201          If %trim(operator) = 'ENDDO' or %trim(operator) = 'END';
348800180201             If doCount > 0;
348900180201                If doLevel(doCount) = indentCount - 1;
349000180201                   operator = 'ENDDO';
349100180201                EndIf;
349200180201             EndIf;
349300180201          EndIf;
349400180201
349500180201          // Convert END to ENDSL?
349600180201          If %trim(operator) = 'ENDSL' or %trim(operator) = 'END';
349700180201             If slCount > 0;
349800180201                If slLevel(slCount) = indentCount - 2;
349900180201                   operator = 'ENDSL';
350000180201                EndIf;
350100180201             EndIf;
350200180201          EndIf;
350300180201
350400180201          If %trim(operator) = 'END';
350500180201             If inCase;
350600180201                operator = 'ENDCS';
350700180201             Else;
350800180201                operator = 'ENDIF';
350900180201             EndIf;
351000180201          EndIf;
351100180201
351200180201          sourceLine = %trim(operator) + ';';
351300180201
351400180201          convert = *On;
351500180201
351600180201          If operator = 'ENDCS';
351700180201             inCase = *Off;
351800180201          EndIf;
351900180201
352000180201       EndSr;
352100180201       //-------------------------------------------------------------------------------------------
352200180201
352300180201      /Eject
352400180201       //-------------------------------------------------------------------------------------------
352500180201       // Convert EVALx.
352600180201       //-------------------------------------------------------------------------------------------
352700180201       BegSr subUserCvt_EVALx;
352800180201
352900180201          // Returning for a multi-line EVAL - restore the original opcode.
353000180201          If inEval;
353100180201             operator = evalOperator;
353200180201          EndIf;
353300180201
353400180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
353500180201
353600180201          If not inEval;          // First line of EVAL.
353700180201             inEval = *On;
353800180201             If %scan('H':operator:5) > 0  // Half-adjust.
353900180201             or %scan('R':operator:1) > 0; // EVALR.
354000180201                sourceLine = %trimr(operator) + ' ' + %trim(extFactor2);
354100180201             Else;
354200180201                sourceLine = %trim(extFactor2);
354300180201             EndIf;
354400180201             If not inSpan;
354500180201                sourceLine = %trim(sourceLine) + ';';
354600180201             Else;
354700180201                inSpan = *Off;
354800180201             EndIf;
354900180201          Else;                   // Second+ line of EVAL.
355000180201             sourceLine = *Blanks;
355100180201             %subst(sourceLine:%len(%trim(operator)) + 2)
355200180201                   = %trim(extFactor2);
355300180201             If not inSpan;
355400180201                sourceLine = %trimr(sourceLine) + ';';
355500180201             EndIf;
355600180201             inSpan = *Off;
355700180201          EndIf;
355800180201
355900180201          // Multi-line EVAL?  Save the opcode.
356000180201          If inEval;
356100180201             evalOperator = operator;
356200180201          Else;
356300180201             evalOperator = *Blanks;
356400180201          EndIf;
356500180201
356600180201          convert = *On;
356700180201
356800180201       EndSr;
356900180201       //-------------------------------------------------------------------------------------------
357000180201
357100180201      /Eject
357200180201       //-------------------------------------------------------------------------------------------
357300180201       // Convert EXCEPT.
357400180201       //-------------------------------------------------------------------------------------------
357500180201       BegSr subUserCvt_EXCEPT;
357600180201
357700180201          sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
357800180201
357900180201          convert = *On;
358000180201
358100180201       EndSr;
358200180201       //-------------------------------------------------------------------------------------------
358300180201
358400180201      /Eject
358500180201       //-------------------------------------------------------------------------------------------
358600180201       // Convert Embedded SQL.
358700180201       //-------------------------------------------------------------------------------------------
358800180201       BegSr subUserCvt_EXEC_SQL;
358900180201
359000180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
359100180201
359200180201          If workDirective = '/EXEC SQL';
359300180201             sourceLine = 'Exec SQL';
359400180201             inSQL = *On;
359500180201             inSpan = *Off;
359600180201          Else;
359700180201             sourceLine = %trimr(%subst(codeLine:2));
359800180201             If not inSpan;
359900180201                sourceLine = %trim(sourceLine) + ';';
360000180201             Else;
360100180201                inSQL = *On;
360200180201                inSpan = *Off;
360300180201             EndIf;
360400180201          EndIf;
360500180201
360600180201          convert = *On;
360700180201
360800180201       EndSr;
360900180201       //-------------------------------------------------------------------------------------------
361000180201
361100180201      /Eject
361200180201       //-------------------------------------------------------------------------------------------
361300180201       // Convert EXFMT.
361400180201       //-------------------------------------------------------------------------------------------
361500180201       BegSr subUserCvt_EXFMT;
361600180201
361700180201          sourceLine = %trim(operator) + ' ' + %trim(factor2);
361800180201
361900180201          // Append datastructure?
362000180201          If result <> *Blanks;
362100180201             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
362200180201          Else;
362300180201             sourceLine = %trim(sourceLine)  + ';';
362400180201          EndIf;
362500180201
362600180201          // Check indicators?
362700180201          If lw <> *Blanks;
362800180201             ERRCheck = *On;
362900180201             ERRInd = lw;
363000180201          EndIf;
363100180201
363200180201          convert = *On;
363300180201
363400180201       EndSr;
363500180201       //-------------------------------------------------------------------------------------------
363600180201
363700180201      /Eject
363800180201       //-------------------------------------------------------------------------------------------
363900180201       // Convert EXSR.
364000180201       //-------------------------------------------------------------------------------------------
364100180201       BegSr subUserCvt_EXSR;
364200180201
364300180201          sourceLine = 'ExSr ' + %trim(factor2) + ';';
364400180201
364500180201          convert = *On;
364600180201
364700180201       EndSr;
364800180201       //-------------------------------------------------------------------------------------------
364900180201
365000180201      /Eject
365100180201       //-------------------------------------------------------------------------------------------
365200180201       // Convert EXTRCT
365300180201       //-------------------------------------------------------------------------------------------
365400180201       BegSr subUserCvt_EXTRCT;
365500180201
365600180201          // Split out duration and code.
365700180201          x = %scan(':':factor2);
365800180201          If x = 0;
365900180201             nonConvRsn =  'No duration code specified.';
366000180201             LeaveSr;
366100180201          EndIf;
366200180201
366300180201          durDuration = %trim(%subst(factor2:1:x-1));
366400180201          durCode     = %xlate(lo:up:%trim(%subst(factor2:x+1)));
366500180201
366600180201          Select;
366700180201             When durCode = '*Y' or durCode = '*YEARS';
366800180201                durCode = '%years';
366900180201             When durCode = '*M' or durCode = '*MONTHS';
367000180201                durCode = '%months';
367100180201             When durCode = '*D' or durCode = '*DAYS';
367200180201                durCode = '%days';
367300180201             When durCode = '*H' or durCode = '*HOURS';
367400180201                durCode = '%hours';
367500180201             When durCode = '*MN' or durCode = '*MINUTES';
367600180201                durCode = '%minutes';
367700180201             When durCode = '*S' or durCode = '*SECONDS';
367800180201                durCode = '%seconds';
367900180201             When durCode = '*MS' or durCode = '*MSECONDS';
368000180201                durCode = '%mseconds';
368100180201             Other;
368200180201                nonConvRsn = 'Invalid duration code specified.';
368300180201                LeaveSr;
368400180201          EndSl;
368500180201
368600180201          sourceLine = %trim(result) + ' = %subdt(' + %trim(durDuration)
368700180201                     + ':' + %trim(durCode) + ');';
368800180201
368900180201          // Check indicators?
369000180201          If lw <> *Blanks;
369100180201             ERRCheck = *On;
369200180201             ERRInd = lw;
369300180201          EndIf;
369400180201
369500180201          convert = *On;
369600180201
369700180201       EndSr;
369800180201       //-------------------------------------------------------------------------------------------
369900180201
370000180201      /Eject
370100180201       //-------------------------------------------------------------------------------------------
370200180201       // Convert FEOD.
370300180201       //-------------------------------------------------------------------------------------------
370400180201       BegSr subUserCvt_FEOD;
370500180201
370600180201          sourceLine = %trim(operator) + %trim(extFactor2) + ';';
370700180201
370800180201          // Check indicators?
370900180201          If lw <> *Blanks;
371000180201             ERRCheck = *On;
371100180201             ERRInd = lw;
371200180201          EndIf;
371300180201
371400180201          convert = *On;
371500180201
371600180201       EndSr;
371700180201       //-------------------------------------------------------------------------------------------
371800180201
371900180201      /Eject
372000180201       //-------------------------------------------------------------------------------------------
372100180201       // Convert FORCE.
372200180201       //-------------------------------------------------------------------------------------------
372300180201       BegSr subUserCvt_FORCE;
372400180201
372500180201          sourceLine = %trim(operator) + %trim(extFactor2) + ';';
372600180201
372700180201          convert = *On;
372800180201
372900180201       EndSr;
373000180201       //-------------------------------------------------------------------------------------------
373100180201
373200180201      /Eject
373300180201       //-------------------------------------------------------------------------------------------
373400180201       // Convert FOR.
373500180201       //-------------------------------------------------------------------------------------------
373600180201       BegSr subUserCvt_FOR;
373700180201
373800180201          sourceLine = 'For ' + %trim(extFactor2) + ';';
373900180201
374000180201          convert = *On;
374100180201
374200180201       EndSr;
374300180201       //-------------------------------------------------------------------------------------------
374400180201
374500180201      /Eject
374600180201       //-------------------------------------------------------------------------------------------
374700180201       // Convert IF.
374800180201       //-------------------------------------------------------------------------------------------
374900180201       BegSr subUserCvt_IF;
375000180201
375100180201          // Returning for a multi-line IF?  Reinstate original opcode.
375200180201          If inIf;
375300180201             operator = ifOperator;
375400180201          EndIf;
375500180201
375600180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
375700180201
375800180201          If operator = 'IF';     // Use Extended Factor2.
375900180201             If not inIf;            // First line of IF.
376000180201                sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
376100180201                If not inSpan;
376200180201                   sourceLine = %trim(sourceLine) + ';';
376300180201                Else;
376400180201                   inIf = *On;
376500180201                   inSpan = *Off;
376600180201                EndIf;
376700180201             Else;                   // Second line of IF.
376800180201                //            sourceLine = *Blanks;
376900180201                //            %subst(sourceLine:40) = %trim(extFactor2);
377000180201                sourceLine = %trim(extFactor2);
377100180201                If not inSpan;
377200180201                   sourceLine = %trimr(sourceLine) + ';';
377300180201                   //               inIf = *Off;
377400180201                EndIf;
377500180201                //            inSpan = *On;
377600180201                inSpan = *Off;
377700180201             EndIf;
377800180201          Else;
377900180201             // Fixed format.
378000180201             opCode = %xlate(lo:up:opCode);
378100180201             If not inIf;         // First line of IF.
378200180201                ifCompare = %subst(opCode:3:2);
378300180201                sourceLine = 'If';
378400180201             Else;                // Second line of IF.
378500180201                If %subst(opCode:1:3) = 'AND';
378600180201                   ifCompare = %subst(opCode:4:2);
378700180201                   sourceLine = 'And';
378800180201                Else;
378900180201                   ifCompare = %subst(opCode:3:2);
379000180201                   sourceLine = 'Or';
379100180201                EndIf;
379200180201             EndIf;
379300180201             If ifCompare = 'EQ';
379400180201                ifCompare = '=';
379500180201             ElseIf ifCompare = 'GT';
379600180201                ifCompare = '>';
379700180201             ElseIf ifCompare = 'GE';
379800180201                ifCompare = '>=';
379900180201             ElseIf ifCompare = 'LT';
380000180201                ifCompare = '<';
380100180201             ElseIf ifCompare = 'LE';
380200180201                ifCompare = '<=';
380300180201             ElseIf ifCompare = 'NE';
380400180201                ifCompare = '<>';
380500180201             EndIf;
380600180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
380700180201                                + ' ' + %trim(ifCompare) + ' '
380800180201                                + %trim(factor2);
380900180201             If not inSpan;
381000180201                sourceLine = %trimr(sourceLine) + ';';
381100180201                inIf = *Off;
381200180201             Else;
381300180201                inIf = *On;
381400180201                inSpan = *Off;
381500180201             EndIf;
381600180201          EndIf;
381700180201
381800180201          // Multi-line IF?  Retain original opcode.
381900180201          If inIf;
382000180201             ifOperator = operator;
382100180201          Else;
382200180201             ifOperator = *Blanks;
382300180201          EndIf;
382400180201
382500180201          convert = *On;
382600180201
382700180201       EndSr;
382800180201       //-------------------------------------------------------------------------------------------
382900180201
383000180201      /Eject
383100180201       //-------------------------------------------------------------------------------------------
383200180201       // Convert IN.
383300180201       //-------------------------------------------------------------------------------------------
383400180201       BegSr subUserCvt_IN;
383500180201
383600180201          If factor1 <> *Blanks;
383700180201             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
383800180201                        + %trim(factor2) + ';';
383900180201          Else;
384000180201             sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
384100180201          EndIf;
384200180201
384300180201          // Set resulting indicators?
384400180201          If lw <> *Blanks;
384500180201             ERRCheck = *On;
384600180201             ERRInd = lw;
384700180201          EndIf;
384800180201
384900180201          convert = *On;
385000180201
385100180201       EndSr;
385200180201       //-------------------------------------------------------------------------------------------
385300180201
385400180201      /Eject
385500180201       //-------------------------------------------------------------------------------------------
385600180201       // Convert ITER.
385700180201       //-------------------------------------------------------------------------------------------
385800180201       BegSr subUserCvt_ITER;
385900180201
386000180201          sourceLine = %trim(operator) + ';';
386100180201
386200180201          convert = *On;
386300180201
386400180201       EndSr;
386500180201       //-------------------------------------------------------------------------------------------
386600180201
386700180201      /Eject
386800180201       //-------------------------------------------------------------------------------------------
386900180201       // Convert LEAVExx.
387000180201       //-------------------------------------------------------------------------------------------
387100180201       BegSr subUserCvt_LEAVE;
387200180201
387300180201          sourceLine = %trim(operator) + ';';
387400180201
387500180201          convert = *On;
387600180201
387700180201       EndSr;
387800180201       //-------------------------------------------------------------------------------------------
387900180201
388000180201      /Eject
388100180201       //-------------------------------------------------------------------------------------------
388200180201       // Convert LOOKUP.
388300180201       //-------------------------------------------------------------------------------------------
388400180201       BegSr subUserCvt_LOOKUP;
388500180201
388600180201          //            If %subst(factor2:1:3) = 'TAB';  // Table lookup.
388700180201          //            Else;                            // Array lookup.
388800180201          //               // Extract element variable.
388900180201          //               x = %scan('(':factor2);
389000180201          //               If x = 0;   // No variable specified, so use a substitute.
389100180201          //                  lookupVar = 'lookupIndex';
389200180201          //               Else;
389300180201          //                  lookupVar = %subst(factor2:x+1:%scan(')':factor2:x)-x-1);
389400180201          //               EndIf;
389500180201          //               If eq <> *Blanks and lw <> *Blanks;
389600180201          //                  sourceLine = '%lookupLE(';
389700180201          //               ElseIf eq <> *Blanks and hi <> *Blanks;
389800180201          //                  sourceLine = '%lookupGE(';
389900180201          //               ElseIf lw <> *Blanks;
390000180201          //                  sourceLine = '%lookupLT(';
390100180201          //               ElseIf hi <> *Blanks;
390200180201          //                  sourceLine = '%lookupGT(';
390300180201          //               Else;
390400180201          //                  sourceLine = '%lookup(';
390500180201          //               EndIf;
390600180201          //               sourceLine = %trim(sourceLine) + %trim(factor1) + ':'
390700180201          //                          + %trim(factor2) + ');';
390800180201          //            EndIf;
390900180201          //            convert = *On;
391000180201
391100180201       EndSr;
391200180201       //-------------------------------------------------------------------------------------------
391300180201
391400180201      /Eject
391500180201       //-------------------------------------------------------------------------------------------
391600180201       // Convert MONITOR.
391700180201       //-------------------------------------------------------------------------------------------
391800180201       BegSr subUserCvt_MONITOR;
391900180201
392000180201          sourceLine = 'Monitor;';
392100180201
392200180201          convert = *On;
392300180201
392400180201       EndSr;
392500180201       //-------------------------------------------------------------------------------------------
392600180201
392700180201      /Eject
392800180201       //-------------------------------------------------------------------------------------------
392900180201       // Convert MOVE.
393000180201       //-------------------------------------------------------------------------------------------
393100180201       BegSr subUserCvt_MOVE;
393200180201
393300180201          // Pad the result?
393400180201          x = %scan('P':operator:5);
393500180201
393600180201          If x > 0 and %subst(operator:5:1) <> 'L';
393700180201             // Move right and pad left.
393800180201             sourceLine = 'EvalR ' + %trim(result) + ' = ' + %trim(factor2)
393900180201                        + ';';
394000180201
394100180201          ElseIf x > 0 and %subst(operator:5:1) = 'L';
394200180201             // Move left and pad right.
394300180201             sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';
394400180201
394500180201          ElseIf factor1 = *Blanks;
394600180201             // Straight move.
394700180201             If %lookup(%xlate(lo:up:%trim(result)):@opCodeUp) = 0;
394800180201                sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';
394900180201             Else;
395000180201                // Result is a reserved word - don't convert.
395100180201                nonConvRsn = 'Result field name is a reserved word.';
395200180201                LeaveSr;
395300180201             EndIf;
395400180201
395500180201          Else;
395600180201             // Conversion from one format to another...
395700180201             //         sourceLine = %xlate(lo:up:factor1);
395800180201
395900180201             //         If sourceLine = '*CYMD';   // Date.
396000180201             //            sourceLine = %trim(result) + ' = %dec(' + %trim(factor2)
396100180201             //                       + ':*CYMD);';
396200180201             //         Else;
396300180201             nonConvRsn = 'Data conversion is needed.';
396400180201             LeaveSr; // Don't convert.
396500180201             //         EndIf;
396600180201          EndIf;
396700180201
396800180201          convert = *On;
396900180201
397000180201       EndSr;
397100180201       //-------------------------------------------------------------------------------------------
397200180201
397300180201      /Eject
397400180201       //-------------------------------------------------------------------------------------------
397500180201       // Convert MOVEA.
397600180201       //-------------------------------------------------------------------------------------------
397700180201       BegSr subUserCvt_MOVEA;
397800180201
397900180201          // Not supported.
398000180201
398100180201       EndSr;
398200180201       //-------------------------------------------------------------------------------------------
398300180201
398400180201      /Eject
398500180201       //-------------------------------------------------------------------------------------------
398600180201       // Convert MULT.
398700180201       //-------------------------------------------------------------------------------------------
398800180201       BegSr subUserCvt_MULT;
398900180201
399000180201          // Half-adjust?
399100180201          x = %scan('H':operator:4);
399200180201          If x > 0;
399300180201             sourceLine = 'Eval(H)';
399400180201          Else;
399500180201             sourceLine = *Blanks;
399600180201          EndIf;
399700180201
399800180201          If factor1 = *Blanks;
399900180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
400000180201                        + ' = ' + %trim(result)
400100180201                        + ' * ' + %trim(factor2) +';';
400200180201          Else;
400300180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
400400180201                        + ' = ' + %trim(factor1)
400500180201                        + ' * ' + %trim(factor2) + ';';
400600180201          EndIf;
400700180201
400800180201          sourceLine = %trim(sourceLine);
400900180201
401000180201          convert = *On;
401100180201
401200180201       EndSr;
401300180201       //-------------------------------------------------------------------------------------------
401400180201
401500180201      /Eject
401600180201       //-------------------------------------------------------------------------------------------
401700180201       // Convert MVR.
401800180201       //-------------------------------------------------------------------------------------------
401900180201       BegSr subUserCvt_MVR;
402000180201
402100180201          sourceLine = %trim(result) + ' = %rem(' + %trim(divFactor1)
402200180201                     + ':' + %trim(divFactor2) + ');';
402300180201
402400180201          convert = *On;
402500180201
402600180201       EndSr;
402700180201       //-------------------------------------------------------------------------------------------
402800180201
402900180201      /Eject
403000180201       //-------------------------------------------------------------------------------------------
403100180201       // Convert NEXT.
403200180201       //-------------------------------------------------------------------------------------------
403300180201       BegSr subUserCvt_NEXT;
403400180201
403500180201          sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
403600180201                     + %trim(factor2) + ';';
403700180201
403800180201
403900180201          // Check indicators?
404000180201          If lw <> *Blanks;
404100180201             ERRCheck = *On;
404200180201             ERRInd = lw;
404300180201          EndIf;
404400180201
404500180201          convert = *On;
404600180201
404700180201       EndSr;
404800180201       //-------------------------------------------------------------------------------------------
404900180201
405000180201      /Eject
405100180201       //-------------------------------------------------------------------------------------------
405200180201       // Convert OCCUR.
405300180201       //-------------------------------------------------------------------------------------------
405400180201       BegSr subUserCvt_OCCUR;
405500180201
405600180201          If factor1 = *Blanks;      // Get occurrence.
405700180201             sourceLine = %trim(result) + ' = ' + '%occur('
405800180201                        + %trim(factor2) + ');';
405900180201          ElseIf result = *Blanks;   // Set occurrent.
406000180201             sourceLine = '%occur(' + %trim(factor2) + ') = '
406100180201                        + %trim(factor1) + ';';
406200180201          Else;
406300180201             nonConvRsn = 'Cannot determine of OCCUR is used to set or '
406400180201                        + 'get the occurrence.';
406500180201             LeaveSr;
406600180201          EndIf;
406700180201
406800180201          // Check resulting indicators?
406900180201          If lw <> *Blanks;
407000180201             ERRCheck = *On;
407100180201             ERRInd = lw;
407200180201          EndIf;
407300180201
407400180201          convert = *On;
407500180201
407600180201       EndSr;
407700180201       //-------------------------------------------------------------------------------------------
407800180201
407900180201      /Eject
408000180201       //-------------------------------------------------------------------------------------------
408100180201       // Convert ON-ERROR.
408200180201       //-------------------------------------------------------------------------------------------
408300180201       BegSr subUserCvt_ON_ERROR;
408400180201
408500180201          If extFactor2 = *Blanks;
408600180201             sourceLine = %trim(operator) + ';';
408700180201          Else;
408800180201             sourceLine = %trim(operator) + ' ' + %trim(extFactor2) + ';';
408900180201          EndIf;
409000180201
409100180201          convert = *On;
409200180201
409300180201       EndSr;
409400180201       //-------------------------------------------------------------------------------------------
409500180201
409600180201      /Eject
409700180201       //-------------------------------------------------------------------------------------------
409800180201       // Convert OPEN.
409900180201       //-------------------------------------------------------------------------------------------
410000180201       BegSr subUserCvt_OPEN;
410100180201
410200180201          sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
410300180201
410400180201          // Check resulting indicators?
410500180201          If lw <> *Blanks;
410600180201             ERRCheck = *On;
410700180201             ERRInd = lw;
410800180201          EndIf;
410900180201
411000180201          convert = *On;
411100180201
411200180201       EndSr;
411300180201       //-------------------------------------------------------------------------------------------
411400180201
411500180201      /Eject
411600180201       //-------------------------------------------------------------------------------------------
411700180201       // Convert OTHER.
411800180201       //-------------------------------------------------------------------------------------------
411900180201       BegSr subUserCvt_OTHER;
412000180201
412100180201          sourceLine = 'Other;';
412200180201
412300180201          convert = *On;
412400180201
412500180201       EndSr;
412600180201       //-------------------------------------------------------------------------------------------
412700180201
412800180201      /Eject
412900180201       //-------------------------------------------------------------------------------------------
413000180201       // Convert OUT.
413100180201       //-------------------------------------------------------------------------------------------
413200180201       BegSr subUserCvt_OUT;
413300180201
413400180201          If factor1 = *Blanks;
413500180201             sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
413600180201          Else;
413700180201             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
413800180201                        + %trim(factor2) + ';';
413900180201          EndIf;
414000180201
414100180201          // Set resulting indicators?
414200180201          If lw <> *Blanks;
414300180201             ERRCheck = *On;
414400180201             ERRInd = lw;
414500180201          EndIf;
414600180201
414700180201          convert = *On;
414800180201
414900180201       EndSr;
415000180201       //-------------------------------------------------------------------------------------------
415100180201
415200180201      /Eject
415300180201       //-------------------------------------------------------------------------------------------
415400180201       // Convert POST.
415500180201       //-------------------------------------------------------------------------------------------
415600180201       BegSr subUserCvt_POST;
415700180201
415800180201          If factor2 = *Blanks;
415900180201             nonConvRsn =  'No filename specified in Factor2.';
416000180201             LeaveSr;
416100180201          EndIf;
416200180201
416300180201          If result <> *Blanks;
416400180201             nonConvRsn =  'INFDS specified in result.';
416500180201             LeaveSr;
416600180201          EndIf;
416700180201
416800180201          If factor1 = *Blanks;
416900180201             sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
417000180201          Else;
417100180201             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
417200180201                        + %trim(factor2) + ';';
417300180201          EndIf;
417400180201
417500180201          // Set resulting indicators?
417600180201          If lw <> *Blanks;
417700180201             ERRCheck = *On;
417800180201             ERRInd = lw;
417900180201          EndIf;
418000180201
418100180201          convert = *On;
418200180201
418300180201       EndSr;
418400180201       //-------------------------------------------------------------------------------------------
418500180201
418600180201      /Eject
418700180201       //-------------------------------------------------------------------------------------------
418800180201       // Convert READ.
418900180201       //-------------------------------------------------------------------------------------------
419000180201       BegSr subUserCvt_READ;
419100180201
419200180201          If factor1 <> *Blanks;
419300180201             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
419400180201                        + %trim(factor2);
419500180201          Else;
419600180201             sourceLine = %trim(operator) + ' ' + %trim(factor2);
419700180201          EndIf;
419800180201
419900180201          // Append datastructure?
420000180201          If result <> *Blanks;
420100180201             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
420200180201          Else;
420300180201             sourceLine = %trim(sourceLine)  + ';';
420400180201          EndIf;
420500180201
420600180201          // Check indicators?
420700180201          If eq <> *Blanks;
420800180201             EOFCheck = *On;
420900180201             EOFInd = eq;
421000180201             EOFFile = %trim(factor2);
421100180201          EndIf;
421200180201          If lw <> *Blanks;
421300180201             ERRCheck = *On;
421400180201             ERRInd = lw;
421500180201          EndIf;
421600180201
421700180201          convert = *On;
421800180201
421900180201       EndSr;
422000180201       //-------------------------------------------------------------------------------------------
422100180201
422200180201      /Eject
422300180201       //-------------------------------------------------------------------------------------------
422400180201       // Convert REALLOC.
422500180201       //-------------------------------------------------------------------------------------------
422600180201       BegSr subUserCvt_REALLOC;
422700180201
422800180201          sourceLine = %trim(result) + ' = %realloc(' + %trim(factor2)
422900180201                     + ');';
423000180201
423100180201          // Set resulting indicators?
423200180201          If lw <> *Blanks;
423300180201             ERRCheck = *On;
423400180201             ERRInd = lw;
423500180201          EndIf;
423600180201
423700180201          convert = *On;
423800180201
423900180201       EndSr;
424000180201       //-------------------------------------------------------------------------------------------
424100180201
424200180201      /Eject
424300180201       //-------------------------------------------------------------------------------------------
424400180201       // Convert REL.
424500180201       //-------------------------------------------------------------------------------------------
424600180201       BegSr subUserCvt_REL;
424700180201
424800180201          sourceLine = %trim(operator) + ' ' + %trim(factor1)
424900180201                     + ' ' + %trim(factor2) + ';';
425000180201
425100180201          // Check resulting indicators?
425200180201          If lw <> *Blanks;
425300180201             ERRCheck = *On;
425400180201             ERRInd = lw;
425500180201          EndIf;
425600180201
425700180201          convert = *On;
425800180201
425900180201       EndSr;
426000180201       //-------------------------------------------------------------------------------------------
426100180201
426200180201      /Eject
426300180201       //-------------------------------------------------------------------------------------------
426400180201       // Convert RESET.
426500180201       //-------------------------------------------------------------------------------------------
426600180201       BegSr subUserCvt_RESET;
426700180201
426800180201          sourceLine = %trim(operator);
426900180201
427000180201          If factor1 <> *Blanks;
427100180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1);
427200180201          EndIf;
427300180201
427400180201          If factor2 <> *Blanks;
427500180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor2);
427600180201          EndIf;
427700180201
427800180201          sourceLine = %trimr(sourceLine) + ' ' + %trim(result) + ';';
427900180201
428000180201          // Check indicators?
428100180201          If hi <> *Blanks;
428200180201             NRFCheck = *On;
428300180201             NRFInd = eq;
428400180201             NRFFile = %trim(factor2);
428500180201          EndIf;
428600180201          If lw <> *Blanks;
428700180201             ERRCheck = *On;
428800180201             ERRInd = lw;
428900180201          EndIf;
429000180201
429100180201          convert = *On;
429200180201
429300180201       EndSr;
429400180201       //-------------------------------------------------------------------------------------------
429500180201
429600180201      /Eject
429700180201       //-------------------------------------------------------------------------------------------
429800180201       // Convert RETURN;
429900180201       //-------------------------------------------------------------------------------------------
430000180201       BegSr subUserCvt_RETURN;
430100180201
430200180201          sourceLine = 'Return ' + %trim(%subst(operator:7))
430300180201                     + ' ' + %trim(extFactor2) + ';';
430400180201
430500180201          convert = *On;
430600180201
430700180201       EndSr;
430800180201       //-------------------------------------------------------------------------------------------
430900180201
431000180201      /Eject
431100180201       //-------------------------------------------------------------------------------------------
431200180201       // Convert ROLBK.
431300180201       //-------------------------------------------------------------------------------------------
431400180201       BegSr subUserCvt_ROLBK;
431500180201
431600180201          sourceLine = %trim(operator) + ' ' + %trim(factor1);
431700180201
431800180201          sourceLine = %trim(sourceLine)  + ';';
431900180201
432000180201          // Check indicators?
432100180201          If lw <> *Blanks;
432200180201             ERRCheck = *On;
432300180201             ERRInd = lw;
432400180201          EndIf;
432500180201
432600180201          convert = *On;
432700180201
432800180201       EndSr;
432900180201       //-------------------------------------------------------------------------------------------
433000180201
433100180201      /Eject
433200180201       //-------------------------------------------------------------------------------------------
433300180201       // Convert SCAN.
433400180201       //-------------------------------------------------------------------------------------------
433500180201       BegSr subUserCvt_SCAN;
433600180201
433700180201          // Determine length of comparator.
433800180201          x = %scan(':':factor1);
433900180201          If x = 0;   // No length specified.
434000180201             scanLength = *Blanks;               // Scan length
434100180201             scanString = %trim(factor1);        // Scan string
434200180201          Else;
434300180201             scanLength = %subst(factor1:x+1);   // Scan length
434400180201             scanString = %subst(factor1:1:x-1); // Scan string
434500180201          EndIf;
434600180201
434700180201          // Determine starting point.
434800180201          x = %scan(':':factor2);
434900180201          If x = 0;   // No start specified.
435000180201             scanStart = '1';                    // Start position
435100180201             scanBase = %trim(factor2);          // Base string
435200180201          Else;
435300180201             scanStart = %subst(factor2:x+1);    // Start position
435400180201             scanBase = %subst(factor2:1:x-1);   // Base string
435500180201          EndIf;
435600180201
435700180201          // Build the new line.
435800180201          If scanLength = *Blanks;
435900180201             // No length specified.
436000180201             sourceLine = '%scan(' + %trim(scanString)
436100180201                        + ':' + %trim(scanBase) + ':' + %trim(scanStart)
436200180201                        + ')';
436300180201          Else;
436400180201             // Use a subset of the scan string.
436500180201             sourceLine = '%scan(%subst('
436600180201                        + %trim(scanString) + ':1:' + %trim(scanLength)
436700180201                        + '):' + %trim(scanBase) + ':' + %trim(scanStart)
436800180201                        + ')';
436900180201          EndIf;
437000180201
437100180201          // Result specified?
437200180201          If result = *Blanks;
437300180201             scanNoResult = *On;
437400180201             sourceLine = 'If ' + %trimr(sourceLine) + ' = 0;';
437500180201          Else;
437600180201             scanNoResult = *Off;
437700180201             sourceLine = %trim(result) + ' = ' + %trimr(sourceLine) + ';';
437800180201          EndIf;
437900180201
438000180201          // Set resulting indicators?
438100180201          If lw <> *Blanks;
438200180201             ERRCheck = *On;
438300180201             ERRInd = lw;
438400180201          EndIf;
438500180201          If eq <> *Blanks;
438600180201             foundCheck = *On;
438700180201             foundInd = eq;
438800180201          EndIf;
438900180201
439000180201          convert = *On;
439100180201
439200180201       EndSr;
439300180201       //-------------------------------------------------------------------------------------------
439400180201
439500180201      /Eject
439600180201       //-------------------------------------------------------------------------------------------
439700180201       // Convert SELECT
439800180201       //-------------------------------------------------------------------------------------------
439900180201       BegSr subUserCvt_SELECT;
440000180201
440100180201          sourceLine = 'Select;';
440200180201
440300180201          convert = *On;
440400180201
440500180201       EndSr;
440600180201       //-------------------------------------------------------------------------------------------
440700180201
440800180201      /Eject
440900180201       //-------------------------------------------------------------------------------------------
441000180201       // Convert SETOFF
441100180201       //-------------------------------------------------------------------------------------------
441200180201       BegSr subUserCvt_SETOFF;
441300180201
441400180201          setOff = *On;
441500180201          setOffInd1 = hi;
441600180201          setOffInd2 = lw;
441700180201          setOffInd3 = eq;
441800180201
441900180201          dropLine = *On;
442000180201
442100180201          convert = *On;
442200180201
442300180201       EndSr;
442400180201       //-------------------------------------------------------------------------------------------
442500180201
442600180201      /Eject
442700180201       //-------------------------------------------------------------------------------------------
442800180201       // Convert SETON
442900180201       //-------------------------------------------------------------------------------------------
443000180201       BegSr subUserCvt_SETON;
443100180201
443200180201          setOn = *On;
443300180201          setOnInd1 = hi;
443400180201          setOnInd2 = lw;
443500180201          setOnInd3 = eq;
443600180201
443700180201          dropLine = *On;
443800180201
443900180201          convert = *On;
444000180201
444100180201       EndSr;
444200180201       //-------------------------------------------------------------------------------------------
444300180201
444400180201      /Eject
444500180201       //-------------------------------------------------------------------------------------------
444600180201       // Convert SETxx.
444700180201       //-------------------------------------------------------------------------------------------
444800180201       BegSr subUserCvt_SETxx;
444900180201
445000180201          sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
445100180201                     + %trim(factor2);
445200180201          If result <> *Blanks;
445300180201             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
445400180201          Else;
445500180201             sourceLine = %trim(sourceLine)  + ';';
445600180201          EndIf;
445700180201
445800180201          // Check resulting indicators.
445900180201          If hi <> *Blanks;
446000180201             NRFCheck = *On;
446100180201             NRFInd = hi;
446200180201             NRFFile = %trim(factor2);
446300180201          EndIf;
446400180201          If eq <> *Blanks;
446500180201             equalCheck = *On;
446600180201             equalInd = eq;
446700180201          EndIf;
446800180201          If lw <> *Blanks;
446900180201             ERRCheck = *On;
447000180201             ERRInd = lw;
447100180201          EndIf;
447200180201
447300180201          convert = *On;
447400180201
447500180201       EndSr;
447600180201       //-------------------------------------------------------------------------------------------
447700180201
447800180201      /Eject
447900180201       //-------------------------------------------------------------------------------------------
448000180201       // Convert SHTDN
448100180201       //-------------------------------------------------------------------------------------------
448200180201       BegSr subUserCvt_SHTDN;
448300180201
448400180201          sourceLine = '*IN' + hi + ' = %shtdn();';
448500180201
448600180201          convert = *On;
448700180201
448800180201       EndSr;
448900180201       //-------------------------------------------------------------------------------------------
449000180201
449100180201      /Eject
449200180201       //-------------------------------------------------------------------------------------------
449300180201       // Convert SORTA.
449400180201       //-------------------------------------------------------------------------------------------
449500180201       BegSr subUserCvt_SORTA;
449600180201
449700180201          sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
449800180201
449900180201          sourceLine = %trim(sourceLine)  + ';';
450000180201
450100180201          convert = *On;
450200180201
450300180201       EndSr;
450400180201       //-------------------------------------------------------------------------------------------
450500180201
450600180201      /Eject
450700180201       //-------------------------------------------------------------------------------------------
450800180201       // Convert SQRT.
450900180201       //-------------------------------------------------------------------------------------------
451000180201       BegSr subUserCvt_SQRT;
451100180201
451200180201          sourceLine = %trim(result) + ' = %sqrt(' + %trim(factor2) + ');';
451300180201
451400180201          convert = *On;
451500180201
451600180201       EndSr;
451700180201       //-------------------------------------------------------------------------------------------
451800180201
451900180201      /Eject
452000180201       //-------------------------------------------------------------------------------------------
452100180201       // Convert SUB.
452200180201       //-------------------------------------------------------------------------------------------
452300180201       BegSr subUserCvt_SUB;
452400180201
452500180201          // Half-adjust?
452600180201          x = %scan('H':operator:4);
452700180201          If x > 0;
452800180201             operator = 'SUB';
452900180201             sourceLine = 'Eval(H)';
453000180201          Else;
453100180201             sourceLine = *Blanks;
453200180201          EndIf;
453300180201
453400180201          If factor1 = *Blanks;
453500180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
453600180201                        + ' = ' + %trim(result)
453700180201                        + ' - ' + %trim(factor2) +';';
453800180201          Else;
453900180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
454000180201                        + ' = ' + %trim(factor1)
454100180201                        + ' - ' + %trim(factor2) + ';';
454200180201          EndIf;
454300180201
454400180201          sourceLine = %trim(sourceLine);
454500180201
454600180201          convert = *On;
454700180201
454800180201       EndSr;
454900180201       //-------------------------------------------------------------------------------------------
455000180201
455100180201      /Eject
455200180201       //-------------------------------------------------------------------------------------------
455300180201       // Convert SUBDUR.
455400180201       //-------------------------------------------------------------------------------------------
455500180201       BegSr subUserCvt_SUBDUR;
455600180201
455700180201          // Split out duration and code.
455800180201          x = %scan(':':factor2);
455900180201          If x = 0;
456000180201             x = %scan(':':result);
456100180201             If x = 0;
456200180201                nonConvRsn =  'No duration code specified.';
456300180201                LeaveSr;
456400180201             Else;
456500180201                durNewDate = *Off;
456600180201             EndIf;
456700180201          Else;
456800180201             durNewDate = *On;
456900180201          EndIf;
457000180201
457100180201          If durNewDate;
457200180201             durDuration = %trim(%subst(factor2:1:x-1));
457300180201             durCode     = %xlate(lo:up:%trim(%subst(factor2:x+1)));
457400180201
457500180201             Select;
457600180201                When durCode = '*Y' or durCode = '*YEARS';
457700180201                   durCode = '%years';
457800180201                When durCode = '*M' or durCode = '*MONTHS';
457900180201                   durCode = '%months';
458000180201                When durCode = '*D' or durCode = '*DAYS';
458100180201                   durCode = '%days';
458200180201                When durCode = '*H' or durCode = '*HOURS';
458300180201                   durCode = '%hours';
458400180201                When durCode = '*MN' or durCode = '*MINUTES';
458500180201                   durCode = '%minutes';
458600180201                When durCode = '*S' or durCode = '*SECONDS';
458700180201                   durCode = '%seconds';
458800180201                When durCode = '*MS' or durCode = '*MSECONDS';
458900180201                   durCode = '%mseconds';
459000180201                Other;
459100180201                   nonConvRsn = 'Invalid duration code specified.';
459200180201                   LeaveSr;
459300180201             EndSl;
459400180201
459500180201             If factor1 = *Blanks;
459600180201                sourceLine = %trim(result) + ' = ' + %trim(result);
459700180201             Else;
459800180201                sourceLine = %trim(result) + ' = ' + %trim(factor1);
459900180201             EndIf;
460000180201
460100180201             sourceLine = %trimr(sourceLine) + ' - ' + %trim(durCode)
460200180201                        + '(' + %trim(durDuration) + ');';
460300180201          Else;
460400180201             durDuration = %trim(%subst(result:1:x-1));
460500180201             durCode     = %xlate(lo:up:%trim(%subst(result:x+1)));
460600180201
460700180201             Select;
460800180201                When durCode = '*Y' or durCode = '*YEARS';
460900180201                When durCode = '*M' or durCode = '*MONTHS';
461000180201                When durCode = '*D' or durCode = '*DAYS';
461100180201                When durCode = '*H' or durCode = '*HOURS';
461200180201                When durCode = '*MN' or durCode = '*MINUTES';
461300180201                When durCode = '*S' or durCode = '*SECONDS';
461400180201                When durCode = '*MS' or durCode = '*MSECONDS';
461500180201                Other;
461600180201                   nonConvRsn = 'Invalid duration code specified.';
461700180201                   LeaveSr;
461800180201             EndSl;
461900180201
462000180201             sourceLine = %trim(durDuration) + ' = %diff(' + %trim(factor1)
462100180201                        + ':' + %trim(factor2) + ':' + %trim(durCode) + ');';
462200180201          EndIf;
462300180201
462400180201          // Set resulting indicators?
462500180201          If lw <> *Blanks;
462600180201             ERRCheck = *On;
462700180201             ERRInd = lw;
462800180201          EndIf;
462900180201
463000180201          convert = *On;
463100180201
463200180201       EndSr;
463300180201       //-------------------------------------------------------------------------------------------
463400180201
463500180201      /Eject
463600180201       //-------------------------------------------------------------------------------------------
463700180201       // Convert SUBST.
463800180201       //-------------------------------------------------------------------------------------------
463900180201       BegSr subUserCvt_SUBST;
464000180201
464100180201          // Pad the result?
464200180201          x = %scan('P':operator:4);
464300180201          If x = 0                                              // Not padding.
464400180201          and factor1 <> *Blanks                                // Factor1 specified.
464500180201          and %xlate(lo:up:factor1) <> %xlate(lo:hi:result);    // Factor1 not the same as result
464600180201             nonConvRsn = 'No padding specified, and factor1 and result '
464700180201                        + 'are not the same.';
464800180201             LeaveSr;    // Don't convert - too difficult to get right.
464900180201          EndIf;
465000180201
465100180201          substLen = %trim(factor1);
465200180201
465300180201          x = %scan(':':factor2);
465400180201          If x = 0;
465500180201             substStart = '1';
465600180201             x = %len(%trim(factor2)) + 1;
465700180201          Else;
465800180201             substStart = %subst(factor2:x+1);
465900180201          EndIf;
466000180201
466100180201          sourceLine = %trim(result) + ' = %subst('
466200180201                     + %subst(factor2:1:x-1) + ':'
466300180201                     + %trim(substStart)
466400180201                     + ':' + %trim(substLen) + ');';
466500180201
466600180201          // Set resulting indicators?
466700180201          If lw <> *Blanks;
466800180201             ERRCheck = *On;
466900180201             ERRInd = lw;
467000180201          EndIf;
467100180201
467200180201          convert = *On;
467300180201
467400180201       EndSr;
467500180201       //-------------------------------------------------------------------------------------------
467600180201
467700180201      /Eject
467800180201       //-------------------------------------------------------------------------------------------
467900180201       // Convert TEST.
468000180201       //-------------------------------------------------------------------------------------------
468100180201       BegSr subUserCvt_TEST;
468200180201
468300180201          If operator = 'TEST';
468400180201             operator = 'Test(E)';
468500180201          EndIf;
468600180201
468700180201          sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
468800180201                     + %trim(result) + ';';
468900180201
469000180201          // Set resulting indicators?
469100180201          If lw <> *Blanks;
469200180201             ERRCheck = *On;
469300180201             ERRInd = lw;
469400180201          EndIf;
469500180201
469600180201          convert = *On;
469700180201
469800180201       EndSr;
469900180201       //-------------------------------------------------------------------------------------------
470000180201
470100180201      /Eject
470200180201       //-------------------------------------------------------------------------------------------
470300180201       // Convert TIME.
470400180201       //-------------------------------------------------------------------------------------------
470500180201       BegSr subUserCvt_TIME;
470600180201
470700180201          sourceLine = %trim(result) + ' = %time();';
470800180201
470900180201          convert = *On;
471000180201
471100180201       EndSr;
471200180201       //-------------------------------------------------------------------------------------------
471300180201
471400180201      /Eject
471500180201       //-------------------------------------------------------------------------------------------
471600180201       // Convert UNLOCK.
471700180201       //-------------------------------------------------------------------------------------------
471800180201       BegSr subUserCvt_UNLOCK;
471900180201
472000180201          sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
472100180201
472200180201          // Check indicators?
472300180201          If lw <> *Blanks;
472400180201             ERRCheck = *On;
472500180201             ERRInd = lw;
472600180201          EndIf;
472700180201
472800180201          convert = *On;
472900180201
473000180201       EndSr;
473100180201       //-------------------------------------------------------------------------------------------
473200180201
473300180201      /Eject
473400180201       //-------------------------------------------------------------------------------------------
473500180201       // Convert UPDATE.
473600180201       //-------------------------------------------------------------------------------------------
473700180201       BegSr subUserCvt_UPDATE;
473800180201
473900180201          sourceLine = %trim(operator) + ' ' + %trim(factor2);
474000180201
474100180201          // Append datastructure?
474200180201          If result <> *Blanks;
474300180201             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
474400180201          Else;
474500180201             sourceLine = %trim(sourceLine)  + ';';
474600180201          EndIf;
474700180201
474800180201          // Check indicators?
474900180201          If lw <> *Blanks;
475000180201             ERRCheck = *On;
475100180201             ERRInd = lw;
475200180201          EndIf;
475300180201
475400180201          convert = *On;
475500180201
475600180201       EndSr;
475700180201       //-------------------------------------------------------------------------------------------
475800180201
475900180201      /Eject
476000180201       //-------------------------------------------------------------------------------------------
476100180201       // Convert WHEN.
476200180201       //-------------------------------------------------------------------------------------------
476300180201       BegSr subUserCvt_WHEN;
476400180201
476500180201          // Returning for a multi-line IF?  Reinstate original opcode.
476600180201          If inWhen;
476700180201             operator = whenOperator;
476800180201          EndIf;
476900180201
477000180201          Exsr subUserCheckSpan;  // Does this line span more than one line?
477100180201
477200180201          If operator = 'WHEN';     // Use Extended Factor2.
477300180201             If not inWhen;            // First line of IF.
477400180201                sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
477500180201                If not inSpan;
477600180201                   sourceLine = %trim(sourceLine) + ';';
477700180201                Else;
477800180201                   inWhen = *On;
477900180201                   inSpan = *Off;
478000180201                EndIf;
478100180201             Else;                   // Second line of WHEN.
478200180201                //            sourceLine = *Blanks;
478300180201                //            %subst(sourceLine:40) = %trim(extFactor2);
478400180201                sourceLine = %trim(extFactor2);
478500180201                If not inSpan;
478600180201                   sourceLine = %trimr(sourceLine) + ';';
478700180201                   //               inWhen = *Off;
478800180201                EndIf;
478900180201                inSpan = *Off;
479000180201             EndIf;
479100180201          Else;
479200180201             // Fixed format.
479300180201             opCode = %xlate(lo:up:opCode);
479400180201             If not inWhen;         // First line of WHEN.
479500180201                whenCompare = %subst(opCode:5:2);
479600180201                sourceLine = 'When';
479700180201             Else;                // Second line of WHEN.
479800180201                If %subst(opCode:1:3) = 'AND';
479900180201                   whenCompare = %subst(opCode:4:2);
480000180201                   sourceLine = 'And';
480100180201                Else;
480200180201                   whenCompare = %subst(opCode:3:2);
480300180201                   sourceLine = 'Or';
480400180201                EndIf;
480500180201             EndIf;
480600180201             If whenCompare = 'EQ';
480700180201                whenCompare = '=';
480800180201             ElseIf whenCompare = 'GT';
480900180201                whenCompare = '>';
481000180201             ElseIf whenCompare = 'GE';
481100180201                whenCompare = '>=';
481200180201             ElseIf whenCompare = 'LT';
481300180201                whenCompare = '<';
481400180201             ElseIf whenCompare = 'LE';
481500180201                whenCompare = '<=';
481600180201             ElseIf whenCompare = 'NE';
481700180201                whenCompare = '<>';
481800180201             EndIf;
481900180201             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
482000180201                                + ' ' + %trim(whenCompare) + ' '
482100180201                                + %trim(factor2);
482200180201             If not inSpan;
482300180201                sourceLine = %trimr(sourceLine) + ';';
482400180201                inWhen = *Off;
482500180201             Else;
482600180201                inWhen = *On;
482700180201                inSpan = *Off;
482800180201             EndIf;
482900180201          EndIf;
483000180201
483100180201          // Multi-line IF?  Retain original opcode.
483200180201          If inWhen;
483300180201             whenOperator = operator;
483400180201          Else;
483500180201             whenOperator = *Blanks;
483600180201          EndIf;
483700180201
483800180201          convert = *On;
483900180201
484000180201       EndSr;
484100180201       //-------------------------------------------------------------------------------------------
484200180201
484300180201      /Eject
484400180201       //-------------------------------------------------------------------------------------------
484500180201       // Convert WRITE.
484600180201       //-------------------------------------------------------------------------------------------
484700180201       BegSr subUserCvt_WRITE;
484800180201
484900180201          sourceLine = %trim(operator) + ' ' + %trim(factor2);
485000180201
485100180201          // Append datastructure?
485200180201          If result <> *Blanks;
485300180201             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
485400180201          Else;
485500180201             sourceLine = %trim(sourceLine)  + ';';
485600180201          EndIf;
485700180201
485800180201          // Check indicators?
485900180201          If eq <> *Blanks;
486000180201             EOFCheck = *On;
486100180201             EOFInd = eq;
486200180201             EOFFile = %trim(factor2);
486300180201          EndIf;
486400180201          If lw <> *Blanks;
486500180201             ERRCheck = *On;
486600180201             ERRInd = lw;
486700180201          EndIf;
486800180201
486900180201          convert = *On;
487000180201
487100180201       EndSr;
487200180201       //-------------------------------------------------------------------------------------------
487300180201
487400180201      /Eject
487500180201       //-------------------------------------------------------------------------------------------
487600180201       // Convert XFOOT.
487700180201       //-------------------------------------------------------------------------------------------
487800180201       BegSr subUserCvt_XFOOT;
487900180201
488000180201          If %scan('H':operator) = 0;
488100180201             sourceLine = %trim(result) + ' = %xfoot(' + %trim(factor2)
488200180201                        + ');';
488300180201          Else;
488400180201             // Half-adjust.
488500180201             sourceLine = 'Eval(H) ' + %trim(result) + ' = %xfoot('
488600180201                        + %trim(factor2) + ');';
488700180201          EndIf;
488800180201
488900180201          convert = *On;
489000180201
489100180201       EndSr;
489200180201       //-------------------------------------------------------------------------------------------
489300180201
489400180201      /Eject
489500180201       //-------------------------------------------------------------------------------------------
489600180201       // Convert XLATE.
489700180201       //-------------------------------------------------------------------------------------------
489800180201       BegSr subUserCvt_XLATE;
489900180201
490000180201          //      // Pad the result?
490100180201          //      x = %scan('P':operator:6);
490200180201          //      If x > 0;
490300180201          //         padResult = *On;
490400180201          //         padTarget = result;
490500180201          //         // Drop the extender.
490600180201          //         operator = 'XLATE';
490700180201          //      EndIf;
490800180201
490900180201          // Derive from and to.
491000180201          x = %scan(':':factor1);
491100180201          If x = 0;
491200180201             LeaveSr;    // Invalid specification - there MUST be a from and to - don't convert.
491300180201          Else;
491400180201             xlateFrom = %subst(factor1:1:x-1);
491500180201             xlateTo = %subst(factor1:x+1);
491600180201          EndIf;
491700180201
491800180201          // Check for start position.
491900180201          x = %scan(':':factor2);
492000180201          If x = 0;
492100180201             xlateStart = *Blanks;
492200180201             xlateBase = factor2;
492300180201          Else;
492400180201             xlateStart = %subst(factor2:x+1);
492500180201             xlateBase = %subst(factor2:1:x-1);
492600180201          EndIf;
492700180201
492800180201          // Build new line.
492900180201          sourceLine = %trim(result) + ' = %xlate('
493000180201                     + %trim(xlateFrom) + ':' + %trim(xlateTo) + ':'
493100180201                     + %trim(xlateBase);
493200180201          If xlateStart <> *Blanks;
493300180201             sourceLine = %trimr(sourceLine) + ':' + %trim(xlateStart);
493400180201          EndIf;
493500180201          sourceLine = %trimr(sourceLine) + ');';
493600180201
493700180201          // Set resulting indicators?
493800180201          If lw <> *Blanks;
493900180201             ERRCheck = *On;
494000180201             ERRInd = lw;
494100180201          EndIf;
494200180201
494300180201          convert = *On;
494400180201
494500180201       EndSr;
494600180201       //-------------------------------------------------------------------------------------------
494700180201
494800180201      /Eject
494900180201       //-------------------------------------------------------------------------------------------
495000180201       // Convert Z-ADD.
495100180201       //-------------------------------------------------------------------------------------------
495200180201       BegSr subUserCvt_Z_ADD;
495300180201
495400180201          sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';
495500180201
495600180201          // Half-adjust required?
495700180201          If %len(%trim(operator)) > 5;
495800180201             sourceLine = 'Eval(H) ' + %trim(sourceLine);
495900180201          EndIf;
496000180201
496100180201          convert = *On;
496200180201
496300180201       EndSr;
496400180201       //-------------------------------------------------------------------------------------------
496500180201
496600180201      /Eject
496700180201       //-------------------------------------------------------------------------------------------
496800180201       // Convert Z-SUB.
496900180201       //-------------------------------------------------------------------------------------------
497000180201       BegSr subUserCvt_Z_SUB;
497100180201
497200180201
497300180201          sourceLine = %trim(result) + ' = ' + %trim(factor2) + ' * -1;';
497400180201
497500180201          // Half-adjust required?
497600180201          If %len(%trim(operator)) > 5;
497700180201             sourceLine = 'Eval(H) ' + %trim(sourceLine);
497800180201          EndIf;
497900180201
498000180201          convert = *On;
498100180201
498200180201       EndSr;
498300180201       //-------------------------------------------------------------------------------------------
498400180201
498500180201      /Eject
498600180201       //-------------------------------------------------------------------------------------------
498700180201       // Check if the next line is a continuation of the current line.
498800180201       //-------------------------------------------------------------------------------------------
498900180201       BegSr subUserCheckSpan;
499000180201
499100180201          inspan = *Off;
499200180201          savedSRCDTA = SRCDTA;
499300180201          savedLineType = %xlate(lo:up:lineType);      // Save current line type for comparison.
499400180201          x = 0;
499500180201
499600180201          // Is the current line a continuation line?
499700180201          If savedLineType = 'D';
499800180201             If declName <> *Blanks;
499900180201                If %scan('...':%trim(declOptions)) > 0;
500000180201                   // Yes - so we must be in a span.
500100180201                   inSpan = *On;
500200180201                EndIf;
500300180201             EndIf;
500400180201          EndIf;
500500180201
500600180201          If not inSpan;
500700180201             Read SRCREC;
500800180201             DoW not %eof();
500900180201                x += 1;     // Keep a track of how many lines we have read.
501000180201
501100180201                lineType = %xlate(lo:up:lineType);
501200180201
501300180201                If lineType <> *Blank
501400180201                and lineType <> savedLineType;
501500180201                   // Not a spanned line.
501600180201                   Leave;
501700180201
501800180201                ElseIf lineType = 'D'
501900180201                and %subst(directive:1:1) <> '*';                       // D-spec and no comment
502000180201                   If declName = *Blanks
502100180201                   and declType = *Blanks
502200180201                   and declLen = *Blanks
502300180201                   and declKeyWords <> *Blanks;
502400180201                      //               and ((declType <> *Blanks and workDeclType = *Blanks)
502500180201                      //                    or (declType <> *Blanks and declType <> workDeclType)
502600180201                      //                    or (declType = *Blanks and declKeyWords <> *Blanks));
502700180201                      inSpan = *On;
502800180201                   EndIf;
502900180201                   Leave;
503000180201
503100180201                ElseIf lineType = 'P'
503200180201                and %subst(directive:1:1) <> '*';                       // P-spec and no comment
503300180201                   If declName = *Blanks
503400180201                   and (procType <> *Blanks or procKeyWords <> *Blanks);
503500180201                      inSpan = *On;
503600180201                   EndIf;
503700180201                   Leave;
503800180201
503900180201                ElseIf lineType = 'H'
504000180201                and %subst(directive:1:1) = *Blank;                     // H-spec and no comment
504100180201                   inSpan = *On;
504200180201                   Leave;
504300180201
504400180201                ElseIf lineType = 'C'
504500180201                and %subst(directive:1:1) = *Blank;                      // C-spec and no comment
504600180201                   opCode = %xlate(lo:up:opCode);
504700180201                   If %subst(operator:1:4) = 'EVAL';
504800180201                      If opCode = *Blanks and extFactor2 <> *Blanks;     // EVAL continues.
504900180201                         inSpan = *On;
505000180201                      EndIf;
505100180201                      Leave;
505200180201                   ElseIf %subst(operator:1:6) = 'CALLP';
505300180201                      If opCode = *Blanks;                               // CALLP continues.
505400180201                         inSpan = *On;
505500180201                      EndIf;
505600180201                      Leave;
505700180201                   ElseIf operator = 'IF';                               // IF Continues.
505800180201                      If opCode = *Blanks;
505900180201                         inSpan = *On;
506000180201                      EndIf;
506100180201                      Leave;
506200180201                   ElseIf %subst(operator:1:2) = 'IF';                   // IF Continues.
506300180201                      If %subst(opCode:1:2) = 'OR'
506400180201                      or %subst(opCode:1:3) = 'AND'
506500180201                      or opCode = *Blanks;
506600180201                         inSpan = *On;
506700180201                      EndIf;
506800180201                      Leave;
506900180201                   ElseIf %subst(operator:1:2) = 'DO';                   // DO Continues.
507000180201                      If %subst(opCode:1:2) = 'OR'
507100180201                      or %subst(opCode:1:3) = 'AND'
507200180201                      or opCode = *Blanks;
507300180201                         inSpan = *On;
507400180201                      EndIf;
507500180201                      Leave;
507600180201                   ElseIf %subst(operator:1:4) = 'WHEN';                 // WHEN Continues.
507700180201                      If %subst(opCode:1:2) = 'OR'
507800180201                      or %subst(opCode:1:3) = 'AND'
507900180201                      or opCode = *Blanks;
508000180201                         inSpan = *On;
508100180201                      EndIf;
508200180201                      Leave;
508300180201                   EndIf;
508400180201
508500180201                ElseIf lineType = 'C'
508600180201                and %subst(directive:1:1) = '+';                        // Embedded SQL
508700180201                   inSpan = *On;
508800180201                   Leave;
508900180201
509000180201                ElseIf lineType = 'F'
509100180201                and %subst(directive:1:1) <> '*';                       // F-spec and no comment
509200180201                   If fileName = *Blanks and fileKeyWords <> *Blanks;
509300180201                      inSpan = *On;
509400180201                   EndIf;
509500180201                   Leave;
509600180201
509700180201                ElseIf %subst(directive:1:1) = '/';          // Directive, so line must end here.
509800180201                   Leave;
509900180201                   //            ElseIf lineType = ' '
510000180201                   //            and opCode <> *Blanks;
510100180201                 //               Leave;                                       // Free-format line.
510200180201                EndIf;
510300180201
510400180201                Read SRCREC;
510500180201             EndDo;
510600180201          EndIf;
510700180201
510800180201          // End of file breaks the logic!  We need to reposition to the last record before
510900180201          // continuing.
511000180201          If %eof(QRPGLESRC);
511100180201             SetGT *HIVAL SRCREC;
511200180201             ReadP SRCREC;
511300180201          EndIf;
511400180201
511500180201          // Return to the previous point.
511600180201          For i = 1 to x;
511700180201             ReadP SRCREC;
511800180201          EndFor;
511900180201
512000180201          SRCDTA = savedSRCDTA;
512100180201
512200180201       EndSr;
512300180201       //-------------------------------------------------------------------------------------------
512400180201
512500180201      /Eject
512600180201       //-------------------------------------------------------------------------------------------
512700180201       // Get the type of declaration encountered - it may not be on the current line!
512800180201       //-------------------------------------------------------------------------------------------
512900180201       BegSr subUserGetDeclarationType;
513000180201
513100180201          // Start with what we've got.
513200180201          If declSuffix  = ' '
513300180201          and (declPrefix = ' '
513400180201          or declPrefix = 'U' or declPrefix = 'S');
513500180201             workDeclType = %xlate(lo:up:declType);
513600180201             savedName = %trim(declName);
513700180201          Else;
513800180201             workDeclType = *Blank;
513900180201             savedName = %trim(%subst(fullLine:1:74));
514000180201          EndIf;
514100180201
514200180201          // If we already have the declaration type, then stop.
514300180201          If workDeclType = 'S'
514400180201          or workDeclType = 'DS'
514500180201          or workDeclType = 'C'
514600180201          or workDeclType = 'B'
514700180201          or workDeclType = 'E'
514800180201          or workDeclType = 'PR'
514900180201          or workDeclType = 'PI'
515000180201          or workDeclType = *Blanks and inPrototype;
515100180201             workDeclLine = SRCSEQ;
515200180201             LeaveSr;
515300180201          EndIf;
515400180201
515500180201          savedSRCDTA = SRCDTA;
515600180201          savedLineType = %xlate(lo:up:lineType);      // Save current line type for comparison.
515700180201          x = 0;
515800180201          workDeclLine = 0;
515900180201
516000180201          //      // Name of the variable/routine should be on this line.
516100180201          //      savedName = %trim(declOptions);
516200180201
516300180201          // Trim any ellipsis from the name as this is not valid in free-form.
516400180201          x = %scan('...':savedName);
516500180201          If x > 0;
516600180201             savedName = %subst(savedName:1:x-1);
516700180201             x = 0;
516800180201          EndIf;
516900180201
517000180201          // Read ahead to find the next line with a declaration type.
517100180201          Read SRCREC;
517200180201          DoW not %eof();
517300180201             x += 1;     // Keep a track of how many lines we have read.
517400180201
517500180201             lineType = %xlate(lo:up:lineType);
517600180201
517700180201             If lineType <> savedLineType;
517800180201                // End of this declaration.
517900180201                Leave;
518000180201             EndIf;
518100180201
518200180201             If declType <> *Blanks;
518300180201                workDeclType = %xlate(lo:up:declType);
518400180201                workDeclLine = SRCSEQ;
518500180201                Leave;
518600180201             EndIf;
518700180201
518800180201             Read SRCREC;
518900180201          EndDo;
519000180201
519100180201          // End of file breaks the logic!  We need to reposition to the last record before
519200180201          // continuing.
519300180201          If %eof(QRPGLESRC);
519400180201             SetGT *HIVAL SRCREC;
519500180201             ReadP SRCREC;
519600180201          EndIf;
519700180201
519800180201          // Return to the previous point.
519900180201          For i = 1 to x;
520000180201             ReadP SRCREC;
520100180201          EndFor;
520200180201
520300180201          SRCDTA = savedSRCDTA;
520400180201
520500180201       EndSr;
520600180201       //-------------------------------------------------------------------------------------------
520700180201
520800180201      /Eject
520900180201       //-------------------------------------------------------------------------------------------
521000180201       // Get the line number at which the current structure ends.
521100180201       //-------------------------------------------------------------------------------------------
521200180201       BegSr subUserGetEndLine;
521300180201
521400180201          savedSRCDTA = SRCDTA;
521500180201          endLine = 0;
521600180201          endFound = *Off;
521700180201
521800180201          // Read ahead to find the start of the next declaration.
521900180201          Read SRCREC;
522000180201          x = 1;
522100180201          DoW not %eof();
522200180201             If lineType <> *Blanks
522300180201             and %xlate(lo:up:lineType) <> workLineType;
522400180201                // We've found a different line type.
522500180201                Leave;
522600180201             Else;
522700180201                If %len(%trim(codeLine)) >= 4;
522800180201                   If %xlate(lo:up:%subst(codeLine:1:4)) = 'DCL-';
522900180201                      // We've found a different line type.
523000180201                      Leave;
523100180201                   EndIf;
523200180201                EndIf;
523300180201             EndIf;
523400180201
523500180201             If codeLine = *Blanks;
523600180201                // Ignore empty lines.
523700180201       //      ElseIf %subst(directive:1:1) = '/';
523800180201       //         // Ignore directives.
523900180201             ElseIf %subst(directive:2:1) = '*'
524000180201                 or %len(%trim(codeLine)) >= 2
524100180201                and %subst(%trim(codeLine):1:2) = '//';
524200180201                // Ignore comment.
524300180201             ElseIf inSpan
524400180201                and declName = *Blanks
524500180201                and SRCSEQ = workDeclLine;
524600180201                // Ignore the curent declaration.
524700180201             ElseIf declType = *Blanks
524800180201                and (declLen <> *Blanks or declKeywords <> *Blanks);
524900180201                // Ignore sub-field definition.
525000180201             ElseIf declType = *Blanks
525100180201                and declName <> *Blanks
525200180201                and %scan('...':declOptions) = 0;
525300180201                // Ignore sub-field definition.
525400180201             ElseIf %scan('...':declOptions) > 0;
525500180201                // We have a continuation line, but is it a sub-field or a new
525600180201                // delcaration?
525700180201                GetDeclarationType(tempDeclType
525800180201                                  :tempSavedName
525900180201                                  :tempDeclLine);
526000180201                If tempDeclType <> *Blanks;
526100180201                   // We've hit the next declaration or code.
526200180201                   Leave;
526300180201                EndIf;
526400180201             Else;
526500180201                // We've hit the next declaration or code.
526600180201                Leave;
526700180201             EndIf;
526800180201
526900180201             Read SRCREC;
527000180201             x += 1;     // Keep a track of how many lines we have read.
527100180201          EndDo;
527200180201
527300180201          // We are now at the start of the next declaration.
527400180201          endLine = SRCSEQ;
527500180201
527600180201          // End of file breaks the logic!  We need to reposition to the last record before
527700180201          // continuing.
527800180201          If %eof(QRPGLESRC);
527900180201             SetGT *HIVAL SRCREC;
528000180201             //ReadP SRCREC;
528100180201          EndIf;
528200180201
528300180201          // Return to the previous point.
528400180201          For i = 1 to x;
528500180201             ReadP SRCREC;
528600180201
528700180201             // Move the end point for blank lines or comments.
528800180201             If not endFound;
528900180201                If (lineType = *Blanks
529000180201                or %subst(directive:1:1) = '*'
529100180201                or %subst(directive:1:2) = '//'
529200180201                or (%len(%trim(codeLine)) > 0
529300180201                and %subst(%trim(codeLine):1:2) = '//'));
529400180201                   //            and %subst(directive:1:1) <> '/';
529500180201                Else;
529600180201                   endFound = *On;
529700180201                   endLine = SRCSEQ;
529800180201                EndIf;
529900180201             EndIf;
530000180201          EndFor;
530100180201
530200180201          SRCDTA = savedSRCDTA;
530300180201
530400180201       EndSr;
530500180201       //-------------------------------------------------------------------------------------------
530600180201
530700180201      /Eject
530800180201       //-------------------------------------------------------------------------------------------
530900180201       // Move field definitions to D-specs.
531000180201       //-------------------------------------------------------------------------------------------
531100180201       BegSr subUserMoveDefs;
531200180201
531300180201          codeStart = SRCSEQ;   // Save the start of the source.
531400180201          savedSRCDTA = SRCDTA;
531500180201
531600180201          Clear movedDefs;
531700180201          Reset DCLS;
531800180201
531900180201          // Read through the source and create a D-spec for every field definition found.
532000180201          DoW not %eof(QRPGLESRC);
532100180201             // Stop if we hit either the start or end of a procedure (to preserve local
532200180201             // definitions of variables).
532300180201             If lineType = 'P'
532400180201             or %xlate(lo:up:%subst(%trim(codeLine) + '        ':1:8))
532500180201                                                          = 'DCL-PROC'
532600180201             or %xlate(lo:up:%subst(%trim(codeLine) + '        ':1:8))
532700180201                                                          = 'END-PROC';
532800180201                Leave;
532900180201             EndIf;
533000180201
533100180201             If %xlate(lo:up:lineType) = 'C'
533200180201             and %subst(directive:1:1) = ' ';
533300180201                opCode = %xlate(lo:up:opCode);
533400180201                // C-Spec with a size definition.
533500180201                If opCode <> *Blanks
533600180201                and %subst(opCode:1:4) <> 'EVAL'
533700180201                and opCode <> 'IF'
533800180201                and opCode <> 'WHEN'
533900180201                and opCode <> 'DOW'
534000180201                and opCode <> 'DOU'
534100180201                and opCode <> 'DSPLY'
534200180201                and opCode <> 'CALLP'
534300180201                and (len <> *Blanks or opCode = 'DEFINE');
534400180201                   moveDef = *Off;
534500180201                   // Only do if not already moved.
534600180201                   If %lookup(%xlate(lo:up:result):movedDefs) = 0;
534700180201                      Reset DCLS;
534800180201                      // In-line definition.
534900180201                      If len <> *Blanks
535000180201                      and %scan('+':len) = 0 and %scan('-':len) = 0;
535100180201                         moveDef = *On;
535200180201                         DCLS.fieldName = result;
535300180201                         If dec = *Blanks;
535400180201                            DCLS.type = '     Char';
535500180201                         Else;
535600180201                            DCLS.type = '   Packed';
535700180201                         EndIf;
535800180201                         DCLS.definition = '(' + %trim(len);
535900180201                         If dec <> *Blanks;
536000180201                            DCLS.definition = %trimr(DCLS.definition)
536100180201                                            + ':' + %trim(dec);
536200180201                         EndIf;
536300180201                         DCLS.definition = %trimr(DCLS.definition) + ')';
536400180201                      EndIf;
536500180201
536600180201                      // *LIKE Definition
536700180201                      If %xlate(lo:up:opCode) = 'DEFINE';
536800180201                         moveDef = *On;
536900180201                         DCLS.fieldName = result;
537000180201                         If %xlate(lo:up:factor1) = '*LIKE';
537100180201                            %subst(DCLS.definition:8)
537200180201                                        = 'LIKE(' + %trimr(factor2);
537300180201                            // Length adjustment?
537400180201                            If %scan('+':len) > 0 or %scan('-':len) > 0;
537500180201                               len = %scanrpl(' ':'':len);
537600180201                               DCLS.definition = %trimr(DCLS.definition)
537700180201                                               + ':' + %trim(len);
537800180201                            EndIf;
537900180201                            DCLS.definition = %trimr(DCLS.definition) + ')';
538000180201                         Else;
538100180201                            If %xlate(lo:up:%trim(factor2)) = '*LDA';
538200180201                               DCLS.definition = %trimr(DCLS.definition)
538300180201                                     + ' DTAARA(' + %trimr(factor2) + ')';
538400180201                            Else;
538500180201                               DCLS.definition = %trimr(DCLS.definition)
538600180201                                 + ' DTAARA(''' + %trimr(factor2) + ''')';
538700180201                            EndIf;
538800180201                         EndIf;
538900180201                      EndIf;
539000180201
539100180201                      If moveDef;
539200180201                         // Put any additional keywords needed here!
539300180201                         DCLS.definition = %trimr(DCLS.definition) + ';';
539400180201                         If comment <> *Blanks;
539500180201                            DCLS.comment = '// ' + comment;
539600180201                         EndIf;
539700180201
539800180201                         // Store the moved definition.
539900180201                         x = %lookup(' ':movedDefs);
540000180201                         movedDefs(x) = %xlate(lo:up:result);
540100180201                      EndIf;
540200180201                   EndIf;
540300180201                EndIf;
540400180201             EndIf;
540500180201
540600180201             // Anything to output?
540700180201             If DCLS.fieldName <> *Blanks;
540800180201                DCLS.decl = 'Dcl-S ';
540900180201                If not defsMoved;
541000180201                   // Log start of moved field block;
541100180201                   SRCDTA = *Blanks;
541200180201                   codeLine = @comments(1);
541300180201                   Exsr subUserWriteLine;
541400180201                   codeLine = @comments(2);
541500180201                   Exsr subUserWriteLine;
541600180201                   codeLine = @comments(1);
541700180201                   Exsr subUserWriteLine;
541800180201                   defsMoved = *On;
541900180201                EndIf;
542000180201
542100180201                lineType = ' ';
542200180201                codeLine = DCLS;
542300180201                countMoved += 1;
542400180201                Clear DCLS.fieldName;
542500180201
542600180201                Exsr subUserWriteLine;
542700180201             EndIf;
542800180201
542900180201             Read QRPGLESRC;
543000180201          EndDo;
543100180201
543200180201          If defsMoved;
543300180201             // Log end of moved field block;
543400180201             SRCDTA = *Blanks;
543500180201             codeLine = @comments(1);
543600180201             Exsr subUserWriteLine;
543700180201             codeLine = @comments(3);
543800180201             Exsr subUserWriteLine;
543900180201             codeLine = @comments(1);
544000180201             Exsr subUserWriteLine;
544100180201          EndIf;
544200180201
544300180201          // Reposition source file pointer to the start of the source again.
544400180201          Close QRPGLESRC;
544500180201          Open QRPGLESRC;
544600180201          Read SRCREC;
544700180201          DoW SRCSEQ <> codeStart;
544800180201             Read SRCREC;
544900180201          EndDo;
545000180201
545100180201          defsMoved = *On;
545200180201          SRCDTA = savedSRCDTA;
545300180201
545400180201       EndSr;
545500180201       //-------------------------------------------------------------------------------------------
545600180201
545700180201      /Eject
545800180201       //-------------------------------------------------------------------------------------------
545900180201       // Output the current line.
546000180201       //-------------------------------------------------------------------------------------------
546100180201       BegSr subUserWriteLine;
546200180201
546300180201          countTarget += 1;
546400180201
546500180201          Write OUTREC;
546600180201          //Except OUTREC;
546700180201
546800180201       EndSr;
546900180201       //-------------------------------------------------------------------------------------------
547000180201
547100180201      /Eject
547200180201       //-------------------------------------------------------------------------------------------
547300180201       // Exit the program directly.
547400180201       //-------------------------------------------------------------------------------------------
547500180201       BegSr subExitProgram;
547600180201
547700180201          Exsr subUserExitProgram;     // Perform any user-specified exit processing.
547800180201
547900180201          // If commitment control is active, a commit should have been done if everything
548000180201          // was OK, so issue a rollback here to catch and remove any uncommitted changes.
548100180201          If cfgCommitControl = '*MASTER';
548200180201             RolBk;
548300180201          EndIf;
548400180201
548500180201          If cfgCloseDown = 'Y';
548600180201             *INLR = *On;                  // Close down the program.
548700180201          EndIf;
548800180201
548900180201          Return;                          // Exit the program.
549000180201
549100180201       EndSr;
549200180201       //-------------------------------------------------------------------------------------------
549300180201
549400180201      /Eject
549500180201       //-------------------------------------------------------------------------------------------
549600180201       // USER: Exit processing.
549700180201       //-------------------------------------------------------------------------------------------
549800180201       BegSr subUserExitProgram;
549900180201
550000180201          // ** Place any program-specific exit code here.
550100180201          // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
550200180201
550300180201          If @pShutDown <> 'Y';
550400180201             Close QRPGLESRC;
550500180201             Close QRPGLESRC2;
550600180201          EndIf;
550700180201
550800180201          If @pShutDown = 'Y' and initialCall <> 'Y';
550900180201             cfgCloseDown = 'Y';
551000180201             Write Z1ENDRPT;
551100180201             Close CVTRPGFRP1;
551200180201          EndIf;
551300180201
551400180201          // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
551500180201
551600180201       EndSr;
551700180201       //-------------------------------------------------------------------------------------------
551800180201
551900180201      /Eject
552000180201       //-------------------------------------------------------------------------------------------
552100180201       // Initialisation
552200180201       //-------------------------------------------------------------------------------------------
552300180201       BegSr subInitialise;
552400180201
552500180201          // Flag initial call.
552600180201          If initialCall = *Blank;
552700180201             initialCall = 'Y';
552800180201          Else;
552900180201             initialCall = 'N';
553000180201          EndIf;
553100180201
553200180201          // Perform user-specified intialisation processing.
553300180201          Exsr subUserInitialise;
553400180201
553500180201       EndSr;
553600180201       //-------------------------------------------------------------------------------------------
553700180201
553800180201      /Eject
553900180201       //-------------------------------------------------------------------------------------------
554000180201       // USER: Initialisation
554100180201       //-------------------------------------------------------------------------------------------
554200180201       BegSr subUserInitialise;
554300180201
554400180201          // Set configuration/processing options:
554500180201          cfgCommitControl   = '*NONE  '; // Commitment control setting: *MASTER/*SLAVE
554600180201          cfgCloseDown       = 'N';       // Close down the program on exit?
554700180201
554800180201
554900180201          // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
555000180201
555100180201          // Shut down?
555200180201          If @pShutDown = 'Y';
555300180201             Exsr subExitProgram;
555400180201          EndIf;
555500180201
555600180201          // Open audit report.
555700180201          If initialCall = 'Y';
555800180201             Open CVTRPGFRP1;
555900180201             Z1#TTL = 'RPG/ILE to Free-Format Conversion Report';
556000180201             overflow = *On;
556100180201          EndIf;
556200180201
556300180201          fromFileLib = %trim(@pFromLib) + '/' + %trim(@pFromFile);
556400180201          Open QRPGLESRC;
556500180201
556600180201          toFileLib = %trim(@pToLib) + '/' + %trim(@pToFile);
556700180201          Open QRPGLESRC2;
556800180201
556900180201          Reset countSource;
557000180201          Reset countTarget;
557100180201          Reset countEligible;
557200180201          Reset countConv;
557300180201          Reset CountNotConv;
557400180201
557500180201          Reset maxIndent;
557600180201          Reset movedDefs;
557700180201          Reset moveDef;
557800180201          Reset inCode;
557900180201          Reset inArrayData;
558000180201          Reset indentCount;
558100180201
558200180201          indentCount = mainlineIndent;
558300180201
558400180201          // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
558500180201
558600180201       EndSr;
558700180201       //-------------------------------------------------------------------------------------------
558800180201       //===========================================================================================
558900180201
559000180201      /Eject
559100180201       //==========================================================================================
559200180201       // Get the type of declaration encountered - it may not be on the current line!
559300180201       //==========================================================================================
559400180201       Dcl-Proc GetDeclarationType;
559500180201
559600180201       // -- Procedure Interface ------------------------------------------------------------------
559700180201       Dcl-PI GetDeclarationType;
559800180201          @pDeclType               Char( 2 );
559900180201          @pSavedName              Char( 80 );
560000180201          @pDeclLine                        Like(SRCSEQ);
560100180201       End-PI;
560200180201
560300180201       // -- Data Structures ----------------------------------------------------------------------
560400180201
560500180201       // -- Variables ----------------------------------------------------------------------------
560600180201       Dcl-S savedLineType        Char(  1 );
560700180201       Dcl-S x                  Packed( 3:0 );
560800180201       Dcl-S savedSRCDTA          Char( 100 );
560900180201
561000180201       //-------------------------------------------------------------------------------------------
561100180201
561200180201          // Start with what we've got.
561300180201          If ((declExt = ' ' and declPrefix  = ' ')
561400180201          or declPrefix = 'S' or declPrefix = 'U')
561500180201          and declSuffix = ' ';
561600180201             @pDeclType = %xlate(lo:up:declType);
561700180201             @pSavedName = %trim(declName);
561800180201          Else;
561900180201             @pDeclType = *Blank;
562000180201             @pSavedName = %trim(%subst(fullLine:1:74));
562100180201          EndIf;
562200180201
562300180201          x = %scan(' ':@pSavedName);
562400180201          If x > 1;
562500180201             @pSavedName = %subst(@pSavedName:1:x-1);
562600180201          EndIf;
562700180201
562800180201          // If we already have the declaration type, then stop.
562900180201          If @pDeclType = 'S'
563000180201          or @pDeclType = 'DS'
563100180201          or @pDeclType = 'C'
563200180201          or @pDeclType = 'B'
563300180201          or @pDeclType = 'E'
563400180201          or @pDeclType = 'PR'
563500180201          or @pDeclType = 'PI'
563600180201          or @pDeclType = *Blanks and inPrototype;
563700180201             @pDeclLine = SRCSEQ;
563800180201             Return;
563900180201          EndIf;
564000180201
564100180201          savedSRCDTA = SRCDTA;
564200180201          savedLineType = %xlate(lo:up:lineType);      // Save current line type for comparison.
564300180201          x = 0;
564400180201          @pDeclLine = 0;
564500180201
564600180201          //   // Name of the variable/routine should be on this line.
564700180201          //   savedName = %trim(declOptions);
564800180201
564900180201          // Trim any ellipsis from the name as this is not valid in free-form.
565000180201          x = %scan('...':@pSavedName);
565100180201          If x > 0;
565200180201             @pSavedName = %subst(@pSavedName:1:x-1);
565300180201             x = 0;
565400180201          ElseIf declFrom <> *Blanks
565500180201              or declLen <> *Blanks
565600180201              or declOptions <> *BLanks;
565700180201             // It's not a declaration - it's a subfield.
565800180201             @pDeclType = %xlate(lo:up:declType);
565900180201             @pDeclLine = SRCSEQ;
566000180201             Return;
566100180201          EndIf;
566200180201
566300180201          // Read ahead to find the next line with a declaration type.
566400180201          Read SRCREC;
566500180201          DoW not %eof();
566600180201             x += 1;     // Keep a track of how many lines we have read.
566700180201
566800180201             lineType = %xlate(lo:up:lineType);
566900180201
567000180201             If lineType <> savedLineType;
567100180201                // End of this declaration.
567200180201                Leave;
567300180201             EndIf;
567400180201
567500180201             If declType <> *Blanks;
567600180201                // We have found the declaration.
567700180201                @pDeclType = %xlate(lo:up:declType);
567800180201                @pDeclLine = SRCSEQ;
567900180201                Leave;
568000180201             ElseIf declFrom <> *Blanks
568100180201                 or declLen <> *Blanks
568200180201                 or declOptions <> *BLanks;
568300180201                // It's not a declaration - it's a subfield.
568400180201                @pDeclType = %xlate(lo:up:declType);
568500180201                @pDeclLine = SRCSEQ;
568600180201                Leave;
568700180201             EndIf;
568800180201
568900180201             Read SRCREC;
569000180201          EndDo;
569100180201
569200180201          // End of file breaks the logic!  We need to reposition to the last record before
569300180201          // continuing.
569400180201          If %eof(QRPGLESRC);
569500180201             SetGT *HIVAL SRCREC;
569600180201             ReadP SRCREC;
569700180201          EndIf;
569800180201
569900180201          // Return to the previous point.
570000180201          For i = 1 to x;
570100180201             ReadP SRCREC;
570200180201          EndFor;
570300180201
570400180201          SRCDTA = savedSRCDTA;
570500180201
570600180201          Return;
570700180201
570800180201       //------------------------------------------------------------------------------------------
570900180201          End-Proc;
571000180201
571100180201      /Eject
571200180201       //==========================================================================================
571300180201       // Split a line at a logical break based on a max length.
571400180201       //==========================================================================================
571500180201          Dcl-Proc SplitLine;
571600180201
571700180201       // -- Procedure Interface ------------------------------------------------------------------
571800180201          Dcl-PI SplitLine;
571900180201             @pCurrentLine        VarChar(92);
572000180201             @pOverflow           VarChar(92);
572100180201             @pMaxLength           Packed( 3:0 ) CONST;
572200180201          End-PI;
572300180201
572400180201       // -- Data Structures ----------------------------------------------------------------------
572500180201
572600180201       // -- Variables ----------------------------------------------------------------------------
572700180201          Dcl-S x                  Packed( 3:0 );
572800180201
572900180201       //-------------------------------------------------------------------------------------------
573000180201
573100180201          @pOverflow = *Blanks;
573200180201          x = %len(%trim(@pCurrentLine));
573300180201          If x > @pMaxLength;
573400180201             x = @pMaxLength;
573500180201          EndIf;
573600180201
573700180201          // Scan backwards through the line, looking for a place to break it.
573800180201          For x = x downto 1;
573900180201             If %scan(%subst(@pCurrentLine:x:1):' ') > 0;
574000180201                // Break here, and put the rest into a new line.
574100180201                @pOverflow = %subst(@pCurrentLine:x);
574200180201                @pCurrentLine = %subst(@pCurrentLine:1:x-1);
574300180201                Leave;
574400180201             EndIf;
574500180201          EndFor;
574600180201
574700180201          Return;
574800180201
574900180201       //------------------------------------------------------------------------------------------
575000180201          End-Proc;
575100180201
575200180201      /Eject
575300180201       //==========================================================================================
575400180201       // Check for an array definition and adjust the length according to the number of elements.
575500180201       //==========================================================================================
575600180201          Dcl-Proc AdjustArrayLength;
575700180201
575800180201       // -- Procedure Interface ------------------------------------------------------------------
575900180201          Dcl-PI AdjustArrayLength;
576000180201          @pLength               Packed( 7:0 );
576100180201          End-PI;
576200180201
576300180201       // -- Data Structures ----------------------------------------------------------------------
576400180201
576500180201       // -- Variables ----------------------------------------------------------------------------
576600180201          Dcl-S x                  Packed( 3:0 );
576700180201          Dcl-S i                  Packed( 3:0 );
576800180201          Dcl-S j                  Packed( 3:0 );
576900180201          Dcl-S elements           Packed( 5:0 );
577000180201          Dcl-S savedSRCDTA          Char( 100 );
577100180201
577200180201       //-------------------------------------------------------------------------------------------
577300180201
577400180201          savedSRCDTA = SRCDTA;
577500180201          x = 0;
577600180201
577700180201          // Read ahead to find the next line with a declaration type.
577800180201          DoW not %eof();
577900180201             // Array definition on the current line?
578000180201             i = %scan('DIM(':%xlate(lo:up:declKeywords));
578100180201
578200180201             If i > 0;
578300180201                j = %scan(')':declKeywords:i+4);
578400180201                elements = %dec(%subst(declKeywords:i + 4:j - i - 4):7:0);
578500180201                // Adjust the length of the variable.
578600180201                If %rem(@pLength:elements) = 0;
578700180201                   @pLength = %div(@pLength:elements);
578800180201                EndIf;
578900180201                Leave;
579000180201             EndIf;
579100180201
579200180201             Read SRCREC;
579300180201             x += 1;     // Keep a track of how many lines we have read.
579400180201
579500180201             lineType = %xlate(lo:up:lineType);
579600180201
579700180201             If lineType <> *Blank
579800180201             and lineType <> 'D';
579900180201                // Not part of this definition - stop looking for array definition.
580000180201                Leave;
580100180201
580200180201             ElseIf lineType = 'D'
580300180201             and %subst(directive:1:1) <> '*';                       // D-spec and no comment
580400180201                If declName <> *Blanks;
580500180201                   // A new declaration - stop looking for array definition.
580600180201                   Leave;
580700180201                EndIf;
580800180201             EndIf;
580900180201          EndDo;
581000180201
581100180201          // End of file breaks the logic!  We need to reposition to the last record before
581200180201          // continuing.
581300180201          If %eof(QRPGLESRC);
581400180201             SetGT *HIVAL SRCREC;
581500180201             ReadP SRCREC;
581600180201          EndIf;
581700180201
581800180201          // Return to the previous point.
581900180201          For i = 1 to x;
582000180201             ReadP SRCREC;
582100180201          EndFor;
582200180201
582300180201          SRCDTA = savedSRCDTA;
582400180201
582500180201          Return;
582600180201
582700180201       //------------------------------------------------------------------------------------------
582800180201          End-Proc;
582900180201       //==========================================================================================
583000180201     O*QRPGLESRC2E            OUTREC
583100180201     O*                       SRCSEQ
583200180201     O*                       SRCDAT
583300180201     O*                       SRCDTA
583400180201**CTDATA @opCodeUP
583500180201ACQ       Acq
583600180201BEGSR     BegSr
583700180201CALLP     CallP
583800180201CHAIN     Chain
583900180201CLEAR     Clear
584000180201CLOSE     Close
584100180201COMMIT    Commit
584200180201DEALLOC   DeAlloc
584300180201DELETE    Delete
584400180201DOU       DoU
584500180201DOW       DoW
584600180201DSPLY     Dsply
584700180201DUMP      Dump
584800180201ELSE      Else
584900180201ELSEIF    ElseIf
585000180201ENDDO     EndDo
585100180201ENDFOR    EndFor
585200180201ENDIF     EndIf
585300180201ENDMON    EndMon
585400180201ENDSL     EndSl
585500180201ENDSR     EndSr
585600180201EVAL      Eval
585700180201EVALR     EvalR
585800180201EVAL-CORR Eval-Corr
585900180201EXCEPT    Except
586000180201EXFMT     Exfmt
586100180201EXSR      Exsr
586200180201EXEC SQL  Exec SQL
586300180201FEOD      FEOD
586400180201FOR       For
586500180201FORCE     Force
586600180201IF        If
586700180201IN        In
586800180201ITER      Iter
586900180201LEAVE     Leave
587000180201LEAVESR   LeaveSr
587100180201MONITOR   Monitor
587200180201NEXT      Next
587300180201ON-ERROR  On-Error
587400180201OPEN      Open
587500180201OTHER     Other
587600180201OUT       Out
587700180201POST      Post
587800180201READ      Read
587900180201READC     ReadC
588000180201READE     ReadE
588100180201READP     ReadP
588200180201READPE    ReadPE
588300180201REL       Rel
588400180201RESET     Reset
588500180201RETURN    Return
588600180201ROLBK     RolBk
588700180201SELECT    Select
588800180201SETGT     SetGT
588900180201SETLL     SetLL
589000180201SORTA     SortA
589100180201TEST      Test
589200180201UNLOCK    Unlock
589300180201UPDATE    Update
589400180201WHEN      When
589500180201WRITE     Write
589600180201XML-INTO  XML-Into
589700180201XMLSAX    XMLSAX
589800180201ENDCS     ----------
589900180201AND       and
590000180201OR        or
590100180201**CTDATA @declUP
590200180201DCL-F     Dcl-F
590300180201DCL-S     Dcl-S
590400180201DCL-C     Dcl-C
590500180201DCL-PR    Dcl-PR
590600180201DCL-PI    Dcl-PI
590700180201DCL-PROC  Dcl-Proc
590800180201DCL-DS    Dcl-DS
590900180201END-DS    End-DS
591000180201END-PR    End-PR
591100180201END-PI    End-PI
591200180201END-PROC  End-Proc
591300180201CTL-OPT   Ctl-Opt
591400180201**CTDATA @comments
591500180201//===========================================================================================
591600180201// Start of moved field definitions.
591700180201// End of moved field definitions.
