*&---------------------------------------------------------------------*
*& Report z_test_alv_grid_oop
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_alv_grid_oop.

initialization.

at selection-screen.

start-of-selection  .
  data Object1 type ref to zshow_alv.
  create object Object1 .
  data param1 type string value 'xxxxxxxx'.
  object1->showalv(
    exporting
      p1 = 'xxxxxxx'
  ).
end-of-selection.

top-of-page.

end-of-page.

form build_header.
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
endform..
