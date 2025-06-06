*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: Z250318.........................................*
DATA:  BEGIN OF STATUS_Z250318                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_Z250318                       .
CONTROLS: TCTRL_Z250318
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *Z250318                       .
TABLES: Z250318                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
