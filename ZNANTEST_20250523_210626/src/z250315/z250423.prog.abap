*&---------------------------------------------------------------------*
*& Report z250423
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250423.
data db6        like standard table of t100.
data db6out     like standard table of t100.

data start_time type i.
data end_time   type i.
data run_time   type float.

select * from t100 up to 100 rows into table db6.

get run time field start_time.

select * into table db6out
  from t100
  for all entries in db6
  where sprsl = db6-sprsl
    and arbgb = db6-arbgb
    and msgnr = db6-msgnr.

*get run time field end_time.
*run_time = end_time – start_time.
*
*write : / run_time .

cl_demo_output=>DISPLAY( db6out ).
write |{ lines( db6out ) }|.
data(str1) = | 400  { start_time } |.
select * from z250318 where desc1 = @str1 into table @data(tab1).
