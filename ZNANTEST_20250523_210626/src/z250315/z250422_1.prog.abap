*&---------------------------------------------------------------------*
*& REPORT ZTESTREPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250422_1.

*初始化的一些工作 这里定义的变量是全局的，
*每个事件块里面的变量，只能作用于当前块里面
initialization.
  write / 'INITIALIZATION'.
  types: begin of type1,
           vbeln type vbeln_va,
           erdat type erdat,
           vkorg type vkorg,
         end of type1.
  data tab1 type table of type1.

  types : begin of type2,
            vbeln  type vbeln_va,
            posnr  type posnr_va,
            matnr  type matnr,
            kwmeng type kwmeng,
            vrkme  type vrkme,
          end of type2.
  data tab2 type table of type2.

  data str5 type string value `sfaf`.

  write 'xxxxxxxxxxxxxxxxxxxxxxx'.

  write 45.

  types: begin of type3,
           vbeln  type vbeln_va,
           vrkme  type vrkme,

           erdat  type erdat,
           vkorg  type vkorg,
           posnr  type posnr_va,
           matnr  type matnr,
           kwmeng type kwmeng,

         end of type3.
  data tab4 type table of type3.

  data arr  type table of string.
  skip.
  write / sy-uline.

  " 用户输入

  " 定义用户输入内容

  parameters vbeln type vbeln_va.
  parameters vrkme type vrkme.
  parameters erdat type erdat.
  parameters vkorg type vkorg.
  parameters posnr type posnr_va.
  parameters matnr type matnr.
  parameters kwmeng type kwmeng.

  " 处理用户输入
at selection-screen.
  write / 'AT SELECTION-SCREEN'.
  skip.
  write: / sy-uline.



  write / 'START-OF-SELECTION'.
  write / vbeln.
  write / erdat.
  write / vkorg.
  write / posnr.
  write / matnr.
  write / kwmeng.
  write / vrkme.
  write / sy-uline.


  if vbeln is not initial.
    append | A~VBELN  = '{ vbeln }'| to arr .
  endif.
  if erdat is not initial.
    append | A~ERDAT  = '{ erdat }''| to arr .

  endif.
  if vkorg is not initial.
    append | A~VKORG = '{ vkorg }'| to arr .

  endif.
  if posnr is not initial.
    append | A~POSNR = '{ posnr }'| to arr .
  endif.


  if matnr is not initial.
    append | B~MATNR = '{ matnr }'| to arr .
  endif.
  if kwmeng is not initial.
    append | B~KWMENG = '{ kwmeng }'| to arr .
  endif.
  if vrkme is not initial.
    append | B~VRKME = '{ vrkme }'| to arr .
  endif.

*在用户输入界面的操作
*IF ARR IS INITIAL .
*MESSAGE '请输入过滤参数' TYPE 'E'.
*ENDIF.





*用户完成输入
start-of-selection.

*构造查询语句
  perform build_sql.
*普通报表
  perform display_report.
**显示ALV报表格式
  perform alv.







*/封装数据获取
form build_sql.
*封装SQL拼接
* 使用 STRING 操作将数组转换为单个字符串
  data querystr type string.
  concatenate lines of arr into querystr separated by ' AND  '.
  if querystr is not initial.
    querystr = | { querystr }| .
  endif.
  write / |{ querystr }|.
  write: / '用户输入如下：'.
  skip.
  write: / sy-uline.



  write /'START-OF-SELECTION'.
  select  vbeln  erdat  vkorg from vbak into
  table tab1.
  write / |VBAK 条目数量为：{ lines( tab1 )  }|.
  select  vbeln posnr matnr kwmeng  vrkme from vbap into
  table tab2.
  write / |VBAP 条目数量为：{ lines( tab2 )  }|.
  skip.
  data str1 type string.
  str1 = 'SELECT A~VBELN, B~VRKME FROM VBAK AS A INNER JOIN VBAP AS B '
  &&'ON A~VBELN = B~VBELN INTO TABLE @DATA(TAB4) '&& 'WHERE ' && querystr.
  write / '查询表达式为：' && str1.
  skip.
  try.
      if querystr is  initial.
        write / '1'.
        select a~vbeln, b~vrkme, b~erdat, a~vkorg, b~posnr, b~matnr, b~kwmeng from vbak as a
        inner join vbap as b on a~vbeln = b~vbeln into table @tab4.
      else.
        write / '2'.
        select  a~vbeln, b~vrkme, b~erdat, a~vkorg, b~posnr, b~matnr, b~kwmeng from vbak as a
        inner join vbap as b on a~vbeln = b~vbeln into table @tab4 where (querystr).
      endif.

    catch cx_sy_native_sql_error into data(lx_sql_error).
      write: / 'XXXX'.
  endtry.
  write / |共同条目数量为：{ lines( tab4 )  }|.
  write / |完成查询 sy|.
endform.

