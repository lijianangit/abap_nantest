*&---------------------------------------------------------------------*
*& Report z250403
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250403.

parameters encoding type abap_encoding obligatory default 'UTF-8'.

data lv_converter   type ref to cl_abap_conv_in_ce.
data file_content_x type xstring value 'E6B1AA'.
data cx_root        type ref to cx_root.
data lv_text        type string.

data uuid type guid_16.
CALL FUNCTION 'GUID_CREATE'
  IMPORTING
    ev_guid_16 = !uuid.

write !uuid.

try.
    lv_converter = cl_abap_conv_in_ce=>create( input    = file_content_x
                                               encoding = encoding ).

    lv_converter->read( importing data = lv_text ).
    write:/ 'encoding: ', encoding, ' text: ', lv_text.

  catch cx_root into cx_root.
    write / cx_root->get_text( ).
endtry.
