report z_alv_row_editable.
*&---------------------------------------------------------------------*
*& 程 序 名：YTEST_DEMO1
*& 程序描述：ALV单元格可编辑
*& 创 建 者：你们的小涵
*& 创建日期：2023/03/10
*&---------------------------------------------------------------------*
*& 版本     修改者(公司)     日期         修改描述
*& 1.0.0    XXXX           YYYYMMDD      创建程序
*&---------------------------------------------------------------------*


" 选择屏幕用
types: begin of typ_s_screen,
         ebeln type ekko-ebeln, " 采购凭证编号
         bukrs type ekko-bukrs, " 公司代码
         werks type ekpo-werks, " 工厂
         ernam type ekko-ernam, " 对象创建人姓名
       end of typ_s_screen.
" ALV显示用
types: begin of ty_out,
         c           type char01,     "（单元格编辑前提需要有可编辑的！！）
         sel         type sel,
         ebeln       type ekko-ebeln, " 采购凭证编号
         bukrs       type ekko-bukrs, " 公司代码
         ekorg       type ekko-ekorg, " 采购组织
         ekgrp       type ekko-ekgrp, " 采购组
         kunnr       type ekko-kunnr, " 客户编号
         ebelp       type ekpo-ebelp, " 凭证项目编号
         matnr       type ekpo-matnr, " 物料编号
         werks       type ekpo-werks, " 工厂
         lgort       type ekpo-lgort, " 库存地点
         matkl       type ekpo-matkl, " 物料组
         menge       type ekpo-menge, " 采购订单数量
         meins       type ekpo-meins, " 采购订单计量单位
*   单元格可编辑
         field_style type lvc_t_styl, " 控制字段可编辑的参数
       end of ty_out.
" 表类型



types tt_out type standard table of ty_out.


data gt_alv      type tt_out.
data gv_screen   type typ_s_screen.

data gs_layout   type lvc_s_layo."alv布局配置
data gt_fieldcat type lvc_t_fcat."列标准配置

selection-screen begin of block b01 with frame title text-001.
  select-options:
    s_ebeln for gv_screen-ebeln,
    s_bukrs for gv_screen-bukrs.
  parameters p_werks type werks_d obligatory default '1000'.
selection-screen end of block b01.

initialization.
  clear:
  gt_alv,
  gt_fieldcat."列配置

*&---------------------------------------------------------------------*
*               START-OF-SELECTION 执行主逻辑
*&---------------------------------------------------------------------*
start-of-selection.

  "数据取得
  select
    ekko~ebeln,
    ekko~bukrs,
    ekko~ekorg,
    ekko~ekgrp,
    ekko~kunnr,
    ekpo~ebelp,
    ekpo~matnr,
    ekpo~werks,
    ekpo~lgort,
    ekpo~matkl,
    ekpo~menge,
    ekpo~meins
    from ekko
    inner join ekpo on ekko~ebeln = ekpo~ebeln
    where ekpo~werks = @p_werks
      and ekko~ebeln in @s_ebeln
      and ekko~bukrs in @s_bukrs
    into corresponding fields of table @gt_alv
    up to 20 rows.

  data: stylelin type lvc_s_styl.
  loop at gt_alv assigning field-symbol(<fs1>).

    if <fs1>-field_style is initial.
      clear stylelin.
      if <fs1>-menge > 1.
        stylelin-fieldname = 'MENGE'." 需要编辑的列名
*        STYLELIN-STYLE = cl_gui_alv_grid=>mc_style_disabled. " 设置为可编辑状态
        stylelin-style = cl_gui_alv_grid=>mc_style_enabled.   " 设置为不可编辑状态
        append stylelin to <fs1>-field_style.
        clear  stylelin.
      endif.
      "注释解开即可Dump
*      CLEAR stylelin.
*      IF <fs1>-menge > 1.
*        stylelin-fieldname = 'BUKRS'." 需要编辑的列名
**        STYLELIN-STYLE = cl_gui_alv_grid=>mc_style_disabled. " 设置为可编辑状态
*        stylelin-style = cl_gui_alv_grid=>mc_style_enabled.   " 设置为不可编辑状态
*        APPEND stylelin TO <fs1>-field_style.
*        CLEAR  stylelin.
*      ENDIF.
    endif.
  endloop.

  "Layout
  gs_layout-cwidth_opt      = 'X'.  "优化行宽度
  gs_layout-zebra           = 'X'.  "斑马纹!
  gs_layout-box_fname       = 'SEL'. "选择列
*  gs_layout-edit            = 'X'.  "ALV全部可编辑
  "单元格可编辑
  gs_layout-stylefname      = 'FIELD_STYLE'.

  "Fieldcat
  data: ls_fieldcat type lvc_s_fcat.
  define hong.
    ls_fieldcat-fieldname = &1."字段名
    ls_fieldcat-scrtext_l = &2."文本描述
    ls_fieldcat-edit      = &3."可编辑-------->ALV列全部可编辑
    ls_fieldcat-no_out    = &4."不显示列
    append ls_fieldcat to gt_fieldcat.
    clear ls_fieldcat.
  end-of-definition.

  hong 'C' 'C' 'X' 'X'."必须有一列可编辑
  hong 'EBELN' '采购凭证编号' '' ''.
  hong 'BUKRS' '公司代码' '' ''.
  hong 'EKORG' '采购组织' '' ''.
  hong 'EKGRP' '采购组' '' ''.
  hong 'KUNNR' '客户编号' '' ''.
  hong 'EBELP' '凭证项目编号' '' ''.
  hong 'MATNR' '物料编号' '' ''.
  hong 'WERKS' '工厂' '' ''.
  hong 'LGORT' '库存地点' '' ''.
  hong 'MATKL' '物料组' '' ''.
  hong 'MENGE' '采购订单数量' '' ''.
  hong 'MEINS' '采购订单计量单位' '' ''.

  call function 'REUSE_ALV_GRID_DISPLAY_LVC'
    exporting
      i_callback_program = sy-repid
*     i_callback_pf_status_set = 'F_STATUS_SET '
*     i_callback_user_command  = 'F_USER_COMMAND '
*     i_grid_title       = ''
      is_layout_lvc      = gs_layout
      it_fieldcat_lvc    = gt_fieldcat
      i_save             = 'A'
    tables
      t_outtab           = gt_alv
    exceptions
      program_error      = 1
      others             = 2.
  if sy-subrc <> 0.
*   系统返回消息
    message id sy-msgid
          type sy-msgty
        number sy-msgno
          with sy-msgv1
               sy-msgv2
               sy-msgv3
               sy-msgv4.
  endif.
