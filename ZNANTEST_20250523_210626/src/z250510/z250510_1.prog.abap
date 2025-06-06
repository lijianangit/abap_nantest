*&---------------------------------------------------------------------*
*& Report z250510_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250510_1.
tables: mara, z250510_tab_1.

load-of-program.

top-of-page."在页首输出时触发。


initialization.
  data(utli) = new z_nantest_util( ).
  selection-screen begin of block b01 with frame title text-001.
    parameters rb_mai radiobutton group act user-command dummy default 'X'. " 维护视图
    parameters rb_imp radiobutton group act. " 数据查看
    parameters rb_req radiobutton group act. " 数据查看
  selection-screen end of block b01.
  selection-screen begin of block b02 with frame title text-002.
    select-options p_matnr for mara-matnr modif id m1.
  selection-screen end of block b02.
  selection-screen begin of block b03 with frame title text-003.
    parameters p_file like rlgrap-filename obligatory modif id m2 default 'O:\ondDrive\OneDrive\宿舍电脑\sap程序文件\z250510_1_upload.xlsx'. " obligatory.
    parameters P_begin type i  default 3 obligatory modif id m2 .
  selection-screen end of block b03.
  selection-screen function key 1.           " 第一个按钮
  tables sscrfields.
  sscrfields-functxt_01 = '模板下载'.      " 定义第一个按钮文本
  sscrfields-from_text  = '模板下载'.
  sscrfields-to_text    = '模板下载'.

at selection-screen output. " 在屏幕选择数据输出时触发。PBO
  " 在这个事件里声明的变量都是局部变量。
  " TODO: variable is assigned but never used (ABAP cleaner)
  data tab1 type table of screen.

  loop at screen.  " 遍历选择屏幕中的所有元素根据选择的内容进行显示隐藏
    case 'X'.
      when rb_mai.
        if screen-group1 = 'M1'.
          screen-active = '1'.
        endif.
        if screen-group1 = 'M2'.
          screen-active = '0'.
        endif.
      when rb_imp.
        if screen-group1 = 'M1'.
          screen-active = '0'.
        endif.
        if screen-group1 = 'M2'.
          screen-active = '1'.
        endif.
      when rb_req.
        if screen-group1 = 'M1'.
          screen-active = '1'.
        endif.
        if screen-group1 = 'M2'.
          screen-active = '0'.
        endif.
    endcase.
    append screen to tab1.
    modify screen.  " 保存更改
  endloop.

  " 数据选择和处理事件."

at selection-screen. " 在屏幕选择执行的时候,点击执行PAI
  case sy-ucomm.
    when 'DUMMY'.
      message 'DUMMY' type 'S'.
    when 'FC01'.
      utli->download_template( template_name     = 'Z250510_1_EXCEL'
                               window_title      = '模板下载'
                               default_file_name = 'Z250510_1_EXCEL' ). " 模板下载处理的FROM
  endcase.
  message |{ sy-ucomm }| type 'S'.

start-of-selection. " 点击执行后的主程序代码。
  case 'X'.
    when rb_mai.
      call function 'VIEW_MAINTENANCE_CALL'
        exporting
          action               = 'S' " S = Display U = Change T = Transport
          show_selection_popup = ''
          view_name            = 'z250510_tab_1'.

    when rb_imp.
      data lt_intern    type table of alsmex_tabline.

*      utli->upload_template( exporting
*                               p_file     = p_file
*                             changing
*                               lt_datatab = tab1[] ).

      " field-symbols result_table type  any table.
      data result_table type table of z250510_tab_1.
      "获取到文件内容
      utli->upload_template_v2( exporting
                                  pa_path   = p_file
                                  begin_row = p_begin
                                  begin_col = 2
                                importing
                                  gt_out    = lt_intern ).
      "转换为指定内表
      perform transform_data using    lt_intern
                             changing result_table.
      "填充描述信息
      utli->fill_table_file( changing tab1 = result_table[] ).
      "cl_demo_output=>display( result_table[] ).
      perform remove_data tables result_table[].

      insert z250510_tab_1 from table result_table[].
      if sy-subrc = 0.
        utli->display_table( changing result_tab = result_table ).
        perform remove_data tables result_table.

      endif.
    when rb_req.

      select * from z250510_tab_1
        into table @data(tab2)
        where matnr in @p_matnr.

      utli->display_table( changing result_tab = tab2 ).
  endcase.

end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。

*&---------------------------------------------------------------------*
*& Form frm_process_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_process_data tables  gt_out type table of z250510_tab_1 .
  data gv_flag type c value 'X'.

*  data gt_out1 type table of z250510_tab_1.
*  clear gv_flag.
*    loop at tab1 assigning field-symbol(<line1>).
*    endloop.
*     loop at gt_out into  data(gs_out).  "GT_OUT" 具有无法用于声明的通用类型。
*     endloop.
*  loop at tab1 assigning field-symbol(<line1>).
*    if <line1>-zfzlf is initial.
*      message | | type 'E'.
*    endif.
*    if <line1>-zflag is initial.
*      message || type 'E'.
*    endif.
*    if <line1>-ztxpm is initial.
*      message || type 'E'.
*    endif.
*  endloop.
endform.

data para_type type table of alsmex_tabline.
data gt_out2 type table of z250510_tab_1.
form transform_data using    lt_intern like para_type
                    changing gt_out    like gt_out2.

  if lt_intern[] is initial.
    return.
  endif.
  data ls_intern type alsmex_tabline.
  data gs_out    type z250510_tab_1.
  clear gs_out.
  loop at lt_intern into ls_intern.
    case ls_intern-col.
      when '0001'.
        gs_out-matnr = ls_intern-value.
        translate gs_out-matnr to upper case.
      when '0002'.
        gs_out-zfzlf = ls_intern-value.  " 是否需要支付专利费（是/否）
      when '0003'.
        gs_out-zflag = ls_intern-value. " 单价是否已包含(是/否)
      when '0004'.
        gs_out-ztxpm = ls_intern-value.   " 特许权使用费品名
      when '0005'.
        gs_out-flag = ls_intern-value.  " 已停用标识
    endcase.

    at end of row.
      gs_out-client = sy-mandt.
      append gs_out to gt_out.
      clear gs_out.
    endat.
  endloop.
endform.

form remove_data tables tab1.
  try.
      delete from z250510_tab_1.
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
