*&---------------------------------------------------------------------*
*& Report z250513_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250513_1.

load-of-program.

top-of-page."在页首输出时触发。

initialization. " 在程序开始执行时初始化数据时触发。
  tables: eban,ebkn,ekko,ekpo, eina,stxh,stxl,makt.
  types: begin of result_type,
           banfn   type eban-banfn,
           bnfpo   type eban-bnfpo,
           loekz   type eban-loekz,
           idnlf   type eban-idnlf,   " 供应商物料编号
           ebeln   type eban-ebeln,
           flief   type eban-flief,
           statu   type eban-statu,
           frgst   type eban-frgst,
           frgkz   type eban-frgkz,
           matnr   type eban-matnr,
           maktx   type makt-maktx,   " 外发组件描述
           bednr   type eban-bednr,   " 需求跟踪号

           txz01   like eban-txz01,
           menge   like eban-menge,
           bsmng   like eban-bsmng,   " PR未转PO数量
           badat   like eban-badat,   " 需求日期
           ernam   like eban-ernam,
           lfdat   like eban-lfdat,   " 交货日期
           meins   like eban-meins,
           werks   like eban-werks,
           ekgrp   like eban-ekgrp,
           lgort   like eban-lgort,
           ekorg   like eban-ekorg,
           ebelp   like eban-ebelp,
           matnr_z type afpo-matnr,   " 外发组件
           bsart   like eban-bsart,
           pstyp   like eban-pstyp,
           knttp   like eban-knttp,
           matkl   like eban-matkl,
           kostl   like ebkn-kostl,
           vbeln   like ebkn-vbeln,
           vbelp   like ebkn-vbelp,
           sakto   like ebkn-sakto,
           dispo   like eban-dispo,
           charg   like eban-charg,
           lname   type c LENGTH 255,
           tdline  type c LENGTH 255,
         end of result_type.
  data result_tab type table of result_type with header line.
  selection-screen begin of block bk1 with frame title text-001.
    select-options P_ebeln for eban-ebeln. " 采购订单编号
    select-options P_bsmng for eban-bsmng. " 对应于此采购申请的订货数量
    select-options P_vbeln for eban-disub_vbeln. " 销售和分销凭证号
    select-options P_kostl for eban-kostl. " 成本中心
    select-options P_flief for eban-flief. " 固定的供应商
    select-options P_ekorg for eban-ekorg. " 采购组织
    select-options P_lgort for eban-lgort. " 库存地点
    select-options P_matnr for eban-matnr memory id mat. " 物料号
    select-options p_werks for eban-werks. " 工厂
    select-options P_badat for eban-badat. " 需求请求日期
    select-options p_ekgrp for eban-ekgrp. " 采购组
    select-options p_frgkz for eban-frgkz. " 批准标识
    select-options p_frgst for eban-frgst. " 采购申请中的批准策略
    select-options p_statu for eban-statu. " 采购申请的处理状态
    select-options p_loekz for eban-loekz. " 采购凭证中的删除标识
    select-options p_knttp for eban-knttp. " 科目分配类别
    select-options p_pstyp for eban-pstyp. " 采购凭证中的项目类别
    select-options p_bnfpo for eban-bnfpo. " 采购申请中的项目编号
    select-options p_banfn for eban-banfn. " 采购申请编号
    select-options p_bsart for eban-bsart. " 采购申请凭证类型
    select-options p_dispo for eban-dispo. " 物料需求计划控制员
  selection-screen end of block bk1.

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行PAI

start-of-selection. " 点击执行后的主程序代码。
  data(util) = new z_nantest_util( ).
  select *
    from ( eban as a
             left  join
               ebkn as b on  a~banfn = b~banfn
                         and a~bnfpo = b~bnfpo )
    into corresponding fields of table @result_tab
    where ebeln       in @P_ebeln
      and disub_vbeln in @P_vbeln
      and a~kostl     in @P_kostl
      and flief       in @P_flief
      and ekorg       in @P_ekorg
      and lgort       in @P_lgort
      and matnr       in @P_matnr
      and werks       in @P_werks
      and badat       in @P_badat
      and ekgrp       in @P_ekgrp
      and frgkz       in @P_frgkz
      and statu       in @P_statu
      and A~loekz     in @P_loekz
      and knttp       in @P_knttp
      and pstyp       in @P_pstyp
      and a~bnfpo     in @P_bnfpo
      and a~banfn     in @P_banfn
      and bsart       in @P_bsart.
  sort result_tab[] by matnr
                       ebeln.
  describe table result_tab lines data(line).
  util->display_table( changing result_tab = result_tab[] ).

end-of-selection. " 选择数据结束时触发。

end-of-page."在页尾输出时触发。
