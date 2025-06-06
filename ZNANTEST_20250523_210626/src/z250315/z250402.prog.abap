*&---------------------------------------------------------------------*
*& Report z250402
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250402.

parameters: path type string obligatory.
data: file_content_lines_bin type standard table of string,
      file_content_line_bin  type raw255,
      file_length            type int4,
      file_content_x         type string.

at selection-screen on value-request for path.
  data filetable    type filetable.
  data selectedfile like line of filetable.
  data result       type int4.

  cl_gui_frontend_services=>file_open_dialog( exporting  window_title      = '选择上传文件'
                                                         initial_directory = 'C:\Code'
                                              changing   file_table        = filetable
                                                         rc                = result
                                              exceptions others            = 1 ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  read table filetable into selectedfile index 1."获取选择的文件名，这个支持多选
  path = selectedfile-filename.

start-of-selection.

  call method cl_gui_frontend_services=>gui_upload
    exporting
      filename     = path
      filetype     =  'ASC'
*      'BIN'"BIN代表二进制
      read_by_line = 'X'
    importing
      filelength   = file_length
    changing
      data_tab     = file_content_lines_bin
    exceptions
      others       = 1.
  if sy-subrc <> 0.
    write:/ 'error occurred'.
    return.
  endif.

  concatenate lines of file_content_lines_bin into file_content_x in character mode."把内部数据合并到变量中存着

  file_content_x = file_content_x(file_length).

  write: 'file uploaded: ', file_length, ' bytes'.
