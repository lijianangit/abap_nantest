*&---------------------------------------------------------------------*
*& Report z250428_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250428_2.

select * from z250318

  where !priority = ( select max( priority ) from z250318 )  " 物料，交货单，唯一码 为主键  还可以and 加其他的筛选条件

  into table @data(lt_log4).

cl_salv_table=>factory(
*  exporting
*                                  list_display = if_salv_c_bool_sap=>false
*                                  r_container  =
*                                  container_name =
  importing
    r_salv_table = data(tab2)
  changing
    t_table      = lt_log4 ).
" catch cx_salv_msg.

tab2->display( ).

data itab type table of scarr with empty key.

data(var1) = value #( itab[ 1 ] optional ).
data(var2) = value #( itab[ 1 ] default value #( carrid   = 'XXX'
                                                 carrname = 'xxx' ) ).

data(dref1) = ref #( itab[ 1 ] optional ).
data(dref2) = ref #( itab[ 1 ] default new #( carrid   = 'XXX'
                                              carrname = 'xxx' ) ).

assert var1 is initial.
assert dref1 is initial.

assert var2 = dref2->*.



data itab2 type table of ref to scarr with empty key.

itab2 = value #( ( new scarr( carrid = 'XX' carrname = 'YYYY' ) ) ).

class number definition.
  public section.
    data value type i.
    methods:
      get returning value(r) type i,
      constructor importing n type i.
endclass.

class number implementation.
  method get.
    r = value.
  endmethod.
  method constructor.
    value = n.
  endmethod.
endclass.

start-of-selection.
"number的内表
  types itab3 type table of ref to number with empty key.

  data(itab3) = value itab3( for j = 1 until j > 2
                             ( new number( j ) ) ).

  data(n1) = itab3[ 1 ]->value.
  data(n2) = itab3[ 2 ]->get( ).
