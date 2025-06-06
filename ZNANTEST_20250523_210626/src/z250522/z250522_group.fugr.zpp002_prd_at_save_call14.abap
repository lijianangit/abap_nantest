FUNCTION ZPP002_PRD_AT_SAVE_CALL14.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IS_HEADER_DIALOG) TYPE  CAUFVD
*"  EXCEPTIONS
*"      ERROR_WITH_MESSAGE
*"----------------------------------------------------------------------

  DATA:lt_resb TYPE TABLE OF resbdget.

  SELECT SINGLE * INTO @DATA(ls_010) FROM zcat0010 WHERE bukrs  = @is_header_dialog-bukrs
                                                     AND werks  = @is_header_dialog-werks
                                                     AND zbz    = 'ZPP002_PRD_AT_SAVE_CALL14'
                                                     AND sign   = '+'
                                                     AND active =  @abap_true.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CALL FUNCTION 'CO_BC_RESBD_OF_ORDER_GET'
    EXPORTING
      aufnr_act      = is_header_dialog-aufnr
      check_vbkz_del = ''
    TABLES
      resbd_get      = lt_resb.

  CHECK lt_resb[] IS NOT INITIAL.

  SELECT matnr,bwkey,bklas
    INTO TABLE @DATA(lt_mbew)
    FROM mbew
    FOR ALL ENTRIES IN @lt_resb
    WHERE matnr = @lt_resb-matnr
    AND   bwkey = @is_header_dialog-werks .
  IF sy-subrc  EQ 0.
    SORT lt_mbew BY matnr bwkey.

    SELECT * INTO TABLE @DATA(lt_0146)
      FROM zppt0146
      FOR ALL ENTRIES IN @lt_mbew
      WHERE bklas = @lt_mbew-bklas
      AND   werks = @lt_mbew-bwkey.
    IF sy-subrc EQ 0.
      SORT lt_0146 BY dwerks bklas.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

  LOOP AT lt_resb INTO DATA(ls_resb).
    READ TABLE lt_mbew INTO DATA(ls_mbew) WITH KEY matnr = ls_resb-matnr
                                                   bwkey = is_header_dialog-werks
                                                   BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE lt_0146 WITH KEY werks = is_header_dialog-werks
                                  bklas = ls_mbew-bklas
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        READ TABLE lt_0146 WITH KEY dwerks = ls_resb-werks
                                    bklas  = ls_mbew-bklas
                                    TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          DATA(lv_mess) = |物料号{ ls_resb-matnr } 发料工厂维护错误！ |.
          MESSAGE e000(zpp) WITH lv_mess RAISING error_with_message.
        ELSE.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
