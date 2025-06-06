*&---------------------------------------------------------------------*
*& Include zsdt0001_pai
*&---------------------------------------------------------------------*

MODULE exit INPUT.
  LEAVE PROGRAM .
ENDMODULE.
"按钮功能
MODULE user_command_0100 INPUT.
  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0 .
    WHEN 'EXIT' OR  'CANCEL'.
      LEAVE PROGRAM .
    WHEN '&SAVE'.
      PERFORM frm_save_data. "保存数据
    WHEN '&DELE'.
      PERFORM frm_delete_data. "删除数据
*    WHEN '&DAM'.
*      PERFORM frm_disp_edit.  " 显示<->修改
  ENDCASE.
ENDMODULE.
