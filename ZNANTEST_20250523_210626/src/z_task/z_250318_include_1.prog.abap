*&---------------------------------------------------------------------*
*& Include z_250318_include_1
*&---------------------------------------------------------------------*


data text1 type string value 001.
text1 = text-002.
  data: begin of gt_item occurs 0,
          werks      type z250318-werks,      " 工厂
          lgort      type z250318-lgort,      " 库存地点
          lgobe      type z250318-lgobe,      " 仓储地点的描述
          priority   type num2 ,   " 优先级
          creator    type z250318-creator,    " 创建人
          createdate type z250318-createdate, " 状态
          updateuser type z250318-updateuser, " 创建人
          updatedate type z250318-updatedate, " 状态
          desc1      type str35,
          dd_handle  type char10,
          modify     type lvc_t_styl,
          newid      type i,
          del        type char1,
          update     type char1,
          add        type char1,
        end of gt_item.

  data gs_item      like line of gt_item.
  data gt_upd       like table of gt_item.
  data gt_del       like table of gt_item.
  data gs_del       like line of gt_del.
  data gv_newid     type i.
  data ok_code      like sy-ucomm.
  data lt_drop_down type lvc_t_drop.
  data ls_drop_down type lvc_s_drop.
  data gt_ddval     type lvc_t_drop.
  data gw_ddval     type lvc_s_drop.
  data gs_stb       type lvc_s_stbl.
  data wa_fieldcat type lvc_s_fcat. " 用于定义ALV列字段相关类型数据,结构
  data gs_layout    type lvc_s_layo.
  data go_alv       type ref to cl_gui_alv_grid.
  data gt_fieldcat  type lvc_t_fcat.
  data g_toolbar    type ui_functions.
  data gs_con       type ref to cl_gui_custom_container.
  data gt_events    type slis_t_event.
  data gw_events    type slis_alv_event.
  constants c_status_form type slis_formname value 'PF_STATUS_SET'. " 字符型，功能常量
  constants c_command_form type slis_formname value 'USER_COMMAND'.  " 字符型，功能常量
  data grid   type ref to cl_gui_alv_grid.
  data g_pos type i.                      " 用于alv字段目录最后顺序
  data g_edit type char1.                  " 编辑状态flag.

  gs_stb-row = 'X'. " 基于行的稳定刷新
  gs_stb-col = 'X'. " 基于列稳定刷新
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

data:go_event_receiver type ref to gcl_event_handler.



form get_data using P_werks.

  select * from z250318 into corresponding fields of table @gt_item
   where  werks in @P_werks.
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


*    " 复制的时候会有多个，重复重复提高效率
*    DELETE ADJACENT DUPLICATES FROM pt_mod_cells COMPARING ROW_ID.
*
*    LOOP AT pt_mod_cells into DATA(LS_cells) .
*
*      READ TABLE gt_item into DATA(ls_item) index LS_cells-ROW_ID.
*      IF sy-subrc = 0.
*          ls_item-update = abap_true.
*          MODIFY gt_item from ls_item index LS_cells-ROW_ID TRANSPORTING update.
*      ENDIF.
*
*
*    ENDLOOP.



endform.
*&---------------------------------------------------------------------*
*& Form frm_edit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_edit.  " 修改
  data editable  type c1.
  " TODO: variable is assigned but never used (ABAP cleaner)
  data cellStyle type raw4.

  if g_edit = 'X'.
    editable = 'X'.
    cellStyle = cl_gui_alv_grid=>mc_style_enabled.
    g_edit = ''.
  else.
    editable = ''.
    cellStyle = cl_gui_alv_grid=>mc_style_disabled.
    g_edit = 'X'.
  endif.
  refresh gt_fieldcat.
  " ----该处存放ALV需要展示的字段 --------
  perform f_input_fieldcat
    using 'WERKS'
          '工厂'
          editable
          ''
          'T001L'
          'WERKS'.
  perform f_input_fieldcat
    using 'LGORT'
          '库存地点'
          editable
          ''
          'T001L'
          'LGORT'.
  perform f_input_fieldcat
    using 'LGOBE'
          '仓储地点的描述'
          ''
          ''
          'T001L'
          'LGOBE'.

  perform f_input_fieldcat
    using 'PRIORITY'
          '优先级'
          editable
          ''
          ''
          ''.
  " TODO: variable is assigned but never used (ABAP cleaner)
  data l_count   type i.
  data ls_modify type lvc_s_styl.
  loop at gt_item assigning field-symbol(<fs_item>).
    l_count += 1.
    <fs_item>-modify = value #( style = cellStyle
                                (  fieldname = 'WERKS' )
                                (  fieldname = 'LGORT' )
                                (  fieldname = 'PRIORITY' )
                                (  fieldname = 'CREATOR' )
                                (  fieldname = 'CREATEDATE' )
                                (  fieldname = 'UPDATEUSER' )
                                (  fieldname = 'UPDATEDATE' ) ).
  endloop.
  go_alv->set_frontend_fieldcatalog( it_fieldcatalog = gt_fieldcat ).

  go_alv->refresh_table_display( ).
  " go_alv->refresh_table_display( is_stable = gs_stb ).
