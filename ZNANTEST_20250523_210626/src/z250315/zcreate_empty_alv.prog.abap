*&---------------------------------------------------------------------*
*& Report zcreate_empty_alv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zcreate_empty_alv no standard page heading.
*&---------------------------------------------------------------------*
*& Report ZALV_COM_DEMO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
tables:sscrfields.
data functxt type smp_dyntxt.
data: gt_fldct type lvc_t_fcat,
      gs_glayt type lvc_s_glay,
      gs_slayt type lvc_s_layo,
      gt_event type lvc_t_evts,
      gs_varnt type disvariant,
      gt_scol  type lvc_t_scol,
      gv_repid type sy-repid.
data: gs_f4 type lvc_s_f4,
      gt_f4 type lvc_t_f4.

data: begin of gs_out ,
        seled type c length 1,
        cscol type lvc_t_scol,
        matnr type mara-matnr,
      end of gs_out.
data: gt_out like table of gs_out.

selection-screen begin of block b1 with frame title txb01.
  select-options: s_matnr for gs_out-matnr.
selection-screen end of block b1.


*定义默认按钮 1 2 3 4 5
selection-screen function key 1.

initialization.
  perform load.

at selection-screen output.
  functxt-icon_id   = icon_export.
  functxt-quickinfo = '点击下载模板'.
  functxt-icon_text = '下载模板'.
  sscrfields-functxt_01 = functxt.
  txb01 = '筛选条件'.
  %_s_matnr_%_app_%-text = '物料'(s01).

at selection-screen.
  if sy-ucomm = 'ONLI'.
    perform input_check.
  endif.
  if sy-ucomm = 'FC01'.
  endif.

start-of-selection.
  perform getdata.
  perform outdata using gt_out.

*&---------------------------------------------------------------------*
*&      Form  input_check
*&---------------------------------------------------------------------*
form input_check.
*添加检查代码
endform.

*&---------------------------------------------------------------------*
*&  获取数据，程序执行和刷新的时候调用
*&---------------------------------------------------------------------*
form getdata.
  data:ls_styl type lvc_s_styl.
  data:ls_scol type lvc_s_scol.
  data:ls_colo type lvc_s_colo.
  clear: gt_out.



****举例***
*  "单元格颜色
*  DATA: ls_scol TYPE lvc_s_scol.
*  DATA: ls_colo TYPE lvc_s_colo.
*  CLEAR gt_scol.
*  CLEAR:ls_scol.
*  ls_scol-fname = 'MATNR'.
*  CLEAR:ls_colo.
*  "501 绿底 ； 610 红底； 310 黄底；710 橙底
*  ls_colo-col = '6'.  "alv 控制: 颜色
*  ls_colo-int = '0'. "alv 控制: 强化
*  ls_colo-inv = '1'.  "alv 控制: 相反
*  ls_scol-color = ls_colo.
*  ls_scol-nokeycol = 'X'."ALV 控制: 覆盖码颜色
*  APPEND ls_scol TO gt_scol.
*  gs_out-cscol = gt_scol.

endform.                    "getdata

*&---------------------------------------------------------------------*
*&      Form  outdata
*&---------------------------------------------------------------------*
form outdata using gt_out like gt_out.
  DATA lv_ilines TYPE i.
  DATA lv_slines TYPE string.
  DATA lv_title  TYPE lvc_title.

  lv_ilines = lines( gt_out ).
  lv_slines = lv_ilines.
  lv_title = |条目数:{ lv_slines }|.
  gv_repid = sy-repid.
  gs_slayt-smalltitle = 'X'.
  gs_slayt-zebra      = 'X'. " 斑马
  gs_slayt-detailinit = 'X'.
  gs_slayt-box_fname  = 'SELED'.
  gs_slayt-ctab_fname = 'CSCOL'.
  gs_varnt-report = 'xxxxxxxxxx'.
  gs_varnt-handle = 1.
*  gs_varnt-variant    = sy-repid. "
  gs_glayt-edt_cll_cb = 'X'.

*  CHECK gt_out IS NOT INITIAL.
  call function 'REUSE_ALV_GRID_DISPLAY_LVC'
    exporting
      it_fieldcat_lvc         = gt_fldct
      i_save                  = 'A'
      is_variant              = gs_varnt
      it_events               = gt_event
      is_layout_lvc           = gs_slayt
      i_grid_settings         = gs_glayt
      i_callback_program      = gv_repid
      i_grid_title            = lv_title
      i_callback_user_command = 'USER_COMMAND'
