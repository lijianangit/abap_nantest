class z_rest_handler definition
  public
  final
  create public .

  public section.

    interfaces if_http_extension .

  protected section.
  private section.

    methods get
      importing
        !server type ref to if_http_server .
endclass.


class z_rest_handler implementation.

  method get.

    data: lt_fields       type tihttpnvp,
          s_carrid        type rseloption,
          s_connid        type rseloption,
          lv_content_type type string.
    data: ls_selopt type rsdsselopt.

    server->request->get_form_fields( changing fields = lt_fields ).
    if lt_fields is initial.

      server->response->set_status( code = 404 reason = '未查询到传入参数,请检查' ).
      return.
    endif.
    field-symbols: <fs> like line of lt_fields.

    loop at lt_fields assigning <fs>.
      translate <fs>-name to upper case.
      case <fs>-name.
        when 'CARRID'.
          clear ls_selopt.
          ls_selopt-sign = 'I'.
          ls_selopt-option = 'EQ'.
          ls_selopt-low = <fs>-value.
          append ls_selopt to s_CARRID.

        when 'CONNID'.
          clear ls_selopt.
          ls_selopt-sign = 'I'.
          ls_selopt-option = 'EQ'.
          ls_selopt-low = <fs>-value.
          append ls_selopt to s_CONNID.
      endcase.
    endloop.

    data: lt_data type table of spfli.
    select *
      from spfli
      into corresponding fields of table lt_data
      where carrid in s_CARRID
        and connid in s_CONNID.


    data: lv_str type string.
    call transformation id
source data = lt_data
result xml lv_str.
    server->response->set_cdata( lv_str ).

    server->response->set_status( code = 200 reason = 'OK' ).
    lv_content_type = 'application/json'.

    server->response->set_content_type( lv_content_type ).



  endmethod.
  method if_http_extension~handle_request.
    types: begin of ty_data,
             matnr type matnr,
             maktx type maktx,
           end of ty_data,
           begin of ty_mat,
             matnr type matnr,
           end of ty_mat.

    data: lt_data type table of ty_data,
          lt_mat  type table of ty_mat,
          ls_mat  type ty_mat.

    data: lr_mat  type range of matnr,
          lrs_mat like line of lr_mat.

    data: lt_form_fields   type tihttpnvp, "请求url参数 name-value的内表 表单数据
          lt_header_fields type tihttpnvp, "请求头部数据 name-value的内表 请求头
          lv_method        type string,    "请求类型
          lv_request       type string,    "请求json数据
          lv_response      type string.    "返回json数据

    data request type ref to if_http_request .
    request = server->request.
    "请求类型
    lv_method = server->request->get_method(  ).

    "请求url参数
    server->request->get_form_fields( changing fields = lt_form_fields ).

    "请求头部数据
    server->request->get_header_fields( changing fields = lt_header_fields ).

    "请求json数据
    lv_request = server->request->get_cdata( ).

    "json转abap
    /ui2/cl_json=>deserialize( exporting json = lv_request
                               changing  data = lt_mat ).

    "将内表数据转成range用作查询条件
    loop at lt_mat into ls_mat.
      lrs_mat-sign = 'I'.
      lrs_mat-option = 'EQ'.
      lrs_mat-low = ls_mat-matnr.
      append lrs_mat to lr_mat.
    endloop.

    case lv_method.
      when 'GET'.

        select matnr maktx into corresponding fields of table lt_data
               from makt
               up to 20 rows
               where spras = sy-langu
               and matnr in lr_mat.

        "abap转换json
        /ui2/cl_json=>serialize( exporting data   = lt_data
                                 receiving r_json = lv_response ).

        "返回json数据给调用端
        server->response->set_cdata( exporting data = lv_response ).

        "请求响应
        server->response->set_status( code = 200 reason = 'OK' ).

        server->response->set_content_type( content_type = 'application/json').

      when others.

        "如果不是get请求，则返回错误
        server->response->set_status( code = 405 reason = 'ERROR' ).

        server->response->set_content_type( content_type = 'application/json').

    endcase.



  endmethod.
endclass.
