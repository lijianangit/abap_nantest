*&---------------------------------------------------------------------*
*& Report z250517
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250517.


*type pools for alv declarations
TYPE-POOLS: slis. " 引入ALV类型池

*structure declaration for tstc table
TYPES: BEGIN OF ty_tstc, " 定义TSTC表的结构
        tcode TYPE tcode, " 事务代码
        pgmna TYPE program_id, " 程序名称
        dypno TYPE dynpronr, " 屏幕编号
        END OF ty_tstc. " 结束结构定义

* Internal table and workarea declarations for tstc
DATA: it_tstc TYPE STANDARD TABLE OF ty_tstc, " 内部表声明
      wa_tstc TYPE ty_tstc. " 工作区声明

*data declarations for ALV
DATA: it_layout TYPE slis_layout_alv, " ALV布局数据类型
      wa_fieldcat TYPE slis_fieldcat_alv, " 字段目录数据类型
      it_fieldcat TYPE slis_t_fieldcat_alv, " 字段目录表类型
      it_eventexit TYPE slis_t_event_exit, " 事件退出数据类型
      wa_eventexit TYPE slis_event_exit. " 事件退出工作区类型

*initialisation event
INITIALIZATION. " 初始化事件
*start of selection event
START-OF-SELECTION. " 开始选择事件

*subroutine to fetch data from the db table
PERFORM fetch_data. " 执行数据获取子程序

*subroutine for output display
PERFORM alv_output. " 执行ALV输出子程序

*&---------------------------------------------------------------------*
*&      Form  fetch_data
*&---------------------------------------------------------------------*
*       *subroutine to fetch data from the db table
*----------------------------------------------------------------------*
FORM fetch_data.
*Internal table and work area declaratin for TSTC (local tables)
DATA : lt_tstc TYPE STANDARD TABLE OF ty_tstc, " 内部表声明
         ls_tstc TYPE ty_tstc. " 工作区声明

*Static field definition
*Reads the last tcode and stores it in l_tstc that on refresh further data
*beyond this value is fetched
STATICS l_tstc TYPE tcode. " 静态字段声明

* Selection from the tstc table
*we select till 25 rows and on further refresh next 25 are selected
*we select transactions having screen numbers only
SELECT tcode
       pgmna
       dypno
       FROM tstc
       INTO CORRESPONDING FIELDS OF TABLE lt_tstc
       UP TO 25 ROWS
       WHERE tcode GT l_tstc " 选择大于l_tstc的tcode
       AND tcode  LIKE 'M%' " 选择以'M'开头的tcode
       AND dypno NE '0000'. " 排除屏幕编号为'0000'的记录

* Code for transferring the values of local table to output table
* for 25 rows as sy-tfill is 25.
*In case there are no records a message pops up.
IF sy-subrc EQ 0. " 如果没有错误
    DESCRIBE TABLE it_tstc. " 获取内部表的描述
    READ TABLE lt_tstc INTO ls_tstc INDEX sy-tfill. " 读取最后一行数据
    l_tstc = ls_tstc-tcode. " 更新l_tstc为最后一行的tcode
    it_tstc[] = lt_tstc[]. " 将数据赋值给输出表
ELSE. " 如果有错误
    MESSAGE 'No Records found ' TYPE 'i'. " 显示错误消息
ENDIF.
ENDFORM. " 读取数据子程序结束

*&---------------------------------------------------------------------*
*&      Form  alv_output
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_output.
*subroutine to refresh alv
PERFORM event_exits. " 执行事件退出子程序
*field catalogue
PERFORM build_fieldcat. " 执行字段目录子程序
*Layout for alv
PERFORM build_layout. " 执行布局子程序
*output display
PERFORM alv_display. " 执行ALV显示子程序
ENDFORM. " ALV输出子程序结束

*&---------------------------------------------------------------------*
*&      Form  event_exits
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*subroutine to refresh alv
FORM event_exits.
CLEAR wa_eventexit. " 清除事件退出工作区
wa_eventexit-ucomm = '&REFRESH'. " 设置刷新命令
wa_eventexit-after = 'X'. " 设置事件退出条件
APPEND wa_eventexit TO it_eventexit. " 将事件退出添加到列表
ENDFORM. " 事件退出子程序结束

