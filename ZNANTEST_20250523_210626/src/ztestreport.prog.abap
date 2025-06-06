*&---------------------------------------------------------------------*
*& REPORT ZTESTREPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztestreport.

*初始化的一些工作 这里定义的变量是全局的，
*每个事件块里面的变量，只能作用于当前块里面
INITIALIZATION.
  WRITE / 'INITIALIZATION'.
  TYPES: BEGIN OF type1,
           vbeln TYPE vbeln_va,
           erdat TYPE erdat,
           vkorg TYPE vkorg,
         END OF type1.
  DATA tab1 TYPE TABLE OF type1.

  TYPES :BEGIN OF type2,
           vbeln  TYPE vbeln_va,
           posnr  TYPE posnr_va,
           matnr  TYPE matnr,
           kwmeng TYPE kwmeng,
           vrkme  TYPE vrkme,
         END OF type2.
  DATA tab2 TYPE TABLE OF type2.

  DATA str5 TYPE string VALUE `sfaf`.

  WRITE :'xxxxxxxxxxxxxxxxxxxxxxx'.



  WRITE  45.

  TYPES: BEGIN OF type3,
           vbeln  TYPE vbeln_va,
           vrkme  TYPE vrkme,




           erdat  TYPE erdat,
           vkorg  TYPE vkorg,
           posnr  TYPE posnr_va,
           matnr  TYPE matnr,
           kwmeng TYPE kwmeng,

         END OF type3.
  DATA tab4 TYPE TABLE OF type3.

  DATA arr TYPE TABLE OF string.
  SKIP.
  WRITE: / sy-uline.

*用户输入

*定义用户输入内容

  PARAMETERS vbeln TYPE vbeln_va.
  PARAMETERS vrkme TYPE vrkme.
  PARAMETERS erdat TYPE erdat.
  PARAMETERS vkorg TYPE vkorg.
  PARAMETERS posnr TYPE posnr_va.
  PARAMETERS matnr TYPE matnr.
  PARAMETERS  kwmeng TYPE kwmeng.





*处理用户输入
AT SELECTION-SCREEN.
  WRITE / 'AT SELECTION-SCREEN'.
  SKIP.
  WRITE: / sy-uline.



  WRITE / 'START-OF-SELECTION'.
  WRITE / vbeln.
  WRITE / erdat.
  WRITE / vkorg.
  WRITE / posnr.
  WRITE / matnr.
  WRITE / kwmeng.
  WRITE / vrkme.
  WRITE / sy-uline.


  IF vbeln IS NOT INITIAL.
    APPEND | A~VBELN  = '{ vbeln }'| TO arr .
  ENDIF.
  IF erdat IS NOT INITIAL.
    APPEND | A~ERDAT  = '{ erdat }''| TO arr .

  ENDIF.
  IF vkorg IS NOT INITIAL.
    APPEND | A~VKORG = '{ vkorg }'| TO arr .

  ENDIF.
  IF posnr IS NOT INITIAL.
    APPEND | A~POSNR = '{ posnr }'| TO arr .
  ENDIF.


  IF matnr IS NOT INITIAL.
    APPEND | B~MATNR = '{ matnr }'| TO arr .
  ENDIF.
  IF kwmeng IS NOT INITIAL.
    APPEND | B~KWMENG = '{ kwmeng }'| TO arr .
  ENDIF.
  IF vrkme IS NOT INITIAL.
    APPEND | B~VRKME = '{ vrkme }'| TO arr .
  ENDIF.

*在用户输入界面的操作
*IF ARR IS INITIAL .
*MESSAGE '请输入过滤参数' TYPE 'E'.
*ENDIF.





*用户完成输入
START-OF-SELECTION.

*构造查询语句
  PERFORM build_sql.
*普通报表
  PERFORM display_report.
**显示ALV报表格式
  PERFORM alv.







