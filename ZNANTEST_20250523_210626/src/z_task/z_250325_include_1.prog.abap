*&---------------------------------------------------------------------*
*& 包含               Z_250325_INCLUDE_1
*&---------------------------------------------------------------------*



*&------------------------------------------------------------------&*
*&  数据查看
*&------------------------------------------------------------------&*
form frm_view_data.
  " 查询数据
  select *                                    "#EC CI_ALL_FIELDS_NEEDED
    into table gt_out
    from z250318
    where werks in so_werks.

  " ALV显示数据
  data ls_fieldcat type line of slis_t_fieldcat_alv.
  data lt_fieldcat type slis_t_fieldcat_alv.
  data ls_layout   type slis_layout_alv.
  ls_layout-colwidth_optimize = 'X'. " 自动设置列宽

  define mac_setfieldcat.
    ls_fieldcat-fieldname = &1.
    ls_fieldcat-seltext_m = &2.
    ls_fieldcat-tabname   = &3.

    append ls_fieldcat to lt_fieldcat.
    clear ls_fieldcat.
  end-of-definition.

  mac_setfieldcat 'WERKS' '工厂编号' 'GT_OUT'.
  mac_setfieldcat 'LGORT' '存储地点' 'GT_OUT'.
  mac_setfieldcat 'LGOBE' '存储地点描述' 'GT_OUT'.
  mac_setfieldcat 'DPNAME'   '发料部门' 'GT_OUT'.
  mac_setfieldcat 'PRIORITY' '优先级' 'GT_OUT'.

  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program = sy-repid
      is_layout          = ls_layout
      it_fieldcat        = lt_fieldcat
    tables
      t_outtab           = gt_out
    exceptions
      program_error      = 1.
endform.

*&------------------------------------------------------------------&*
*&  数据维护
*&------------------------------------------------------------------&*
form frm_main_data.
  data lv_action           TYPE c LENGTH 1    value 'S'.
  data lv_view_name        like dd02v-tabname value 'z250318'.
  data lt_dba_sellist      type table of vimsellist.
  data lt_dba_sellist_temp type table of vimsellist.

  ranges lr_mandt for z250318-client.
  ranges lr_werks for z250318-werks.

  " S表示修改，U表示读
  case 'X'.
    when pa_view.
      lv_action = 'U'.
    when pa_main.
      lv_action = 'S'.
    when others.
  endcase.

  " 筛选需要维护的数据的条件，将mandt哥werks作为选择条件装到lt_dba_sellist[]，并且这两个条件是AND关系

  lr_mandt = value #( sign   = 'I'
                      option = 'EQ'
                      low    = sy-mandt ).
  append lr_mandt.

  refresh lt_dba_sellist_temp.
  call function 'VIEW_RANGETAB_TO_SELLIST' " 视图需要按条件筛选，只展示想要展示的字段的数据，则调用这个函数实现。
    exporting
      fieldname = 'CLIENT'
    tables
      sellist   = lt_dba_sellist_temp[]
      rangetab  = lr_mandt[].
  append lines of lt_dba_sellist_temp to lt_dba_sellist.

*  lr_werks-sign = 'I'.
*  lr_werks-option = 'EQ'.
*  lr_werks-low = so_werks.
*  APPEND lr_werks.
  if so_werks[] is not initial."屏幕输入的工厂范围信息
    append lines of so_werks to lr_werks.
  endif.

  refresh lt_dba_sellist_temp.
  call function 'VIEW_RANGETAB_TO_SELLIST'
    exporting
      fieldname = 'WERKS'
    tables
      sellist   = lt_dba_sellist_temp[]
      rangetab  = lr_werks[].
  append lines of lt_dba_sellist_temp to lt_dba_sellist.

  " 当输入仓库号时查询出仓库描述



  " 调用视图维护器
  call function 'VIEW_MAINTENANCE_CALL'
    exporting
      action                       = lv_action " 判断执行读还是写
      view_name                    = lv_view_name
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
