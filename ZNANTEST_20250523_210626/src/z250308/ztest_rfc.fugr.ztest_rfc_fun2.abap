FUNCTION ZTEST_RFC_FUN2.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  EXPORTING
*"     VALUE(LV_BANFN) TYPE  EBAN-BANFN
*"----------------------------------------------------------------------


*&---------------------------------------------------------------------*
*& Report ZMM_BOTECK_019
*&---------------------------------------------------------------------*
*& 命名规则：定义变量lv 和 定义工作区ls或gw 和 定义内表lt或gt
*&---------------------------------------------------------------------*
*& 采购申请创建调用BAPI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& 定义变量和工作区和内表
*&---------------------------------------------------------------------*

  data:lv_bnfpo      type eban-bnfpo.                   "定义变量
  data:ls_pritem     type bapimereqitemimp.             "定义工作区
  data:ls_pritemx    type bapimereqitemx.               "定义工作区
  data:lt_pritem     type table of bapimereqitemimp.    "定义内表
  data:lt_pritemx    type table of bapimereqitemx.      "定义内表
  data:ls_head       type bapimereqheader.              "定义工作区
  data:ls_headx      type bapimereqheaderx.             "定义工作区
  data:lt_bapireturn type table of bapiret2.            "定义内表
  data:ls_praccount  type bapimereqaccount.             "定义工作区
  data:ls_praccountx type bapimereqaccountx.            "定义工作区
  data:lt_praccount  type table of bapimereqaccount.    "定义内表
  data:lt_praccountx type table of bapimereqaccountx.   "定义内表
*&---------------------------------------------------------------------*
*& 采购申请行项目赋值逻辑
*&------------------------------------------------------------------
  lv_bnfpo               = lv_bnfpo  + 10.              "直接给BAPI入参赋值-采购申请类型行项目号处理逻辑

*&---------------------------------------------------------------------*
*& 给BAPI参数对应工作区赋值
*&---------------------------------------------------------------------*

  ls_head-pr_type        = 'BN06'.                      "直接给BAPI入参赋值-采购申请类型
  ls_headx-pr_type       = 'X'.                         "直接给BAPI入参赋值-采购申请类型-标记
  ls_pritem-preq_item    = lv_bnfpo.                    "直接给BAPI入参赋值-采购申请类型行项目号
  ls_pritem-preq_name    = sy-uname.                    "直接给BAPI入参赋值-采购申请创建人取系统ID
  ls_pritem-trackingno   = '需求跟踪号'.                "直接给BAPI入参赋值-需求跟踪号
  ls_pritem-material     = '000000000000010687'.        "直接给BAPI入参赋值-物料号需要补全前导零，按18位补
  ls_pritem-plant        = 'H101'.                      "直接给BAPI入参赋值-工厂
  ls_pritem-quantity     = 10.                          "直接给BAPI入参赋值-采购申请数量
  ls_pritem-deliv_date   = sy-datum.                    "直接给BAPI入参赋值-采购申请交货日期取系统日期
  ls_pritem-fixed        = 'X' .                        "直接给BAPI入参赋值-采购申请固定点
  ls_pritem-pur_group    = 'BN1'.                       "直接给BAPI入参赋值-采购组
  ls_pritem-acctasscat   = 'A'.                         "直接给BAPI入参赋值-科目分配类别

  append ls_pritem to lt_pritem.                        "将工作区ls_pritem赋值给内表lt_pritem
  ls_pritemx-preq_item   = lv_bnfpo.                    "直接给BAPI入参赋值-标记
  ls_pritemx-material    = 'X'.                         "直接给BAPI入参赋值-标记
  ls_pritemx-plant       = 'X'.                         "直接给BAPI入参赋值-标记
  ls_pritemx-quantity    = 'X'.                         "直接给BAPI入参赋值-标记
  ls_pritemx-deliv_date  = 'X'.                         "直接给BAPI入参赋值-标记
  ls_pritemx-fixed       = 'X'.                         "直接给BAPI入参赋值-标记
  ls_pritemx-preq_name   = 'X'.                         "直接给BAPI入参赋值-标记
  ls_pritemx-trackingno  = 'X'.                         "直接给BAPI入参赋值-标记
  ls_pritemx-acctasscat  = 'X'.                         "直接给BAPI入参赋值-标记

  if ls_pritem-pur_group <> ''.
    ls_pritemx-pur_group = 'X'.                         "直接给BAPI入参赋值-标记
  endif.
  append ls_pritemx to lt_pritemx.                      "将工作区ls_pritemx赋值给内表lt_pritemx

  ls_praccount-preq_item    = lv_bnfpo.                 "直接给BAPI入参赋值-采购申请类型行项目号
  ls_praccount-serial_no    = '01'.                     "直接给BAPI入参赋值-科目分配的序号
  ls_praccount-costcenter   = 'CN10880001'.             "直接给BAPI入参赋值-成本中心
  ls_praccount-asset_no     = '000066200000'.           "直接给BAPI入参赋值-资产编号
  ls_praccount-orderid      = '000001090061'.           "直接给BAPI入参赋值-订单编号
  append ls_praccount to lt_praccount.                  "将工作区ls_pracccount赋值给内表lt_praccount

  ls_praccountx-preq_item   = lv_bnfpo.                 "直接给BAPI入参赋值-采购申请类型行项目号
  ls_praccountx-serial_no   = '01'.                      "直接给BAPI入参赋值-科目分配的序号
  ls_praccountx-costcenter  = ''.                       "直接给BAPI入参赋值-成本中心
  ls_praccountx-asset_no    = 'X'.                      "直接给BAPI入参赋值-资产编号
  ls_praccountx-orderid     = ''.                       "直接给BAPI入参赋值-订单编号
  append ls_praccountx to lt_praccountx.                "将工作区ls_praccountx赋值给内表lt_accountx

*&---------------------------------------------------------------------*
*& 调用BAPI
*&---------------------------------------------------------------------*

  call function 'BAPI_PR_CREATE'
    exporting                                           "BAPI入参
      prheader   = ls_head
      prheaderx  = ls_headx
    importing                                           "BAPI出参
      number     = lv_banfn
    tables                                              "表参数（入参）
      return     = lt_bapireturn
      pritem     = lt_pritem
      pritemx    = lt_pritemx
      praccount  = lt_praccount
      praccountx = lt_praccountx.
  if lv_banfn is not initial.
    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait = 'X'.
    write:'BOTECK采购申请',lv_banfn,'创建成功！'.
  else.
    call function 'BAPI_TRANSACTION_ROLLBACK'.
  endif.
endfunction.
