*&---------------------------------------------------------------------*
*& Include zinclude1
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& 包含               ZMMR005_CLS
*&---------------------------------------------------------------------*

  class lcl_event_receiver  definition .  "定义类 捕捉各种事件
    public  section .

      methods handle_modify                    "数据改变
        for  event data_changed  of cl_gui_alv_grid
        importing er_data_changed .

      methods handle_click
        for event hotspot_click of cl_gui_alv_grid
        importing e_column_id es_row_no.


  endclass .                     "LCL_EVENT_RECEIVER DEFINITION

  class lcl_event_receiver  implementation .  "实现类 处理事件

* 界面修改事件
    method handle_modify  .
      perform frm_data_changed  using er_data_changed .
    endmethod .                     "HANDLE_MODIFY

    method handle_click.
      perform frm_hotspot_click using e_column_id es_row_no.
    endmethod.
  endclass .                     "LCL_EVENT_RECEIVER IMPLEMENTATION









*&---------------------------------------------------------------------*
*& 包含               ZMMR005_TOP
*&---------------------------------------------------------------------*
tables: zmmt0013,sscrfields.
  type-pools:slis.
  data gv_flag.
  data:begin of gs_out.
         include structure zmmt0013.
  data:    row like bapiret2-row.
  data: icon(4).
  data: message type string..
  data: messages type bapiret2_t.
  data: celltab type lvc_t_styl.
  data:end of gs_out.

  data: gt_lt_out like table of zmmt0013.
  data: gs_ls_out like zmmt0013.
  data: gt_out like table of gs_out.

  field-symbols: <gs_out> like line of gt_out.
  data: gt_out2 like table of zmmt0013.
  data: gs_fcat2 type lvc_s_fcat.
  data: gt_fieldcat type lvc_t_fcat.
  data: ok_code like sy-ucomm,
        save_ok like sy-ucomm.
  data: go_grid1  type ref to cl_gui_alv_grid.
  data:gv_container        type scrfname value 'BCALV_GRID_DEMO_0100_CONT1',
       go_custom_container type ref to cl_gui_custom_container.
  data:go_handler type ref to lcl_event_receiver.
  data:gs_layout type lvc_s_layo.
*虚拟字段用于消息处理
  data gv_dummy type bapi_msg.
**DATA gv_privilege TYPE c.
  "DATA gt_event_receiver  type  ref  to lcl_event_receiver.
  constants: cns_light_r(4) value '@0A@',  "红灯
             cns_light_g(4) value '@08@'.  "绿灯

  define macro_add_fieldcat.
    clear gs_fcat2.
    gs_fcat2-fieldname = &1.
    gs_fcat2-coltext = &2.
    gs_fcat2-outputlen = &3.
    gs_fcat2-edit = &4.
    gs_fcat2-hotspot = &5.
    append gs_fcat2 to gt_fieldcat.
  end-of-definition.

*将系统消息append到消息内表中
  define macro_add_message.
    call function 'HRIQ_APPEND_SYS_MESSAGE_TABLE'
    exporting
      iv_row = &1
      changing
        ct_return           = &2 .
  end-of-definition.
  "INCLUDE: zexcel_include,zalv_include_v1,zpop_message.






*----------------------------------------------------------------------*
***INCLUDE ZMMR005_MOD.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
  module pbo output.
    set pf-status 'PF_9005'.
    set titlebar 'TITLE_9005'.
    data : lv_stable type lvc_s_stbl.   "刷新稳定性
    lv_stable-row = '1'.
    lv_stable-col = '1'.

    if go_custom_container is initial.
      create object go_custom_container
        exporting
          container_name = gv_container.
      create object go_grid1
        exporting
          i_parent = go_custom_container.

      perform frm_init_style.
      gs_layout-stylefname = 'CELLTAB'.
      gs_layout-cwidth_opt = 'X'.

      call method go_grid1->set_ready_for_input
        exporting
          i_ready_for_input = 0.


      call method go_grid1->set_table_for_first_display
        exporting
          is_layout       = gs_layout
        changing
          it_fieldcatalog = gt_fieldcat
          it_outtab       = gt_out[].
    endif.

    create object go_handler.
    set handler go_handler->handle_modify for go_grid1.
    set handler go_handler->handle_click for go_grid1.

    call method go_grid1->register_edit_event
      exporting
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    call method go_grid1->refresh_table_display
      exporting
        is_stable = lv_stable.
  endmodule.