endform.
*&---------------------------------------------------------------------*
*& Form frm_add
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_add.  " 新增
  clear gs_item.
  gs_item-creator    = sy-uname.
  gs_item-createdate = sy-datum.
  gs_item-werks      = p_werks-low.
  gs_item-add        = 'X'.
  append gs_item to gt_item.
  refresh gt_fieldcat.
  perform f_input_fieldcat
    using 'WERKS'
          '工厂'
          'X'
          ''
          'T001L'
          'WERKS'.
  perform f_input_fieldcat
    using 'LGORT'
          '库存地点'
          'X'
          ''
          'T001L'
          'LGORT'.
  perform f_input_fieldcat
    using 'LGOBE'
          '仓储地点的描述 '
          ''
          ''
          'T001L'
          'LGOBE'.
  perform f_input_fieldcat
    using 'PRIORITY'
          '优先级'
          'X'
          ''
          ''
          ''.


  go_alv->set_frontend_fieldcatalog( it_fieldcatalog = gt_fieldcat ).
  go_alv->refresh_table_display( is_stable = gs_stb ).
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

  go_alv->get_selected_rows( importing et_index_rows = lt_select ).

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
  go_alv->refresh_table_display( is_stable = gs_stb ).
endform.
*&---------------------------------------------------------------------*
*& Form frm_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_save.
  data lt_add    like table of z250318.
  data ls_add    like line of lt_add.
  data lt_delete like table of z250318.
  data ls_delete like line of lt_delete.

  go_alv->if_cached_prop~set_prop( exporting
                                     propname           = 'GridModified'
                                     propvalue          = '1'
                                   exceptions
                                     prop_not_found     = 1
                                     invalid_name       = 2
                                     error_set_property = 3
                                     others             = 4 ).
  if sy-subrc <> 0.
    " Implement suitable error handling here
  endif.
  go_alv->check_changed_data( ).
*        IMPORTING
*          E_VALID   =
*        CHANGING
*          C_REFRESH = 'X'
  " 新增 修改
  sort gt_upd by werks.
  loop at gt_item assigning field-symbol(<fs_item>).
    " 校验数据正确
    if <fs_item>-werks is initial or <fs_item>-lgort is initial or <fs_item>-priority is initial.
      message '请确保工厂,库存地点,优先级数据数据完备' type 'E'.
      leave list-processing. " 离开alv程序
    endif.

    if abap_true = 'true'.

    endif.

    if <fs_item>-add is initial.  " 修改操作
      " TODO: variable is assigned but never used (ABAP cleaner)
      read table gt_upd into data(gs_upd) with key werks = <fs_item>-werks
                                                   lgort = <fs_item>-lgort binary search.
    endif.
    " 添加修改人修改时间信息
    if sy-subrc = 0.
      <fs_item>-creator    = sy-uname.
      <fs_item>-createdate = sy-datum.
    endif.
    move-corresponding <fs_item> to ls_add.
    append ls_add to lt_add.
    clear ls_add.
  endloop.
  " 删除
  loop at gt_del into gs_del.
    if gs_del-del is not initial.
      move-corresponding gs_del to ls_delete.
      append ls_delete to lt_delete.
    endif.
    clear:ls_delete,
           gs_del.
  endloop.
  if lt_add[] is not initial.
    modify z250318 from table lt_add.  " 新增,更改
  endif.
  if lt_delete[] is not initial.
    delete z250318 from table lt_delete.  " 删除
  endif.
