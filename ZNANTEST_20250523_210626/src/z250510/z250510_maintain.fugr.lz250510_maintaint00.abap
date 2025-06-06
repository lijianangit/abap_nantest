*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: Z250510_TAB_1...................................*
DATA:  BEGIN OF STATUS_Z250510_TAB_1                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_Z250510_TAB_1                 .
CONTROLS: TCTRL_Z250510_TAB_1
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *Z250510_TAB_1                 .
TABLES: Z250510_TAB_1                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
