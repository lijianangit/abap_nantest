*&---------------------------------------------------------------------*
*& Report z_innertable_maintain
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_innertable_maintain.


tables:zsy_d_qm61_ppap.
type-pools:slis.
data:begin of gt_item occurs 0,
       werks     type zsy_d_qm61_ppap-werks,    "工厂
       matnr     type zsy_d_qm61_ppap-matnr,    "物料编号
       maktx     type makt-maktx,             "物料描述
       lifnr     type zsy_d_qm61_ppap-lifnr,    "供应商或债权人的帐号
       name_org1 type but000-name_org1,    "供应商描述
       zcjr      type zsy_d_qm61_ppap-zcjr,    "创建人
       zcjrq     type zsy_d_qm61_ppap-zcjrq,    "创建日期
       zxgr      type zsy_d_qm61_ppap-zxgr,    "修改人
       zxgrq     type zsy_d_qm61_ppap-zxgrq,    "修改日期
       zzt       type zsy_d_qm61_ppap-zzt,    "状态
       dd_handle type char10,
       modify    type lvc_t_styl,
       newid     type i,
       del       type char1,
       update    type char1,
       add       type char1,
     end of gt_item.
data:gs_item like line of gt_item.
data:gt_upd like table of gt_item.
data:gt_del like table of gt_item.
data:gs_del like line of gt_del.
data: gv_newid   type i.
data: ok_code like sy-ucomm.
data lt_drop_down type lvc_t_drop.
data ls_drop_down type lvc_s_drop.
data:
  gt_ddval type lvc_t_drop,
  gw_ddval type lvc_s_drop.
data gs_stb type lvc_s_stbl.
data:
  wa_fieldcat type lvc_s_fcat, "用于定义ALV列字段相关类型数据,结构
  gs_layout   type lvc_s_layo,
  go_alv      type ref to cl_gui_alv_grid,
  gt_fieldcat type lvc_t_fcat,
  g_toolbar   type ui_functions,
  gs_con      type ref to cl_gui_custom_container.
data: gt_events type slis_t_event,
      gw_events type slis_alv_event.
constants c_status_form type slis_formname value 'PF_STATUS_SET'. "字符型，功能常量
constants c_command_form type slis_formname value 'USER_COMMAND'. "字符型，功能常量
data: grid type ref to cl_gui_alv_grid.
data: g_pos type i."用于alv字段目录最后顺序
data  g_edit type char1.  "编辑状态flag.
gs_stb-row = 'X'." 基于行的稳定刷新
gs_stb-col = 'X'." 基于列稳定刷新
class gcl_event_handler definition.
  public section.
    methods:
      handle_user_command   for event user_command of cl_gui_alv_grid
        importing
          e_ucomm,
*      handle_data_changed   FOR EVENT data_changed_finished  OF cl_gui_alv_grid
*       IMPORTING
*          er_good_cells,
      handle_data_changed   for event data_changed  of cl_gui_alv_grid
        importing
          er_data_changed,
      handle_hotspot_click  for event hotspot_click of cl_gui_alv_grid
        importing
          e_row_id
          e_column_id
          es_row_no.
endclass.
class gcl_event_handler implementation.
  method handle_hotspot_click.
*    PERFORM frm_hotspot_click.
  endmethod.
  method handle_user_command.
    case e_ucomm.
      when 'EDIT'.
        perform frm_edit.
      when 'ADD'.
        perform frm_add.
      when 'DEL'.
        perform frm_del.
      when 'SAVE'.
        perform frm_save.
    endcase.
  endmethod.                    "handle_user_command


  method handle_data_changed.

    perform frm_data_changed
      using
        er_data_changed->mt_mod_cells.

*    PERFORM frm_data_changed
*      USING
*        et_good_cells.


  endmethod.


endclass.

data:
  go_event_receiver type ref to gcl_event_handler.
selection-screen begin of block b1 with frame title text-s01.
  parameters: p_werks like zsy_d_qm61_ppap-werks obligatory.  "工厂
  select-options: s_matnr for zsy_d_qm61_ppap-matnr,     "物料
                  s_lifnr for zsy_d_qm61_ppap-lifnr,     "供应商
                  s_zzt for zsy_d_qm61_ppap-zzt.         "状态
