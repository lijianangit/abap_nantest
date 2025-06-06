*&---------------------------------------------------------------------*
*& Include z_250329_include_1
*&---------------------------------------------------------------------*

parameters group1 type c radiobutton group g1 user-command z_do_some_thing.
parameters group2 type c radiobutton group g1.
parameters group3 type c radiobutton group g1.

data lt_datatab type table of z250318.


form get_path changing p_path.
  call function 'WS_FILENAME_GET'
    exporting
      def_filename     = 'Z_250318_TAB_EXECL.xlsx'
      def_path         = 'C:\Users\nan\Desktop\'
      mask             = ',EXCEL.XLSX,*.XLS,TXT,*.TXT,EXCEL.XLS,*.XLSX.'
      mode             = 'O'
"     TITLE            = ' '
    importing
      filename         = p_path
"     RC               =
    exceptions
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      others           = 5.
  if sy-subrc <> 0.
  endif.
endform.

form frm_temp_download.
  data: ls_wwwdatatab     like wwwdatatab,
        lt_mime           like w3mime occurs 10,
        lv_filename       type string,
        lv_path           type string,
        lv_fullpath       type string,
        window_title      type string,
        default_file_name type string.
  data: lv_destination type rlgrap-filename,
        lv_subrc       type sy-subrc.
  clear: ls_wwwdatatab,lt_mime[],lv_filename,lv_path,lv_fullpath,window_title,default_file_name.
  clear: lv_destination,lv_subrc.
  ls_wwwdatatab-relid = 'MI'.
  ls_wwwdatatab-objid = 'Z_250318_TAB_EXECL'.                        "这里写入TCODE:SMW0上传的对象
  ls_wwwdatatab-text  = 'Z_250318_TAB_EXECL'.
  window_title = '下载导入模板'.
  default_file_name = 'Z_250318_TAB_EXECL'.

  call function 'WWWDATA_IMPORT'                          "#EC *
    exporting
      key               = ls_wwwdatatab
    tables
      mime              = lt_mime
    exceptions
      wrong_object_type = 1
      import_error      = 2
      others            = 3.
  call method cl_gui_frontend_services=>file_save_dialog
    exporting
      window_title         = window_title
      default_extension    = 'xlsx'
      default_file_name    = default_file_name
    changing
      filename             = lv_filename
      path                 = lv_path
      fullpath             = lv_fullpath
    exceptions
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      others               = 4.
  if sy-subrc <> 0.
    stop.
  endif.
  if lv_fullpath is not initial.
    lv_destination = lv_fullpath.
    call function 'DOWNLOAD_WEB_OBJECT'
      exporting
        key         = ls_wwwdatatab
        destination = lv_destination
      importing
        rc          = lv_subrc.
    if lv_subrc = 0.
      message '模板下载成功' type 'S'.
    else.
      message '模板下载失败' type 'E'.
    endif.
  endif.
endform.


form frm_get_data_file using p_file changing lt_datatab type table.
  data lt_raw type truxs_t_text_data.

  " TODO: variable is assigned but never used (ABAP cleaner)
  data lw_datatab type z250318 .


  refresh: lt_datatab[],lt_raw[].
  " 调用函数将Excel内容保存到内表
  call function 'TEXT_CONVERT_XLS_TO_SAP'
    exporting
      i_line_header        = 'X'
      i_tab_raw_data       = lt_raw
      i_filename           = p_file
    tables
      i_tab_converted_data = lt_datatab
    exceptions
      conversion_failed    = 1
      others               = 2.
  if sy-subrc <> 0.
    message '获取文件数据失败' type 'I'.
    stop.
  endif.
  loop at lt_datatab into lw_datatab.
  endloop.
endform.
"校验工厂和库位是否在t001标准表中存在
form valid_data tables tab1.
  data tab2 type table of z250318.

  tab2[] = tab1[].
  loop at tab2 assigning field-symbol(<line1>).
    select single * from t001l where werks = @<line1>-werks and lgort = @<line1>-lgort into @data(line1).
    if sy-subrc <> 0.
      message | { <line1>-lgort }+{ <line1>-werks }不存在,请检查数据  | type 'E'.
    endif.

  endloop.
