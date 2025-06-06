*&---------------------------------------------------------------------*
*& Report zmmr005_copy
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zmmr005_copy.
*&---------------------------------------------------------------------*
*&
*& 程序名:   ZMMR005
*&  标题：特许商品使用费
*&-------------------------------------------------
*&  创建日期       程序员     程序类型
*&  2020-09-22    史冠林       REPORT
*& 功能说明书:  CW_FS_MM67 特许商品使用费_MM组_v1.0_2020920
*&-------------------------------------------------
*&  描述:
*&  工单批量修改
*&=================================================
*&  修改日期   版本    修改人      修改描述
*&
*&---------------------------------------------------------------------*

INCLUDE zinclude1.



START-OF-SELECTION.

  IF pa_r1 = 'X'.
    PERFORM frm_auth_check USING 'CM'.
    PERFORM frm_maintain_data.
  ELSEIF pa_r2 = 'X'.
    PERFORM frm_auth_check USING 'CM'.
    IF pa_path IS INITIAL.
      MESSAGE s000 WITH '请选择导入文件' DISPLAY LIKE 'E'.
      STOP.
    ENDIF.
    PERFORM frm_import_data.
    PERFORM frm_process_data.
    PERFORM frm_display_data.
  ELSEIF pa_r3 = 'X'.
    PERFORM frm_auth_check USING 'RD'.
    PERFORM frm_read_data.
    PERFORM frm_display_data2.
  ENDIF.
