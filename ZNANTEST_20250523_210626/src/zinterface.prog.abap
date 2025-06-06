*&---------------------------------------------------------------------*
*& Report zinterface
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zinterface.

initialization.
interface zif_example_interface.
  methods:
    method_name
      importing
        iv_parameter     type string
      returning
        value(rv_result) type string.
endinterface.

class zcl_example_class definition.
  public section.
    interfaces zif_example_interface.
endclass.
class zcl_example_class implementation.
  method zif_example_interface~method_name.
    rv_result = iv_parameter.
  endmethod.
endclass.

parameters desc type string .


at selection-screen.

start-of-selection.

  data Object1 type ref to zinterface.
  create object Object1.
  object1->zinterface1~m1( desc ).

  data: lo_class_instance type ref to zcl_example_class.
  data: lv_result type string.
  create object lo_class_instance.
  lv_result = lo_class_instance->zif_example_interface~method_name( iv_parameter = 'Hello World' ).
  write lv_result.



top-of-page.

end-of-page.