*      i_callback_pf_status_set = 'SET_STATUS'
    tables
      t_outtab                = gt_out.
endform.

*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
form set_status using pt_extab type slis_t_extab ##CALLED.
*  SET PF-STATUS 'STD_FULL' EXCLUDING pt_extab.
*  SET TITLEBAR 'T100' WITH '商机修改'(t01) gv_titl1 gv_titl2.
endform.                    "SET_STATUS

*&---------------------------------------------------------------------*
*& Form get_fldcat
*&---------------------------------------------------------------------*
form get_fldcat using p_fieldname p_seltext.
  data: ls_fldct type lvc_s_fcat.
  data: s_mask    type  dd04l-convexit.
  data lv_kind type ref to cl_abap_elemdescr.
  data lv_dnam type domname.
  data lv_fieldname_tmp type dd07t-ddtext.
  "配置列属性
  ls_fldct-fieldname     =  p_fieldname.
  ls_fldct-scrtext_l     =  p_seltext.
  ls_fldct-scrtext_m     =  p_seltext.
  ls_fldct-scrtext_s     =  p_seltext.
  ls_fldct-colddictxt = 'R'.
  ls_fldct-selddictxt = 'R'.
  ls_fldct-just = 'C'.


  lv_kind ?= cl_abap_datadescr=>describe_by_data( p_fieldname ).
  if lv_kind->help_id <> ''.
    select single domname into lv_dnam
       from dd04l
       where rollname = lv_kind->help_id.
    if sy-subrc = 0.
      select single ddtext into lv_fieldname_tmp
        from dd07t
        where domvalue_l = p_fieldname   and
              domname    = lv_dnam and
              ddlanguage = sy-langu.
    endif.
  endif.
  if lv_fieldname_tmp is not initial.
    select single convexit  into  s_mask  from dd04l where rollname = lv_fieldname_tmp.
    if sy-subrc = 0 and s_mask is not initial.
      concatenate '==' s_mask into ls_fldct-edit_mask .
    endif.
  else.
    select single convexit  into  s_mask  from dd04l where rollname = p_fieldname.
    if sy-subrc = 0 and s_mask is not initial.
      concatenate '==' s_mask into ls_fldct-edit_mask .
    endif.
  endif.
  ls_fldct-col_opt   = 'A'.  "自动优化列宽
  ls_fldct-edit      = ''.
  case ls_fldct-fieldname.
    when 'KBEDK' or 'KBEIP' or 'KBETR' or 'WRB08' or 'WRBDB' or 'WRBDJ' or
         'WRBDK' or 'WRBHL' or 'WRBIP' or 'WRBJH' or 'WRBYF' or 'WRBQT'.
      ls_fldct-cfieldname = 'WAERS'.
      ls_fldct-decimals_o = 2.
      ls_fldct-no_zero    = 'X'.
    when 'DKUAN' or 'IPMNG' or 'MENGE' or 'CPUNH' or 'GBMEM' or 'GBHDD' or
         'GBSSD' or 'GBSHA' or 'WRBXD' or 'BSTMG' or 'BDMNG'.
      ls_fldct-qfieldname = 'MEINS'.
      ls_fldct-decimals_o = 3.
      ls_fldct-no_zero = 'X'.
    when 'JBQHT'.
      ls_fldct-checkbox  = 'X'.
    when 'FWTYP' or 'FWCNT'.
      ls_fldct-ref_table  = ''. "防止ALV编辑出现00002(输入有效值)错误
      ls_fldct-ref_field  = ''. "
      ls_fldct-f4availabl = 'X'.
    when others.
  endcase.

  append ls_fldct to  gt_fldct .
endform.

