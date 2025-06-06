*&---------------------------------------------------------------------*
*& Report z_250329
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_250329.

*&---------------------------------------------------------------------*
*& Report z_test_file_template
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
include  z_250329_include_1.
tables ekpo.

selection-screen begin of block bk1 with frame title text-001.
  parameters p_file like rlgrap-filename modif id m1 default 'C:\Users\nan\Desktop\Z_250318_TAB_EXECL.xlsx'. " obligatory.
selection-screen end of block bk1.

" 人员选择条件
selection-screen begin of block bk2 with frame title text-002.
selection-screen end of block bk2.
selection-screen function key 1.           " 第一个按


initialization.
  tables sscrfields.
  sscrfields-functxt_01 = '模板下载'.      " 定义第一个按钮文本
  sscrfields-from_text  = '模板下载'.
  sscrfields-to_text    = '模板下载'.

** 给p_file绑定事件
at selection-screen on value-request for p_file.
  perform get_path changing p_file.  " 文件上传处理的FROM





at selection-screen output.
  " TODO: variable is assigned but never used (ABAP cleaner)
  data tab1 type table of screen.

  loop at screen.  " 遍历选择屏幕中的所有元素
    case 'X'.
      when group1.
        if screen-group1 = 'M1'. " 隐藏 MODIF ID = 'M2' 的屏幕元素
          screen-active = '1'.
        endif.
      when group2.
        if screen-group1 = 'M1'. " 隐藏 MODIF ID = 'M2' 的屏幕元素
          screen-active = '0'.
        endif.
      when group3.
        if screen-group1 = 'M1'. " 隐藏 MODIF ID = 'M2' 的屏幕元素
          screen-active = '0'.
        endif.
    endcase.
    append screen to tab1.

    modify screen.  " 保存更改
  endloop.


at selection-screen.
** 按钮命令事件处理  按钮功能
  case sscrfields-ucomm.
    when 'FC01'.
      perform frm_temp_download.           "模板下载处理的FROM
  endcase.

start-of-selection.
  if p_file <> '' and group1 = 'X'.
    perform frm_get_data_file using    p_file
                              changing lt_datatab.            " 文件内容处理的FROM
    perform remove_data tables lt_datatab.

*    perform valid_data tables lt_datatab.
*
*    " perform display_alv tables lt_datatab.
*    call screen 2000.

  else.
    message '请先上传文件' type 'S' display like 'E'.
  endif.