selection-screen end of block b1.
*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
initialization.
  "perform frm_check_auth.  "权限检查
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
at selection-screen.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
at selection-screen output.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_xxxx.
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
start-of-selection.
  "获取数据
  perform frm_get_data.
*    PERFORM frm_prc_data.
* ALV 设定
  perform f_fieldcat_build. "第二步设置字段目录，即报表表头的显示部分
  perform frm_sub_get_down.
  perform create_alv.
  perform frm_ooalv_dis.
  call  screen 0100.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
end-of-selection.
*    PERFORM frm_display.
*&---------------------------------------------------------------------*
*& Form frm_get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_get_data .
  select * into corresponding fields of table gt_item from zsy_d_qm61_ppap
       where werks = p_werks and matnr in s_matnr and lifnr in s_lifnr and zzt in s_zzt.
  loop at gt_item assigning field-symbol(<fs_item>).
    select single maktx into <fs_item>-maktx from makt where spras = '1' and matnr = <fs_item>-matnr.  "物料描述
    select single name_org1 into <fs_item>-name_org1 from but000 where partner = <fs_item>-lifnr.      "供应商描述
  endloop.
  gt_upd[] = gt_item[].
endform.
*&---------------------------------------------------------------------*
*& Form frm_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED_>MT_MOD_CELLS
*&---------------------------------------------------------------------*
form frm_data_changed  using pt_mod_cells type lvc_t_modi.
endform.
*&---------------------------------------------------------------------*
*& Form frm_edit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_edit .  "修改
  if g_edit = 'X'.
    refresh gt_fieldcat.
    perform f_input_fieldcat using:
*----该处存放ALV需要展示的字段 STR--------
      'WERKS' '工厂' '' '' '' '',
      'MATNR' '物料编码' '' '' '' '',
      'MAKTX' '物料描述' '' '' '' '',
      'LIFNR' '供应商编码' '' '' '' '',
      'NAME_ORG1' '供应商描述' '' '' '' '',
      'ZCJR' '创建人' '' '' '' '',
      'ZCJRQ' '创建日期' '' '' '' '',
      'ZXGR' '修改人' '' '' '' '',
      'ZXGRQ' '修改日期' '' '' '' '',
      'ZXGR' '修改人' ''  '' '' '',
      'ZZT' '状态' ''  '' '' ''.
    call method go_alv->set_frontend_fieldcatalog
      exporting
        it_fieldcatalog = gt_fieldcat.

    call method go_alv->refresh_table_display.

    g_edit = ''.
  else.
    refresh gt_fieldcat.
    perform f_input_fieldcat using:
*----该处存放ALV需要展示的字段 STR--------
   'WERKS' '工厂' '' '' 'ZSY_D_QM61_PPAP' 'WERKS',
   'MATNR' '物料编码' '' '' 'ZSY_D_QM61_PPAP' 'MATNR',
   'MAKTX' '物料描述' '' '' 'MAKT' 'MAKTX',
   'LIFNR' '供应商编码' '' '' 'ZSY_D_QM61_PPAP' 'LIFNR',
   'NAME_ORG1' '供应商描述' '' '' 'BUT000' 'NAME_ORG1',
   'ZCJR' '创建人' '' '' 'ZSY_D_QM61_PPAP' 'ZCJR',
   'ZCJRQ' '创建日期' '' '' 'ZSY_D_QM61_PPAP' 'ZCJRQ',
   'ZXGR' '修改人' '' '' 'ZSY_D_QM61_PPAP' 'ZXGR',
   'ZXGRQ' '修改日期' '' '' 'ZSY_D_QM61_PPAP' 'ZXGRQ',
   'ZZT' '状态' 'X'  '' 'ZSY_D_QM61_PPAP' 'ZZT'.

    call method go_alv->set_frontend_fieldcatalog
      exporting
        it_fieldcatalog = gt_fieldcat.

    call method go_alv->refresh_table_display.
    g_edit = 'X'.
  endif.
  call method go_alv->refresh_table_display
    exporting
      is_stable = gs_stb.
