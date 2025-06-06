*&---------------------------------------------------------------------*
*& Report z_test_alv_list
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_alv_list.

tables: sflight.
include vex02top.
data: gt_sflight like sflight occurs 0.
data: gs_extract1 like disextract.
data: gs_extract2 like disextract.
* Excluding table
*---------------------------------------------------------------------*
*
initialization.

at selection-screen output.

at selection-screen.





start-of-selection.
  select * from sflight into table gt_sflight .
  if p_save = 'X'.
    call function 'REUSE_ALV_EXTRACT_SAVE'
      exporting
        is_extract     = gs_extract1
        i_get_selinfos = 'X'
      tables
        it_exp01       = gt_sflight.
    exit.
  endif.
  if p_load = 'X'.
    call function 'REUSE_ALV_EXTRACT_LOAD'
      exporting
        is_extract = gs_extract2
      tables
        et_exp01   = gt_sflight.

  endif.
* Call ABAP/4 List Viewer
  call function 'REUSE_ALV_LIST_DISPLAY'
    exporting
      i_callback_program = gs_extract1-report
      i_structure_name   = 'SFLIGHT'
      i_save             = 'A'
    tables
      t_outtab           = gt_sflight.
