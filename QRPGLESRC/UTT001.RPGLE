     ?* Prototypes (UTPT001)
     ?*====  Convert string to Upper/lower  ====
     D NamUl           PR            64A
     D  Text64                       64A
     D  TextLn                       10I 0
     ?*===========  Center a string  ===========
     D NamCtr          PR            64A
     D  Ctxt64                       64A
     D  CtxtLn                       10I 0
     ?*=  Move 6 Digit Date to Date Data Type  ==
     D UTSD06          PR            12
     D  D06Date6                      6S 0
      *
     D UTSD06DS        DS            12
     D  D06Date                        D   Overlay(UTSD06DS)
     D  D06Eoj                        2A   Overlay(UTSD06DS:11)
     ?*=  Move Date Data Type to 6 Digit Date  ==
     D UTSDDT          PR             8
     D  DDTDate                        D
      *
     D UTSDDTDS        DS             8
     D  DDTDate6                      6S 0 Overlay(UTSDDTDS)
     D  DDTEoj                        2A   Overlay(UTSDDTDS:7)
     ?*====  Break date into characters  =======
     D UTSD2C          PR            38
     D  D2CDateIn                      D
      *
     D UTSD2CDS        DS            38
     D  D2CMM                         2A   Overlay(UTSD2CDS)
     D  D2CMM3                        3A   Overlay(UTSD2CDS:3)
     D  D2CMM9                        9A   Overlay(UTSD2CDS:6)
     D  D2CDD                         2A   Overlay(UTSD2CDS:15)
     D  D2CDD4                        4A   Overlay(UTSD2CDS:17)
     D  D2CDAY3                       3A   Overlay(UTSD2CDS:21)
     D  D2CDAY9                       9A   Overlay(UTSD2CDS:24)
     D  D2CYY                         4A   Overlay(UTSD2CDS:33)
     D  D2CEOJ                        2A   Overlay(UTSD2CDS:37)
     ?*====  Break time stamp into characters  =======
     D UTST2C          PR            60
     D  T2CTSIn                        Z
      *
     D UTST2CDS        DS            60
     D  T2CMM                         2A   Overlay(UTST2CDS)
     D  T2CMM3                        3A   Overlay(UTST2CDS:3)
     D  T2CMM9                        9A   Overlay(UTST2CDS:6)
     D  T2CDD                         2A   Overlay(UTST2CDS:15)
     D  T2CDD4                        4A   Overlay(UTST2CDS:17)
     D  T2CDAY3                       3A   Overlay(UTST2CDS:21)
     D  T2CDAY9                       9A   Overlay(UTST2CDS:24)
     D  T2CYY                         4A   Overlay(UTST2CDS:33)
     D  T2CHR                         2A   Overlay(UTST2CDS:37)
     D  T2CMN                         2A   Overlay(UTST2CDS:39)
     D  T2CHRMN                       5A   Overlay(UTST2CDS:41)
     D  T2CSC                         2A   Overlay(UTST2CDS:46)
     D  T2CHRMNSC                     8A   Overlay(UTST2CDS:48)
     D  T2CAMPM                       2A   Overlay(UTST2CDS:56)
     D  T2CEOJ                        2A   Overlay(UTST2CDS:59)
