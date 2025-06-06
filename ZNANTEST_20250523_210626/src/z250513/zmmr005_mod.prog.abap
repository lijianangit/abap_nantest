*&---------------------------------------------------------------------*
*& 包含               ZMMR084_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form frm_get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_get_data .
  select from ( eban as a
    left outer join ebkn as b
    on a~banfn = b~banfn
    and a~bnfpo = b~bnfpo )
    fields
    a~bsart,
    a~banfn,
    a~bnfpo,
    a~pstyp,
    a~knttp,
    a~loekz,
    a~statu,
    a~frgst,
    a~frgkz,
    a~ekgrp,
    a~badat,
    a~werks,
    a~matnr,
    a~idnlf,
    a~txz01,
    a~lgort,
    a~menge,
    a~meins,
    a~lfdat,
    a~ekorg,
    a~flief,
    a~matkl,
    a~ebeln,
    a~ebelp,
    b~kostl,
    b~vbeln,
    b~vbelp,
    b~sakto,
    a~bsmng,
    a~dispo,
    a~ernam,
    a~charg,
    a~bednr

    where a~bsart in @so_bsart
    and a~bnfpo in @so_bnfpo
    and a~ekgrp in @so_ekgrp
    and a~frgst in @so_frgst
    and a~frgkz in @so_frgkz
    and a~ebeln in @so_ebeln
    and a~banfn in @so_banfn
    and a~pstyp in @so_pstyp
    and a~knttp in @so_knttp
    and a~loekz in @so_loekz
    and a~statu in @so_statu
    and a~badat in @so_badat
    and a~werks in @so_werks
    and a~matnr in @so_matnr
    and a~lgort in @so_lgort
    and a~flief in @so_flief
    and a~ekorg in @so_ekorg
    and a~dispo in @so_dispo
    into corresponding fields of table @gt_out.    "#EC CI_NO_TRANSFORM

  check gt_out[] is not initial.

  select from  ebkn as a
    left join ( afpo left join makt
    on afpo~matnr = makt~matnr and makt~spras = @sy-langu )
    on a~aufnr = afpo~aufnr
    fields
    a~banfn,
    a~bnfpo,
    a~aufnr,
    afpo~matnr as matnr_z,
    makt~maktx
    for all entries in @gt_out
    where a~banfn = @gt_out-banfn
    and a~bnfpo = @gt_out-bnfpo
    into table @data(lt_ebkn).                     "#EC CI_NO_TRANSFORM

  sort lt_ebkn[] by banfn bnfpo.

  if so_bsmng is not initial.
    loop at gt_out.
      gt_out-bsmng = gt_out-menge - gt_out-bsmng.
      if gt_out-bsmng not in so_bsmng.
        delete gt_out.
      else.
        modify gt_out.
      endif.
    endloop.
  else.
    loop at gt_out.
      gt_out-bsmng = gt_out-menge - gt_out-bsmng.
      gt_out-matnr_z = ''.
      gt_out-maktx = ''.

      if gt_out-matnr = space.

*        SELECT SINGLE aufnr INTO @DATA(lv_aufnr)
*          FROM ebkn
*          WHERE  banfn = gt_out-banfn
*          AND bnfpo = gt_out-bnfpo .
        read table lt_ebkn into data(ls_ebkn)
                             with key banfn = gt_out-banfn
                                      bnfpo = gt_out-bnfpo
                                      binary search.
        if sy-subrc eq 0.
*          IF ls_ebkn-aufnr <> ''.
*
*            SELECT SINGLE
*              afpo~matnr
*              makt~maktx
*              INTO ( gt_out-matnr_z ,gt_out-maktx )
*              FROM afpo
*              INNER JOIN makt
*              ON afpo~matnr = makt~matnr
*              WHERE  afpo~aufnr = ls_ebkn-aufnr.
*
*          ENDIF.
          gt_out-matnr_z = ls_ebkn-matnr_z.
          gt_out-maktx = ls_ebkn-maktx.
          clear ls_ebkn.
        endif.

      endif.

      modify gt_out.
    endloop.
  endif.

  data: il_tline like tline occurs 0 with header line.
  data : vl_tdname like thead-tdname.
  loop at gt_out assigning field-symbol(<fs_alv>).
    vl_tdname = |{ conv banfn( <fs_alv>-banfn ) alpha = in }|  && |{ conv bnfpo( <fs_alv>-bnfpo ) alpha = in }| .
    clear : il_tline.
    call function 'READ_TEXT'
      exporting
*       CLIENT                  = SY-MANDT
        id                      = 'B01'
        language                = sy-langu
        name                    = vl_tdname
        object                  = 'EBAN'
*       ARCHIVE_HANDLE          = 0
*      IMPORTING
*       header                  = htext
      tables
        lines                   = il_tline
      exceptions
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        others                  = 8.
    loop at il_tline. "循环赋值给alv
      <fs_alv>-tdline = il_tline-tdline.
    endloop.

  endloop.