*&---------------------------------------------------------------------*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*Field catalogue
FORM build_fieldcat.
CLEAR wa_fieldcat. " 清除字段目录工作区
wa_fieldcat-row_pos = '1'. " 设置行位置
wa_fieldcat-col_pos = '1'. " 设置列位置
wa_fieldcat-fieldname = 'TCODE'. " 设置字段名
wa_fieldcat-tabname = 'it_tstc'. " 设置表名
wa_fieldcat-seltext_m = 'TRANSACTION'. " 设置选择文本
APPEND wa_fieldcat TO it_fieldcat. " 将字段目录添加到列表

CLEAR wa_fieldcat. " 清除字段目录工作区
wa_fieldcat-row_pos = '1'. " 设置行位置
wa_fieldcat-col_pos = '2'. " 设置列位置
wa_fieldcat-fieldname = 'PGMNA'. " 设置字段名
wa_fieldcat-tabname = 'it_tstc'. " 设置表名
wa_fieldcat-seltext_m = 'PROGRAM'. " 设置选择文本
APPEND wa_fieldcat TO it_fieldcat. " 将字段目录添加到列表

CLEAR wa_fieldcat. " 清除字段目录工作区
wa_fieldcat-row_pos = '1'. " 设置行位置
wa_fieldcat-col_pos = '3'. " 设置列位置
wa_fieldcat-fieldname = 'DYPNO'. " 设置字段名
wa_fieldcat-tabname = 'it_tstc'. " 设置表名
wa_fieldcat-seltext_m = 'SCREEN'. " 设置选择文本
APPEND wa_fieldcat TO it_fieldcat. " 将字段目录添加到列表
ENDFORM. " 构建字段目录子程序结束

*&---------------------------------------------------------------------*
*&      Form  build_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*Layout
FORM build_layout.
it_layout-zebra = 'X'. " 设置斑马线效果
it_layout-colwidth_optimize = 'X'. " 设置列宽优化
ENDFORM. " 构建布局子程序结束

*&---------------------------------------------------------------------*
*&      Form  alv_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*ALV output
FORM alv_display.
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid " 当前程序ID
    i_callback_user_command = 'USER_COMMAND' " 用户命令回调
    i_callback_pf_status_set = 'PFSTATUS' " 状态设置回调
    it_fieldcat = it_fieldcat " 字段目录
    is_layout = it_layout " 布局
    it_event_exit = it_eventexit " 事件退出
    i_screen_start_column = 10 " 屏幕开始列
    i_screen_start_line = 20 " 屏幕开始行
    i_screen_end_column = 70 " 屏幕结束列
    i_screen_end_line = 45 " 屏幕结束行
    i_grid_title = 'Call Tcode Refresh ALV' " 网格标题
  TABLES
    t_outtab = it_tstc. " 输出表
ENDFORM. " ALV显示子程序结束

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*User actions on ALV
FORM user_command USING r_ucomm TYPE sy-ucomm " 用户命令
                        rs_selfield TYPE slis_selfield.
  CASE r_ucomm. " 根据用户命令进行操作
*User clicks a transaction code and that tcode is called from ALV
    WHEN '&IC1'.
      READ TABLE it_tstc INDEX rs_selfield-tabindex INTO wa_tstc. " 读取用户点击的行数据
      IF sy-subrc = 0. " 如果读取成功
        CALL TRANSACTION wa_tstc-tcode. " 调用事务代码
      ENDIF.
*user clicks the refresh button and the next 25 records are displayed
    WHEN '&REFRESH'.
      PERFORM fetch_data. " 执行数据获取子程序
      rs_selfield-refresh = 'X'. " 设置刷新标志
      rs_selfield-col_stable = 'X'. " 设置列稳定标志
      rs_selfield-row_stable = 'X' ." 设置行稳定标志

 ENDCASE.
ENDFORM. " 用户命令处理子程序结束

*&---------------------------------------------------------------------*
*&      Form  pfstatus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*Form for settings the pf status to the alv
FORM pfstatus USING ut_extab TYPE slis_t_extab.
 SET PF-STATUS 'STANDARD_FULLSCREEN' OF PROGRAM 'SAPLKKBL'. " 设置PF状态为标准全屏
ENDFORM. " 设置PF状态子程序结束
