*&---------------------------------------------------------------------*
*& Include zsdt0001_form
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& 包含               ZSDT0001_FORM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form frm_get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text 我真服了
*&---------------------------------------------------------------------*
form frm_get_data .
  "根据fs字段参考获取相应的数据
  if onl1 = 'X'.
    "年度
    select * from ztsd004
*      INNER JOIN tvm1t ON ztsd004~bezei = tvm1t~bezei
      into corresponding fields of table gt_year.

  elseif onl2 = 'X'.
    "促销
    select * from ztsd005
*      INNER JOIN t188t ON ztsd005~vtext = t188t~vtext
*      INNER JOIN t151t ON ztsd005~ktext = t151t~ktext
*     INNER JOIN tvm1t ON ztsd005~bezei = tvm1t~bezei
      into corresponding fields of table gt_prom.

  elseif onl3 = 'X'.
    "产品
    select * from ztsd006
*     INNER JOIN t188t ON ztsd006~vtext = t188t~vtext
*      INNER JOIN t151t ON ztsd006~ktext = t151t~ktext
*      INNER JOIN makt ON ztsd006~maktx = makt~maktx
      into corresponding fields of table gt_prod.
  endif.
endform.

*&---------------------------------------------------------------------*
*& Form frm_init_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_init_layout .
  gs_layout-cwidth_opt  =  'X'.
  gs_layout-zebra  = 'X'." 颜色交替.
  gs_layout-edit = 'X'. "修改

endform.
*&---------------------------------------------------------------------*
*& Form frm_init_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_init_fieldcat ."宏定义

  clear gs_fieldcat.
  "年度字段展示
  if onl1 = 'X'.
    m_fcat:
'MJAHR'  '年度' ''  ,
'MVGR1'  '系列代码' ''  ,
'BEZEI'  '系列名称' ''  ,
'PRICE'  '返利单价' ''  ,
'ERNAM'  '创建人' ''  ,
'AUDAT'   '创建日期'  '' ,
'ZERNAM'  '审核人' ''  ,
'ANGDT'  '审核日期' ''  ,
'STATE'  '状态' ''  ,
'ZTIME'  '更新时间' '' .

    append gs_fieldcat to gt_fieldcat .

  elseif onl2 = 'X'.
    m_fcat:
   'MJAHR'   '年度'            ''  ,
   'KDGRP'   '客户分类'        ''  ,
   'MVGR1'   '系列代码'        ''  ,
   'KONDA'   '促销类型'        ''  ,
   'VTEXT'   '促销类型描述'    ''  ,
   'KTEXT'   '客户分类名称'    ''  ,
   'BEZEI'   '系列名称'        ''  ,
   'PRICE'   '返利单价'        ''  ,
   'ERNAM'   '创建人'          ''  ,
   'AUDAT'   '创建日期'        ''  ,
   'ZERNAM'   '审核人'         ''  ,
   'ANGDT'   '审核日期'        ''  ,
   'STATE'   '状态'            ''  ,
   'ZTIME'   '更新时间'        ''  .

    append gs_fieldcat to gt_fieldcat .
  elseif onl3 = 'X'.
    m_fcat:
'MJAHR' '年度' '' ,
'KONDA' '促销类型' '' ,
'VTEXT' '促销类型描述' '' ,
'KDGRP' '客户分类' '' ,
'KTEXT' '客户分类名称'  ''  ,
'MANTR' '产品编码' '' ,
'MAKTX' '产品名称' '' ,
'PRICE' '返利单价' '' ,
'ERNAM' '创建人' '' ,
'AUDAT' '创建日期' '' ,
'ZERNAM'  '审核人' '' ,
'ANGDT' '审核日期' '' ,
'STATE' '状态' '' ,
'ZTIME' '更新时间' '' .
    append gs_fieldcat to gt_fieldcat .
  endif.
  perform frm_toolbar .
endform.

*关闭到alv上的部分按钮
form frm_toolbar .
  refresh g_toolbar.
  perform append_alv_exclude_functions tables g_toolbar  using:
               cl_gui_alv_grid=>mc_fc_reprep            ,
               cl_gui_alv_grid=>mc_fc_check             ,
               cl_gui_alv_grid=>mc_mb_export            ,
               cl_gui_alv_grid=>mc_fc_detail            ,
