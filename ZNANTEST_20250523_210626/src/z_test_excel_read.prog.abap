*&---------------------------------------------------------------------*
*& Report z_test_excel_read
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_excel_read.


tables:t001,t001w.
types:begin of ty_exl,
        bukrs like t001-bukrs, "公司代码
        werks like t001w-werks, "工厂
      end of ty_exl.

data gt_exl type standard table of ty_exl with header line.

*SCREEN
parameters p_path type c length 200.

at selection-screen on value-request for p_path."弹出对话框
  perform get_path .

start-of-selection .
  perform get_data .   "取数
  perform display.

end-of-selection .

"获取文件路径
form get_path.
  call function 'WS_FILENAME_GET'
    exporting
*     DEF_FILENAME     = ' '
*     DEF_PATH         = ' '
      mask             = ',EXCEL.XLS,*.XLS,TXT,*.TXT,EXCEL.XLSX,*.XLSX.'
      mode             = 'O'
*     TITLE            = ' '
    importing
      filename         = p_path
*     RC               =
    exceptions
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      others           = 5.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.
endform.
"获取文件内容
form get_data .
  data lt_raw type truxs_t_text_data .
  data lv_path type rlgrap-filename .
  data lt_line type c value 1.
  lv_path = p_path .

  call function 'TEXT_CONVERT_XLS_TO_SAP'
    exporting
      i_field_seperator    = 'X'
      i_line_header        = lt_line "第一行不读
      i_tab_raw_data       = lt_raw "必输参数
      i_filename           = lv_path "路径
    tables
      i_tab_converted_data = gt_exl[] "读取EXCEL数据到内表
    exceptions
      conversion_failed    = 1
      others               = 2.
  if sy-subrc <> 0.
  endif.
endform.
form display .
  loop at gt_exl.
    write: / gt_exl-bukrs, gt_exl-werks.
  endloop.
endform.
