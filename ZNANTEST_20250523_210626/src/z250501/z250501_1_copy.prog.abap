

***********************************************************************
*  Report <ZMMR002>
************************************************************************
*
*  作者:            侯荣亮1212
*  完成日期:        2020/09/14
*  描述:            制单人维护
************************************************************************
*  版本号 日期       作者   修改描述 功能更改说明书
************************************************************************
*  1.    YYYY/MM/DD author  Read dataset from app. Server @001
************************************************************************
REPORT z250501_1_copy NO STANDARD PAGE HEADING LINE-SIZE 255 MESSAGE-ID zmm.

tables: zmmt0002.
DATA gs_zmmt0002 TYPE zmmt0002.
DATA gt_zmmt0002 TYPE TABLE OF zmmt0002.

*&------------------------------------------------------------------&*
*&  选择屏幕
*&------------------------------------------------------------------&*
SELECTION-SCREEN BEGIN OF BLOCK blk_0001 WITH FRAME TITLE TEXT-001.
  select-options:
  rs_werks for zmmt0002-werks,
  rs_lgpbe for zmmt0002-lgpbe,
  rs_zbr for zmmt0002-zbr,
  rs_zfhr for zmmt0002-zfhr.
SELECTION-SCREEN END OF BLOCK blk_0001.

SELECTION-SCREEN BEGIN OF BLOCK b1k_02 WITH FRAME TITLE TEXT-002.
  PARAMETERS rd_main RADIOBUTTON GROUP act USER-COMMAND dummy."维护视图
  PARAMETERS rd_view RADIOBUTTON GROUP act."数据查看
SELECTION-SCREEN END OF BLOCK b1k_02.

START-OF-SELECTION.
  CASE 'X'.
    WHEN rd_main.
      PERFORM frm_maintian.
    WHEN rd_view.
      PERFORM frm_display.
    WHEN OTHERS.
  ENDCASE.


FORM frm_maintian.
  DATA lv_action TYPE c VALUE 'S'.
  DATA lv_view_name TYPE dd02v-tabname VALUE 'ZMMVV002'.
  DATA lt_dba_sellist TYPE TABLE OF vimsellist.

  RANGES lr_mandt FOR t001-mandt.
  RANGES lr_werks FOR t001w_werks.
  RANGES lr_lgpbe FOR zmmt0002-lgpbe.
  RANGES lr_zbr FOR zmmt0002-zbr.

*集团
  lr_mandt-sign   = 'I'. "range的三个参数，sign值为I和E，I表示包含，E表示排除；
  lr_mandt-option = 'EQ'."option ：如果HIGH为空，为单值选择，有EQ,NE,GT,LE,LT等逻辑操作。如果HIGH不为空，则是区间选择，有BT,NB等操作。
  lr_mandt-low    = sy-mandt. "HIGH为高值，LOW为低值。
  APPEND lr_mandt.

  CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST' "视图需要按条件筛选，只展示想要展示的字段的数据，则调用这个函数实现。
    EXPORTING
      fieldname = 'MANDT'
    TABLES
      sellist   = lt_dba_sellist[]
      rangetab  = lr_mandt[].

*工厂
  IF Rs_werks IS NOT INITIAL.
    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
      EXPORTING
        fieldname          = 'WERKS'
        append_conjunction = 'AND'
      TABLES
        sellist            = lt_dba_sellist[]
        rangetab           = rs_werks.
  ENDIF.

*库存仓位
  IF Rs_lgpbe IS NOT INITIAL.
    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
      EXPORTING
        fieldname          = 'LGPBE'
        append_conjunction = 'AND'
      TABLES
        sellist            = lt_dba_sellist[]
        rangetab           = rs_lgpbe.
  ENDIF.

*制单人
  IF rs_zbr IS NOT INITIAL.
    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
      EXPORTING
        fieldname          = 'ZBR'
        append_conjunction = 'AND'
      TABLES
        sellist            = lt_dba_sellist[]
*       rangetab           = lr_zbr[].
        rangetab           = rs_zbr.
  ENDIF.

*制单人
  IF rs_zfhr IS NOT INITIAL.
    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
      EXPORTING
        fieldname          = 'ZFHR'
        append_conjunction = 'AND'
      TABLES
        sellist            = lt_dba_sellist[]
*       rangetab           = lr_zbr[].
        rangetab           = rs_zfhr.
  ENDIF.

*  调用视图维护器
  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = lv_action "判断执行读还是写
      view_name                    = lv_view_name
    TABLES
      dba_sellist                  = lt_dba_sellist[]
    EXCEPTIONS
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
      OTHERS                       = 15.



ENDFORM.


*&------------------------------------------------------------------&*
*&  数据查看
*&------------------------------------------------------------------&*
FORM frm_display.
  SELECT *
    INTO TABLE  gt_zmmt0002
    FROM zmmt0002
    WHERE werks IN rs_werks
    AND  lgpbe  IN rs_lgpbe
    AND  zbr    IN rs_zbr
    AND  zfhr   IN rs_zfhr.

  IF gt_zmmt0002 IS INITIAL.
    MESSAGE s001 WITH '查询表zmmt0002结果为空' DISPLAY LIKE 'E'.
  ENDIF.

  DATA: ls_fieldcat TYPE LINE OF slis_t_fieldcat_alv  .
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv  .
  DATA ls_layout TYPE  slis_layout_alv.
  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'."  ADD BY 1766808 20250106

  DEFINE setfieldcat.
    ls_fieldcat-fieldname = &1.
    ls_fieldcat-tabname = &2.
    ls_fieldcat-seltext_m = &3.
    APPEND ls_fieldcat TO lt_fieldcat[].
    CLEAR ls_fieldcat.
  END-OF-DEFINITION.


  setfieldcat 'WERKS' 'ZMMT0002' '工厂' .
  setfieldcat 'LGPBE' 'ZMMT0002' '仓管员'.
  setfieldcat 'ZBR' 'ZMMT0002' '存储'.
  setfieldcat 'ZFHR' 'ZMMT0002' '复核人'.
*  ADD BY 1766808 20250106
*  新增字段
  setfieldcat 'ZLXFS' 'ZMMT0002' '仓管员联系方式'.
  setfieldcat 'ZCCDD' 'ZMMT0002' '存储地点'.
  setfieldcat 'ZWLLJ' 'ZMMT0002' '物流路径'.
*  END ADD


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = '制单人维护'
      is_layout          = ls_layout
      it_fieldcat        = lt_fieldcat
    TABLES
      t_outtab           = gt_zmmt0002
    EXCEPTIONS
      program_error      = 1.

ENDFORM.


*&--------------------------------------------------------------------*
*&      检查选择屏幕
*&--------------------------------------------------------------------*
FORM frm_check_auth.
  DATA: lv_action TYPE char02.

  CASE 'X'.
    WHEN rd_view.
      lv_action = '03'.
    WHEN rd_main.
      lv_action = '01'.

  ENDCASE.

  LOOP AT gt_zmmt0002 INTO gs_zmmt0002.
    AUTHORITY-CHECK OBJECT 'M_MSEG_LGO'
ID 'ACTVT' FIELD lv_action
ID 'WERKS' FIELD gs_zmmt0002-werks
ID 'LGPBE' FIELD 'DUMMY'
ID 'BWART' FIELD 'DUMMY'.
    IF sy-subrc <> 0.
      MESSAGE e001 WITH rs_werks.
      STOP.
    ENDIF.
  ENDLOOP.
ENDFORM.
