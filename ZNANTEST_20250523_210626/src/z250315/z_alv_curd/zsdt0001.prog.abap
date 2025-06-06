*&---------------------------------------------------------------------*
*& Report zsdt0001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zsdt0001.

INCLUDE zsdt0001_top.
INCLUDE zsdt0001_form.
INCLUDE zsdt0001_pai.
INCLUDE zsdt0001_pbo.

INITIALIZATION.
  "  PERFORM frm_check_authority . "权限检查


START-OF-SELECTION.

  PERFORM frm_get_data. "获取数据

END-OF-SELECTION.

  SET PF-STATUS '0100'. "设置gui状态

  IF gt_year IS NOT INITIAL OR gt_prod IS NOT INITIAL OR gt_prom IS NOT INITIAL.
     CALL SCREEN 0100 . "显示数据
  ELSE.
    MESSAGE s000 DISPLAY LIKE 'E'.
  ENDIF.
