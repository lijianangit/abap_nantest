class ztest_bapi definition
  public
  create public.
  public section.
    interfaces if_oo_adt_classrun.
    methods test_bapi importing desc type string.

  protected section.
  private section.
    data result type bapireturn.
ENDCLASS.



CLASS ZTEST_BAPI IMPLEMENTATION.


  method if_oo_adt_classrun~main.
    test_bapi( 'xxxxxxxxx' ).
    out->write(
      exporting
        data = result
    ).
    write result.

  endmethod.


  method test_bapi.
    write / desc.
    data:itab type standard table of bapi0002_1 .
    call function 'BAPI_COMPANYCODE_GETLIST'
      importing
        return           = result
      tables
        companycode_list = itab.
    write / result.
  endmethod.
ENDCLASS.
