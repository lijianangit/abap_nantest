*&---------------------------------------------------------------------*
*& Report z250415_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*


report z250415_1.


data init                   type c length 1.
data container              type ref to cl_gui_custom_container.
data editor                 type ref to cl_gui_textedit.
data send_to_address        type string                         value '1506263806@qq.com'.
data send_title             type so_obj_des                     value '这是标题'.
data file_size              type int4.
data file_content_lines_bin type standard table of raw255.
data file_content_line_bin  type raw255.
data file_content_x         type xstring.
data line                   type c length 256.
data text_tab               like standard table of line.
data file_path              type string.
data ok_code                like sy-ucomm.
data save_ok                like sy-ucomm.

constants send_from type adr6-smtp_addr value '1506263806@qq.com'.

start-of-selection.
  line = '第一行'.
  append line to text_tab.
  line = '--------------------------------------------------'.
  append line to text_tab.
  line = '...'.
  append line to text_tab.

  call screen 0100.

form send_mail using iv_subject type so_obj_des it_send_to type string_table it_body type bcsy_text.
  data: lo_recipient     type ref to cl_cam_address_bcs,
        lo_send_request  type ref to cl_bcs,
        lv_line          like line of it_body,
        lv_len           type so_obj_len value 0,
        lo_sender        type ref to cl_cam_address_bcs,
        lo_document      type ref to cl_document_bcs,
        lv_send_to       type adr6-smtp_addr,
        lo_bcs_exception type ref to cx_root,
        lv_message       type string.
  try.
      lo_send_request = cl_bcs=>create_persistent( ).

      loop at it_body into lv_line.
        lv_len = lv_len + strlen( lv_line ).
      endloop.

      lo_document = cl_document_bcs=>create_document(
        i_type    = 'RAW'
        i_text    = it_body
        i_length  = lv_len
        i_subject = iv_subject ).

      lo_send_request->set_document( lo_document ).

      lo_sender = cl_cam_address_bcs=>create_internet_address( send_from ).
      lo_send_request->set_sender( lo_sender ).

      loop at it_send_to into lv_send_to.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_send_to ).
        lo_send_request->set_send_immediately( i_send_immediately = 'X' ).

        lo_send_request->add_recipient( i_recipient = lo_recipient i_express   = 'X' ).
      endloop.

      if file_content_x is not initial.
        perform add_attachment using lo_document.
      endif.
      lo_send_request->send( i_with_error_screen = 'X' ).

      commit work and wait.

    catch cx_bcs into lo_bcs_exception.
      lv_message = lo_bcs_exception->get_text( ).
      write:/ lv_message.
      return.
  endtry.
endform.

form add_attachment using io_document type ref to cl_document_bcs.
  data: lv_att_type    type soodk-objtp,
        lv_att_name    type sood-objdes,
        lv_att_size    type sood-objlen,
        lv_att_cont    type solix_tab,
        lt_pdf_content type solix_tab.

  lv_att_type = 'BIN'.
  lv_att_name = 'attachment.pdf'.
  lv_att_size = xstrlen( file_content_x  ).
  lv_att_cont = cl_document_bcs=>xstring_to_solix( ip_xstring = file_content_x ).

  io_document->add_attachment( i_attachment_type    = lv_att_type
                               i_attachment_subject = lv_att_name
                               i_attachment_size    = lv_att_size
                               i_att_content_hex    = lv_att_cont ).
endform.
form upload_file.
  data: filetable    type filetable,
        selectedfile like line of filetable,
        result       type int4.

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
  endif.

  read table filetable into selectedfile index 1.
  file_path = selectedfile-filename.

  call method cl_gui_frontend_services=>gui_upload
    exporting
      filename     = file_path
      filetype     = 'BIN'
      read_by_line = 'X'
    importing
      filelength   = file_size
    changing
      data_tab     = file_content_lines_bin
    exceptions
      others       = 1.
  if sy-subrc <> 0.
    write:/ 'error occurred'.
    return.
  endif.

  concatenate lines of file_content_lines_bin into file_content_x in byte mode.

  file_content_x = file_content_x(file_size).

endform.

module status_0100 output.
  set pf-status 'SCREEN_100'.
  if init is initial.
    init = 'X'.
    create object: container exporting container_name = 'TEXTEDIT',
                   editor    exporting parent = container.
  endif.
  editor->set_text_as_stream( exporting text = text_tab ).
endmodule.

module user_command_0100 input.
  save_ok = ok_code.
  case save_ok.
    when 'SEND'.
      editor->get_text_as_stream( importing text = text_tab ).

      data: lt_send_to type string_table.

      translate send_to_address to lower case.
      append send_to_address to lt_send_to.

      data: lt_body type bcsy_text,
            ls_body like line of lt_body.

      loop at text_tab into line.
        ls_body-line = line.
        append ls_body to lt_body.
      endloop.

      perform send_mail using send_title lt_send_to lt_body .

    when 'UPLOAD'.
      perform upload_file.

  endcase.
  set screen 100.
endmodule.

module cancel input.
  leave program.
endmodule.