endform.
*&---------------------------------------------------------------------*
*& Form frm_add
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_add .  "新增
  clear gs_item.
  gv_newid = gv_newid + 1.
  gs_item-newid = gv_newid.
  gs_item-zcjr = sy-uname.
  gs_item-zcjrq = sy-datum.
  gs_item-werks = p_werks.
  gs_item-add = 'X'.
  append gs_item to gt_item.
  refresh gt_fieldcat.
  perform f_input_fieldcat using:
*----该处存放ALV需要展示的字段 STR--------
   'WERKS' '工厂' '' '' 'ZSY_D_QM61_PPAP' 'WERKS',
   'MATNR' '物料编码' 'X' '' 'ZSY_D_QM61_PPAP' 'MATNR',
   'MAKTX' '物料描述' '' '' 'MAKT' 'MAKTX',
   'LIFNR' '供应商编码' 'X' '' 'ZSY_D_QM61_PPAP' 'LIFNR',
   'NAME_ORG1' '供应商描述' '' '' 'BUT000' 'NAME_ORG1',
   'ZCJR' '创建人' '' '' 'ZSY_D_QM61_PPAP' 'ZCJR',
   'ZCJRQ' '创建日期' '' '' 'ZSY_D_QM61_PPAP' 'ZCJRQ',
   'ZXGR' '修改人' '' '' 'ZSY_D_QM61_PPAP' 'ZXGR',
   'ZXGRQ' '修改日期' '' '' 'ZSY_D_QM61_PPAP' 'ZXGRQ',
   'ZZT' '状态' 'X'  '' 'ZSY_D_QM61_PPAP' 'ZZT'.
  call method go_alv->set_frontend_fieldcatalog
    exporting
      it_fieldcatalog = gt_fieldcat.
  call method go_alv->refresh_table_display
    exporting
      is_stable = gs_stb.
endform.
*&---------------------------------------------------------------------*
*& Form frm_del
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_del .  "删除
  data lt_select type lvc_t_row.
*  DATA ls_del LIKE LINE OF gt_del.

  call method go_alv->get_selected_rows
    importing
      et_index_rows = lt_select.

  loop at lt_select into data(ls_select).
    read table gt_item into gs_item index ls_select-index.
    if sy-subrc = 0.
      move-corresponding gs_item to gs_del.
      gs_del-del = 'X'.
      append gs_del to gt_del.
      clear gs_del.
    endif.
    delete gt_item index ls_select-index.
  endloop.
  call method go_alv->refresh_table_display
    exporting
      is_stable = gs_stb.
endform.
*&---------------------------------------------------------------------*
*& Form frm_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_save .
  data:lt_add like table of zsy_d_qm61_ppap,
       ls_add like line of lt_add.
  data:lt_update like table of zsy_d_qm61_ppap,
       ls_update like line of lt_update.
  data:lt_delete like table of zsy_d_qm61_ppap,
       ls_delete like line of lt_delete.
  data ls_stb type lvc_s_stbl.
  call method go_alv->if_cached_prop~set_prop
    exporting
      propname           = 'GridModified'
      propvalue          = '1'
    exceptions
      prop_not_found     = 1
      invalid_name       = 2
      error_set_property = 3
      others             = 4.
  if sy-subrc <> 0.
*       Implement suitable error handling here
  endif.
  call method go_alv->check_changed_data
*        IMPORTING
*          E_VALID   =
*        CHANGING
*          C_REFRESH = 'X'
    .
  "新增 修改
  sort gt_upd by werks matnr lifnr.
  loop at gt_item assigning field-symbol(<fs_item>).
    if <fs_item>-add is initial.  "修改操作
      read table gt_upd into data(gs_upd) with key werks = <fs_item>-werks matnr = <fs_item>-matnr lifnr = <fs_item>-lifnr binary search.
      if sy-subrc = 0 and gs_upd-zzt <> <fs_item>-zzt.
        <fs_item>-zxgr = sy-uname.
        <fs_item>-zxgrq = sy-datum.
      endif.
    endif.
    select single maktx into <fs_item>-maktx from makt where spras = '1' and matnr = <fs_item>-matnr.  "物料描述
    select single name_org1 into <fs_item>-name_org1 from but000 where partner = <fs_item>-lifnr.      "供应商描述
    move-corresponding <fs_item> to ls_add.
    append ls_add to lt_add.
    clear ls_add.
  endloop.
  "删除
  loop at gt_del into gs_del.
    if gs_del-del is not initial.
      move-corresponding gs_del to ls_delete.
      append ls_delete to lt_delete.
    endif.
    clear:ls_delete,gs_del.
  endloop.
  if lt_add[] is not initial.
    modify zsy_d_qm61_ppap from table lt_add.  "新增,更改
  endif.
  if lt_delete[] is not initial.
    delete zsy_d_qm61_ppap from table lt_delete.  "删除
  endif.