*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  module pai input.
    save_ok = ok_code.
    clear ok_code.
    case save_ok.
      when 'EXIT'.
        perform frm_exit_program.
*    WHEN 'SWITCH'.
*      PERFORM frm_switch_edit_mode.
      when 'POST'.
        perform frm_save_data.
      when others.
*     do nothing
    endcase.

  endmodule.



*&---------------------------------------------------------------------*
*& 包含               ZMMR005_SCR
*&---------------------------------------------------------------------*
  selection-screen: function key 1 .
  selection-screen begin of block blk_b01 with frame title text-001.
    parameters : pa_r1 radiobutton group g1 default 'X' user-command singleclick.

    parameters : pa_r2 radiobutton group g1  .

    parameters: pa_path type rlgrap-filename modif id m1 .
    parameters: pa_line1 type i default '3' modif id m1.

    parameters : pa_r3 radiobutton group g1  .
    select-options: so_matnr for zmmt0013-matnr.

  selection-screen end of block blk_b01.

  initialization.
    sscrfields-functxt_01 = '@49@下载模板'.

  at selection-screen output. "根据按钮屏蔽相反的输入块
    if pa_r2 = ''.
      loop at screen.
        if screen-group1 = 'M1'.
          screen-active = 0.
          modify screen.
        endif.

      endloop.
    elseif pa_r2 = 'X'.

      loop at screen.
        if screen-group1 = 'M1'.
          screen-active = 1.
          modify screen.
        endif.

      endloop.
    endif.

  at selection-screen.

    case sscrfields-ucomm.          "处理按钮命令
      when'FC01'.
        perform frm_download_template.

      when others.

    endcase.

  at selection-screen on value-request for pa_path.
    perform frm_file_f4_help using pa_path.



*&---------------------------------------------------------------------*
*& 包含               ZMMR005_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form frm_download_template
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_download_template .
    data: lv_file type rlgrap-filename.
    data: ls_wwwdatatab type wwwdatatab.

    "获取要下载的文件路径
    call function 'WS_FILENAME_GET'
      exporting
        def_filename     = '物料特许权使用费信息维护导入模板.xlsx'
        mode             = 'S'
      importing
        filename         = lv_file
      exceptions
        inv_winsys       = 1
        no_batch         = 2
        selection_cancel = 3
        selection_error  = 4
        others           = 5.
    if sy-subrc = 0.
      "获取文件信息
      select * into corresponding fields of ls_wwwdatatab from wwwdata
      where  relid eq 'MI' and objid eq 'ZMMR005'. "#EC CI_ALL_FIELDS_NEEDED
      endselect.
      "下载模板到指定路径
      call function 'DOWNLOAD_WEB_OBJECT'
        exporting
          key         = ls_wwwdatatab
          destination = lv_file.
    endif.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_file_f4_help
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PA_PATH
*&---------------------------------------------------------------------*
  form frm_file_f4_help  using  uv_filename like rlgrap-filename.
    call function 'KD_GET_FILENAME_ON_F4'
      changing
        file_name     = uv_filename
      exceptions
        mask_too_long = 1
        others        = 2.
    if sy-subrc <> 0.
      "MESSAGE e159.
    endif.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_import_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_import_data .
    data lt_intern type table of alsmex_tabline.
    data ls_intern type alsmex_tabline.

    call function 'SAPGUI_PROGRESS_INDICATOR'
      exporting
        text = '读取Excel...'.

    call function 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      exporting
        filename                = pa_path
        i_begin_col             = 2
        i_begin_row             = pa_line1
        i_end_col               = 255
        i_end_row               = 65535
      tables
        intern                  = lt_intern[]
      exceptions
        inconsistent_parameters = 1
        upload_ole              = 2
        others                  = 3.
