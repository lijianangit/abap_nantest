*&---------------------------------------------------------------------*
*& Report z_sy_property
*&---------------------------------------------------------------------*
*& 测试系统变量的值
*&---------------------------------------------------------------------*
report z_test_sy_property.

split 'sadfasdf,45454' at ',' into table data(lt_anln1).

data(out) = cl_demo_output=>new( ).
data data1 type syst.
*cl_demo_output=>display( data1 ).
*do.
*  assign component ( sy-index + 1 ) of structure data1 to field-symbol(<fs1>).
*  out->write_data( <fs1> ).
*enddo.
*out->display( ).

select * from sflight into table @data(tab1).
data(i) = 0.
data(sum1) = 0.
while i < 100.
  sum1 += i.
  i += 1.
endwhile.




data cl_descr type ref to cl_abap_structdescr.
cl_descr ?= cl_abap_typedescr=>describe_by_data( data1 ). " 父 ？= 子
cl_demo_output=>display( cl_descr->components ).
