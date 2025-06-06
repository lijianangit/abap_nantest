
class zshow_alv definition
  public
  final
  create public .

  public section.
    types: tab type standard table of ref to zshow_alv with default key.
    class-methods class_constructor.
    methods:
      showALV importing value(p1) type string exporting result type string,
      build_fieldcat ,
      build_sort,
      build_layout,
      build_header.
    interfaces if_oo_adt_classrun.

  protected section.
  private section.
    data:
      fieldcat    type   slis_t_fieldcat_alv,  "字段清单内表
      fieldcat_ln like   line of fieldcat,
      layout      type slis_layout_alv,              "ALV格式
      sortcat     type   slis_t_sortinfo_alv,   "ALV排序字段清单内表
      sortcat_ln  like   line of sortcat,
      eventcat    type   slis_t_event,            "ALV事件
      eventcat_ln like   line of eventcat.
    data: col_pos type i.
endclass.



class zshow_alv implementation.

  method class_constructor.
    type-pools: slis.
  endmethod.
  method build_fieldcat.
*    fieldcat_ln-ref_tabname  =  ''.
*    fieldcat_ln-ref_fieldname = 'mandt'.
    fieldcat_ln-seltext_m = '显示mandt'.
    fieldcat_ln-fieldname     =  'mandt'.
    fieldcat_ln-key             = 'X'.
    fieldcat_ln-col_pos  = '1'.
    fieldcat_ln-outputlen = '20'.
    append  fieldcat_ln  to fieldcat.

    fieldcat_ln-ref_tabname  =  'uuid'.
    fieldcat_ln-fieldname     =  'uuid'.
    fieldcat_ln-seltext_m     =  'uuid'.
    fieldcat_ln-key             = 'X'.
    fieldcat_ln-do_sum         = space.
    fieldcat_ln-no_out        = space.
    fieldcat_ln-qfieldname   = space.
    fieldcat_ln-hotspot       = 'X'.
    append  fieldcat_ln  to fieldcat.

    fieldcat_ln-ref_tabname  =  'desc1'.
    fieldcat_ln-fieldname     =  'desc1'.
    fieldcat_ln-seltext_m     =  '显示desc1'.
    fieldcat_ln-key             = 'X'.
    fieldcat_ln-do_sum         = space.
    fieldcat_ln-no_out        = space.
    fieldcat_ln-qfieldname   = space.
    fieldcat_ln-hotspot       = 'X'.
    append  fieldcat_ln  to fieldcat.

    fieldcat_ln-ref_tabname  =  'desc2'.
    fieldcat_ln-fieldname     =  'desc2'.
    fieldcat_ln-seltext_m     =  '显示desc2'.
    fieldcat_ln-key             = 'X'.
    fieldcat_ln-do_sum         = space.
    fieldcat_ln-no_out        = space.
    fieldcat_ln-qfieldname   = space.
    fieldcat_ln-hotspot       = 'X'.
    append  fieldcat_ln  to fieldcat.

    fieldcat_ln-ref_tabname  =  'createdate'.
    fieldcat_ln-fieldname     =  'createdate'.
    fieldcat_ln-seltext_m     =  '显示createdate'.
    fieldcat_ln-key             = 'X'.
    fieldcat_ln-do_sum         = space.
    fieldcat_ln-no_out        = space.
    fieldcat_ln-qfieldname   = space.
    fieldcat_ln-hotspot       = 'X'.
    append  fieldcat_ln  to fieldcat.

    fieldcat_ln-ref_tabname  =  'creater'.
    fieldcat_ln-fieldname     =  'creater'.
    fieldcat_ln-seltext_m     =  '显示creater'.
    fieldcat_ln-key            = 'X'.
    fieldcat_ln-do_sum         = space.
    fieldcat_ln-no_out        = space.
    fieldcat_ln-qfieldname   = space.
    fieldcat_ln-hotspot       = 'X'.
    append  fieldcat_ln  to fieldcat.

    fieldcat_ln-ref_tabname  =  'age'.
    fieldcat_ln-fieldname     =  'age'.
    fieldcat_ln-seltext_m     =  '显示age'.
    fieldcat_ln-key             = 'X'.
    fieldcat_ln-do_sum         = space.
    fieldcat_ln-no_out        = space.
    fieldcat_ln-qfieldname   = space.
    fieldcat_ln-hotspot       = 'X'.
    fieldcat_ln-edit = 'X'."是否可以编辑
    fieldcat_ln-fix_column = 'X'.
    append  fieldcat_ln  to fieldcat.

    fieldcat_ln-fieldname = 'VRKME'.
    fieldcat_ln-col_pos  = '2'.
    fieldcat_ln-key = 'X'.
    fieldcat_ln-outputlen = '20'.
    fieldcat_ln-seltext_m = 'VRKME'.
    append fieldcat_ln to fieldcat.
  endmethod.

  method build_layout.
    layout-zebra                = 'X'.    "呈现颜色交替
    layout-detail_popup         = 'X'.    "是否弹出详细信息窗口
    layout-f2code               = '&ETA'. "设置触发弹出详细信息窗口的功能码，这里是双击
    layout-no_vline             = 'X'.    "这个用来设置列间隔线
    layout-colwidth_optimize    = 'X'.    "优化列宽选项是否设置
    layout-detail_initial_lines = 'X'.
    layout-detail_titlebar      = '详细内容'."设置弹出窗口的标题栏
  endmethod.

  method build_sort.

  endmethod.

  method showalv.
    write / '当前程序名:' && sy-repid.
    write / '调用该程序的程序名:' && sy-cprog.

    select  *  from ztab1 into table @data(ivbap).
    build_fieldcat( ).
    build_layout( ).
    build_sort( ).
    eventcat_ln-name  =  'TOP_OF_PAGE'.
    eventcat_ln-form  =  'PAGEPPEADER'.
    append  eventcat_ln  to  eventcat.
    call function 'REUSE_ALV_GRID_DISPLAY'
      exporting
        i_callback_program      = sy-repid
