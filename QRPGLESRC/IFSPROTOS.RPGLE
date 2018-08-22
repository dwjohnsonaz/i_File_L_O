000100000000       //*********************************************************************
000200000000       // The information contained in this document has not been submitted
000300000000       // to any formal IBM test and is distributed AS IS.  The use of this
000400000000       // information or the implementation of any of these techniques is a
000500000000       // customer responsibility and depends on the customer's ability to
000600000000       // evaluate and integrate them into the customer's operational
000700000000       // environment.  See Special Notices in redbook SG24-5402 for more.
000800000000       //*********************************************************************
000900000000
001000000000       // IFSPROTO from IFSSRC in RPGISCOOL
001100000000       // Prototypes for IFS APIs
001200000000       //*********************************************************************
001300000000       // Open() - Open File API
001400000000       //  From System API Reference OS/400 UNIX-Type APIs
001500000000
001600000000       // #include <fcntl.h>
001700000000       //  int open(const char *path, int oflag, . . .);
001800000000       Dcl-PR open                  Int(10:0) ExtProc('open');
001900000000          path@                 Pointer Value options(*String);
002000000000          oflag                     Int(10:0) Value;
002100180528          mode                      Uns(10:0) Value Options(*nopass) ;
002200180528          Codepage                  Uns(10:0) Value Options(*nopass) ;
002300000000       End-PR;
002400000000
002500000000       //---------------------------------------------------------------------
002600000000       // read() -- Read from Descriptor
002700000000       //  From System API Reference OS/400 UNIX-Type APIs
002800000000
002900000000       // #include <unistd.h>
003000000000       //  ssize_t read(int file_descriptor,
003100000000       //               void *buf, size_t nbyte);
003200000000       Dcl-PR read                  Int(10:0) Extproc('read');
003300000000          FileDescI                 Int(10:0) Value;
003400000000          bufferI@              Pointer Value;
003500180528          nbyte                     Uns(10:0) Value;
003600000000       End-PR;
003700000000
003800000000       //---------------------------------------------------------------------
003900000000       // write() -- Write to Descriptor
004000000000       //  From System API Reference OS/400 UNIX-Type APIs
004100000000
004200000000       // #include <unistd.h>
004300000000       //  ssize_t write
004400000000       //  (int file_descriptor, const void *buf, size_t nbyte);
004500000000       Dcl-PR write                 Int(10:0) Extproc('write');
004600000000          FileDescO                 Int(10:0) Value;
004700000000          bufferO@              Pointer Value;
004800180528          nbyte                     Uns(10:0) value ;
004900000000       End-PR;
005000000000
005100000000       //---------------------------------------------------------------------
005200000000       // close() -- Close File or Socket Descriptor
005300000000       //  From System API Reference OS/400 UNIX-Type APIs
005400000000
005500000000       // #include <unistd.h>
005600000000       //  int close(int fildes);
005700000000       Dcl-PR close                 Int(10:0) Extproc('close');
005800000000          FileDesc                  Int(10:0) Value;
005900000000       End-PR;
006000000000
006100000000       //---------------------------------------------------------------------
006200000000       // lseek()--Set File Read/Write Offset
006300000000       //  From System API Reference OS/400 UNIX-Type APIs
006400000000
006500000000       // #include <unistd.h>                                                  ª
006600000000       //  off_t lseek(int file_descriptor, off_t offset, int whence);
006700000000       Dcl-PR lseek                 Int(10:0) Extproc('lseek');
006800000000          filedesc                  Int(10:0) Value;
006900000000          offset                    Int(10:0) Value;
007000000000          whence                    Int(10:0) Value;
007100000000       End-PR;
007200180528       Dcl-PR  IFS_IO ;
007300180528         *N                        Char(1) ;
007400180528         *N                        Char(1) ;
007500180528         *N                      Packed(5:0) ;
007600180528         *N                        Char(512) ;
007700180528         *N                        Char(128) Options(*NoPass) ;
007800180528         *N                        Char(10) Options(*NoPass) ;
007900180528         *N                         Int(10) Options(*NoPass) ;
008000180528         *N                         Int(10) Options(*NoPass) ;
008100180528         *N                        Char(1) Options(*NoPass) ;
008200180528       End-PR ;
008300000000       //*******************************************************************
008400000000       // OPENDFN from IFSSRC in RPGISCOOL
008500000000       // structure definition for openfunction
008600000000       //     from QSYSINC/H.FCNTL member
008700000000       //********************************************************************
008800000000       ///===================================================================/
008900000000       ///=   File Access Modes                                             =/
009000000000       ///===================================================================/
009100000000       //#define O_RDONLY   00001        /* Open for reading only           */
009200000000       Dcl-S O_RDONLY               Int(10:0) INZ(x'01');
009300000000       //#define O_WRONLY   00002        /* Open for writing only           */
009400000000       Dcl-S O_WRONLY               Int(10:0) INZ(x'02');
009500000000       //#define O_RDWR     00004        /* Open for reading and writing    */
009600000000       Dcl-S O_RDWR                 Int(10:0) INZ(x'04');
009700000000       //#define O_CREAT      00010      /* Create file if it doesn't exist */
009800000000       Dcl-S O_CREATE               Int(10:0) INZ(x'08');
009900000000       //#define O_EXCL       00020      /* Exclusive use flag              */
010000000000       Dcl-S O_EXCL                 Int(10:0) INZ(x'10');
010100000000       ///*                   00040         reserved                        */
010200000000       //#define O_TRUNC      00100      /* Truncate flag                   */
010300000000       Dcl-S O_TRUNC                Int(10:0) INZ(x'40');
010400000000       ///===================================================================/
010500000000       ///=   File Status Flags                                             =/
010600000000       ///===================================================================/
010700000000       //#define O_CODEPAGE   040000000  /* code page flag                  */
010800000000       Dcl-S O_CODEPAGE             Int(10:0) INZ(x'800000');
010900000000       //#define O_TEXTDATA  0100000000  /* text data flag                  */
011000000000       Dcl-S O_TEXTDATA             Int(10:0) INZ(x'01000000');
011100000000       //#define O_APPEND     00400      /* Set append mode                 */
011200000000       Dcl-S O_APPEND               Int(10:0) INZ(x'0100');
011300000000       //#define O_LARGEFILE  004000000000  /* Large file access            */
011400000000       Dcl-S O_LARGEFILE            Int(10:0) INZ(x'20000000');
011500000000       //#define O_INHERITMODE 001000000000 /* inherit mode flag            */
011600000000       Dcl-S O_INHERITMODE          Int(10:0) INZ(x'08000000');
011700000000       ///===================================================================/
011800000000       ///=   Share Mode Values                                             =/
011900000000       ///===================================================================/
012000000000       //#define O_SHARE_RDONLY 000000200000 /* Share with readers only     */
012100000000       Dcl-S O_SHARE_RDONLY         Int(10:0) INZ(x'010000');
012200000000       //#define O_SHARE_WRONLY 000000400000 /* Share with writers only     */
012300000000       Dcl-S O_SHARE_WRONLY         Int(10:0) INZ(x'020000');
012400000000       //#define O_SHARE_RDWR   000001000000 /* Share with readers and
012500000000       //                                       writers                     */
012600000000       Dcl-S O_SHARE_RDWR           Int(10:0) INZ(x'040000');
012700000000       //#define O_SHARE_NONE   000002000000 /* Share with neither readers
012800000000       //                                       nor writers                 */
012900000000       Dcl-S O_SHARE_NONE           Int(10:0) INZ(x'080000');
013000000000
013100000000       // from QSYSINC/SYS.STAT member
013200000000       ///====================================================================*/
013300000000       ///= Definitions of Security attributes and File Types                 */
013400000000       ///====================================================================*/
013500000000       // O w n e r   a t t r i b u t e s
013600000000       //   #define S_IRUSR 0000400    /* Read for owner                      */
013700000000       Dcl-S S_IRUSR                Int(10:0) INZ(x'0100');
013800000000       //   #define S_IWUSR 0000200    /* Write for owner                     */
013900000000       Dcl-S S_IWUSR                Int(10:0) INZ(x'80');
014000000000       //   #define S_IXUSR 0000100    /* Execute and Search for owner        */
014100000000       Dcl-S S_IXUSR                Int(10:0) INZ(x'40');
014200000000       //   #define S_IRWXU (S_IRUSR|S_IWUSR|S_IXUSR)  /* Read, Write,
014300000000       //                                                 Execute for owner   */
014400000000       Dcl-S S_IRWXU                Int(10:0) INZ(x'01C0');
014500000000
014600000000       // P r i m a r y   g r o u p   a t t r i b u t e s
014700000000       //   #define S_IRGRP 0000040         /* Read for group                 */
014800000000       Dcl-S S_IRGRP                Int(10:0) INZ(x'20');
014900000000       //   #define S_IWGRP 0000020         /* Write for group                */
015000000000       Dcl-S S_IWGRP                Int(10:0) INZ(x'10');
015100000000       //   #define S_IXGRP 0000010         /* Execute and Search for group   */
015200000000       Dcl-S S_IXGRP                Int(10:0) INZ(x'08');
015300000000       //   #define S_IRWXG (S_IRGRP|S_IWGRP|S_IXGRP)  /* Read, Write,
015400000000       //                                                 Execute for group   */
015500000000       Dcl-S S_IRWXG                Int(10:0) INZ(x'38');
015600000000
015700000000       // *P U B L I C   a t t r i b u t e s
015800000000       //   #define S_IROTH 0000004         /* Read for other                 */
015900000000       Dcl-S S_IROTH                Int(10:0) INZ(x'04');
016000000000       //   #define S_IWOTH 0000002         /* Write for other                */
016100000000       Dcl-S S_IWOTH                Int(10:0) INZ(x'02');
016200000000       //   #define S_IXOTH 0000001         /* Execute and Search for other   */
016300000000       Dcl-S S_IXOTH                Int(10:0) INZ(x'01');
016400000000       //   #define S_IRWXO (S_IROTH|S_IWOTH|S_IXOTH)  /* Read, Write,
016500000000       //                                                 Execute for other   */
016600000000       Dcl-S S_IRWXO                Int(10:0) INZ(x'07');
016700000000
016800000000       ///*******************************************************************/
016900000000       ///*   Constants for lseek()                                         */
017000000000       ///*******************************************************************/
017100000000       //   #define SEEK_SET    0        /* Seek to given position          */
017200000000       Dcl-C SEEK_SET                  0;
017300000000       //   #define SEEK_CUR    1        /* Seek relative to current
017400000000       //                                   position                        */
017500000000       Dcl-C SEEK_CUR                  1;
017600000000       //   #define SEEK_END    2        /* Seek relative to end of file    */
017700000000       Dcl-C SEEK_END                  2;
