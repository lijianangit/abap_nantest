*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: Z250501_TAB.....................................*
DATA:  BEGIN OF STATUS_Z250501_TAB                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_Z250501_TAB                   .
CONTROLS: TCTRL_Z250501_TAB
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *Z250501_TAB                   .
TABLES: Z250501_TAB                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
