*&---------------------------------------------------------------------*
*& Report z250428
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250428.


data:begin of ls_data1,
       fd1 type char10,
       fd2 type char10,
       fd3 type char10,
     end of ls_data1.

data:begin of ls_data2,
       fd1 type char10,
       fd2 type char10,
       fd4 type char10,
     end of ls_data2.

ls_data1 = value #( fd1 = |First|
                    fd2 = |Second|
                    fd3 = |Third| ).

ls_data2 = corresponding #( ls_data1 ).
write: / |****************************************|.
write: / |*CORRESPONDING NO MAPPING AND NO EXCEPT*|.
write: / |FD1:|,ls_data2-fd1,|FD2:|,ls_data2-fd2,|FD4:|,ls_data2-fd4.
skip.
ls_data2 = corresponding #( ls_data1 mapping fd4 = fd3 ).
write: / |****************************************|.
write: / |*CORRESPONDING MAPPING AND NO EXCEPT*|.
write: / |FD1:|,ls_data2-fd1,|FD2:|,ls_data2-fd2,|FD4:|,ls_data2-fd4.
skip.
ls_data2 = corresponding #( ls_data1 except fd2 ).
write: / |****************************************|.
write: / |*CORRESPONDING NO MAPPING AND EXCEPT*|.
write: / |FD1:|,ls_data2-fd1,|FD2:|,ls_data2-fd2,|FD4:|,ls_data2-fd4.
skip.
ls_data2 = corresponding #( ls_data1 mapping fd4 = fd3 except fd2 ).
write: / |****************************************|.
write: / |*CORRESPONDING MAPPING AND EXCEPT*|.
write: / |FD1:|,ls_data2-fd1,|FD2:|,ls_data2-fd2,|FD4:|,ls_data2-fd4.




data: lt_t001 type standard table of acdoca.

select
  bukrs,
  belnr,
  gjahr,
  buzei
  from bseg
  up to 3 rows
  into table @data(lt_bseg) order by abper descending .

"CORRESPONDING
lt_t001 = corresponding #( lt_bseg mapping rbukrs = bukrs
                                           docln  = buzei ).
"Display data
cl_salv_table=>factory(
  importing
    r_salv_table = data(lcl_alv)
  changing
    t_table      = lt_t001 ).

lcl_alv->display( ).