*               cl_gui_alv_grid=>mc_fc_refresh           ,
               cl_gui_alv_grid=>mc_fc_graph             ,
               cl_gui_alv_grid=>mc_fc_loc_undo          ,
               cl_gui_alv_grid=>mc_fc_loc_delete_row    ,
               cl_gui_alv_grid=>mc_fc_loc_insert_row    ,
               cl_gui_alv_grid=>mc_fc_loc_copy_row      ,
               cl_gui_alv_grid=>mc_fc_loc_cut           ,
               cl_gui_alv_grid=>mc_fc_loc_append_row    ,
               cl_gui_alv_grid=>mc_fc_loc_paste_new_row ,
               cl_gui_alv_grid=>mc_fc_info              ,
               cl_gui_alv_grid=>mc_fc_loc_copy          ,
               cl_gui_alv_grid=>mc_fc_loc_paste         ,
               cl_gui_alv_grid=>mc_fc_print             ,
               cl_gui_alv_grid=>mc_mb_sum               ,
               cl_gui_alv_grid=>mc_mb_view              ,
               cl_gui_alv_grid=>mc_fc_current_variant   ,
               cl_gui_alv_grid=>mc_fc_save_variant      ,
               cl_gui_alv_grid=>mc_fc_load_variant      ,
               cl_gui_alv_grid=>mc_fc_maintain_variant  ,
               cl_gui_alv_grid=>mc_fc_deselect_all      ,
               cl_gui_alv_grid=>mc_fc_select_all        .


endform.
form append_alv_exclude_functions tables pt_exclude type ui_functions
                                    using  p_value    type ui_func.
  append p_value to pt_exclude.
endform.


*&---------------------------------------------------------------------*
*& Form frm_display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_display_alv  .
  if  onl1 = 'X'.
    call method gs_alv->set_table_for_first_display
      exporting
        it_toolbar_excluding          = g_toolbar
        is_layout                     = gs_layout
      changing
        it_outtab                     = gt_year "传出表
        it_fieldcatalog               = gt_fieldcat "表单列格式
      exceptions
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        others                        = 4.
  elseif onl2 = 'X'.
    call method gs_alv->set_table_for_first_display
      exporting
        it_toolbar_excluding          = g_toolbar
        is_layout                     = gs_layout
      changing
        it_outtab                     = gt_prom "传出表
        it_fieldcatalog               = gt_fieldcat "表单列格式
      exceptions
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        others                        = 4.
  elseif onl3 = 'X'.
    call method gs_alv->set_table_for_first_display
      exporting
        it_toolbar_excluding          = g_toolbar
        is_layout                     = gs_layout
      changing
        it_outtab                     = gt_prod "传出表
        it_fieldcatalog               = gt_fieldcat "表单列格式
      exceptions
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        others                        = 4.
  endif.
endform.

form creat_alv .
  create object gs_parent
    exporting
      container_name = 'GC_CON'. "界面中的cunstomer control 控件名称
*将lav注入到容器中
  create object gs_alv
    exporting
      i_parent = gs_parent.
endform.
*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form refresh_alv .
  gs_stable-row = 'X'.
  gs_stable-col = 'X'.

  call method gs_alv->refresh_table_display
    exporting
      is_stable = gs_stable