" 定义报表显示
form display_report.
  if lines( tab4 ) >= 0.
    write / |{ lines( tab4 )  }|.

    write: / ' LS_LINE1-VBELN' ,' LS_LINE1-VRKME'.
    loop at tab4 into data(ls_line1).
      write: / ls_line1-vbeln ,
       ls_line1-vrkme,
       ls_line1-erdat,
       ls_line1-vkorg,
       ls_line1-posnr,
       ls_line1-matnr,
       ls_line1-kwmeng.
    endloop.
  else.
    message '未查询到数据' type 'E'.
  endif.

endform.


*START-OF-SELECTION中的所有代码完成后触发
end-of-selection.
  skip.
  write: / 'END-OF-SELECTION'.

*其他功能





*&---------------------------------------------------------------------*
*& FORM ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
form alv .
*  作用
  type-pools:slis.

  data : lt_fieldcat type slis_t_fieldcat_alv,
         wt_fieldcat type slis_fieldcat_alv,
         ls_layout   type slis_layout_alv,
         lt_sort     type slis_t_sortinfo_alv, "表类型
         wa_sort     type slis_sortinfo_alv. "类型

  types:begin of lt_xs,
          vbeln type vbak-vbeln,
          matnr type vbap-matnr,
        end of lt_xs.
  data :gw_xs type lt_xs,
        wa_xs type table of lt_xs.


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
  append wt_fieldcat to lt_fieldcat.


  wt_fieldcat-fieldname = 'VRKME'.
  wt_fieldcat-col_pos  = '2'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'VRKME'.
  append wt_fieldcat to lt_fieldcat.


  wt_fieldcat-fieldname = 'ERDAT'.
  wt_fieldcat-col_pos  = '4'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'ERDAT'.
  append wt_fieldcat to lt_fieldcat.

  wt_fieldcat-fieldname = 'VKORG'.
  wt_fieldcat-col_pos  = '5'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'VKORG'.
  append wt_fieldcat to lt_fieldcat.

  wt_fieldcat-fieldname = 'POSNR'.
  wt_fieldcat-col_pos  = '6'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'POSNR'.
  append wt_fieldcat to lt_fieldcat.

  wt_fieldcat-fieldname = 'MATNR'.
  wt_fieldcat-col_pos  = '7'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'VRKME'.
  append wt_fieldcat to lt_fieldcat.

  wt_fieldcat-fieldname = 'KWMENG'.
  wt_fieldcat-col_pos  = '8'.
  wt_fieldcat-key = 'X'.
  wt_fieldcat-outputlen = '20'.
  wt_fieldcat-seltext_m = 'KWMENG'.
  append wt_fieldcat to lt_fieldcat.

*排序字段配置
  wa_sort-fieldname = 'KWMENG'."排序字段
  wa_sort-up      = 'X'."降序
  wa_sort-spos      = '1'."排序的顺序，如果根据多个字段来排时，决定哪个先排
  append wa_sort to lt_sort.






  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program     = sy-repid       "当前程序名
      i_callback_top_of_page = 'FRM_CREATE_HEADER_LIST'
      is_layout              = ls_layout
      it_fieldcat            = lt_fieldcat
      i_save                 = 'A'
    tables
      t_outtab               = tab4 "数据源
    exceptions
      program_error          = 1
      others                 = 2.






endform.








*&---------------------------------------------------------------------*
*& FORM SHOWALVHEADER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
form showalvheader.



*页头信息
  data listheader type slis_t_listheader.
  data  wa_listheader type  slis_listheader.
  wa_listheader-typ  = 'S'.
  wa_listheader-key  = '用户:'.
  wa_listheader-info = sy-uname.
  append wa_listheader to listheader.


  call function 'REUSE_ALV_COMMENTARY_WRITE'
    exporting
      it_list_commentary = listheader.

endform.


form frm_create_header_list.

  data: gs_layout     type slis_layout_alv,     "布局
        gt_fieldcat   type slis_t_fieldcat_alv, "字段
        gt_listheader type slis_t_listheader.   "标题列
  data: ls_listheader type slis_listheader,
        lv_datum      type char10,
        lv_uzeit      type char10.

  clear gt_listheader.

  "大标题
  ls_listheader-typ = 'H'.
  ls_listheader-info = 'XXX学校'.
  append ls_listheader to gt_listheader.
  clear ls_listheader.

  "中标题
  ls_listheader-typ = 'S'.
  ls_listheader-info = '学生名单'.
  append ls_listheader to gt_listheader.
  clear ls_listheader.

  write sy-datum to lv_datum dd/mm/yyyy.
  write sy-uzeit to lv_uzeit using edit mask '__:__:__'.

  "小标题
  ls_listheader-typ = 'A'.
  ls_listheader-info = 'Today:' && lv_datum && 'Time:' && lv_uzeit.
  append ls_listheader to gt_listheader.
  clear ls_listheader.


  call function 'REUSE_ALV_COMMENTARY_WRITE'
    exporting
      it_list_commentary = gt_listheader.
endform.
