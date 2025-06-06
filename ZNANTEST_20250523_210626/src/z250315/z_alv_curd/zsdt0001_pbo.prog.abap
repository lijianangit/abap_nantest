*&---------------------------------------------------------------------*
*& Include zsdt0001_pbo
*&---------------------------------------------------------------------*

MODULE init_alv OUTPUT.
  IF  gs_alv IS INITIAL.
    PERFORM creat_alv.
    PERFORM frm_init_fieldcat.  " 设置输出屏幕的ALV输出字段
    PERFORM frm_init_layout.    " 设置输出屏幕的ALV显示格式
    PERFORM frm_display_alv.    " 调用ALV显示函数显示数据
  ELSE.
    PERFORM refresh_alv . "刷新屏幕
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'. "gui状态
  SET TITLEBAR '0100'.
ENDMODULE.
