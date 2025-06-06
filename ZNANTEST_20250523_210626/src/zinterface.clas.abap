class zinterface definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.
    interfaces zinterface1.
  protected section.
  private section.
endclass.



class zinterface implementation.

  method if_oo_adt_classrun~main.
    out->write(
      exporting
        data = 555555
    ).
  endmethod.

  method zinterface1~m1.
    write / param1.
    write / 'xxxxxxxxx'.
  endmethod.

endclass.


