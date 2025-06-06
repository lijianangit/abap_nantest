*&---------------------------------------------------------------------*
*& Report ztest_bapi
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ztest_bapi2.

load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。

  parameters:p_matnr  type matnr  default '000000000000010687' .

  parameters:p_ekorg  type ekorg default ''.

  parameters:p_werks  type werks_d default 'H101' .

  parameters:lgort_d  type z_lgort  default '1001'.

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行PAI

start-of-selection. " 点击执行后的主程序代码。
  data pritem type standard table of bapimereqitemimp with header line.
  data bapimereqitemimp type bapimereqitemimp.

  select * from eban where ernam = 'KN681' order by erdat descending into table @data(tab1)   up to 25 rows.
  data(out) = cl_demo_output=>new( ).

  out->write_data( tab1 ).
  bapimereqitemimp = value bapimereqitemimp( material = '10687' ).
  append bapimereqitemimp to pritem.
  data bapimereqheader type bapimereqheader.
  data resultNo type banfn .



















  data:lv_banfn       type eban-banfn .

  data:lv_bnfpo       type eban-bnfpo .

  data:ls_pritem      type bapimereqitemimp .

  data:ls_pritemx     type bapimereqitemx .

  data:lt_pritem      type table of bapimereqitemimp .

  data:lt_pritemx     type table of bapimereqitemx .

  data:ls_head        type bapimereqheader  .

  data:ls_headx       type bapimereqheaderx.

  data:lt_bapireturn  type table of bapiret2 .

*


start-of-selection.
  ls_head-pr_type = 'NB'. " 订单类型

  ls_headx-pr_type = 'X'.
  clear lv_bnfpo.
  ls_pritem-preq_item  = lv_bnfpo.

  ls_pritem-preq_name  = sy-uname.

  ls_pritem-material   = p_matnr.

  ls_pritem-plant      = p_werks.

  ls_pritem-purch_org  = p_ekorg.

  ls_pritem-store_loc   = lgort_d.

  ls_pritem-quantity   = 10.

  ls_pritem-deliv_date = sy-datum.

  append ls_pritem to lt_pritem.

  ls_pritemx-preq_item  = lv_bnfpo.

  ls_pritemx-material   = 'X'.

  ls_pritemx-plant      = 'X'.

  ls_pritemx-quantity   = 'X'.

  ls_pritemx-deliv_date = 'X'.

  ls_pritemx-purch_org  = 'X'.

  ls_pritemx-store_loc   = 'X'.


  append ls_pritemx to lt_pritemx.

  call function 'BAPI_PR_CREATE'
    exporting
      prheader  = ls_head
      prheaderx = ls_headx
    importing
      number    = lv_banfn
    tables
      return    = lt_bapireturn
      pritem    = lt_pritem
      pritemx   = lt_pritemx."标识需要跟新的字段
  out->write_data( lt_bapireturn ).
  out->write_data( lt_pritem ).
  out->write_data( lt_pritemx ).
  out->display( ).

  IF lv_banfn is  initial .
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.

*  call function 'BAPI_PR_CREATE'
*    importing
*      number      = resultNo
*      prheaderexp = bapimereqheader
*    tables
**     return      =
*      pritem      = pritem[].
**     pritemexp              =
**     pritemsource           =
**     praccount              =
**     praccountproitsegment  =
**     praccountx             =
**     praddrdelivery         =
**     pritemtext             =
**     prheadertext           =
**     extensionin            =
**     extensionout           =
**     prversion              =
**     prversionx             =
**     allversions            =
**     prcomponents           =
**     prcomponentsx          =
**     serviceoutline         =
**     serviceoutlinex        =
**     servicelines           =
**     servicelinesx          =
**     servicelimit           =
**     servicelimitx          =
**     servicecontractlimits  =
**     servicecontractlimitsx =
**     serviceaccount         =
**     serviceaccountx        =
**     servicelongtexts       =
**     serialnumber           =
**     serialnumberx          =
*  write / sy-subrc.
*
*
*  if resultNo is not initial.
*
*    call function 'BAPI_TRANSACTION_COMMIT'
*      exporting
*        wait = 'X'.
*
*    write resultNo.
*
*  else.
*
*    call function 'BAPI_TRANSACTION_ROLLBACK'.
*
*  endif.

end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。