*  IF lt_update[] IS NOT INITIAL.
*    MODIFY zsy_d_qm61_ppap FROM TABLE lt_update.  "更改
*  ENDIF.
  commit work and wait.
  if sy-subrc = 0.
    message '数据已保存' type 'S'.
  else.
    message '数据未保存' type 'E'.
  endif.
  call method go_alv->refresh_table_display
    exporting
      is_stable = gs_stb.
endform.

*&---------------------------------------------------------------------*
*& Form frm_check_auth
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_check_auth .
  authority-check object 'ZQM06_WERK'
          id 'WERKS' field p_werks.
  if sy-subrc <> 0.
    message e036(zsy_qm_dev) with p_werks.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form f_fieldcat_build
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form f_fieldcat_build .
**- ALV格式设定
  gs_layout-zebra           = 'X'.    "设置Grid的行颜色变换显示
*  gs_layout-cwidth_opt      = 'X'.    "设置Grid的字段列宽度自动适应
*  gs_layout-edit            = ''.
*  gs_layout-stylefname  = 'ALV_CELLTAB'.
*  gs_layout-ctab_fname  = 'CELLCOLOR'.
  gs_layout-stylefname = 'MODIFY'.
* 主要的字段目录参数。
  clear g_pos.
  perform f_input_fieldcat using:
*----该处存放ALV需要展示的字段 STR--------
   'WERKS' '工厂' 'X' '' 'ZSY_D_QM61_PPAP' 'WERKS',
   'MATNR' '物料编码' 'X' '' 'ZSY_D_QM61_PPAP' 'MATNR',
   'MAKTX' '物料描述' 'X' '' 'MAKT' 'MAKTX',
   'LIFNR' '供应商编码' 'X' '' 'ZSY_D_QM61_PPAP' 'LIFNR',
   'NAME_ORG1' '供应商描述' 'X' '' 'BUT000' 'NAME_ORG1',
   'ZCJR' '创建人' 'X' '' 'ZSY_D_QM61_PPAP' 'ZCJR',
   'ZCJRQ' '创建日期' 'X' '' 'ZSY_D_QM61_PPAP' 'ZCJRQ',
   'ZXGR' '修改人' 'X' '' 'ZSY_D_QM61_PPAP' 'ZXGR',
   'ZXGRQ' '修改日期' 'X' '' 'ZSY_D_QM61_PPAP' 'ZXGRQ',
   'ZZT' '状态' 'X'  '' 'ZSY_D_QM61_PPAP' 'ZZT'.
*----该处存放ALV需要展示的字段 END--------
  g_edit = 'X'.
endform.
*&---------------------------------------------------------------------*
*& Form f_input_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
form f_input_fieldcat using value(p_field)
                              value(p_name)
                              value(p_edit)
                              value(p_drdn)
                              value(p_table)
                              value(p_ref).
* 共通字段，用USING子程序传输

  g_pos = g_pos + 1.
  wa_fieldcat-col_pos = g_pos. "输出列位置
  wa_fieldcat-fieldname = p_field. "字段名称,必须大写
  wa_fieldcat-coltext = p_name. "字段标题
  wa_fieldcat-edit = p_edit . "设置单元格可编辑
  wa_fieldcat-drdn_field = p_drdn.
  wa_fieldcat-outputlen = '10'.
  wa_fieldcat-ref_table = p_table.
  wa_fieldcat-ref_field = p_ref.
