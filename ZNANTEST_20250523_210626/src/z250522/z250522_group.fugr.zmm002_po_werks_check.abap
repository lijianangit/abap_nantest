FUNCTION ZMM002_PO_WERKS_CHECK.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IS_PO_HEADER) TYPE  MEPOHEADER
*"  TABLES
*"      IT_PO_ITEM TYPE  PURCHASE_ORDER_ITEMS
*"  CHANGING
*"     REFERENCE(CH_FAILED) TYPE  MMPUR_BOOL
*"----------------------------------------------------------------------

  DATA:lv_message TYPE char255.
  DATA:ls_item  TYPE mepoitem.
  DATA:lt_bom  TYPE mmpur_t_mdpm.
  DATA:lt_schedules  TYPE purchase_order_schedules.

*$---------------------------------------------$*
*   增强开关
*$---------------------------------------------$*
  SELECT COUNT(*)
  FROM zcat0006
  WHERE zenname = 'ZMM002_PO_WERKS_CHECK'
    AND zactive = 'X'.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  LOOP AT it_po_item INTO DATA(ls_po_item).
    ls_item = ls_po_item-item->get_data( ).

    "1.外协加工的PO且工厂是1063和1060工厂
    IF ls_item-pstyp EQ '3' AND ( ls_item-werks EQ '1063' OR ls_item-werks = '2773' OR ls_item-werks EQ '1064' OR ls_item-werks = '2774' OR ls_item-werks EQ '2873'
                                  OR ls_item-werks = '1653' OR ls_item-werks EQ '1654' ).    "change by 9999301 OSM-34183

      "2.获取外协组件
      lt_schedules = ls_po_item-item->get_schedules( ).
      DATA(ls_schedules) = lt_schedules[ 1 ].
      ls_schedules-schedule->get_bom( IMPORTING et_bom = lt_bom ).

      "3.判断外协组件是否是3001评估类
      LOOP AT lt_bom INTO DATA(ls_bom) WHERE werks NE ls_item-werks.
        SELECT COUNT(*)
          FROM
          mbew
          WHERE
          matnr EQ @ls_bom-matnr
          AND bwkey EQ @ls_bom-werks
          AND bklas EQ '3001'.
        IF sy-subrc EQ 0.
          lv_message = '报税物料'&& ls_bom-matnr && '工厂与订单行项目工厂不一致！'.
          mmpur_business_obj_id ls_item-id.
          mmpur_message_forced  'E' 'ZMM' '000' lv_message '' '' ''.
          CALL METHOD ls_po_item-item->invalidate( ). "将发生错误的行设置为无效
          ch_failed = 'X'.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDLOOP.


ENDFUNCTION.
