*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 25.09.2018 at 21:52:54
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZCHK_FIELDS.....................................*
DATA:  BEGIN OF STATUS_ZCHK_FIELDS                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCHK_FIELDS                   .
CONTROLS: TCTRL_ZCHK_FIELDS
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZCHK_FIELDS                   .
TABLES: ZCHK_FIELDS                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
