FUNCTION Z_TEST_RFC_1.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(RFC) TYPE  CHAR5 OPTIONAL
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CHAR5
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------


OUTPUT = RFC + 5.

WRITE: OUTPUT.


ENDFUNCTION.
