*&---------------------------------------------------------------------*
*& Report z_test_file_template
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_file_template.

tables ekpo.

tables sscrfields.

parameters: p_file like rlgrap-filename." obligatory.
selection-screen function key 1.           "第一个按钮


initialization.
  sscrfields-functxt_01 = '模板下载'.      "定义第一个按钮文本
  sscrfields-from_text = 'sdaaaaaaaaaaa'.
  sscrfields-to_text = 'sdaaaaaaaaaaa'.

** 给p_file绑定事件
at selection-screen on value-request for p_file.
  perform frm_selectfile changing p_file.  "文件上传处理的FROM

at selection-screen.
** 按钮命令事件处理  按钮功能
  case sscrfields-ucomm.
    when 'FC01'.
      perform frm_temp_download.           "模板下载处理的FROM
  endcase.

start-of-selection.
  if p_file ne ''.
    perform frm_get_data_file.            "文件内容处理的FROM
  else.
    message '请先上传文件' type 'S' display like 'E'.
  endif.

form frm_selectfile changing cv_selfile like rlgrap-filename.
  data: lv_rc        type i,
        lt_filetable type filetable.

  data lv_file_filter type string.
  data lv_window_title type string.

  lv_window_title = '请选择导入Excel文件'."'请选择导入Excel文件'
  lv_file_filter = 'Excel(*.XLSX)|*.XLSX|全部文件 (*.*)|*.*|'."'Excel(*.XLSX)|*.XLSX|全部文件 (*.*)|*.*|'

  call method cl_gui_frontend_services=>file_open_dialog
    exporting
      window_title            = lv_window_title
      file_filter             = lv_file_filter
      multiselection          = space
    changing
      file_table              = lt_filetable
      rc                      = lv_rc
    exceptions
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5.
  if sy-subrc <> 0.
    message '文件上传失败' type 'E'.
  endif.
endform.                    "SELECT_FILE
form frm_temp_download .
  data: ls_wwwdatatab     like wwwdatatab,
        lt_mime           like w3mime occurs 10,
        lv_filename       type string,
        lv_path           type string,
        lv_fullpath       type string,
        window_title      type string,
        default_file_name type string.
  data: lv_destination type rlgrap-filename,
        lv_subrc       type sy-subrc.
  clear: ls_wwwdatatab,lt_mime[],lv_filename,lv_path,lv_fullpath,window_title,default_file_name.
  clear: lv_destination,lv_subrc.
  ls_wwwdatatab-relid = 'MI'.
  ls_wwwdatatab-objid = 'Z_TEST_EBAN'.                        "这里写入TCODE:SMW0上传的对象
  ls_wwwdatatab-text  = 'XXXX模板关系（ZACE06）'.
  window_title = '下载导入模板'.
  default_file_name = 'XXXX模板关系（ZACE06）'.

  call function 'WWWDATA_IMPORT'                          "#EC *
    exporting
      key               = ls_wwwdatatab
    tables
      mime              = lt_mime
    exceptions
      wrong_object_type = 1
      import_error      = 2
      others            = 3.
  call method cl_gui_frontend_services=>file_save_dialog
    exporting
      window_title         = window_title
      default_extension    = 'xlsx'
      default_file_name    = default_file_name
    changing
      filename             = lv_filename
      path                 = lv_path
      fullpath             = lv_fullpath
    exceptions
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      others               = 4.
  if sy-subrc <> 0.
    stop.
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
endform.
form frm_get_data_file .
  data: lt_raw type truxs_t_text_data.
  types: begin of ty_datatab,
           fd01 type string,    "存放第一列数据的字段
           fd02 type string,    "存放第二列数据的字段
           fd03 type string,    "存放第三列数据的字段
           fd04 type string,    "存放第四列数据的字段
         end of ty_datatab.
  data lt_datatab type table of ty_datatab.
  data lw_datatab type ty_datatab.
  refresh: lt_datatab[],lt_raw[].
** 调用函数将Excel内容保存到内表
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
    stop.
  endif.
  loop at lt_datatab into lw_datatab.
  endloop.
endform.