*  LOOP AT gt_out WHERE ebeln IS NOT INITIAL.
*    SELECT SINGLE lifnr aedat INTO (gt_out-lifnr, gt_out-aedat)
*      FROM ekko
*      WHERE ebeln = gt_out-ebeln.
*    IF sy-subrc = 0.
*      SELECT SINGLE @abap_true FROM lfa1
*        WHERE lifnr = gt_out-lifnr.
*      IF sy-subrc = 0.
*        CONCATENATE lfa1-name1 lfa1-name2 INTO gt_out-lname.
*      ENDIF.
*      MODIFY gt_out.
*      CLEAR gt_out.
*    ENDIF.
*  ENDLOOP.
endform.
*&---------------------------------------------------------------------*
*& Form frm_alv_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_alv_display .
* 定义列自动宽度优化
  gs_layout-cwidth_opt = 'X'.
* 定义条纹显示
  gs_layout-zebra = 'X'.

* 确定ALV输出列的属性
  perform frm_fill_fieldcat.

  call function 'REUSE_ALV_GRID_DISPLAY_LVC'
    exporting
      i_callback_program = sy-repid
      is_layout_lvc      = gs_layout
      it_fieldcat_lvc    = gt_fieldcat[]
*     i_callback_pf_status_set = 'FRM_SET_PF_STATUS_0100' " 菜单
*     i_callback_user_command  = 'FRM_USER_COMMAND_0100' "自定义菜单执行代码
*     it_events          = i_events[]
*     is_print           = w_print
      i_save             = 'A'
    tables
      t_outtab           = gt_out "要输出的内表
    exceptions
      program_error      = 1
      others             = 2.
endform.
*&---------------------------------------------------------------------*
*& Form frm_fill_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form frm_fill_fieldcat .
  macro_fill_alv_fieldcat 'BANFN' '采购申请'(c01) '' '' '' ''.
  macro_fill_alv_fieldcat 'BNFPO' '采购申请行项目'(c02) '' '' '' ''.
  macro_fill_alv_fieldcat 'MATNR' '物料编码'(c03) '' '' '' ''.
  macro_fill_alv_fieldcat 'TXZ01' '短文本'(c04) '' '' '' ''.
  macro_fill_alv_fieldcat 'MENGE' '申请数量'(c05) '' '' 'EBAN' 'MENGE'.
  macro_fill_alv_fieldcat 'BSMNG' 'PR未转PO数量'(c06) '' '' 'EBAN' 'MENGE'.
  macro_fill_alv_fieldcat 'BADAT' '请求日期'(c07) '' '' '' ''.
  macro_fill_alv_fieldcat 'ERNAM' '创建者'(c08) '' '' '' ''.
  macro_fill_alv_fieldcat 'LFDAT' '交货日期'(c09) '' '' '' ''.
  macro_fill_alv_fieldcat 'MEINS' '计量单位'(c10) '' '' '' ''.
  macro_fill_alv_fieldcat 'WERKS' '工厂'(c11) '' '' '' ''.
  macro_fill_alv_fieldcat 'EKGRP' '采购组'(c12) '' '' '' ''.
  macro_fill_alv_fieldcat 'LGORT' '库存地点'(c13) '' '' '' ''.
  macro_fill_alv_fieldcat 'EKORG' '采购组织'(c14) '' '' '' ''.
  macro_fill_alv_fieldcat 'LOEKZ' '删除标志'(c15) '' '' '' ''.
  macro_fill_alv_fieldcat 'IDNLF' '供应商物料'(c16) '' '' '' ''.
  macro_fill_alv_fieldcat 'EBELN' '采购订单'(c17) '' '' '' ''.
  macro_fill_alv_fieldcat 'FLIEF' '固定的供应商'(c18) '' '' '' ''.
  macro_fill_alv_fieldcat 'STATU' '处理状态'(c19) '' '' '' ''.
  macro_fill_alv_fieldcat 'FRGST' '批准策略'(c20) '' '' '' ''.
  macro_fill_alv_fieldcat 'FRGKZ' '批准标识'(c21) '' '' '' ''.
  macro_fill_alv_fieldcat 'MATNR_Z' '外发组件'(c22) '' '' '' ''.
  macro_fill_alv_fieldcat 'MAKTX' '外发组件描述'(c23) '' '' '' ''.
  macro_fill_alv_fieldcat 'BEDNR' '需求跟踪号'(c24) '' '' '' ''.
  macro_fill_alv_fieldcat 'DISPO' 'MRP控制者'(c25) '' '' 'EBAN' ''.
  macro_fill_alv_fieldcat 'TDLINE' '项目文本'(c26) '' '' '' ''.
endform.