*$---------------------------------------------$*
*  转换到输出内表
*$---------------------------------------------$*
    if not lt_intern[] is initial.
      clear gs_out.
      loop at lt_intern into ls_intern.
        case ls_intern-col.
          when '0001'.
            gs_out-matnr = ls_intern-value.
            translate gs_out-matnr to upper case.
          when '0002'.
            gs_out-zfzlf = ls_intern-value.  "是否需要支付专利费（是/否）
          when '0003'.
            gs_out-zflag = ls_intern-value. "单价是否已包含(是/否)
          when '0004'.
            gs_out-ztxpm = ls_intern-value.   "特许权使用费品名
          when '0005'.
            gs_out-flag = ls_intern-value.  "已停用标识
        endcase.

        at end of row.
          gs_out-mandt = sy-mandt.
          gs_out-row = ls_intern-row.
          append gs_out to gt_out.
          clear gs_out.
        endat.
      endloop.
    endif.


  endform.
*&---------------------------------------------------------------------*
*& Form frm_display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_display_data .
    clear gs_fcat2.
    clear gt_fieldcat[].
    perform frm_fill_fieldcat.
    call screen '9005'.
*  CLEAR gs_fcat2.
*  CLEAR gt_fieldcat[].
*  PERFORM frm_fill_fieldcat.
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
*    EXPORTING
*      i_callback_program       = sy-repid
*      i_callback_pf_status_set = 'FRM_ZMMR005_STATUS'
*      i_callback_user_command  = 'FRM_USER_COMMAND'
*      is_layout_lvc            = gs_layout
*      it_fieldcat_lvc          = gt_fieldcat[]
*    TABLES
*      t_outtab                 = gt_out[]
*    EXCEPTIONS
*      program_error            = 1.
  endform.

*&---------------------------------------------------------------------*
*&      Form  FRM_ZMMR005_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_EXTAB    text
*----------------------------------------------------------------------*
*FORM frm_zmmr005_status USING ut_extab TYPE slis_t_extab .
*
**        PERFORM EXCLUDE_FCODE. "要屏蔽的自定义按钮
*  SET PF-STATUS 'PF_0500'.
*
*ENDFORM.                    "ZS1002_STATUS

*FORM frm_user_command USING pa_ucomm LIKE sy-ucomm us_selfield TYPE slis_selfield.
*  us_selfield-refresh = 'X'.
*  DATA:lo_grid TYPE REF TO cl_gui_alv_grid.
*  DATA: lv_row TYPE i,
*        lv_col TYPE i.
*  DATA : lv_is_row_id    TYPE lvc_s_row,
*         lv_is_column_id TYPE lvc_s_col,
*         lv_is_row_no    TYPE lvc_s_roid.
*
*  IF lo_grid IS INITIAL.
*    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
*      IMPORTING
*        e_grid = lo_grid.
*  ENDIF.
*
**  CALL METHOD lo_grid->register_edit_event      "注册GRID事件
**    EXPORTING
**      i_event_id = cl_gui_alv_grid=>mc_evt_enter "事件：回车
**    EXCEPTIONS
**      error      = 1
**      OTHERS     = 2.
**  CREATE OBJECT gt_event_receiver.
**  SET  HANDLER gt_event_receiver->handle_modify FOR lo_grid .
*  CASE pa_ucomm.
*    WHEN 'BACK'.
*      SET SCREEN 0.
*    WHEN 'EXIT'.
*      SET SCREEN 0.
*    WHEN '&IC1'.
*      CALL METHOD lo_grid->get_current_cell
*        IMPORTING
*          e_row = lv_row
*          e_col = lv_col.
*      lv_is_row_id = lv_row.
*      lv_is_column_id = lv_col.
*      lv_is_row_no-row_id = lv_row.
*
*      CALL METHOD lo_grid->set_current_cell_via_id
*        EXPORTING
*          is_row_id    = lv_is_row_id           " Row No
*          is_column_id = lv_is_column_id        " Column No
*          is_row_no    = lv_is_row_no.          " Row No.
*    WHEN 'POST'. " 过账
*      IF pa_r2 = 'X'.
*        PERFORM frm_save_data.
*      ENDIF.
**      IF pa_r3 = 'X' .
**        MESSAGE s000 WITH TEXT-003 .
**
**      ENDIF.
*  ENDCASE.
*
*  CASE us_selfield-fieldname.
*    WHEN 'MESSAGE'.
*      READ TABLE gt_out[] INTO gs_out INDEX us_selfield-tabindex.
*      CHECK sy-subrc = 0.
*
*      IF gs_out-messages[] IS NOT INITIAL. "超链接详细消息
*        CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
*          TABLES
*            i_bapiret2_tab = gs_out-messages[].
*
*      ENDIF.
*      CLEAR gs_out.
*  ENDCASE.
*
*  IF NOT lo_grid IS INITIAL.
*    CALL METHOD lo_grid->check_changed_data.
*    CALL METHOD lo_grid->refresh_table_display.
*  ENDIF.
*
*
*ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form frm_read_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_read_data .
    select * from zmmt0013
      into corresponding fields of table gt_out2
      where matnr in so_matnr.                "#EC CI_ALL_FIELDS_NEEDED
  endform.
