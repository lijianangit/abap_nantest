*&---------------------------------------------------------------------*
*& Report z250325
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250325.

DATA: lt_body    TYPE STANDARD TABLE OF x255,"255个字节长度的数组
      lt_headers TYPE STANDARD TABLE OF char255.

CALL FUNCTION 'HTTP_GET'
  EXPORTING
    absolute_uri         = 'HTTPS://WWW.BAIDU.COM'
  TABLES
    response_entity_body = lt_body
    response_headers     = lt_headers
  EXCEPTIONS
    connect_failed       = 1
    OTHERS               = 2.
IF sy-subrc <> 0.
  WRITE:/ 'error occurred during http get'.
  RETURN.
ENDIF.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    filename = 'c:\temp\1.html'
  TABLES
    data_tab = lt_body.

WRITE:/ 'download ok'.
