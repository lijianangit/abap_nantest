*&---------------------------------------------------------------------*
*& Report z250325_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250325_3.

data lv_file_name   type string value 'C:\temp\2.json'.
data lv_file_length type i.
data lt_content     type string_table.
data lv_content     type string.
data lv_json        type string.

call function 'GUI_UPLOAD'
  exporting filename   = lv_file_name
  importing filelength = lv_file_length
  tables    data_tab   = lt_content.

loop at lt_content into lv_content.
  lv_json = lv_json && lv_content.
endloop.

types: begin of ty_json,
         success   type string,
         data type string_table,
       end of ty_json.

data ls_data  type ty_json.
data lv_skill type string.

/ui2/cl_json=>deserialize( exporting json = lv_json
                           changing  data = ls_data ).

write / '解析完成。'.

write:/ ls_data-success.

loop at ls_data-data into lv_skill.
  write / lv_skill.
endloop.
