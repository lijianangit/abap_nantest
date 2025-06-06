*&---------------------------------------------------------------------*
*& Report z250501_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250501_1.
tables z250501_tab.

load-of-program.

top-of-page."在页首输出时触发。

  selection-screen begin of block b01 with frame title text-001.
    select-options:
      lt_werks for  z250501_tab-werks,
      lt_lgpbe for z250501_tab-lgpbe,
      lt_zbr for z250501_tab-zbr.
  selection-screen end of block b01.
  selection-screen begin of block b02 with frame title text-002.
    parameters rd_main radiobutton group act user-command dummy. "维护视图
    parameters rd_view radiobutton group act. "数据查看
  selection-screen end of block b02.

initialization."在程序开始执行时初始化数据时触发。

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行PAI

start-of-selection."点击执行后的主程序代码。
  case 'X'.
    when rd_main.
      perform display_maintain_avl.
    when rd_view.
      perform display_readOnl_ALV.
    when others.
  endcase.

end-of-page."在页尾输出时触发。
*&---------------------------------------------------------------------*
*& Form display_maintain_avl
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form display_maintain_avl .
  data lv_action type c value 'S'.
  data lv_tab_name type dd02v-tabname value 'z250501_tab'.
  data lt_dba_sellist type table of vimsellist. "指定需要维护的字段列表

  ranges lr_mandt for t001-mandt.
  ranges lr_werks for t001w_werks.
  ranges lr_zbr for z250501_tab-zbr.




  lr_mandt = value #( sign   = 'I'
                    option = 'EQ'
                    low    = sy-mandt ).
  append lr_mandt.

  call function 'VIEW_RANGETAB_TO_SELLIST' "视图需要按条件筛选，只展示想要展示的字段的数据，则调用这个函数实现。
    exporting
      fieldname = 'CLIENT'
    tables
      sellist   = lt_dba_sellist[]
      rangetab  = lr_mandt[].

*工厂
  if lt_werks is not initial.
    call function 'VIEW_RANGETAB_TO_SELLIST'
      exporting
        fieldname          = 'WERKS'
        append_conjunction = 'AND'
      tables
        sellist            = lt_dba_sellist[]
        rangetab           = lt_werks[].
  endif.

*库存仓位
  if lt_lgpbe is not initial.
    call function 'VIEW_RANGETAB_TO_SELLIST'
      exporting
        fieldname          = 'LGPBE'
        append_conjunction = 'AND'
      tables
        sellist            = lt_dba_sellist[]
        rangetab           = lt_lgpbe[].
  endif.



*制单人
  if lr_zbr is not initial.
    call function 'VIEW_RANGETAB_TO_SELLIST'
      exporting
        fieldname          = 'ZBR'
        append_conjunction = 'AND'
      tables
        sellist            = lt_dba_sellist[]
        rangetab           = lr_zbr[].
  endif.

*  调用视图维护器
  call function 'VIEW_MAINTENANCE_CALL'
    exporting
      action                       = lv_action "判断执行读还是写
      view_name                    = lv_tab_name
    tables
      dba_sellist                  = lt_dba_sellist[]
    exceptions
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      others                       = 15.



endform.
*&---------------------------------------------------------------------*
*& Form display_readOnl_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form display_readOnl_ALV .
  select * from z250501_tab into table @data(tab1)
   where werks in @lt_werks and lgpbe in @lt_lgpbe and zbr in @lt_zbr.
  cl_salv_table=>factory(
*     exporting
*       list_display   = if_salv_c_bool_sap=>false
*       r_container    =
*       container_name =
    importing
      r_salv_table = data(salv_table)
    changing
      t_table      = tab1
  ).
  "设置工具栏
  data(gr_functions) = salv_table->get_functions( )."获取功能列表
  gr_functions->set_all( abap_true ). "Activate All Generic ALV Functions，将激活所有的ALV内置通用按钮
  salv_table->display( ).
*   catch cx_salv_msg.
endform.
