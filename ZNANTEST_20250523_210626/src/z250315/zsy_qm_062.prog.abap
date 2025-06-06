*&**********************************************************************
*&  Report 程序名  ZSY_QM_061
*&**********************************************************************
*&
*& 作者:
*& 完成日期: ***
*& 描述:
*&**********************************************************************
*& 版本号 日期    作者    修改描述
*&**********************************************************************
*&
*&**********************************************************************
REPORT zsy_qm_062.
*&---------------------------------------------------------------------*
*& define include
*&---------------------------------------------------------------------*
*INCLUDE zsy_qm_061_top.
*INCLUDE zsy_qm_061_f01.
TABLES:zsy_d_qm61_ppap.
TYPE-POOLS:slis.
DATA:BEGIN OF gt_item OCCURS 0,
       werks     TYPE zsy_d_qm61_ppap-werks value '0018',    "工厂
       matnr     TYPE zsy_d_qm61_ppap-matnr,    "物料编号
       maktx     TYPE makt-maktx,             "物料描述
       lifnr     TYPE zsy_d_qm61_ppap-lifnr,    "供应商或债权人的帐号
       name_org1 TYPE but000-name_org1,    "供应商描述
       zcjr      TYPE zsy_d_qm61_ppap-zcjr,    "创建人
       zcjrq     TYPE zsy_d_qm61_ppap-zcjrq,    "创建日期
       zxgr      TYPE zsy_d_qm61_ppap-zxgr,    "修改人
       zxgrq     TYPE zsy_d_qm61_ppap-zxgrq,    "修改日期
       zzt       TYPE zsy_d_qm61_ppap-zzt,    "状态
       dd_handle TYPE char10,
       modify    TYPE lvc_t_styl,
       newid     TYPE i,
       del       TYPE char1,
       update    TYPE char1,
       add       TYPE char1,
     END OF gt_item.
DATA:gs_item LIKE LINE OF gt_item.
DATA:gt_upd LIKE TABLE OF gt_item.
DATA:gt_del LIKE TABLE OF gt_item.
DATA:gs_del LIKE LINE OF gt_del.
DATA: gv_newid   TYPE i.
DATA: ok_code LIKE sy-ucomm.
DATA lt_drop_down TYPE lvc_t_drop.
DATA ls_drop_down TYPE lvc_s_drop.
DATA:
  gt_ddval TYPE lvc_t_drop,
  gw_ddval TYPE lvc_s_drop.
DATA gs_stb TYPE lvc_s_stbl.
DATA:
  wa_fieldcat TYPE lvc_s_fcat, "用于定义ALV列字段相关类型数据,结构
  gs_layout   TYPE lvc_s_layo,
  go_alv      TYPE REF TO cl_gui_alv_grid,
  gt_fieldcat TYPE lvc_t_fcat,
  g_toolbar   TYPE ui_functions,
  gs_con      TYPE REF TO cl_gui_custom_container.
DATA: gt_events TYPE slis_t_event,
      gw_events TYPE slis_alv_event.
CONSTANTS c_status_form TYPE slis_formname VALUE 'PF_STATUS_SET'. "字符型，功能常量
CONSTANTS c_command_form TYPE slis_formname VALUE 'USER_COMMAND'. "字符型，功能常量
DATA: grid TYPE REF TO cl_gui_alv_grid.
DATA: g_pos TYPE i."用于alv字段目录最后顺序
DATA  g_edit TYPE char1.  "编辑状态flag.
gs_stb-row = 'X'." 基于行的稳定刷新
gs_stb-col = 'X'." 基于列稳定刷新
CLASS gcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_user_command   FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm,

*      handle_data_changed   FOR EVENT data_changed_finished  OF cl_gui_alv_grid
*       IMPORTING
*          er_good_cells,
      handle_data_changed   FOR EVENT data_changed  OF cl_gui_alv_grid
        IMPORTING
          er_data_changed,

      handle_hotspot_click  FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING
          e_row_id
          e_column_id
          es_row_no.

ENDCLASS.

CLASS gcl_event_handler IMPLEMENTATION.
  METHOD handle_hotspot_click.
