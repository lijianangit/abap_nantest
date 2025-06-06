*&---------------------------------------------------------------------*
*& Include zsdt0001_top
*&---------------------------------------------------------------------*
DATA: gt_year TYPE TABLE OF ztsd004, "年度
      gt_prom TYPE TABLE OF ztsd005, "促销
      gt_prod TYPE TABLE OF ztsd006, "产品
      gs_year TYPE ztsd004,
      gs_prom TYPE ztsd005,
      gs_prod TYPE ztsd006.

*OOALV
DATA: gs_layout   TYPE lvc_s_layo,
      gt_fieldcat TYPE lvc_t_fcat,
      gs_fieldcat TYPE lvc_s_fcat.
DATA  gs_stable TYPE lvc_s_stbl. "固定
DATA STYLELIN TYPE LVC_S_STYL.
DATA gs_alv TYPE REF TO cl_gui_alv_grid .
DATA gs_parent TYPE REF TO cl_gui_custom_container.
DATA ok_code TYPE sy-ucomm .
DATA g_toolbar   TYPE ui_functions.

"宏定义
DEFINE m_fcat.
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = &1. "字段id
  gs_fieldcat-scrtext_l = &2. "字段描述
  gs_fieldcat-checkbox = &3 . "是否复选框
  " gs_fieldcat-edit  = &4. "是否可编辑

*搜索帮助
*这里的搜索帮助是需要先在se11中定义好后才能在这里使用
  IF onl1 = 'X'.
    gs_fieldcat-ref_table = 'ZTSD004'.  "透明表
    gs_fieldcat-txt_field = 'MVGR1'.    "字段
  ELSEIF onl2 = 'X'.
    gs_fieldcat-ref_table = 'ZTSD005'.
    gs_fieldcat-txt_field = 'KDGRP'.
    gs_fieldcat-txt_field = 'MVGR1'.
    gs_fieldcat-txt_field = 'KONDA'.
  ELSEIF onl3 = 'X'.
    gs_fieldcat-ref_table = 'ZTSD006'.
    gs_fieldcat-txt_field = 'KONDA'.
    gs_fieldcat-txt_field = 'KDGRP'.
  ENDIF.
  APPEND gs_fieldcat TO gt_fieldcat .
END-OF-DEFINITION.

*选择屏幕
SELECTION-SCREEN BEGIN OF BLOCK bo2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : onl1 RADIOBUTTON GROUP rept , "年度
               onl2 RADIOBUTTON GROUP rept,  "促销
               onl3 RADIOBUTTON GROUP rept.  "产品
SELECTION-SCREEN END OF BLOCK bo2.
