*&---------------------------------------------------------------------*
*& Report z250419 cl_gui_html_viewer 来显示html内容
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

report z250419.

parameters filepath type string obligatory.


data filetable              type filetable.
data selectedfile           like line of filetable.
data result                 type int4.
data file_content_lines_bin type standard table of raw255.
data file_content_line_bin  type raw255.
data lv_url                 type char255.
data lv_size                type i value 0.
data okcode                 type sy-ucomm.

at selection-screen on value-request for filepath.

  call method cl_gui_frontend_services=>file_open_dialog
    exporting
      window_title = '选择上传文件'
      file_filter  = 'pdf'
    changing
      file_table   = filetable
      rc           = result
    exceptions
      others       = 1.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    return.
  endif.

  read table filetable into selectedfile index 1.
  filepath = selectedfile-filename.

  call method cl_gui_frontend_services=>gui_upload
    exporting
      filename     = filepath
      filetype     = 'BIN'
      read_by_line = 'X'
    changing
      data_tab     = file_content_lines_bin
    exceptions
      others       = 1.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    return.
  endif.

module status_0100 output.
  set pf-status 'ZSTATUS'.

  perform display_pdf.
endmodule.

module user_command_0100 input.
  okcode = sy-ucomm.
  case okcode.
    when 'QUIT' or 'BACK' or 'EXIT'.
      leave program.
  endcase.
endmodule.

form display_pdf.
  data(go_pdf_container) = new cl_gui_custom_container(
                                                        container_name = 'PDF'
  ).
  data(go_pdf_object) = new cl_gui_html_viewer(
                                                parent = go_pdf_container
  ).

  go_pdf_object->load_data( exporting  type                   = 'application'
                                       subtype                = 'pdf'
                            importing  assigned_url           = lv_url
                            changing   data_table             = file_content_lines_bin
                            exceptions dp_invalid_parameter   = 1
                                       dp_error_general       = 2
                                       cntl_error             = 3
                                       html_syntax_notcorrect = 4
                                       others                 = 5 ).

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    return.
  endif.

  go_pdf_object->show_data( url      = lv_url
                            in_place = abap_true ).
endform.

start-of-selection.

  call screen 0100.
