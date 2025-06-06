FUNCTION ZTEST_INSERTSQL.
*"----------------------------------------------------------------------
*"*"本地接口：
*"----------------------------------------------------------------------
  data ls_record type z250308_tab1.

  TRY.
      data(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).
      data(lv_uuid_x16) = lo_uuid->create_uuid_x16( ).
    CATCH cx_uuid_error. " Error Class for UUID Processing Errors
  ENDTRY.
  DATA stamp_1 TYPE TIMESTAMP.

  GET TIME STAMP FIELD stamp_1.
  ls_record = value z250308_tab1( uuid      = lv_uuid_x16
                                  desc1     = |{ lv_uuid_x16 } '11111111'  |
                                  desc2     = |{ lv_uuid_x16 } '222222222'  |
                                  datetime1 = stamp_1 ).
  insert into z250308_tab1 values ls_record.
endfunction.
