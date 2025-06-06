*&---------------------------------------------------------------------*
*& Report z250325_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250325_2.

DATA: lv_file_name   TYPE string VALUE 'c:\temp\1.html',
      lv_file_length TYPE i,
      lt_content     TYPE string_table,
      lv_content     TYPE string.

CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    filename   = lv_file_name
  IMPORTING
    filelength = lv_file_length
  TABLES
    data_tab   = lt_content.

LOOP AT lt_content INTO lv_content.
  WRITE:/ lv_content.
ENDLOOP.
