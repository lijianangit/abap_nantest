*&---------------------------------------------------------------------*
*& 包含               ZMMR084_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:slis.
TABLES:eban,ebkn.

*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
DATA:gt_fieldcat TYPE lvc_t_fcat,
     gs_fieldcat LIKE LINE OF gt_fieldcat.
DATA: gs_layout   TYPE lvc_s_layo.

DATA:BEGIN OF gs_out,
       banfn       LIKE eban-banfn,
       bnfpo       LIKE eban-bnfpo,
       matnr       LIKE eban-matnr,
       txz01       LIKE eban-txz01,
       menge       LIKE eban-menge,
       bsmng       LIKE eban-bsmng, "PR未转PO数量
       badat       LIKE eban-badat, "需求日期
       ernam       LIKE eban-ernam,
       lfdat       LIKE eban-lfdat, "交货日期
       meins       LIKE eban-meins,
       werks       LIKE eban-werks,
       ekgrp       LIKE eban-ekgrp,
       lgort       LIKE eban-lgort,
       ekorg       LIKE eban-ekorg,
       loekz       LIKE eban-loekz,
       idnlf       LIKE eban-idnlf, "供应商物料
       ebeln       LIKE eban-ebeln,
       ebelp       LIKE eban-ebelp,
       flief       LIKE eban-flief,
       statu       LIKE eban-statu, "处理状态
       frgst       LIKE eban-frgst, "批准策略
       frgkz       LIKE eban-frgkz, "批准标识
       matnr_z     TYPE afpo-matnr, "外发组件
       maktx       TYPE makt-maktx, "外发组件描述
       bednr       LIKE eban-bednr, "需求跟踪号
       bsart       LIKE eban-bsart,
       pstyp       LIKE eban-pstyp,
       knttp       LIKE eban-knttp,
       matkl       LIKE eban-matkl,
       kostl       LIKE ebkn-kostl,
       vbeln       LIKE ebkn-vbeln,
       vbelp       LIKE ebkn-vbelp,
       sakto       LIKE ebkn-sakto,
       dispo       LIKE eban-dispo,
       charg       LIKE eban-charg,
       lname(255)  TYPE c,
       tdline(255) TYPE c,
     END OF gs_out.

DATA:gt_out LIKE TABLE OF gs_out WITH HEADER LINE.

DEFINE macro_fill_alv_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = &1.
  gs_fieldcat-coltext = &2.
  gs_fieldcat-hotspot = &3.
  gs_fieldcat-outputlen = &4.
  gs_fieldcat-ref_table = &5.
  gs_fieldcat-ref_field = &6.
  APPEND gs_fieldcat TO gt_fieldcat.
END-OF-DEFINITION.