*  IF  wa_fieldcat-fieldname = 'ZDYMB'.
*    wa_fieldcat-outputlen = '20'.
*  ENDIF.

  append wa_fieldcat to gt_fieldcat.
  clear wa_fieldcat.


endform. "F_INPUT_FIELDCAT
*&---------------------------------------------------------------------*
*& Form frm_sub_get_down
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_sub_get_down .
  data: l_spras type lvc_s_drop-value,
        l_count type i.
  data ls_modify type lvc_s_styl.
  loop at gt_item assigning field-symbol(<fs_item>).
    l_count += 1.
    <fs_item>-dd_handle = l_count.
*    ls_modify-fieldname = 'WERKS'.
*    ls_modify-style = cl_gui_alv_grid=>mc_style_disabled.
*    APPEND ls_modify TO <fs_item>-modify.
    <fs_item>-modify = value #( style = cl_gui_alv_grid=>mc_style_disabled
                                 (  fieldname = 'WERKS')
                                 (  fieldname = 'MATNR')
                                 (  fieldname = 'MAKTX')
                                 (  fieldname = 'LIFNR')
                                 (  fieldname = 'NAME_ORG1')
                                 (  fieldname = 'ZCJR')
                                 (  fieldname = 'ZCJRQ')
                                 (  fieldname = 'ZXGR')
                                 (  fieldname = 'ZXGRQ')
                                   ).
  endloop.
  perform frm_toolbar.
endform.
*&---------------------------------------------------------------------*
*& Form frm_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_toolbar .
  refresh g_toolbar.
  perform append_alv_exclude_functions tables g_toolbar  using:
               cl_gui_alv_grid=>mc_fc_reprep            ,
               cl_gui_alv_grid=>mc_fc_check             ,
               cl_gui_alv_grid=>mc_mb_export            ,
               cl_gui_alv_grid=>mc_fc_detail            ,
               cl_gui_alv_grid=>mc_fc_refresh           ,
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
*&---------------------------------------------------------------------*
*& Form append_alv_exclude_functions
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_TOOLBAR
*&      --> CL_GUI_ALV_GRID=>MC_FC_REPREP
*&---------------------------------------------------------------------*
form append_alv_exclude_functions tables pt_exclude type ui_functions
                                    using  p_value    type ui_func.
  append p_value to pt_exclude.
endform.                    " APPEND_ALV_EXCLUDE_FUNCTIONS
*&---------------------------------------------------------------------*
*& Form create_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form create_alv .
  create object gs_con
    exporting
      container_name = 'GC_CON'.

  create object go_alv
    exporting
      i_parent = gs_con.
endform.
*&---------------------------------------------------------------------*
*& Form frm_ooalv_dis
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_ooalv_dis .
  data selfield type slis_selfield.
  call method go_alv->register_edit_event
    exporting
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*  EXCEPTIONS
*    error      = 1
*    others     = 2
  .
  if go_event_receiver is initial.
    create object go_event_receiver.
    set handler go_event_receiver->handle_user_command  for go_alv.
    set handler go_event_receiver->handle_data_changed  for go_alv.
  endif.
  call method go_alv->set_drop_down_table
    exporting
      it_drop_down = gt_ddval.
  sort gt_item by werks matnr lifnr.
  call method go_alv->set_table_for_first_display
    exporting
      it_toolbar_excluding          = g_toolbar
      is_layout                     = gs_layout
    changing
      it_outtab                     = gt_item[]
      it_fieldcatalog               = gt_fieldcat
*     it_sort                       =
*     it_filter                     =
    exceptions
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      others                        = 4.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.
endform.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0100 output.
  set pf-status 'S001'.
* SET TITLEBAR 'xxx'.
endmodule.

module user_command_0100 input.

  case ok_code.
    when  'BACK' or 'CANCEL'.
*      CLEAR: gt_item.
      leave to screen 0.
    when 'EDIT'.
      perform frm_edit.
    when 'ADD'.
      perform frm_add.
    when 'DEL'.
      perform frm_del.
    when 'EXIT'.
      leave program.
    when 'SAVE'.
      perform frm_save.
  endcase.


endmodule.
