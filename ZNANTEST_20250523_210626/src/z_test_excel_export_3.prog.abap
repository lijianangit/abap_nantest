*&---------------------------------------------------------------------*
*& Report z_test_excel_export3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_excel_export_3.


type-pools abap.

data lo_excel          type ref to zcl_excel.
data lo_worksheet      type ref to zcl_excel_worksheet.
data cl_writer         type ref to zif_excel_writer.
data ls_table_settings type zexcel_s_table_settings.

start-of-selection.
  " Creates active sheet
  data fileName type string value '123'.
  data filePath type string.
  data fullpath type string.

  cl_gui_frontend_services=>file_save_dialog( exporting  initial_directory = 'C:\Users\nan\Desktop'
                                                         window_title      = '保存模板文件'
                                                         default_extension = ''           " 缺省文件类型
                                                         default_file_name = fileName
                                                         file_filter       = 'Excel 文件 (*.XLSX)|*.XLSX|所有文件 (*.*)|*.*|'
                                              changing   filename          = fileName
                                                         path              = filePath
                                                         fullpath          = fullpath
                                              exceptions cntl_error        = 1
                                                         error_no_gui      = 2
                                                         others            = 3 ).

  lo_excel = new #( ).
  select * from eban where ernam = 'KN681' order by erdat descending into table @data(ebanTab).
  " Get active sheet
  lo_worksheet = lo_excel->get_active_worksheet( )."获取一个活动的sheet
  lo_worksheet->set_title( ip_title = '测试导出excel' )."设置sheet名

  ls_table_settings-table_style      = zcl_excel_table=>builtinstyle_medium2."设置样式
  ls_table_settings-show_row_stripes = abap_true."
  ls_table_settings-nofilters        = abap_true."
  " 输入数据源的内表
  lo_worksheet->bind_table( ip_table          = ebanTab
                            is_table_settings = ls_table_settings ).

  lo_worksheet->freeze_panes( ip_num_rows = 3 ). " 冻结前3行

  cl_writer = new zcl_excel_writer_2007( ).
  data(data1) = cl_writer->write_file( lo_excel ).
  data(result) = cl_bcs_convert=>xstring_to_solix( iv_xstring = data1 ).
  data(bytecount) = xstrlen( data1 ).
  cl_gui_frontend_services=>gui_download( exporting bin_filesize = bytecount
                                                    filename     = fullpath
                                                    filetype     = 'BIN'
                                          changing  data_tab     = result ).
