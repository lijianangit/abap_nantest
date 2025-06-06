*&---------------------------------------------------------------------*
*& Report z_test_log
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_log.

***********************************************************************
******************** SELECTION SCREEN *********************************
***********************************************************************
PARAMETERS:
  p_create  RADIOBUTTON GROUP par,
  p_disp    RADIOBUTTON GROUP par,
  p_delete  RADIOBUTTON GROUP par.
***********************************************************************
******************** CONSTANTS, TYPES, DATA ***************************
***********************************************************************
SET EXTENDED CHECK OFF.
INCLUDE sbal_constants.
SET EXTENDED CHECK ON.
TABLES:
  bal_indx.
CONSTANTS:
  const_example_object    TYPE bal_s_log-object    VALUE 'BCT1',
  const_example_extnumber TYPE bal_s_log-extnumber VALUE 'BAL_INDX',
  const_name_msg_ident(9) TYPE c                   VALUE 'MSG_IDENT'.
DATA:
  g_identifier(10)        TYPE n,
  g_lognumber             TYPE balhdr-lognumber.
* these are our own data we want to save with the application log:
DATA:
  g_my_header_data        TYPE bal_s_ex05 OCCURS 0 WITH HEADER LINE,
  BEGIN OF g_my_message_data OCCURS 0,
    identifier            LIKE g_identifier,
    t_my_data             TYPE bal_s_ex06 OCCURS 0,
  END OF g_my_message_data.

***********************************************************************
******************** MAIN PROGRAM *************************************
***********************************************************************
END-OF-SELECTION.

* create log
  IF NOT p_create IS INITIAL.
    PERFORM log_create.
  ENDIF.

* display log
  IF NOT p_disp IS INITIAL.
    PERFORM log_display.
  ENDIF.

* delete log
  IF NOT p_delete IS INITIAL.
    PERFORM log_delete.
  ENDIF.


***********************************************************************
************** FORMS FOR CREATION OF THE LOG *************************
***********************************************************************
*--------------------------------------------------------------------
* FORM log_create.
*--------------------------------------------------------------------
FORM log_create.
  DATA:
    l_log_handle TYPE balloghndl.

* create log header with information about the carriers and
* connection which are calculated in this transaction
  PERFORM log_header_create
            CHANGING
              l_log_handle.

* create the message
  PERFORM log_message_create
            USING
              l_log_handle.

* save the application log and our data
  PERFORM log_save
            USING
              l_log_handle.

ENDFORM.
*--------------------------------------------------------------------
* FORM log_header_create
*--------------------------------------------------------------------
FORM log_header_create
       CHANGING
         c_log_handle   TYPE balloghndl.

  DATA:
    l_s_log     TYPE bal_s_log.


* create log header data
  CLEAR l_s_log.
  l_s_log-object    = const_example_object.
  l_s_log-extnumber = const_example_extnumber.

* define callback routine
  l_s_log-params-callback-userexitp = sy-repid.
  l_s_log-params-callback-userexitf = 'CALLBACK_LOG_DETAIL'.
  l_s_log-params-callback-userexitt = const_callback_form.

* create the log header
  CALL FUNCTION 'BAL_LOG_CREATE'
       EXPORTING
            i_s_log      = l_s_log
       IMPORTING
            e_log_handle = c_log_handle
       EXCEPTIONS
            OTHERS       = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* we want to store some information in the log header
* to describe which carriers and flight were handled in this log
  g_my_header_data-carrid     = 'AB'.  "#EC NOTEXT
  g_my_header_data-txt_carrid = 'Airways AB'.           "#EC NOTEXT
  g_my_header_data-connid     = '0003'."#EC NOTEXT
  g_my_header_data-txt_connid = 'Hamburg - New York'(001).
  APPEND g_my_header_data.
  g_my_header_data-carrid     = 'XY'.  "#EC NOTEXT
  g_my_header_data-txt_carrid = 'XY Lines'.             "#EC NOTEXT
  g_my_header_data-connid     = '0002'."#EC NOTEXT
  g_my_header_data-txt_connid = 'Walldorf - Tokio'(002).
  APPEND g_my_header_data.
  g_my_header_data-carrid     = 'ZZ'.  "#EC NOTEXT
  g_my_header_data-txt_carrid = 'ZZ Wings'.             "#EC NOTEXT
  g_my_header_data-connid     = '0014'."#EC NOTEXT
  g_my_header_data-txt_connid = 'Paris - Frankfurt'(003).
  APPEND g_my_header_data.
ENDFORM.
*--------------------------------------------------------------------
* FORM log_message_create
*--------------------------------------------------------------------
FORM log_message_create
       USING
         i_log_handle   TYPE balloghndl.
  DATA:
    l_s_msg     TYPE bal_s_msg,
    l_s_par     TYPE bal_s_par,
    l_s_my_data TYPE bal_s_ex06.
