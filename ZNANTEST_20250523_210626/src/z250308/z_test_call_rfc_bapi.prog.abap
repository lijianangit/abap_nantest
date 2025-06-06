*&---------------------------------------------------------------------*
*& Report z_test_call_rfc_bapi
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_call_rfc_bapi.

data lo_root       type ref to cx_root.
data lv_subrc      type sy-subrc.
data lv_error_text type c length 100.
data lv_rfcdest    type char30 value 'znantest_connect_sap'. " SM59 连接名称
data lv_output     type i.

" 发送数据
try.
    call function 'ZTEST_RFC_FUN1'
      destination lv_rfcdest
      exporting
        im_p1                 = 55
        im_p2                 = 5
      importing
        output                = lv_output
      exceptions
        system_failure        = 1 message lv_error_text
        communication_failure = 2 message lv_error_text
        others                = 99.
  catch cx_root into lo_root.
    data(lv_message) = lo_root->get_text( ).
    message lv_message type 'S' display like 'E'.
    return.
endtry.

" 发送数据
data banfnStr type banfn.
try.
    call function 'ZTEST_RFC_FUN2'
      destination lv_rfcdest
      importing
        lv_banfn = banfnStr.
  catch cx_sy_zerodivide.
  catch cx_sy_assign_cast_error.
endtry.
call function 'ZTEST_INSERTSQL'.

write |结果：{ lv_output }|.

write |采购申请编号：{ banfnStr }|.
