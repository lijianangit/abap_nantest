*&---------------------------------------------------------------------*
*& Report ztest_system_message
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ztest_system_message.
data tab1 type table of ztab1.
SELECT * FROM ztab1 INTO TABLE @tab1.
call function 'SM02_ADD_MESSAGE'
  exporting
    message = 'xxxxxxxxxxxx' .
if sy-subrc <> 0.
endif.
