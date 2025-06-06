*&---------------------------------------------------------------------*
*& Report z_select_screen
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_select_screen.
*&---------------------------------------------------------------------*
*& Report ZHUGELIANG02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*SAP内存读取
*DATA lv_data TYPE char4.
*GET PARAMETER ID 'T1' FIELD lv_table.
*WRITE lv_table.

*ABAP内存读取
DATA lv_data TYPE char5.
IMPORT lv_data FROM MEMORY ID 'P2'.
WRITE lv_data.

SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.
SELECTION-SCREEN FUNCTION KEY 3.
SELECTION-SCREEN FUNCTION KEY 4.
SELECTION-SCREEN FUNCTION KEY 5.

TABLES: ztstud, sscrfields, ztclas.

SELECTION-SCREEN COMMENT /1(20) TEXT-001.

PARAMETERS p_p2 RADIOBUTTON GROUP g1 USER-COMMAND flag.
PARAMETERS p_p3 RADIOBUTTON GROUP g1  .



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) TEXT-110 FOR FIELD s_stuid .
    SELECT-OPTIONS s_stuid FOR ztstud-stuid .   "学生学号
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) TEXT-111 FOR FIELD s_stuna MODIF ID q1.
    SELECT-OPTIONS s_stuna FOR ztstud-stuna MODIF ID q1. "学生姓名
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) TEXT-112 FOR FIELD s_stusx MODIF ID q1 .
    SELECT-OPTIONS s_stusx FOR ztstud-stusx MODIF ID q1.   "性别
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) TEXT-113 FOR FIELD s_stuag MODIF ID q1.
    SELECT-OPTIONS s_stuag FOR ztstud-stuag MODIF ID q1.   "年龄
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) TEXT-114 FOR FIELD s_stute MODIF ID q1.
    SELECT-OPTIONS s_stute FOR ztstud-stute MODIF ID q1.   "学生电话
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) TEXT-115 FOR FIELD s_claid MODIF ID q1.
    SELECT-OPTIONS s_claid FOR ztstud-claid MODIF ID q1.   "班级编号
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) TEXT-116 FOR FIELD s_clatx MODIF ID q1.
    SELECT-OPTIONS s_CLATX FOR ztclas-clatx MODIF ID q1.   "班级描述
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b1.
*--------------------------------------------------------------------*






*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 1 AS SUBSCREEN.
  PARAMETERS: p_p5 TYPE c LENGTH 10.
SELECTION-SCREEN END OF SCREEN 1.

SELECTION-SCREEN BEGIN OF SCREEN 2 AS SUBSCREEN.
  PARAMETERS: p_p6 TYPE c LENGTH 10.
SELECTION-SCREEN END OF SCREEN 2.

*定义页签
SELECTION-SCREEN BEGIN OF TABBED BLOCK zsan1 FOR 10 LINES.
  SELECTION-SCREEN: TAB (10) button1 USER-COMMAND push1,
  TAB (10) button2 USER-COMMAND push2.
SELECTION-SCREEN END OF BLOCK zsan1.


INITIALIZATION.

  PERFORM frm_init1_values.

FORM frm_init1_values.
*s_claid-sign = 'I'.
*s_claid-option = 'EQ'.
*s_claid-low = '115'.
*APPEND s_claid.
*
*s_stute-sign = 'I'.
*s_stute-option = 'NE'.
*s_stute-low = '114'.
*APPEND s_claid.

  sscrfields-functxt_01 = '@C9@t1'.
  sscrfields-functxt_02 = '@5B@t2'.
  sscrfields-functxt_03 = '@5C@t3'.
  sscrfields-functxt_04 = '@5D@t4'.
  sscrfields-functxt_05 = '@C9@t5'.

  button1 = '支付/发票'.
  button2 = '查询11'.

*设置页签初始子屏幕
  zsan1-prog = sy-cprog.
  zsan1-dynnr = '1'.

ENDFORM.

AT SELECTION-SCREEN.

  PERFORM frm_excude_bnt.


FORM frm_excude_bnt.
  IF sy-ucomm = 'PUSH1'. "页签支付/发票信息
    zsan1-dynnr = '1'.
  ELSEIF sy-ucomm = 'PUSH2'. "页签查询11信息
    zsan1-dynnr = '2'.
  ENDIF.
ENDFORM.


AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF p_p3 = ''.
      IF screen-group1 = 'Q1'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