*     i_soft_refresh =
    exceptions
      finished  = 1
      others    = 2.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form frm_save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_save_data .

  data: gt_tmp_4  type table of ztsd004.
  data: gt_tmp_5  type table of ztsd005.
  data: gt_tmp_6  type table of ztsd006.

  data flg type c length 1.

  "修改数据->内表得到数据->添加导数据库->
  "1.添加成功->修改状态和审核人->修改 审核 存在数据库->返回消息成功
  if  onl1 = 'X'.

    modify  ztsd004 from table gt_year .

    select * from ztsd004
    into corresponding fields of table gt_tmp_4.
    call function 'CTVB_COMPARE_TABLES_3'
      exporting
        it_table_old  = gt_tmp_4
        it_table_new  = gt_year
        iv_key_count  = 100
      importing
        ev_no_changes = flg.
    if  flg = 'X'.

      message s001 display like 'S'.
      exit.
    else .
      message e002 display like 'E'.
      exit .
    endif.
    clear : flg, gt_tmp_4.
  elseif onl2 = 'X'.
    modify  ztsd005 from table gt_prom .
    select * from ztsd005
    into corresponding fields of table gt_tmp_5.
    call function 'CTVB_COMPARE_TABLES_3'
      exporting
        it_table_old  = gt_tmp_5
        it_table_new  = gt_prom
        iv_key_count  = 100
      importing
        ev_no_changes = flg.
    if  flg = 'X'.

      message s001 display like 'S'.
      exit.
    else .
      message e002 display like 'E'.
      exit .
    endif.
    clear : flg, gt_tmp_5.
  elseif onl3 = 'X'.
    modify  ztsd006 from table gt_prod .
    select * from ztsd006
    into corresponding fields of table gt_tmp_6.
    call function 'CTVB_COMPARE_TABLES_3'
      exporting
        it_table_old  = gt_tmp_6
        it_table_new  = gt_prod
        iv_key_count  = 100
      importing
        ev_no_changes = flg.
    if  flg = 'X'.

      message s001 display like 'S'.
      exit.
    else .
      message e002 display like 'E'.
      exit .
    endif.
    clear : flg, gt_tmp_6.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form frm_delete_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_delete_data .
*1.获取选中的行号
*2.把选中的数据给到另一个内表中
*3.删除所选行号
*4.删除数据库

  "删除
  data lt_select type lvc_t_row.
  data gt_del4 type table of ztsd004.
  data gt_del5 type table of ztsd005.
  data gt_del6 type table of ztsd006.
  data gs_del4 like line of gt_del4.
  data gs_del5 like line of gt_del5.
  data gs_del6 like line of gt_del6.
*  DATA ls_del LIKE LINE OF gt_del.

  call method gs_alv->get_selected_rows
    importing
      et_index_rows = lt_select.
  if onl1 = 'X'.
    loop at lt_select into data(ls_select4).
      read table gt_year into gs_year index ls_select4-index.
      if sy-subrc = 0.
        move-corresponding gs_year to gs_del4.
        gs_del4-ztime = 'X'.
        append gs_del4 to gt_del4.
        clear gs_del4.
      endif.
      delete  gt_year index ls_select4-index.
      delete ztsd004 from table gt_del4 .
      if sy-subrc = 0.
        message s003 display like 'S'.
      else.
        message e004 display like 'E'.
      endif.
    endloop.
  elseif onl2 = 'X'.
    loop at lt_select into data(ls_select5).
      read table gt_prom into gs_prom index ls_select5-index.
      if sy-subrc = 0.
        move-corresponding gs_prom to gs_del5.
        gs_del5-ztime = 'X'.
        append gs_del5 to gt_del5.
        clear gs_del5.
      endif.
      delete  gt_prom index ls_select5-index.
      delete ztsd005 from table gt_del5 .
      if sy-subrc = 0.
        message s003 display like 'S'.
      else.
        message e004 display like 'E'.
      endif.
    endloop.
  elseif onl3 = 'X'.
    loop at lt_select into data(ls_select6).
      read table gt_prod into gs_prod index ls_select6-index. "获取选中的行号
      if sy-subrc = 0.
        move-corresponding gs_prod to gs_del6.
        gs_del6-ztime = 'X'.
        append gs_del6 to gt_del6.
        clear gs_del6.
      endif.
      delete  gt_prod index ls_select6-index."删除ooalv显示
      delete ztsd006 from table gt_del6 . "删除数据库中的
      if sy-subrc = 0.
        message s003 display like 'S'.
      else.
        message e004 display like 'E'.
      endif.
    endloop.
  endif.
  perform refresh_alv . "刷新
endform.
*&---------------------------------------------------------------------*
*& Form frm_check_authority
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_check_authority .
*  AUTHORITY-CHECK OBJECT 'ZQM06_WERK'
*          ID 'WERKS' FIELD p_werks.
*  IF sy-subrc <> 0.
*    MESSAGE e036(zsy_qm_dev) WITH p_werks.
*  ENDIF.
endform.
*&---------------------------------------------------------------------*
*& Form frm_disp_edit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM frm_disp_edit .
*      STYLELIN-FIELDNAME = 'ZBQFS'. " 需要编辑的列名
*     STYLELIN-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED. " 设置为不可编辑状态
*      CLEAR STYLELIN.
*ENDFORM.
