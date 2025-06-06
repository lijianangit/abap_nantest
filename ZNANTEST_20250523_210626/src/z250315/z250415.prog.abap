*&---------------------------------------------------------------------*
*& Report z250415
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250415.
"这种方式提示消息不会像E类型的消息那样会终止程序，提示完消息之后会继续执行程序
DATA: lt_msg TYPE rs_t_msg,
      ls_msg TYPE bal_s_msg.
DATA: lf_one_msg_as_sys_msg TYPE flag.
CLEAR ls_msg.
ls_msg-msgty = 'S'.
ls_msg-msgid = '00'.
ls_msg-msgno = '001'.
ls_msg-msgv1 = '消息1'.
ls_msg-msgv2 = '消息2'.
APPEND ls_msg TO lt_msg.
IF lt_msg IS NOT INITIAL.
  SORT lt_msg BY msgv1.
  DELETE ADJACENT DUPLICATES FROM lt_msg COMPARING msgv1.
  cl_epic_ui_services=>show_messages_with_alog(
  it_messages       = lt_msg
  iv_one_msg_direct = lf_one_msg_as_sys_msg ).
ENDIF.