*&---------------------------------------------------------------------*
*& Form frm_fill_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_fill_fieldcat .
    macro_add_fieldcat: 'ROW' '序号' '' '' '' .
    macro_add_fieldcat: 'ICON' '信号灯' '' '' ''.
    macro_add_fieldcat: 'MESSAGE' '消息' '40' '' 'X'.
    macro_add_fieldcat: 'MATNR' '物料号' '20' 'X' ''.
    macro_add_fieldcat: 'ZFZLF' '是否需要支付专利费' '' 'X' ''.
    macro_add_fieldcat: 'ZFLAG' '单价是否已包含(是/否)' '' 'X' ''.
    macro_add_fieldcat: 'ZTXPM' '特许权使用费品名' '' 'X' ''.
    macro_add_fieldcat: 'FLAG' '已停用标识' '' 'X' ''.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_save_data .

    if gv_flag = ''.
      modify zmmt0013 from table gt_lt_out.
      if sy-subrc = 0.
        commit work.
        message s000 with text-008.
      else.
        rollback work.
        message s000 with text-009 display like 'E'.
      endif.
    else.
      message s000 with text-010 display like 'E'.
    endif.
    free gt_lt_out[].
  endform.
*&---------------------------------------------------------------------*
*& Form frm_display_data2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_display_data2 .
    clear gs_fcat2.
    clear gt_fieldcat[].
*  macro_add_fieldcat: 'ROW' '序号' '' '' '' .
    macro_add_fieldcat: 'MATNR' '物料号' '' '' ''.
    macro_add_fieldcat: 'ZFZLF' '是否需要支付专利费' '' '' ''.
    macro_add_fieldcat: 'ZFLAG' '单价是否已包含(是/否)' '' '' ''.
    macro_add_fieldcat: 'ZTXPM' '特许权使用费品名' '' '' ''.
    macro_add_fieldcat: 'FLAG' '已停用标识' '' '' ''.
    macro_add_fieldcat: 'AEDAT' '最后更改日期' '' '' ''.
    macro_add_fieldcat: 'CPUTM' '输入时间' '' '' ''.

    gs_layout-cwidth_opt = 'X'.
    call function 'REUSE_ALV_GRID_DISPLAY_LVC'
      exporting
        i_callback_program = sy-repid
        is_layout_lvc      = gs_layout
        it_fieldcat_lvc    = gt_fieldcat[]
      tables
        t_outtab           = gt_out2[]
      exceptions
        program_error      = 1.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
  form frm_data_changed  using  p_er_data_changed type ref to cl_alv_changed_data_protocol.
    data:lt_mod_data type lvc_t_modi,
         ls_mod_data type lvc_s_modi.
    lt_mod_data = p_er_data_changed->mt_mod_cells.
    loop at lt_mod_data into ls_mod_data.
      call method p_er_data_changed->modify_cell
        exporting
          i_row_id    = ls_mod_data-row_id
          i_fieldname = ls_mod_data-fieldname
          i_value     = ls_mod_data-value.
    endloop.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_init_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_init_style .
    data: lt_celltab type lvc_t_styl,
          lv_index   type i.
    loop at gt_out into gs_out.
      lv_index = sy-tabix.
      refresh lt_celltab.
      perform frm_fill_celltab changing lt_celltab.
      insert lines of lt_celltab into table gs_out-celltab.
      modify gt_out from gs_out index lv_index.
    endloop.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_fill_celltab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_CELLTAB