*&---------------------------------------------------------------------*
*& Form get_fldcat
*&---------------------------------------------------------------------*
form get_fldcat_bys using p_strname.
  data: ls_fldct type lvc_s_fcat.
  call function 'LVC_FIELDCATALOG_MERGE' "
    exporting
      i_structure_name       = p_strname "
    changing
      ct_fieldcat            = gt_fldct "
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.                         "#EC CI_SUBRC
  loop at gt_fldct into ls_fldct.
    ls_fldct-colddictxt = 'R'.
    ls_fldct-selddictxt = 'R'.
    ls_fldct-col_opt   = 'A'.  "自动优化列宽
    ls_fldct-edit      = ''.
    ls_fldct-just = 'C'.
    case ls_fldct-fieldname.
      when 'KBEDK' or 'KBEIP' or 'KBETR' or 'WRB08' or 'WRBDB' or 'WRBDJ' or
           'WRBDK' or 'WRBHL' or 'WRBIP' or 'WRBJH' or 'WRBYF' or 'WRBQT'.
        ls_fldct-cfieldname = 'WAERS'.
        ls_fldct-no_zero    = 'X'.
      when 'DKUAN' or 'IPMNG' or 'MENGE' or 'CPUNH' or 'GBMEM' or 'GBHDD' or
           'GBSSD' or 'GBSHA' or 'WRBXD' or 'BSTMG' or 'BDMNG'.
        ls_fldct-qfieldname = 'MEINS'.
        ls_fldct-no_zero = 'X'.
      when 'JBQHT'.
        ls_fldct-checkbox  = 'X'.
      when 'FWTYP' or 'FWCNT'.
        ls_fldct-ref_table  = ''. "防止ALV编辑出现00002(输入有效值)错误
        ls_fldct-ref_field  = ''. "
        ls_fldct-f4availabl = 'X'.
      when others.
    endcase.
    modify gt_fldct from ls_fldct.
  endloop.
endform.


*&---------------------------------------------------------------------*
*& Form get_fldcat
*&---------------------------------------------------------------------*
form get_fldcat_byt using  p_fieldname p_reft p_reff p_seltext.
  data: ls_fldct type lvc_s_fcat.
  data: s_mask    type  dd04l-convexit.
  data lv_kind type ref to cl_abap_elemdescr.
  data lv_dnam type domname.
  data lv_fieldname_tmp type dd07t-ddtext.
  "配置列属性
  ls_fldct-ref_table     = p_reft.
  ls_fldct-ref_field     = p_reff.
  ls_fldct-fieldname     = p_fieldname.
  ls_fldct-reptext       = p_seltext.
  ls_fldct-coltext       = p_seltext.
  ls_fldct-seltext       = p_seltext.
  ls_fldct-colddictxt    = 'R'.
  ls_fldct-selddictxt    = 'R'.
  ls_fldct-col_opt       = 'A'.
  ls_fldct-edit          = ''.
  ls_fldct-just = 'C'.

  case ls_fldct-fieldname.
    when 'KBEDK' or 'KBEIP' or 'KBETR' or 'WRB08' or 'WRBDB' or 'WRBDJ' or
         'WRBDK' or 'WRBHL' or 'WRBIP' or 'WRBJH' or 'WRBYF' or 'WRBQT'.
      ls_fldct-cfieldname = 'WAERS'.
      ls_fldct-decimals_o = 2.
      ls_fldct-no_zero    = 'X'.
    when 'DKUAN' or 'IPMNG' or 'MENGE' or 'CPUNH' or 'GBMEM' or 'GBHDD' or
         'GBSSD' or 'GBSHA' or 'WRBXD' or 'BSTMG' or 'BDMNG'.
      ls_fldct-qfieldname = 'MEINS'.
      ls_fldct-decimals_o = 3.
      ls_fldct-no_zero = 'X'.
    when 'FWTYP' or 'FWCNT'.
      ls_fldct-f4availabl = 'X'.
    when others.
  endcase.

  append ls_fldct to  gt_fldct .
endform.


*&--------------------------------------------------------------------*
*&      Form  user_command
*&--------------------------------------------------------------------*
form user_command using pv_ucomm type sy-ucomm        ##CALLED
                        pv_field type slis_selfield.
  data lv_code.
  read table gt_out into gs_out index pv_field-tabindex.
  case pv_ucomm.
    when '&IC1'. "双击或者HOTSPOT
      case pv_field-fieldname.
        when 'SJMEM'.
*          cl_demo_output=>display( gs_out-sjmem ).
      endcase.
      return.
    when 'REFRESH'.  "刷新数据
      perform getdata.
    when 'ZBACK' or 'CANCEL'.
      leave to screen 0.
  endcase.

  pv_field-row_stable = 'X'."
  pv_field-col_stable = 'X'."
  pv_field-refresh    = 'X'."
endform.                    "user_command

form load.
  " 配置ALV列
  if gt_fldct[] is initial.
    clear:gt_fldct,
           gt_fldct[].
    perform get_fldcat_byt
      using 'MATNR'
            'MARA'
            'MATNR'
            '物料编码'(f01).
  endif.
endform.
