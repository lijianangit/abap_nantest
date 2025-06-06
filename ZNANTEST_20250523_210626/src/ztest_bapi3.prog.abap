**&---------------------------------------------------------------------*
**& Report ztest_bapi3
**&---------------------------------------------------------------------*
**&
**&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**& Report ztest_bapi
**&---------------------------------------------------------------------*
**&
**&---------------------------------------------------------------------*
report ztest_bapi3.
*
*load-of-program.
*
*top-of-page."在页首输出时触发。
*
*initialization."在程序开始执行时初始化数据时触发。
*  parameters p_path type string .
*  data ebanTab type table of eban.
*at selection-screen on value-request for p_path."弹出文件选择对话框
*  perform get_path.
*
*ME_PROCESS_REQ_CUST
*at selection-screen output."在屏幕选择数据输出时触发。PBO
**在这个事件里声明的变量都是局部变量。
*
**数据选择和处理事件."
*at selection-screen."在屏幕选择执行的时候,点击执行PAI
*
*start-of-selection. " 点击执行后的主程序代码。
*  data pritem type standard table of bapimereqitemimp with header line.
*  data bapimereqitemimp type bapimereqitemimp.
*
*  select * from eban where ernam = 'KN681' order by erdat descending into table @data(tab1)   up to 25 rows.
*  data(out) = cl_demo_output=>new( ).
*
*  out->write_data( tab1 ).
*  bapimereqitemimp = value bapimereqitemimp( material = '10687' ).
*  append bapimereqitemimp to pritem.
*  data bapimereqheader type bapimereqheader.
*  data resultNo type banfn .
*
*
*
*
*data:lv_banfn       type eban-banfn .
*
*data:lv_bnfpo       type eban-bnfpo .
*
*data:ls_pritem      type bapimereqitemimp .
*
*data:ls_pritemx     type bapimereqitemx .
*
*data:lt_pritem      type table of bapimereqitemimp .
*
*data:lt_pritemx     type table of bapimereqitemx .
*
*data:ls_head        type bapimereqheader  .
*
*data:ls_headx       type bapimereqheaderx.
*
*data:lt_bapireturn  type table of bapiret2 .
*
**
*
*
*start-of-selection.
*  ls_head-pr_type = 'NB'. " 订单类型
*
*  ls_headx-pr_type = 'X'.
*  clear lv_bnfpo.
*  ls_pritem-preq_item  = lv_bnfpo.
*
*  ls_pritem-preq_name  = sy-uname.
*
*  ls_pritem-material   = p_matnr.
*
*  ls_pritem-plant      = p_werks.
*
*  ls_pritem-purch_org  = p_ekorg.
*
*  ls_pritem-store_loc   = lgort_d.
*
*  ls_pritem-quantity   = 10.
*
*  ls_pritem-deliv_date = sy-datum.
*
*  append ls_pritem to lt_pritem.
*
*  ls_pritemx-preq_item  = lv_bnfpo.
*
*  ls_pritemx-material   = 'X'.
*
*  ls_pritemx-plant      = 'X'.
*
*  ls_pritemx-quantity   = 'X'.
*
*  ls_pritemx-deliv_date = 'X'.
*
*  ls_pritemx-purch_org  = 'X'.
*
*  ls_pritemx-store_loc   = 'X'.
*
*
*  append ls_pritemx to lt_pritemx.
*
*  call function 'BAPI_PR_CREATE'
*    exporting
*      prheader  = ls_head
*      prheaderx = ls_headx
*    importing
*      number    = lv_banfn
*    tables
*      return    = lt_bapireturn
*      pritem    = lt_pritem
*      pritemx   = lt_pritemx. "标识需要跟新的字段
*  out->write_data( lt_bapireturn ).
*  out->write_data( lt_pritem ).
*  out->write_data( lt_pritemx ).
*  out->display( ).
*
*  if lv_banfn is  initial .
*    call function 'BAPI_TRANSACTION_ROLLBACK'.
*  else.
*    call function 'BAPI_TRANSACTION_COMMIT'
*      exporting
*        wait = 'X'.
*  endif.
*
*end-of-selection."选择数据结束时触发。
*
*end-of-page."在页尾输出时触发。
*
*form get_path.
*  call function 'WS_FILENAME_GET'
*    exporting
*      "     DEF_FILENAME     = ' '
*      "     DEF_PATH         = ' '
*      mask             = ',EXCEL.XLS,*.XLS,TXT,*.TXT,EXCEL.XLSX,*.XLSX.'
*      mode             = 'O'
*"     TITLE            = ' '
*    importing
*      filename         = p_path
*"     RC               =
*    exceptions
*      inv_winsys       = 1
*      no_batch         = 2
*      selection_cancel = 3
*      selection_error  = 4
*      others           = 5.
*  if sy-subrc <> 0.
*  endif.
*endform.
*form get_data .
*  data lt_raw type truxs_t_text_data .
*  data lv_path type rlgrap-filename .
*  data lt_line type c value 1.
*  lv_path = p_path .
*
*  call function 'TEXT_CONVERT_XLS_TO_SAP'
*    exporting
*      i_field_seperator    = 'X'
*      i_line_header        = lt_line "第一行不读
*      i_tab_raw_data       = lt_raw "必输参数
*      i_filename           = lv_path "路径
*    tables
*      i_tab_converted_data = ebanTab "读取EXCEL数据到内表
*    exceptions
*      conversion_failed    = 1
*      others               = 2.
*  if sy-subrc <> 0.
*  endif.
*endform.
