*&---------------------------------------------------------------------*
*& Report z250422_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250422_2.
call screen '1000'.

*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_1000 output.
set pf-status 'S001'.

  data(dock_container) = new cl_gui_docking_container(
*                                                       parent    =
                                                       repid     = sy-repid
                                                       dynnr     = '1000'
                                                       side      = cl_gui_docking_container=>dock_at_left
                                                       extension = 99999
*                                                       style     =
*                                                       lifetime  = lifetime_default
*                                                       caption   =
*                                                       metric    = 0
*                                                       ratio     =
*                                                       no_autodef_progid_dynnr =
*                                                       name      =
  ).
  data(html_view) = new cl_gui_html_viewer(
*    shellstyle               =
    parent                   = dock_container
*    lifetime                 = lifetime_default
*    saphtmlp                 =
*    uiflag                   =
*    end_session_with_browser = 0
*    name                     =
*    saphttp                  =
*    query_table_disabled     = ''
  ).
  html_view->show_url(
    exporting
      url                    = 'https://blog.csdn.net/Li958172829/article/details/139802559'
*      frame                  =
*      in_place               = ' X'
*    exceptions
*      cntl_error             = 1
*      cnht_error_not_allowed = 2
*      cnht_error_parameter   = 3
*      dp_error_general       = 4
*      others                 = 5
  ).
  if sy-subrc <> 0.
*   message id sy-msgid type sy-msgty number sy-msgno
*     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_1000 input.

endmodule.