*  IF lt_update[] IS NOT INITIAL.
*    MODIFY z250318 FROM TABLE lt_update.  "更改
*  ENDIF.
  commit work and wait.
  if sy-subrc = 0.
    g_edit = ''.
    perform frm_edit.
    message '数据已保存' type 'S'.
  else.
    message '数据未保存' type 'E'.
  endif.

  go_alv->refresh_table_display( is_stable = gs_stb ).
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
*  AUTHORITY-CHECK OBJECT 'ZQM06_WERK'
*          ID 'WERKS' FIELD p_werks.
*  IF sy-subrc <> 0.
*    MESSAGE e036(zsy_qm_dev) WITH p_werks.
*  ENDIF.
endform.
*&---------------------------------------------------------------------*
*& Form f_fieldcat_build
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form f_fieldcat_build.
  " - ALV格式设定
  gs_layout-zebra      = 'X'.    " 设置Grid的行颜色变换显示
  gs_layout-sel_mode   = 'D'.    " 设置Grid的行颜色变换显示
  "  gs_layout-box_fname = 'ZZT'.    "设置Grid的行颜色变换显示
  gs_layout-cwidth_opt = 'X'.    " 设置Grid的字段列宽度自动适应
*  gs_layout-edit            = ''.
*  gs_layout-stylefname  = 'ALV_CELLTAB'.
*  gs_layout-ctab_fname  = 'CELLCOLOR'.
  gs_layout-stylefname = 'MODIFY'.
  " 主要的字段目录参数。
  clear g_pos.
  perform f_input_fieldcat
    using 'WERKS'
          '工厂'
          'X'
          ''
          't001l'
          'WERKS'.
  perform f_input_fieldcat
    using 'LGORT'
          '库存地点'
          'X'
          ''
          't001l'
          'LGORT'.
  perform f_input_fieldcat
    using 'LGOBE'
          '仓储地点的描述 '
          'X'
          ''
          't001l'
          'LGOBE'.
  perform f_input_fieldcat
    using 'PRIORITY'
          '优先级'
          'X'
          ''
          ''
          ''.

  " ----该处存放ALV需要展示的字段 END--------
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
  if  wa_fieldcat-fieldname = 'ZZT'.
    wa_fieldcat-checkbox     = 'X'.
  endif.

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
form frm_sub_get_down.
  data l_count   type i.
  data ls_modify type lvc_s_styl.

  loop at gt_item assigning field-symbol(<fs_item>).
    l_count += 1.
    <fs_item>-dd_handle = l_count.
    ls_modify-fieldname = 'WERKS'.
    ls_modify-style     = cl_gui_alv_grid=>mc_style_disabled.
    append ls_modify to <fs_item>-modify.
    <fs_item>-modify = value #( style = cl_gui_alv_grid=>mc_style_disabled
                                (  fieldname = 'WERKS' )
                                (  fieldname = 'LGORT' )
                                (  fieldname = 'LGOBE' )
                                (  fieldname = 'DESC1' )
                                (  fieldname = 'PRIORITY' )
                                (  fieldname = 'CREATOR' )
                                (  fieldname = 'CREATEDATE' )
                                (  fieldname = 'UPDATEUSER' )
                                (  fieldname = 'UPDATEDATE' ) ).
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
form frm_ooalv_dis.
  go_alv->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_modified ).
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*  EXCEPTIONS
*    error      = 1
*    others     = 2
  if go_event_receiver is initial.
    go_event_receiver = new #( ).
    set handler go_event_receiver->handle_user_command for go_alv.
    set handler go_event_receiver->handle_data_changed for go_alv.
  endif.
  go_alv->set_drop_down_table( it_drop_down = gt_ddval ).
  sort gt_item by werks.
  go_alv->set_table_for_first_display( exporting  it_toolbar_excluding          = g_toolbar
                                                  is_layout                     = gs_layout
                                       changing   it_outtab                     = gt_item[]
                                                  it_fieldcatalog               = gt_fieldcat
*  it_sort                       =
*  it_filter                     =
                                       exceptions invalid_parameter_combination = 1
                                                  program_error                 = 2
                                                  too_many_lines                = 3
                                                  others                        = 4 ).
  if sy-subrc <> 0.
    " Implement suitable error handling here
  endif.
endform.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module SET_SCREEN_STATUS output.
  if group1 = 'X'.
    set pf-status 'S001'.
    set titlebar '11111111111111'.
  elseif group1 <> 'X'.
    set pf-status 'S002'.
    set titlebar '22222222222222'.
  endif.
endmodule.

module user_command_0100 input.

  case sy-ucomm.
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
