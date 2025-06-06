FUNCTION Z_TEST_RAP_1.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(IN_AGE1) TYPE  I
*"     VALUE(IN_AGE2) TYPE  I
*"  EXPORTING
*"     VALUE(SUM_AGE) TYPE  I
*"----------------------------------------------------------------------
  select * from sflight into table @data(tab1) .

  sum_age = in_age1 + in_age2.






endfunction.
