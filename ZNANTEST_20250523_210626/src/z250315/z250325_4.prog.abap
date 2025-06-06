*&---------------------------------------------------------------------*
*& Report z250325_4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250325_4.

data lo_http_client type ref to if_http_client.
data lv_html        type string.

cl_http_client=>create_by_destination( exporting destination = 'znantest_Http'
                                       importing client      = lo_http_client ).

lo_http_client->send( ).

lo_http_client->receive( ).

lv_html = lo_http_client->response->get_cdata( ).

DATA data_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.
append 'xxxxx' to data_tab.

call function 'GUI_DOWNLOAD'
  exporting
*   bin_filesize              =
    filename = 'c:\temp\1.html'
*   filetype = 'ASC'
*   append   = space
*   write_field_separator     = space
*   header   = '00'
*   trunc_trailing_blanks     = space
*   write_lf = 'X'
*   col_select                = space
*   col_select_mask           = space
*   dat_mode = space
*   confirm_overwrite         = space
*   no_auth_check             = space
*   codepage =
*   ignore_cerr               = abap_true
*   replacement               = '#'
*   write_bom                 = space
*   trunc_trailing_blanks_eol = 'X'
*   wk1_n_format              = space
*   wk1_n_size                = space
*   wk1_t_format              = space
*   wk1_t_size                = space
*   write_lf_after_last_line  = abap_true
*   show_transfer_status      = abap_true
*   virus_scan_profile        = '/SCET/GUI_DOWNLOAD'
*  importing
*   filelength                =
  tables
    data_tab = data_tab
*   fieldnames                =
*  exceptions
*   file_write_error          = 1
*   no_batch = 2
*   gui_refuse_filetransfer   = 3
*   invalid_type              = 4
*   no_authority              = 5
*   unknown_error             = 6
*   header_not_allowed        = 7
*   separator_not_allowed     = 8
*   filesize_not_allowed      = 9
*   header_too_long           = 10
*   dp_error_create           = 11
*   dp_error_send             = 12
*   dp_error_write            = 13
*   unknown_dp_error          = 14
*   access_denied             = 15
*   dp_out_of_memory          = 16
*   disk_full                 = 17
*   dp_timeout                = 18
*   file_not_found            = 19
*   dataprovider_exception    = 20
*   control_flush_error       = 21
*   others   = 22
  .
if sy-subrc <> 0.
* message id sy-msgid type sy-msgty number sy-msgno
*   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.
write lv_html.
