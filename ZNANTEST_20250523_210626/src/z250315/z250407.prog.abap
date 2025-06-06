*&---------------------------------------------------------------------*
*& Report z250407
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250407.

DATA: init,
      container       TYPE REF TO cl_gui_custom_container,
      editor          TYPE REF TO cl_gui_textedit,
      send_to_address TYPE string VALUE 'j@sap.com',
      send_title      TYPE so_obj_des VALUE '这是标题'.

DATA: line(256) TYPE c,
      text_tab  LIKE STANDARD TABLE OF line.

DATA: ok_code LIKE sy-ucomm,
      save_ok LIKE sy-ucomm.

CONSTANTS: send_from TYPE adr6-smtp_addr VALUE 'j@sap.com'.

START-OF-SELECTION.
  line = '第一行'.
  APPEND line TO text_tab.
  line = '--------------------------------------------------'.
  APPEND line TO text_tab.
  line = '...'.
  APPEND line TO text_tab.

  CALL SCREEN 0100.

FORM send_mail USING iv_subject TYPE so_obj_des it_send_to TYPE string_table it_body TYPE bcsy_text.
  DATA: lo_recipient     TYPE REF TO cl_cam_address_bcs,
        lo_send_request  TYPE REF TO cl_bcs,
        lv_line          LIKE LINE OF it_body,
        lv_len           TYPE so_obj_len VALUE 0,
        lo_sender        TYPE REF TO cl_cam_address_bcs,
        lo_document      TYPE REF TO cl_document_bcs,
        lv_send_to       TYPE adr6-smtp_addr,
        lo_bcs_exception TYPE REF TO cx_root,
        lv_message       TYPE string.
  TRY.
      lo_send_request = cl_bcs=>create_persistent( ).

      LOOP AT it_body INTO lv_line.
        lv_len = lv_len + strlen( lv_line ).
      ENDLOOP.

      lo_document = cl_document_bcs=>create_document(
                      i_type    = 'RAW'
                      i_text    = it_body
                      i_length  = lv_len
                      i_subject = iv_subject ).

      lo_send_request->set_document( lo_document ).

      lo_sender = cl_cam_address_bcs=>create_internet_address( send_from ).
      lo_send_request->set_sender( lo_sender ).

      LOOP AT it_send_to INTO lv_send_to.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_send_to ).
        lo_send_request->set_send_immediately( i_send_immediately = 'X' ).

        lo_send_request->add_recipient( i_recipient = lo_recipient i_express   = 'X' ).
      ENDLOOP.
      lo_send_request->send( i_with_error_screen = 'X' ).

      COMMIT WORK AND WAIT.

    CATCH cx_bcs INTO lo_bcs_exception.
      lv_message = lo_bcs_exception->get_text( ).
      WRITE:/ lv_message.
      RETURN.
  ENDTRY.
ENDFORM.

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'SCREEN_100'.
  IF init IS INITIAL.
    init = 'X'.
    CREATE OBJECT: container EXPORTING container_name = 'TEXTEDIT',
                   editor    EXPORTING parent = container.
  ENDIF.
  editor->set_text_as_stream( EXPORTING text = text_tab ).
ENDMODULE.

MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CASE save_ok.
    WHEN 'SEND'.
      editor->get_text_as_stream( IMPORTING text = text_tab ).

      DATA: lt_send_to TYPE string_table.

      TRANSLATE send_to_address TO LOWER CASE.
      APPEND send_to_address TO lt_send_to.

      DATA: lt_body TYPE bcsy_text,
            ls_body LIKE LINE OF lt_body.

      LOOP AT text_tab INTO line.
        ls_body-line = line.
        APPEND ls_body TO lt_body.
      ENDLOOP.

      PERFORM send_mail USING send_title lt_send_to lt_body .

  ENDCASE.
  SET SCREEN 100.
ENDMODULE.

MODULE cancel INPUT.
  LEAVE PROGRAM.
ENDMODULE.