* create a message
* 327(BL): "&1 customers were allowed to fly for free (see detail)"
  CLEAR l_s_msg.
  l_s_msg-msgty = 'E'.
  l_s_msg-msgid = 'BL'.
  l_s_msg-msgno = '327'.
  l_s_msg-msgv1 = '3'.
* define callback routine
  l_s_msg-params-callback-userexitp = sy-repid.
  l_s_msg-params-callback-userexitf = 'CALLBACK_MSG_DETAIL'.
  l_s_msg-params-callback-userexitt = const_callback_form.
* define an identifer. This is used to establish the link between
* the message and its additional data
  ADD 1 TO g_identifier.
* put his identifier into the parameters of the message
  l_s_par-parname = const_name_msg_ident.
  l_s_par-parvalue   = g_identifier.
  APPEND l_s_par TO l_s_msg-params-t_par.
* create the message
  CALL FUNCTION 'BAL_LOG_MSG_ADD'
       EXPORTING
            i_log_handle = i_log_handle
            i_s_msg      = l_s_msg
       EXCEPTIONS
            OTHERS       = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
* we want to store information for this message about the customers
* which were allowed to fly for free:
  g_my_message_data-identifier  = g_identifier.
  l_s_my_data-id          = '00000002'.
  l_s_my_data-txt_id      = 'Peter Smith'.          "#EC NOTEXT
  APPEND l_s_my_data TO g_my_message_data-t_my_data.
  l_s_my_data-id          = '00000013'.
  l_s_my_data-txt_id      = 'Paula Jones'.          "#EC NOTEXT
  APPEND l_s_my_data TO g_my_message_data-t_my_data.
  l_s_my_data-id          = '00001345'.
  l_s_my_data-txt_id      = 'Jane Meyer'.           "#EC NOTEXT
  APPEND l_s_my_data TO g_my_message_data-t_my_data.
  APPEND g_my_message_data.

ENDFORM.

*--------------------------------------------------------------------
* FORM log_save
*--------------------------------------------------------------------
FORM log_save
       USING
         i_log_handle    TYPE balloghndl.

  DATA:
    l_t_log_handle       TYPE bal_t_logh,
    l_s_new_lognumber    TYPE bal_s_lgnm,
    l_t_new_lognumbers   TYPE bal_t_lgnm.


* save this log
  INSERT i_log_handle INTO TABLE l_t_log_handle.
  CALL FUNCTION 'BAL_DB_SAVE'
       EXPORTING
            i_t_log_handle   = l_t_log_handle
       IMPORTING
            e_new_lognumbers = l_t_new_lognumbers
       EXCEPTIONS
            OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* find out the lognumber of this saved log
  READ TABLE l_t_new_lognumbers INTO l_s_new_lognumber
             WITH KEY log_handle = i_log_handle.
  CHECK sy-subrc = 0.
  g_lognumber = l_s_new_lognumber-lognumber.

* also save our own, complex data:
  EXPORT g_my_header_data g_my_message_data
         TO DATABASE bal_indx(al)
         ID g_lognumber.

ENDFORM.

***********************************************************************
************** FORMS FOR DISPLAY OF THE LOG **************************
***********************************************************************
*--------------------------------------------------------------------
* FORM log_display
*--------------------------------------------------------------------
FORM log_display.
  DATA:
    l_s_log_filter     TYPE bal_s_lfil,
    l_s_obj            TYPE bal_s_obj,
    l_s_extn           TYPE bal_s_extn,
    l_t_log_header     TYPE balhdr_t.

* create filter to search for this log on db
  CLEAR l_s_log_filter-object.
  CLEAR l_s_obj.
  l_s_obj-sign = 'I'.
  l_s_obj-option = 'EQ'.
  l_s_obj-low    = const_example_object.
  APPEND l_s_obj TO l_s_log_filter-object.
  CLEAR l_s_extn.
  l_s_extn-sign = 'I'.
  l_s_extn-option = 'EQ'.
  l_s_extn-low    = const_example_extnumber.
  APPEND l_s_extn TO l_s_log_filter-extnumber.

* search for this log
  CALL FUNCTION 'BAL_DB_SEARCH'
       EXPORTING
            i_s_log_filter = l_s_log_filter
       IMPORTING
            e_t_log_header = l_t_log_header
       EXCEPTIONS
            OTHERS         = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* load these messages into memory
  CALL FUNCTION 'BAL_DB_LOAD'
       EXPORTING
            i_t_log_header = l_t_log_header
       EXCEPTIONS
            OTHERS         = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* show this log:
* - we do not specify the display profile I_DISPLAY_PROFILE since
*   we want to use the standard profile
* - we do not specify any filter (like I_S_LOG_FILTER, ...,
*   I_T_MSG_HANDLE) since we want to display all messages available
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
*      EXPORTING
*           I_S_LOG_FILTER         =
*           I_T_LOG_CONTEXT_FILTER =
*           I_S_MSG_FILTER         =
*           I_T_MSG_CONTEXT_FILTER =
*           I_T_LOG_HANDLE         =
*           I_T_MSG_HANDLE         =
*           I_S_DISPLAY_PROFILE    =
       EXCEPTIONS
            OTHERS = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
*--------------------------------------------------------------------
* FORM CALLBACK_LOG_DETAIL
*--------------------------------------------------------------------
FORM callback_log_detail               "#EC CALLED
       TABLES
         i_params  STRUCTURE spar.
* load my specififc data from database
  PERFORM load_my_data
             TABLES
               i_params.
* display header data
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            i_structure_name      = 'BAL_S_EX05'
            i_screen_start_column = 1
            i_screen_start_line   = 1
            i_screen_end_column   = 80
            i_screen_end_line     = 10
       TABLES
            t_outtab              = g_my_header_data
       EXCEPTIONS
            OTHERS                = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*--------------------------------------------------------------------
* FORM CALLBACK_MSG_DETAIL
*--------------------------------------------------------------------
FORM callback_msg_detail               "#EC CALLED
       TABLES
         i_params     STRUCTURE spar.

  DATA:
    l_my_message_data TYPE bal_s_ex06 OCCURS 0.


* load my specififc data from database
  PERFORM load_my_data
             TABLES
               i_params.

* find out the identifier for this message
  READ TABLE i_params WITH KEY param = const_name_msg_ident.
  CHECK sy-subrc = 0.
  g_identifier = i_params-value.

* search for those entries which belong to thgis message
  READ TABLE g_my_message_data WITH KEY identifier = g_identifier.
  CHECK sy-subrc = 0.
  l_my_message_data = g_my_message_data-t_my_data.

* display header data
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            i_structure_name      = 'BAL_S_EX06'
            i_screen_start_column = 1
            i_screen_start_line   = 1
            i_screen_end_column   = 80
            i_screen_end_line     = 10
       TABLES
            t_outtab              = l_my_message_data
       EXCEPTIONS
            OTHERS                = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*--------------------------------------------------------------------
* FORM LOAD_MY_DATA
*--------------------------------------------------------------------
FORM load_my_data
       TABLES
         i_params  STRUCTURE spar.

  DATA:
    l_lognumber TYPE balhdr-lognumber.

* find out the log number of this log which is displayed
* (this number is automatically added by the display module)
  READ TABLE i_params WITH KEY param = bal_param_lognumber.
  IF sy-subrc = 0.
    l_lognumber = i_params-value.
  ENDIF.

* when number has changed, load these data
  IF g_lognumber NE l_lognumber.
    g_lognumber = l_lognumber.
    IMPORT g_my_header_data g_my_message_data
    FROM DATABASE bal_indx(al)
    ID g_lognumber.
    IF sy-subrc NE 0.
      CLEAR:
       g_my_header_data[],
       g_my_message_data[].
    ENDIF.
  ENDIF.

ENDFORM.

***********************************************************************
************** FORMS FOR DELETION OF THE LOG *************************
***********************************************************************
*--------------------------------------------------------------------
* FORM log_delete
*--------------------------------------------------------------------
FORM log_delete.
  DATA:
    l_s_log_filter     TYPE bal_s_lfil,
    l_s_obj            TYPE bal_s_obj,
    l_s_extn           TYPE bal_s_extn,
    l_t_log_header     TYPE balhdr_t.

* create filter to search for this log on db
  CLEAR l_s_log_filter-object.
  CLEAR l_s_obj.
  l_s_obj-sign = 'I'.
  l_s_obj-option = 'EQ'.
  l_s_obj-low    = const_example_object.
  APPEND l_s_obj TO l_s_log_filter-object.
  CLEAR l_s_extn.
  l_s_extn-sign = 'I'.
  l_s_extn-option = 'EQ'.
  l_s_extn-low    = const_example_extnumber.
  APPEND l_s_extn TO l_s_log_filter-extnumber.

* search for this log
  CALL FUNCTION 'BAL_DB_SEARCH'
       EXPORTING
            i_s_log_filter = l_s_log_filter
       IMPORTING
            e_t_log_header = l_t_log_header
       EXCEPTIONS
            OTHERS         = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* delete these logs
  CALL FUNCTION 'BAL_DB_DELETE'
       EXPORTING
            i_t_logs_to_delete = l_t_log_header
       EXCEPTIONS
            OTHERS             = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
