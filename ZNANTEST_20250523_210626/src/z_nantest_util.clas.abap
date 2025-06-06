class z_nantest_util definition
  public
  final
  create public .

  public section.
    types ty_table_of_z250510_tab_1 type table of z250510_tab_1 with default key.

    "! 下载模板文件
    "! @parameter template_name |模板文件的路径
    "! @parameter window_title | 弹窗title
    "! @parameter default_file_name |下载的默认文件名
    methods download_template importing template_name     type string
                                        window_title      type string
                                        default_file_name type string optional.

    methods upload_template importing p_file     type localfile
                            changing  lt_datatab type table.

    methods upload_template_v2
      importing pa_path   type rlgrap-filename optional
                begin_row type i               optional
                begin_col type i               optional
      exporting gt_out    type  any table.

    methods set_update
      importing iv_create type any optional
      changing  cs_data   type any optional.

    methods display_table
      changing
        result_tab type any optional.

    "! 把创建人,创建时间，修改人，修改时间的值进行填充
    "! @parameter tab1 | 需要填充数据的内表
    methods fill_table_file
      changing
        tab1 type standard table.

  protected section.
  private section.
endclass.



class z_nantest_util implementation.
  method download_template.
    data ls_wwwdatatab  type wwwdatatab.
    data lt_mime        type table of w3mime initial size 10.
    data lv_filename    type string.
    data lv_path        type string.
    data lv_fullpath    type string.
    data lv_destination type rlgrap-filename.
    data lv_subrc       type sy-subrc.

    clear lt_mime[].
    ls_wwwdatatab-relid = 'MI'.
    ls_wwwdatatab-objid = template_name.                        " 这里写入TCODE:SMW0上传的对象
    ls_wwwdatatab-text  = template_name.

    call function 'WWWDATA_IMPORT'                          "#EC *
      exporting
        key               = ls_wwwdatatab
      tables
        mime              = lt_mime
      exceptions
        wrong_object_type = 1
        import_error      = 2
        others            = 3.
    cl_gui_frontend_services=>file_save_dialog( exporting  window_title         = window_title
                                                           default_extension    = 'xlsx'
                                                           default_file_name    = default_file_name
                                                changing   filename             = lv_filename
                                                           path                 = lv_path
                                                           fullpath             = lv_fullpath
                                                exceptions cntl_error           = 1
                                                           error_no_gui         = 2
                                                           not_supported_by_gui = 3
                                                           others               = 4 ).
    if sy-subrc <> 0.
      return.
    endif.

    if lv_fullpath is not initial.
      lv_destination = lv_fullpath.
      call function 'DOWNLOAD_WEB_OBJECT'
        exporting
          key         = ls_wwwdatatab
          destination = lv_destination
        importing
          rc          = lv_subrc.
      if lv_subrc = 0.
        message '模板下载成功' type 'S'.
      else.
        message '模板下载失败' type 'E'.
      endif.
    endif.
  endmethod.

  method upLoad_template.
    data lt_raw type truxs_t_text_data.
    refresh: lt_datatab[],lt_raw[].
    " 调用函数将Excel内容保存到内表
    call function 'TEXT_CONVERT_XLS_TO_SAP'
      exporting
        i_line_header        = 'X'
        i_tab_raw_data       = lt_raw
        i_filename           = p_file
      tables
        i_tab_converted_data = lt_datatab
      exceptions
        conversion_failed    = 1
        others               = 2.
    if sy-subrc <> 0.
      message '获取文件数据失败' type 'I'.
      return.
    endif.
*    loop at lt_datatab assigning field-symbol(<line>). "
*      write <line>.
*    endloop.
  endmethod.

  method upLoad_template_v2.
    data lt_intern type table of alsmex_tabline.
    " data ls_intern       type alsmex_tabline.

    call function 'SAPGUI_PROGRESS_INDICATOR'
      exporting
        text = '读取Excel...'.

    call function 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      exporting
        filename                = pa_path
        i_begin_col             = begin_col
        i_begin_row             = begin_row
        i_end_col               = 255
        i_end_row               = 65535
      tables
        intern                  = lt_intern[]
      exceptions
        inconsistent_parameters = 1
        upload_ole              = 2
        others                  = 3.

    if lt_intern[] is initial.
      return.
    endif.

    gt_out = lt_intern.
    " catch cx_sy_struct_creation.

*    loop at lt_intern ASSIGNING field-symbol(<ls_intern>).
*      case ls_intern-col.
*        when '0001'.
*        <ls_intern>-matnr = ls_intern-value.
*          translate gs_out-matnr to upper case.
*        when '0002'.
*          gs_out-zfzlf = ls_intern-value.  " 是否需要支付专利费（是/否）
*        when '0003'.
*          gs_out-zflag = ls_intern-value. " 单价是否已包含(是/否)
*        when '0004'.
*          gs_out-ztxpm = ls_intern-value.   " 特许权使用费品名
*        when '0005'.
*          gs_out-flag = ls_intern-value.  " 已停用标识
*      endcase.
*      set_update( exporting iv_create = 'X'
*                  changing  cs_data   = gs_out ).
*      at end of row.
*        gs_out-client = sy-mandt.
*        " gs_out-row    = ls_intern-row.
*        append gs_out to gt_out.
*        clear gs_out.
*      endat.
*
*    endloop.
  endmethod.

  method set_update.
    " TODO: parameter IV_CREATE is only used in commented-out code (ABAP cleaner)

    field-symbols <lfs_value> type any.

    " 创建数据
    assign component 'ERNAM' of structure cs_data to <lfs_value>.
    <lfs_value> = sy-uname.
    unassign <lfs_value>.
    assign component 'ERDAT' of structure cs_data to <lfs_value>.
    <lfs_value> = sy-datum.
    unassign <lfs_value>.
    assign component 'ERZET' of structure cs_data to <lfs_value>.
    <lfs_value> = sy-uzeit.