*    PERFORM frm_hotspot_click.

  ENDMETHOD.

  METHOD handle_user_command.


    CASE e_ucomm.
      WHEN 'EDIT'.
        PERFORM frm_edit.
      WHEN 'ADD'.
        PERFORM frm_add.
      WHEN 'DEL'.
        PERFORM frm_del.
      WHEN 'SAVE'.
        PERFORM frm_save.
    ENDCASE.

  ENDMETHOD.                    "handle_user_command


  METHOD handle_data_changed.

    PERFORM frm_data_changed
      USING
        er_data_changed->mt_mod_cells.

*    PERFORM frm_data_changed
*      USING
*        et_good_cells.


  ENDMETHOD.


ENDCLASS.

DATA:
  go_event_receiver TYPE REF TO gcl_event_handler.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_werks LIKE zsy_d_qm61_ppap-werks  default '0018' OBLIGATORY .  "工厂

  SELECT-OPTIONS: s_matnr FOR zsy_d_qm61_ppap-matnr,     "物料
                  s_lifnr FOR zsy_d_qm61_ppap-lifnr,     "供应商
                  s_zzt FOR zsy_d_qm61_ppap-zzt.         "状态
SELECTION-SCREEN END OF BLOCK b1.
*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
*INITIALIZATION.
*  PERFORM frm_check_auth.  "权限检查

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.


*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_xxxx.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  "获取数据
  PERFORM frm_get_data.
*    PERFORM frm_prc_data.
* ALV 设定
  PERFORM f_fieldcat_build. "第二步设置字段目录，即报表表头的显示部分
  PERFORM frm_sub_get_down.
  PERFORM create_alv.
  PERFORM frm_ooalv_dis.

  CALL  SCREEN 0100.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*    PERFORM frm_display.

