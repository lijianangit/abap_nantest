*&---------------------------------------------------------------------*
*& Report z_test_excel_read
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_excel_read_2.

parameters p_path type string default 'C:\Users\nan\Desktop\123.XLSX'.

at selection-screen on value-request for p_path."弹出文件选择对话框
  perform get_path.

start-of-selection.
  perform read_excel.


form get_path.
  data fileTable  type filetable.
  data resultCode type i.

  cl_gui_frontend_services=>file_open_dialog( exporting initial_directory = 'C:\Users\nan\Desktop'
                                              changing  file_table        = fileTable
                                                        rc                = resultCode ).
  if sy-subrc <> 0.
    write 'xxxxxx'.
  endif.
  p_path = fileTable[ 1 ]-filename.

endform.

form read_excel.
  " excel文档类对象
  data(lo_excel) = new zcl_excel( ).

  " TODO: variable is assigned but never used (ABAP cleaner)
  data(lf_cxexcel) = new zcx_excel( ).

  " 上传excel

  data(cl_reader) = new  zcl_excel_reader_2007( ).
  lo_excel = cl_reader->zif_excel_reader~load_file( i_filename = p_path
*i_use_alternate_zip = space
*i_from_applserver = SY-BATCH
*iv_zcl_excel_classname =
                                                   ).
  " catch zcx_excel.
  " excel worksheet类对象
  data ebanTab type table of eban.
  data(lo_worksheet) = lo_excel->get_active_worksheet( ).


  "获取行数，列数

  data(row_count) = lo_worksheet->get_highest_row( ).

  data(col_count) = lo_worksheet->get_highest_column( ).

  data eban_tab type table of eban.
  data eban_line type eban.
  data(t_excel) = eban_line.

  lo_worksheet->get_table(
    exporting
      iv_skipped_rows = 0
      iv_skipped_cols = 0
      iv_max_col      = row_count
      iv_max_row      = col_count
    importing
      et_table = eban_tab
  ).
  cl_demo_output=>display( eban_tab ).

endform.
