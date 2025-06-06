*&---------------------------------------------------------------------*
*& Report z_test_file_template
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_file_template_2.

tables ekpo.

tables sscrfields.

selection-screen function key 1.           "第一个按钮
selection-screen function key 2.            "第一个按钮

initialization.
  sscrfields-functxt_01 = '模板下载'.      "定义第一个按钮文本
  sscrfields-functxt_02 = 'excel文件导入'.      "定义第一个按钮文本
  perform dosomething.

start-of-selection.

form dosomething.
  data:lt_mime_data type table of w3mime,
       ls_id        type wwwdataid,
       ls_key       type wwwdatatab.
  data:lv_string       type string,
       lv_xstring      type xstring,
       lv_input_length type i.

  ls_key-relid ='MI'.
  ls_key-objid = 'Z_TEST_EBAN'."模板ID
*  获取模板的数据流
  call function 'WWWDATA_IMPORT'
    exporting
      key               = ls_key
    tables
*     HTML              =
      mime              = lt_mime_data
    exceptions
      wrong_object_type = 1
      import_error      = 2
      others            = 3.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.

  select single value
  from  wwwparams
  where  relid       eq @ls_key-relid
  and    objid       eq @ls_key-objid
  and name eq 'filesize'
  into @data(lv_para_value).

  lv_input_length = lv_para_value.

  call function 'SCMS_BINARY_TO_XSTRING'
    exporting
      input_length = lv_input_length
*     FIRST_LINE   = 0
*     LAST_LINE    = 0
    importing
      buffer       = lv_xstring
    tables
      binary_tab   = lt_mime_data
    exceptions
      failed       = 1
      others       = 2.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.


  "lv_xstring = lv_string.
  data: reader          type ref to zif_excel_reader,
        lo_excel_writer type ref to zif_excel_writer
        .

  create object reader type zcl_excel_reader_2007.
  data(lo_excel) = reader->load( i_excel2007 = lv_xstring ).

  data: lv_file      type xstring,
        lv_bytecount type i,
        lt_file_tab  type solix_tab.

  data(lo_worksheet) = lo_excel->get_active_worksheet( ).
*  lo_worksheet->set_title( ip_title = 'Sheet1' ).
  lo_worksheet->set_cell( ip_column = 'A' ip_row = 4 ip_value = 'Hello world' ).


  create object lo_excel_writer type zcl_excel_writer_2007.
  lv_file = lo_excel_writer->write_file( lo_excel ).

  " Convert to binary
  call function 'SCMS_XSTRING_TO_BINARY'
    exporting
      buffer        = lv_file
    importing
      output_length = lv_bytecount
    tables
      binary_tab    = lt_file_tab.

  cl_gui_frontend_services=>gui_download(
    exporting
      bin_filesize = lv_bytecount
      filename     = 'C:\BP export.xlsx'
      filetype     = 'BIN'
    changing
      data_tab     = lt_file_tab ).


endform.