*&---------------------------------------------------------------------*
*& Form frm_get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_data .
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_item FROM zsy_d_qm61_ppap
       WHERE werks = p_werks AND matnr IN s_matnr AND lifnr IN s_lifnr AND zzt IN s_zzt.
  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
    SELECT SINGLE maktx INTO <fs_item>-maktx FROM makt WHERE spras = '1' AND matnr = <fs_item>-matnr.  "物料描述
    SELECT SINGLE name_org1 INTO <fs_item>-name_org1 FROM but000 WHERE partner = <fs_item>-lifnr.      "供应商描述
  ENDLOOP.
  gt_upd[] = gt_item[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED_>MT_MOD_CELLS
*&---------------------------------------------------------------------*
FORM frm_data_changed  USING pt_mod_cells TYPE lvc_t_modi.


    " 复制的时候会有多个，重复重复提高效率
    DELETE ADJACENT DUPLICATES FROM pt_mod_cells COMPARING ROW_ID.

    LOOP AT pt_mod_cells into DATA(LS_cells) .

      READ TABLE gt_item into DATA(ls_item) index LS_cells-ROW_ID.
      IF sy-subrc = 0.
          ls_item-update = abap_true.
          MODIFY gt_item from ls_item index LS_cells-ROW_ID TRANSPORTING update.
      ENDIF.


    ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_edit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_edit .  "修改
  IF g_edit = 'X'.
    REFRESH gt_fieldcat.
    PERFORM f_input_fieldcat USING:
*----该处存放ALV需要展示的字段 STR--------
      'WERKS' '工厂' 'X' '' '' '',
      'MATNR' '物料编码' 'X' '' '' '',
      'MAKTX' '物料描述' 'X' '' '' '',
      'LIFNR' '供应商编码' 'X' '' '' '',
      'NAME_ORG1' '供应商描述' 'X' '' '' '',
      'ZCJR' '创建人' 'X' '' '' '',
      'ZCJRQ' '创建日期' 'X' '' '' '',
      'ZXGR' '修改人' 'X' '' '' '',
      'ZXGRQ' '修改日期' 'X' '' '' '',
      'ZXGR' '修改人' 'X'  '' '' '',
      'ZZT' '状态' 'X'  '' '' ''.
    CALL METHOD go_alv->set_frontend_fieldcatalog
      EXPORTING
        it_fieldcatalog = gt_fieldcat.

    CALL METHOD go_alv->refresh_table_display.

    g_edit = ''.
  ELSE.
    REFRESH gt_fieldcat.
  PERFORM f_input_fieldcat USING:
*----该处存放ALV需要展示的字段 STR--------
   'WERKS' '工厂' 'X' '' 'ZSY_D_QM61_PPAP' 'WERKS',
   'MATNR' '物料编码' 'X' '' 'ZSY_D_QM61_PPAP' 'MATNR',
   'MAKTX' '物料描述' 'X' '' 'MAKT' 'MAKTX',
   'LIFNR' '供应商编码' 'X' '' 'ZSY_D_QM61_PPAP' 'LIFNR',
   'NAME_ORG1' '供应商描述' '' '' 'BUT000' 'NAME_ORG1',
   'ZCJR' '创建人' 'X' '' 'ZSY_D_QM61_PPAP' 'ZCJR',
   'ZCJRQ' '创建日期' 'X' '' 'ZSY_D_QM61_PPAP' 'ZCJRQ',
   'ZXGR' '修改人' 'X' '' 'ZSY_D_QM61_PPAP' 'ZXGR',
   'ZXGRQ' '修改日期' 'X' '' 'ZSY_D_QM61_PPAP' 'ZXGRQ',
   'ZZT' '状态' 'X'  '' 'ZSY_D_QM61_PPAP' 'ZZT'.

    CALL METHOD go_alv->set_frontend_fieldcatalog
      EXPORTING
        it_fieldcatalog = gt_fieldcat.

    CALL METHOD go_alv->refresh_table_display.
    g_edit = 'X'.
  ENDIF.
  CALL METHOD go_alv->refresh_table_display
    EXPORTING
      is_stable = gs_stb.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_add
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_add .  "新增
  CLEAR gs_item.
  gv_newid = gv_newid + 1.
  gs_item-newid = gv_newid.
  gs_item-zcjr = sy-uname.
  gs_item-zcjrq = sy-datum.
  gs_item-werks = p_werks.
  gs_item-add = 'X'.
  APPEND gs_item TO gt_item.
  REFRESH gt_fieldcat.
  PERFORM f_input_fieldcat USING:
*----该处存放ALV需要展示的字段 STR--------
   'WERKS' '工厂' 'X' '' 'ZSY_D_QM61_PPAP' 'WERKS',
   'MATNR' '物料编码' 'X' '' 'ZSY_D_QM61_PPAP' 'MATNR',
   'MAKTX' '物料描述' 'X' '' 'MAKT' 'MAKTX',
   'LIFNR' '供应商编码' 'X' '' 'ZSY_D_QM61_PPAP' 'LIFNR',
   'NAME_ORG1' '供应商描述' '' '' 'BUT000' 'NAME_ORG1',
   'ZCJR' '创建人' 'X' '' 'ZSY_D_QM61_PPAP' 'ZCJR',
   'ZCJRQ' '创建日期' 'X' '' 'ZSY_D_QM61_PPAP' 'ZCJRQ',
   'ZXGR' '修改人' 'X' '' 'ZSY_D_QM61_PPAP' 'ZXGR',
   'ZXGRQ' '修改日期' 'X' '' 'ZSY_D_QM61_PPAP' 'ZXGRQ',
   'ZZT' '状态' 'X'  '' 'ZSY_D_QM61_PPAP' 'ZZT'.
  CALL METHOD go_alv->set_frontend_fieldcatalog
    EXPORTING
      it_fieldcatalog = gt_fieldcat.
  CALL METHOD go_alv->refresh_table_display
    EXPORTING
      is_stable = gs_stb.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_del
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_del .  "删除
  DATA lt_select TYPE lvc_t_row.
*  DATA ls_del LIKE LINE OF gt_del.

  CALL METHOD go_alv->get_selected_rows
    IMPORTING
      et_index_rows = lt_select.

  LOOP AT lt_select INTO DATA(ls_select).
    READ TABLE gt_item INTO gs_item INDEX ls_select-index.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING gs_item TO gs_del.
      gs_del-del = 'X'.
      APPEND gs_del TO gt_del.
      CLEAR gs_del.
    ENDIF.
    DELETE gt_item INDEX ls_select-index.
  ENDLOOP.
  CALL METHOD go_alv->refresh_table_display
    EXPORTING
      is_stable = gs_stb.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_save .
  DATA:lt_add LIKE TABLE OF zsy_d_qm61_ppap,
       ls_add LIKE LINE OF lt_add.
  DATA:lt_update LIKE TABLE OF zsy_d_qm61_ppap,
       ls_update LIKE LINE OF lt_update.
  DATA:lt_delete LIKE TABLE OF zsy_d_qm61_ppap,
       ls_delete LIKE LINE OF lt_delete.
  DATA ls_stb TYPE lvc_s_stbl.
  CALL METHOD go_alv->if_cached_prop~set_prop
    EXPORTING
      propname           = 'GridModified'
      propvalue          = '1'
    EXCEPTIONS
      prop_not_found     = 1
      invalid_name       = 2
      error_set_property = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
*       Implement suitable error handling here
  ENDIF.
  CALL METHOD go_alv->check_changed_data
*        IMPORTING
*          E_VALID   =
*        CHANGING
*          C_REFRESH = 'X'
    .
  "新增 修改
  SORT gt_upd BY werks matnr lifnr.
  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
    IF <fs_item>-add IS INITIAL.  "修改操作
      READ TABLE gt_upd INTO DATA(gs_upd) WITH KEY werks = <fs_item>-werks matnr = <fs_item>-matnr lifnr = <fs_item>-lifnr BINARY SEARCH.
      IF sy-subrc = 0 AND gs_upd-zzt <> <fs_item>-zzt.
        <fs_item>-zxgr = sy-uname.
        <fs_item>-zxgrq = sy-datum.
      ENDIF.
    ENDIF.
    SELECT SINGLE maktx INTO <fs_item>-maktx FROM makt WHERE spras = '1' AND matnr = <fs_item>-matnr.  "物料描述
    SELECT SINGLE name_org1 INTO <fs_item>-name_org1 FROM but000 WHERE partner = <fs_item>-lifnr.      "供应商描述
    MOVE-CORRESPONDING <fs_item> TO ls_add.
    APPEND ls_add TO lt_add.
    CLEAR ls_add.
  ENDLOOP.
  "删除
  LOOP AT gt_del INTO gs_del.
    IF gs_del-del IS NOT INITIAL.
      MOVE-CORRESPONDING gs_del TO ls_delete.
      APPEND ls_delete TO lt_delete.
    ENDIF.
    CLEAR:ls_delete,gs_del.
  ENDLOOP.
  IF lt_add[] IS NOT INITIAL.
    MODIFY zsy_d_qm61_ppap FROM TABLE lt_add.  "新增,更改
  ENDIF.
  IF lt_delete[] IS NOT INITIAL.
    DELETE zsy_d_qm61_ppap FROM TABLE lt_delete.  "删除
  ENDIF.
*  IF lt_update[] IS NOT INITIAL.
*    MODIFY zsy_d_qm61_ppap FROM TABLE lt_update.  "更改
*  ENDIF.
  COMMIT WORK AND WAIT.
  IF sy-subrc = 0.
    MESSAGE '数据已保存' TYPE 'S'.
  ELSE.
    MESSAGE '数据未保存' TYPE 'E'.
  ENDIF.
  CALL METHOD go_alv->refresh_table_display
    EXPORTING
      is_stable = gs_stb.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_check_auth
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_check_auth .
*  AUTHORITY-CHECK OBJECT 'ZQM06_WERK'
*          ID 'WERKS' FIELD p_werks.
*  IF sy-subrc <> 0.
*    MESSAGE e036(zsy_qm_dev) WITH p_werks.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_fieldcat_build
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_fieldcat_build .
**- ALV格式设定
  gs_layout-zebra    = 'X'.    "设置Grid的行颜色变换显示
  gs_layout-sel_mode = 'D'.    "设置Grid的行颜色变换显示
 " gs_layout-BOX_FNAME = 'ZZT'.    "设置Grid的行颜色变换显示
  gs_layout-cwidth_opt      = 'X'.    "设置Grid的字段列宽度自动适应
*  gs_layout-edit            = ''.
*  gs_layout-stylefname  = 'ALV_CELLTAB'.
*  gs_layout-ctab_fname  = 'CELLCOLOR'.
  gs_layout-stylefname = 'MODIFY'.
* 主要的字段目录参数。
  CLEAR g_pos.
  PERFORM f_input_fieldcat USING:
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
ENDFORM.
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
FORM f_input_fieldcat USING VALUE(p_field)
                              VALUE(p_name)
                              VALUE(p_edit)
                              VALUE(p_drdn)
                              VALUE(p_table)
                              VALUE(p_ref).
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
*  IF  wa_fieldcat-fieldname = 'ZZT'.
*    wa_fieldcat-checkbox     = 'X'.
*  ENDIF.

  APPEND wa_fieldcat TO gt_fieldcat.
  CLEAR wa_fieldcat.


ENDFORM. "F_INPUT_FIELDCAT
*&---------------------------------------------------------------------*
*& Form frm_sub_get_down
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_sub_get_down .
  DATA: l_spras TYPE lvc_s_drop-value,
        l_count TYPE i.
  DATA ls_modify TYPE lvc_s_styl.
  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
    l_count += 1.
    <fs_item>-dd_handle = l_count.
*    ls_modify-fieldname = 'WERKS'.
*    ls_modify-style = cl_gui_alv_grid=>mc_style_disabled.
*    APPEND ls_modify TO <fs_item>-modify.
    <fs_item>-modify = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled
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
  ENDLOOP.
  PERFORM frm_toolbar.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_toolbar .
  REFRESH g_toolbar.
  PERFORM append_alv_exclude_functions TABLES g_toolbar  USING:
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
ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_alv_exclude_functions
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_TOOLBAR
*&      --> CL_GUI_ALV_GRID=>MC_FC_REPREP
*&---------------------------------------------------------------------*
FORM append_alv_exclude_functions TABLES pt_exclude TYPE ui_functions
                                    USING  p_value    TYPE ui_func.
  APPEND p_value TO pt_exclude.
ENDFORM.                    " APPEND_ALV_EXCLUDE_FUNCTIONS
*&---------------------------------------------------------------------*
*& Form create_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_alv .
  CREATE OBJECT gs_con
    EXPORTING
      container_name = 'GC_CON'.

  CREATE OBJECT go_alv
    EXPORTING
      i_parent = gs_con.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_ooalv_dis
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_ooalv_dis .
  DATA selfield TYPE slis_selfield.
  CALL METHOD go_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*  EXCEPTIONS
*    error      = 1
*    others     = 2
  .
  IF go_event_receiver IS INITIAL.
    CREATE OBJECT go_event_receiver.
    SET HANDLER go_event_receiver->handle_user_command  FOR go_alv.
    SET HANDLER go_event_receiver->handle_data_changed  FOR go_alv.
  ENDIF.
  CALL METHOD go_alv->set_drop_down_table
    EXPORTING
      it_drop_down = gt_ddval.
  SORT gt_item BY werks matnr lifnr.
  CALL METHOD go_alv->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding          = g_toolbar
      is_layout                     = gs_layout
    CHANGING
      it_outtab                     = gt_item[]
      it_fieldcatalog               = gt_fieldcat
*     it_sort                       =
*     it_filter                     =
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S001'.
* SET TITLEBAR 'xxx'.
ENDMODULE.

MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN  'BACK' OR 'CANCEL'.
*      CLEAR: gt_item.
      LEAVE TO SCREEN 0.
    WHEN 'EDIT'.
      PERFORM frm_edit.
    WHEN 'ADD'.
      PERFORM frm_add.
    WHEN 'DEL'.
      PERFORM frm_del.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'SAVE'.
      PERFORM frm_save.
  ENDCASE.


ENDMODULE.