*    if iv_create is not initial.
*      return.
*    endif.

    " 更改数据
    unassign <lfs_value>.
    assign component 'AENAM' of structure cs_data to <lfs_value>.
    <lfs_value> = sy-uname.
    unassign <lfs_value>.
    assign component 'AEDAT' of structure cs_data to <lfs_value>.
    <lfs_value> = sy-datum.
    unassign <lfs_value>.
    assign component 'AEZET' of structure cs_data to <lfs_value>.
    <lfs_value> = sy-uzeit.
    unassign <lfs_value>.

*        METHOD set_update.
*
*    FIELD-SYMBOLS:<lfs_value> TYPE any.
*
*    "创建数据
*    ASSIGN COMPONENT 'ERNAM' OF STRUCTURE cs_data TO <lfs_value>.
*    IF <lfs_value> IS ASSIGNED AND <lfs_value> IS INITIAL.
*      <lfs_value> = sy-uname.
*
*      UNASSIGN <lfs_value>.
*      ASSIGN COMPONENT 'ERDAT' OF STRUCTURE cs_data TO <lfs_value>.
*      IF <lfs_value> IS ASSIGNED.
*        <lfs_value> = sy-datum.
*      ENDIF.
*
*      UNASSIGN <lfs_value>.
*      ASSIGN COMPONENT 'ERZET' OF STRUCTURE cs_data TO <lfs_value>.
*      IF <lfs_value> IS ASSIGNED.
*        <lfs_value> = sy-uzeit.
*      ENDIF.
*    ENDIF.
*
*    CHECK iv_create IS INITIAL.
*
*    "更改数据
*    UNASSIGN <lfs_value>.
*    ASSIGN COMPONENT 'AENAM' OF STRUCTURE cs_data TO <lfs_value>.
*    IF <lfs_value> IS ASSIGNED.
*      <lfs_value> = sy-uname.
*    ENDIF.
*    UNASSIGN <lfs_value>.
*    ASSIGN COMPONENT 'AEDAT' OF STRUCTURE cs_data TO <lfs_value>.
*    IF <lfs_value> IS ASSIGNED.
*      <lfs_value> = sy-datum.
*    ENDIF.
*    UNASSIGN <lfs_value>.
*    ASSIGN COMPONENT 'AEZET' OF STRUCTURE cs_data TO <lfs_value>.
*    IF <lfs_value> IS ASSIGNED.
*      <lfs_value> = sy-uzeit.
*    ENDIF.
*  ENDMETHOD.
  endmethod.

  method display_table.
    cl_salv_table=>factory( importing r_salv_table = data(salv_table)
                            changing  t_table      = result_tab ).
    " 设置工具栏
    data(gr_functions) = salv_table->get_functions( ). " 获取功能列表
    gr_functions->set_all( abap_true ). " Activate All Generic ALV Functions，将激活所有的ALV内置通用按钮
    salv_table->display( ).
  endmethod.

  method fill_table_file.
    field-symbols <lfs_value> type any.
    "遍历传进来的内表
    loop at tab1 assigning field-symbol(<cs_data>).
      " 创建数据
      assign component 'ERNAM' of structure <cs_data> to <lfs_value>.
      if <lfs_value> is assigned and <lfs_value> is initial.
        <lfs_value> = sy-uname.

        unassign <lfs_value>.
        assign component 'ERDAT' of structure <cs_data> to <lfs_value>.
        if <lfs_value> is assigned.
          <lfs_value> = sy-datum.
        endif.

        unassign <lfs_value>.
        assign component 'ERZET' of structure <cs_data> to <lfs_value>.
        if <lfs_value> is assigned.
          <lfs_value> = sy-uzeit.
        endif.
      endif.

      " 更改数据
      unassign <lfs_value>.
      assign component 'AENAM' of structure <cs_data> to <lfs_value>.
      if <lfs_value> is assigned.
        <lfs_value> = sy-uname.
      endif.
      unassign <lfs_value>.
      assign component 'AEDAT' of structure <cs_data> to <lfs_value>.
      if <lfs_value> is assigned.
        <lfs_value> = sy-datum.
      endif.
      unassign <lfs_value>.
      assign component 'AEZET' of structure <cs_data> to <lfs_value>.
      if <lfs_value> is assigned.
        <lfs_value> = sy-uzeit.
      endif.
    endloop.
  endmethod.



endclass.
