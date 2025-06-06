*&---------------------------------------------------------------------*
*& Report z_nantest_250218
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_nantest_250218.


class cls definition.
  public section.
    methods meth.
    methods meth2.
    data str type string value `attr`.
  private section.
endclass.

class cls implementation.
  method meth.
    data(str) = 'yyyyyyyy'.
    str = 'xxxxxxxxxx'.
    cl_demo_output=>write( |{ str }\n{
                                me->str }| ).
    cl_demo_output=>display( ).

  endmethod.
  method meth2.
    str = 'xxxxxxxxxx'.
    data(str) = 'yyyyyyyy'.
    cl_demo_output=>write( |{ str }\n{
                                me->str }| ).
    cl_demo_output=>display( ).
  endmethod.

endclass.

start-of-selection.
  new cls( )->meth( ).
  new cls( )->meth2( ).