*&---------------------------------------------------------------------*
  form frm_fill_celltab  changing pt_celltab type lvc_t_styl.
    data: ls_celltab type lvc_s_styl.

    ls_celltab-fieldname = 'MATNR'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
    insert ls_celltab into table pt_celltab.

    ls_celltab-fieldname = 'ZFLAG'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
    insert ls_celltab into table pt_celltab.

    ls_celltab-fieldname = 'ZTXPM'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
    insert ls_celltab into table pt_celltab.

    ls_celltab-fieldname = 'ZFZLF'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
    insert ls_celltab into table pt_celltab.

    ls_celltab-fieldname = 'FLAG'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
    insert ls_celltab into table pt_celltab.

    ls_celltab-fieldname = 'ROW'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
    insert ls_celltab into table pt_celltab.

    ls_celltab-fieldname = 'ICON'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
    insert ls_celltab into table pt_celltab.

    ls_celltab-fieldname = 'MESSAGE'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
    insert ls_celltab into table pt_celltab.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_exit_program
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_exit_program .
    set screen 0.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_switch_edit_mode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_switch_edit_mode .
    if go_grid1->is_ready_for_input( ) eq 0.
* set edit enabled cells ready for input
      call method go_grid1->set_ready_for_input
        exporting
          i_ready_for_input = 1.

    else.
* lock edit enabled cells against input
      call method go_grid1->set_ready_for_input
        exporting
          i_ready_for_input = 0.
    endif.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
  form frm_hotspot_click  using
                                   us_e_column_id type lvc_s_col
                                    us_ROW_NO  type lvc_s_roid.

    read table gt_out into gs_out index us_ROW_NO-row_id.
    if sy-subrc = 0.
      if us_e_column_id-fieldname = 'MESSAGE'.
        data(lv_lines) = lines( gs_out-messages )..
        if lv_lines gt 1.
          call function 'C14ALD_BAPIRET2_SHOW'
            tables
              i_bapiret2_tab = gs_out-messages[].
        elseif lv_lines eq 1.
          read table gs_out-messages into data(lv_mess) index 1.
          message s000(zmm) with lv_mess-message display like 'E'.
        endif.
      endif.
    endif.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_process_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_process_data .
    clear gv_flag.
    loop at gt_out into gs_out.
      clear gs_ls_out.
      clear gs_out-messages[].

      select from zmmt0100 as a
        inner join @gt_out as b
        on a~ztxpm = b~ztxpm
        fields
         a~ztxpm
        into table @data(lt_txpm).

        sort lt_txpm[] by ztxpm.

*需要检查物料是否在MARA 中存在，必输项填写完成
        if gs_out-matnr is initial.
          message e000 with text-002 into gv_dummy.
          macro_add_message gs_out-row gs_out-messages[].
        else.
          call function 'MARA_SINGLE_READ'
            exporting
*             KZRFB             = ' '
*             MAXTZ             = 0
              matnr             = gs_out-matnr
*             SPERRMODUS        = ' '
*             STD_SPERRMODUS    = ' '
*             OUTPUT_NO_MESSAGE =
*       IMPORTING
*             WMARA             =
            exceptions
              lock_on_material  = 1
              lock_system_error = 2
              wrong_call        = 3
              not_found         = 4
              others            = 5.
          if sy-subrc <> 0.
            message e000 with text-007 into gv_dummy.
            macro_add_message gs_out-row gs_out-messages[].
          endif.

        endif.
        if gs_out-zfzlf is initial.
          message e000 with text-004 into gv_dummy.
          macro_add_message gs_out-row gs_out-messages[].
        endif.
        if gs_out-zflag is initial.
          message e000 with text-005 into gv_dummy.
          macro_add_message gs_out-row gs_out-messages[].
        endif.
        if gs_out-ztxpm is initial.
          message e000 with text-006 into gv_dummy.
          macro_add_message gs_out-row gs_out-messages[].
        else.
