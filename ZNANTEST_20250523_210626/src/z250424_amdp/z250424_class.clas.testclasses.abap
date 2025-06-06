*"* use this source file for your ABAP unit test classes

class test_amdp definition final
                for testing risk level harmless duration short.
  private section.
    methods test for testing.
endclass.


class test_amdp implementation.
  method test.

    if not cl_abap_dbfeatures=>use_features(
      exporting
        requested_features =
          value #( ( cl_abap_dbfeatures=>call_amdp_method ) ) ).
      return.
    endif.

    try.
        new z250424_class( )->increase_price( clnt = sy-mandt
                                              inc  = '0.1' ) ##LITERAL.
      catch cx_amdp_error .
        cl_aunit_assert=>fail(
          msg   = 'AMDP method call failed' ##no_text
          level = cl_aunit_assert=>critical ).
    endtry.

    try.
        new z250424_class( )->increase_price_client( inc  = '0.1' ) ##LITERAL.
      catch cx_amdp_error.
        cl_aunit_assert=>fail(
          msg   = 'AMDP method call failed' ##no_text
          level = cl_aunit_assert=>critical ).
    endtry.

    try.
        new z250424_class( )->increase_price_cds_client( inc  = '0.1' ) ##LITERAL.
      catch cx_amdp_error.
        cl_aunit_assert=>fail(
          msg   = 'AMDP method call failed' ##no_text
          level = cl_aunit_assert=>critical ).
    endtry.

  endmethod.
endclass.
