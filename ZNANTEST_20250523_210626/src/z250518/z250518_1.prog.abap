*&---------------------------------------------------------------------*
*& Report z250518_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250518_1.
" data reference 对象不能直接进行赋值,需要通过 ->* 符号 （被称作解引用操作符 , dereferencing operator）。
data lr_num type ref to i.
create data lr_num.
lr_num->* = 2.
write / |引用类型具体类型已经明确:{ lr_num->* }|.


data str1 type string value 'znentets'.
" 引用类型的类型未明确，需要跟field-symbol组合起来
data lr_data type ref to data. ",声明引用类型，未指定具体类型，必须create data
create data lr_data type (str1) .  " 动态创建一个整数类型的数据对象，有内存地址
assign lr_data->* to field-symbol(<fs_data>).
<fs_data> = 42.
write: / '未明确: ', <fs_data>.  " 输出数据的值，即 42

  "引用类型是复杂结构时，其赋值需要如下，方法1
"assign component 'MATNR' of structure <line> to field-symbol(<fld>).


"方法2
data tab_name type tabname value 'z250510_tab_1'. " table name
data(struct_descr) = cl_abap_structdescr=>describe_by_name( tab_name ).
data(table_descr) = cl_abap_tabledescr=>create( p_line_type = cast #( struct_descr ) ).
data table_dref type ref to data.
create data table_dref type handle table_descr."创建对应的内表内存区域
field-symbols <table> type any table.
assign table_dref->* to <table>.
select * from (tab_name) up to 10 rows into corresponding fields of table <table>.
cl_demo_output=>display( <table> ).


*" 根据指定字符串创建对应的结构，然后转型为cl_abap_structdescr
*data(result_structure) = cast cl_abap_structdescr( cl_abap_structdescr=>describe_by_name( p_name = 'Z250510_TAB_1' ) ).
*" 根据结构描述，创建指定的table描述对象
*data(result_table) = cast cl_abap_tabledescr( cl_abap_tabledescr=>create( p_line_type = result_structure ) ).
data tab1         type standard table of string.
data iv_tab_name  type string value 'z250510_tab_1'.
perform build using    iv_tab_name
              changing tab1.
form build using    iv_tab_name type string
           changing et_output   type standard table.

  field-symbols <output> like et_output.

  data(lo_struct) = cl_abap_structdescr=>describe_by_name( iv_tab_name ).
  data(lo_table) = cl_abap_tabledescr=>create( p_line_type = cast #( lo_struct ) ).
  data lr_table type ref to data.
  create data lr_table type handle lo_table.

  assign lr_table->* to  <output>.

  select * from (iv_tab_name) into table <output>  up to 3 rows.
  et_output = <output>.
   "<output>[ 1 ] = 'sdafadsf'.
  "et_output[ 1 ] = 'sdafadsf'.
endform.