*/封装数据获取
FORM build_sql.
*封装SQL拼接
* 使用 STRING 操作将数组转换为单个字符串
  DATA querystr TYPE string.
  CONCATENATE LINES OF arr INTO querystr SEPARATED BY ' AND  '.
  IF querystr IS NOT INITIAL.
    querystr = | { querystr }| .
  ENDIF.
  WRITE / |{ querystr }|.
  WRITE: / '用户输入如下：'.
  SKIP.
  WRITE: / sy-uline.



  WRITE /'START-OF-SELECTION'.
  SELECT  vbeln  erdat  vkorg FROM vbak INTO
  TABLE tab1.
  WRITE / |VBAK 条目数量为：{ lines( tab1 )  }|.
  SELECT  vbeln posnr matnr kwmeng  vrkme FROM vbap INTO
  TABLE tab2.
  WRITE / |VBAP 条目数量为：{ lines( tab2 )  }|.
  SKIP.
  DATA str1 TYPE string.
  str1 = 'SELECT A~VBELN, B~VRKME FROM VBAK AS A INNER JOIN VBAP AS B '
  &&'ON A~VBELN = B~VBELN INTO TABLE @DATA(TAB4) '&& 'WHERE ' && querystr.
  WRITE / '查询表达式为：' && str1.
  SKIP.
  TRY.
      IF querystr IS  INITIAL.
        WRITE / '1'.
        SELECT a~vbeln, b~vrkme, b~erdat, a~vkorg, b~posnr, b~matnr, b~kwmeng FROM vbak AS a
        INNER JOIN vbap AS b ON a~vbeln = b~vbeln INTO TABLE @tab4.
      ELSE.
        WRITE / '2'.
        SELECT  a~vbeln, b~vrkme, b~erdat, a~vkorg, b~posnr, b~matnr, b~kwmeng FROM vbak AS a
        INNER JOIN vbap AS b ON a~vbeln = b~vbeln INTO TABLE @tab4 WHERE (querystr).
      ENDIF.

    CATCH cx_sy_native_sql_error INTO DATA(lx_sql_error).
      WRITE: / 'XXXX'.
  ENDTRY.
  WRITE / |共同条目数量为：{ lines( tab4 )  }|.
  WRITE / |完成查询 sy|.
ENDFORM.

" 定义报表显示
form display_report.
  IF lines( tab4 ) >= 0.
    WRITE / |{ lines( tab4 )  }|.

    WRITE: / ' LS_LINE1-VBELN' ,' LS_LINE1-VRKME'.
    LOOP AT tab4 INTO DATA(ls_line1).
      WRITE: / ls_line1-vbeln ,
       ls_line1-vrkme,
       ls_line1-erdat,
       ls_line1-vkorg,
       ls_line1-posnr,
       ls_line1-matnr,
       ls_line1-kwmeng.
    ENDLOOP.
  ELSE.
    MESSAGE '未查询到数据' TYPE 'E'.
  ENDIF.

ENDFORM.


*START-OF-SELECTION中的所有代码完成后触发
END-OF-SELECTION.
  SKIP.
  WRITE: / 'END-OF-SELECTION'.

*其他功能





*&---------------------------------------------------------------------*
*& FORM ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM alv .
*  作用
  TYPE-POOLS:slis.

  DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
         wt_fieldcat TYPE slis_fieldcat_alv,
         ls_layout   TYPE slis_layout_alv,
         lt_sort     TYPE slis_t_sortinfo_alv, "表类型
         wa_sort     TYPE slis_sortinfo_alv. "类型

  TYPES:BEGIN OF lt_xs,
          vbeln TYPE vbak-vbeln,
          matnr TYPE vbap-matnr,
        END OF lt_xs.
  DATA :gw_xs TYPE lt_xs,
        wa_xs TYPE TABLE OF lt_xs.


*SELECT VBAK~VBELN MATNR FROM VBAK
*LEFT JOIN VBAP
*ON VBAK~VBELN = VBAP~VBELN
*INTO TABLE WA_XS.

  ls_layout-zebra = 'X'.
  ls_layout-detail_popup = 'X'.
  ls_layout-detail_titlebar = '详细信息'.
  ls_layout-f2code = '&ETA'.
  ls_layout-colwidth_optimize = 'X'.



