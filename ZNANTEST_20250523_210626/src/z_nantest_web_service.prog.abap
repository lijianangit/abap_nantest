*&---------------------------------------------------------------------*
*& Report z_nantest_web_service
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_nantest_web_service.
data: lr_proxy type ref to znantes_co_z_nantest_service_p,
      input    type znantes_z_test_rap_1,
      output   type znantes_z_test_rap_1response.
input-in_age1 = 11.
input-in_age2 = 22.
create object lr_proxy
  exporting
    logical_port_name = 'ZNANTES_CO_Z_NANTEST_SERVICE_P_PORT'."SOA消费者中得到逻辑端口我
call method lr_proxy->z_test_rap_1
  exporting
    input  = input
  importing
    output = output.

cl_demo_output=>display( output-sum_age ).