endform.

form display_alv tables tab1.
  data lo_alv     type ref to cl_salv_table.
  " data lo_functions    type ref to cl_salv_functions_list.
  data lo_columns type ref to cl_salv_columns.
  " data lo_column       type ref to cl_salv_column.
  " data lo_sorts        type ref to cl_salv_sorts.        " 排序
  " data lo_agg          type ref to cl_salv_aggregations. " 汇总
  " data li_start_column type i                             value 10.
  " data li_end_column   type i                             value 100.
  " data li_start_line   type i                             value 2.
  " data li_end_line     type i                             value 12.

  " 构建：ALV

  try.
      " 调用静态方法，生产实例对象
      cl_salv_table=>factory( importing r_salv_table = lo_alv
                              changing  t_table      = tab1[] ).

    catch cx_salv_msg.
  endtry.

  " 设定：ALV参数
*  lo_functions = lo_alv->get_functions( ).
*  lo_functions->set_all( 'X' ). " 全局设置-显示ALV默认功能按钮

***设定：ALV参数-排序、汇总
*  lo_sorts = lo_alv->get_sorts( ).
*  lo_sorts->add_sort( columnname = 'BUKRS' ).
*
***设定：ALV参数-汇总
*  lo_agg = lo_alv->get_aggregations( ).
*  lo_agg->add_aggregation( 'DMBTR' ).
*
***数值带符号
*  lo_column = lo_columns->get_column('DMBTR').
*  lo_column->set_sign( abap_true ).
*
**设定：ALV参数-字段设置
  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( abap_true ).
*
*  " 显示：ALV
*  lo_alv->set_screen_popup( start_column = li_start_column
*                            end_column   = li_end_column
*                            start_line   = li_start_line
*                            end_line     = li_end_line ).

  lo_alv->display( ).
endform.


module display_alv_by_custom output.
  data gr_container type ref to cl_gui_custom_container.
  data: gr_table type ref to cl_salv_table.
  data: gr_functions type ref to cl_salv_functions_list.


  " 判断是否已分配了一个有效引用
  if gr_container is not bound.
    "创建容器
    create object gr_container
      exporting
        container_name = 'CONTAINER_1'. "屏幕上用户自定义控件名
    "创建ALV
    cl_salv_table=>factory(
      exporting
        r_container    = gr_container
        container_name = 'CONTAINER_1'
      importing
        r_salv_table   = gr_table
      changing
        t_table        = lt_datatab[] ).
    "设置工具栏
    gr_functions = gr_table->get_functions( ).
    gr_functions->set_all( abap_true ). "Activate All Generic ALV Functions，将激活所有的ALV内置通用按钮

    "显示
    gr_table->display( ).

  endif.
endmodule.


form import_data tables tab1.
  try.
      insert z250318 from table tab1.
      if sy-subrc = 0.
        message |导入数据成功| type 'S'.
      else.
        message |导入数据失败| type 'E'.
      endif.

    catch cx_root into data(lx_exception).
      " 捕获异常，处理错误
      message |{ lx_exception->get_text( ) }| type 'E'.
  endtry.
endform.

form remove_data tables tab1.
  try.
      delete z250318 from tab1.
      if sy-subrc = 0.
        commit work and wait.  " 提交事务
        write '删除成功，已提交事务'.
      else.
        rollback work.  " 回滚事务
        message |删除失败，已回滚事务| type 'E'.

      endif.
    catch cx_root into data(lx_exception).
      " 捕获异常，处理错误
      message |{ lx_exception->get_text( ) }| type 'E'.
  endtry.
endform.

module user_command_2000 input.

  case sy-ucomm.

    when 'ONLI'.
      perform import_data tables lt_datatab.
    when 'FC01'.
      perform frm_temp_download.           " 模板下载处理的FROM
  endcase.


endmodule   .