*       i_callback_pf_status_set = 'SET_STATUS'
        i_callback_user_command = 'USER_COMMAND'
        is_layout               = layout
        it_fieldcat             = fieldcat
        it_sort                 = sortcat
        i_save                  = 'A'
        i_callback_top_of_page  = 'build_header'
*       it_event                = eventcat
*       i_interface_check       = space
*       i_bypassing_buffer      = space
*       i_buffer_active         = space
*       i_callback_program      = space
*       i_callback_pf_status_set    = space
*       i_callback_user_command = space
*       i_callback_top_of_page  = space
*       i_callback_html_top_of_page = space
*       i_callback_html_end_of_list = space
*       i_structure_name        =
*       i_background_id         =
*       i_grid_title            =
*       i_grid_settings         =
*       is_layout               =
*       it_fieldcat             =
*       it_excluding            =
*       it_special_groups       =
*       it_sort                 =
*       it_filter               =
*       is_sel_hide             =
*       i_default               = 'X'
*       i_save                  = space
*       is_variant              =
*       it_events               =
*       it_event_exit           =
*       is_print                =
*       is_reprep_id            =
*       i_screen_start_column   = 0
*       i_screen_start_line     = 0
*       i_screen_end_column     = 0
*       i_screen_end_line       = 0
*       i_html_height_top       = 0
*       i_html_height_end       = 0
*       it_alv_graphics         =
*       it_hyperlink            =
*       it_add_fieldcat         =
*       it_except_qinfo         =
*       ir_salv_fullscreen_adapter  =
*       o_previous_sral_handler =
*      importing
*       e_exit_caused_by_caller =
*       es_exit_caused_by_user  =
      tables
        t_outtab                = ivbap
*      exceptions
*       program_error           = 1
*       others                  = 2
      .
    if sy-subrc <> 0.
*     message id sy-msgid type sy-msgty number sy-msgno
*       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endmethod.

  method build_header.
    data: gs_layout type slis_layout_alv,     "布局
          lv_datum  type char10,
          lv_uzeit  type char10.
    data  gt_listheader type slis_t_listheader.   "标题列
    data: ls_listheader type slis_listheader.
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
  endmethod.

  method if_oo_adt_classrun~main.
    out->write(
      exporting
        data = 'xxxxxxxxxxxxxxx'
    ).
  endmethod.

endclass.