*Excel导入列-特许权使用费品名的数据，如果为“否”不校验，
*否则到ZMMT0100表查找，不在ZMMT0100表内则报错，需要区分大小写
          if gs_out-ztxpm = '否'.
          else.
            read table lt_txpm into data(ls_txpm)
                                       with key ztxpm = gs_out-ztxpm
                                       binary search.
            if sy-subrc eq 0.
            else.
              message e000 with text-013 into gv_dummy.
              macro_add_message gs_out-row gs_out-messages[].
            endif.
          endif.
        endif.
*红绿灯
        if line_exists( gs_out-messages[ type = 'E' ] ).
          gs_out-icon  = cns_light_r.
          gv_flag = 'X'.
        else.
          gs_out-icon  = cns_light_g.
        endif.

*消息
        gs_out-message
                    =  reduce string( init x type string
                                        for wa in gs_out-messages[]
                                        next x = x && ';' && wa-message ).
        shift gs_out-message left deleting leading ';'.

        gs_out-aedat = sy-datum.
        gs_out-cputm = sy-uzeit.
        modify gt_out from gs_out.
        move-corresponding gs_out to gs_ls_out.
        append gs_ls_out to gt_lt_out.
      endloop.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_maintain_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  form frm_maintain_data .
    call function 'VIEW_MAINTENANCE_CALL'
      exporting
        action               = 'S'
        show_selection_popup = ''
        view_name            = 'ZMMT0013'.
  endform.
*&---------------------------------------------------------------------*
*& Form frm_auth_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SY_TCODE
*&---------------------------------------------------------------------*
  form frm_auth_check using pa_privilege type c.
    data lv_errornum type i.
    case pa_privilege.
      when 'CM'. "创建或修改
        clear lv_errornum.
        authority-check object 'ZCA_TCD'
        id 'TCODE' field 'ZMMR005'
        id 'ACTVT' field '01'.
*      CALL FUNCTION 'AUTHORITY_CHECK'
*        EXPORTING
**         NEW_BUFFERING       = 3
*          user                = sy-uname
*          object              = 'ZCA_TCD'
*          field1              = 'TCODE'
*          value1              = 'ZMMR005'
*          field2              = 'ACTVT'
*          value2              = '01'
*        EXCEPTIONS
*          user_dont_exist     = 1
*          user_is_authorized  = 2
*          user_not_authorized = 3
*          user_is_locked      = 4
*          OTHERS              = 5.

        if sy-subrc <> 0.
          lv_errornum = lv_errornum + 1.
        endif.

        authority-check object 'ZCA_TCD'
        id 'TCODE' field 'ZMMR005'
        id 'ACTVT' field '02'.
*      CALL FUNCTION 'AUTHORITY_CHECK'
*        EXPORTING
**         NEW_BUFFERING       = 3
*          user                = sy-uname
*          object              = 'ZCA_TCD'
*          field1              = 'TCODE'
*          value1              = 'ZMMR005'
*          field2              = 'ACTVT'
*          value2              = '02'
*        EXCEPTIONS
*          user_dont_exist     = 1
*          user_is_authorized  = 2
*          user_not_authorized = 3
*          user_is_locked      = 4
*          OTHERS              = 5.

        if sy-subrc <> 0.
          lv_errornum = lv_errornum + 1.
        endif.

        if lv_errornum lt 2.
        else.
          message s000 with text-011 display like 'E'.
          stop.
        endif.

      when 'RD'.  "读取
        authority-check object 'ZCA_TCD'
        id 'TCODE' field 'ZMMR005'
        id 'ACTVT' field '03'.
*      CALL FUNCTION 'AUTHORITY_CHECK'
*        EXPORTING
**         NEW_BUFFERING       = 3
*          user                = sy-uname
*          object              = 'ZCA_TCD'
*          field1              = 'TCODE'
*          value1              = 'ZMMR005'
*          field2              = 'ACTVT'
*          value2              = '03'
*        EXCEPTIONS
*          user_dont_exist     = 1
*          user_is_authorized  = 2
*          user_not_authorized = 3
*          user_is_locked      = 4
*          OTHERS              = 5.

        if sy-subrc <> 0.
          message s000 with text-012 display like 'E'.
          stop.
        endif.

    endcase.
  endform.
