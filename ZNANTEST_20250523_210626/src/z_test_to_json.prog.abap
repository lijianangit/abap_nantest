*&---------------------------------------------------------------------*
*& Report z_test_to_json
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_to_json.
select * from sflight into table @data(tab1) .
data lo_json_ser type ref to cl_trex_json_serializer.
lo_json_ser = new #( data = tab1 ).
lo_json_ser->serialize( ).
data(jsonData) = lo_json_ser->get_data( ).

cl_demo_output=>display_html( html = jsonData ).
cl_demo_output=>display_json( json = jsonData ).
cl_demo_output=>display_text( text = jsonData ).
cl_demo_output=>display_data(
  exporting
    value = jsonData
).

data tab2 like table of sflight.
data  lo_json_des type ref to cl_trex_json_deserializer.
create object lo_json_des.
call method lo_json_des->deserialize
  exporting
    json = jsonData
  importing
    abap = tab2.
cl_demo_output=>display( tab2 ).
