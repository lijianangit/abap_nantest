*&---------------------------------------------------------------------*
*& Report z250424
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250424.

class demo definition.
  public section.
    class-methods main.
endclass.

class demo implementation.
  method main.
    " 是否支持AMDP
    if not cl_abap_dbfeatures=>use_features( requested_features = value #( ( cl_abap_dbfeatures=>call_amdp_method ) ) ).
      cl_demo_output=>display( `Current database system does not support AMDP procedures` ).
      return.
    endif.

    data incprice type sflight-price value '0.1'.
    data(client)     = abap_false.
    data(cds_client) = abap_false.
    cl_demo_input=>new(
      )->add_field( changing field = incprice
      )->add_field( exporting as_checkbox = abap_true
                              text        = `Use session variable CLIENT`
                    changing  field       = client
      )->add_field( exporting as_checkbox = abap_true
                              text        = `Use session variable CDS_CLIENT`
                    changing  field       = cds_client
      )->request( ).

    if    incprice is initial
       or client is not initial and cds_client is not initial.
      return.
    endif.

    select price from sflight
      order by carrid, connid, fldate
      into @data(price_before)
      up to 1 rows.
    endselect.

    if client is initial and cds_client is initial.
      try.
          new z250424_class(
            )->increase_price( clnt = sy-mandt
                               inc  = incprice ).
        catch cx_amdp_error into data(amdp_error).
          cl_demo_output=>display( amdp_error->get_text( ) ).
          return.
      endtry.
    elseif client is not initial.
      try.
          new z250424_class(
            )->increase_price_client( inc = incprice ).
        catch cx_amdp_error into amdp_error.
          cl_demo_output=>display( amdp_error->get_text( ) ).
          return.
      endtry.
    elseif cds_client is not initial.
      try.
          new z250424_class(
            )->increase_price_cds_client( inc = incprice ).
        catch cx_amdp_error into amdp_error.
          cl_demo_output=>display( amdp_error->get_text( ) ).
          return.
      endtry.
    endif.

    select price from sflight
      order by carrid, connid, fldate
      into @data(price_after)
      up to 1 rows.
    endselect.
    if price_after - price_before = incprice.
      " TODO: check spelling: succesfully (typo) -> successfully (ABAP cleaner)
      cl_demo_output=>display( `Price increased succesfully` ).
    endif.
  endmethod.
endclass.

start-of-selection.
  demo=>main( ).