*要显示的列信息
*对应的FIELD
  wt_fieldcat-fieldname = 'VBELN'.
*列的优先级
  wt_fieldcat-col_pos  = '1'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-datatype = 'CHAR'.
*单元格长度
  wt_fieldcat-outputlen = '10'.
*显示名
  wt_fieldcat-seltext_m = '销售凭证'.
  APPEND wt_fieldcat TO lt_fieldcat.


  wt_fieldcat-fieldname = 'VRKME'.
  wt_fieldcat-col_pos  = '2'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'VRKME'.
  APPEND wt_fieldcat TO lt_fieldcat.


  wt_fieldcat-fieldname = 'ERDAT'.
  wt_fieldcat-col_pos  = '4'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'ERDAT'.
  APPEND wt_fieldcat TO lt_fieldcat.

  wt_fieldcat-fieldname = 'VKORG'.
  wt_fieldcat-col_pos  = '5'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'VKORG'.
  APPEND wt_fieldcat TO lt_fieldcat.

  wt_fieldcat-fieldname = 'POSNR'.
  wt_fieldcat-col_pos  = '6'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'POSNR'.
  APPEND wt_fieldcat TO lt_fieldcat.

  wt_fieldcat-fieldname = 'MATNR'.
  wt_fieldcat-col_pos  = '7'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'VRKME'.
  APPEND wt_fieldcat TO lt_fieldcat.

  wt_fieldcat-fieldname = 'KWMENG'.
  wt_fieldcat-col_pos  = '8'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'KWMENG'.
  APPEND wt_fieldcat TO lt_fieldcat.

*排序字段配置
  wa_sort-fieldname = 'KWMENG'."排序字段
  wa_sort-up      = 'X'."降序
  wa_sort-spos      = '1'."排序的顺序，如果根据多个字段来排时，决定哪个先排
  APPEND wa_sort TO lt_sort.






  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid       "当前程序名
      i_callback_top_of_page = 'FRM_CREATE_HEADER_LIST'
      is_layout              = ls_layout
      it_fieldcat            = lt_fieldcat
      i_save                 = 'A'
    TABLES
      t_outtab               = tab4 "数据源
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.






ENDFORM.








*&---------------------------------------------------------------------*
*& FORM SHOWALVHEADER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM showalvheader.



*页头信息
  DATA listheader TYPE slis_t_listheader.
  DATA  wa_listheader TYPE  slis_listheader.
  wa_listheader-typ  = 'S'.
  wa_listheader-key  = '用户:'.
  wa_listheader-info = sy-uname.
  APPEND wa_listheader TO listheader.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = listheader.

ENDFORM.


FORM frm_create_header_list.

  DATA: gs_layout     TYPE slis_layout_alv,     "布局
        gt_fieldcat   TYPE slis_t_fieldcat_alv, "字段
        gt_listheader TYPE slis_t_listheader.   "标题列
  DATA: ls_listheader TYPE slis_listheader,
        lv_datum      TYPE char10,
        lv_uzeit      TYPE char10.

  CLEAR gt_listheader.

  "大标题
  ls_listheader-typ = 'H'.
  ls_listheader-info = 'XXX学校'.
  APPEND ls_listheader TO gt_listheader.
  CLEAR ls_listheader.

  "中标题
  ls_listheader-typ = 'S'.
  ls_listheader-info = '学生名单'.
  APPEND ls_listheader TO gt_listheader.
  CLEAR ls_listheader.

  WRITE sy-datum TO lv_datum DD/MM/YYYY.
  WRITE sy-uzeit TO lv_uzeit USING EDIT MASK '__:__:__'.

  "小标题
  ls_listheader-typ = 'A'.
  ls_listheader-info = 'Today:' && lv_datum && 'Time:' && lv_uzeit.
  APPEND ls_listheader TO gt_listheader.
  CLEAR ls_listheader.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.
ENDFORM.
