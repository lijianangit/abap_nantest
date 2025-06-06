FUNCTION ZTESTFUNCTION.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(IM_P1) TYPE  STRING OPTIONAL
*"     VALUE(IM_P2) TYPE  STRING DEFAULT 'defaultValue'
*"  EXPORTING
*"     VALUE(EX_P1) TYPE  STRING
*"  TABLES
*"      TABL STRUCTURE  EBAN OPTIONAL
*"  CHANGING
*"     REFERENCE(TAB2) TYPE  STANDARD TABLE
*"  RAISING
*"      CX_SY_ZERODIVIDE
*"     RESUMABLE(CX_SY_ASSIGN_CAST_ERROR)
*"----------------------------------------------------------------------

*输入参数：当Function 被调用时候，通过输入参数向Function传递变量或者数值若一个输入参数是可选的（Optional），则该参数可以不传递。
*输出参数：当Function 被调用时候，通过输出参数接受从Function 输出的数据输出参数始终是是可选的（Optional）。
*变更参数：通过变更参数向Function传递变量在Function中可以改变可更改参数的值，并且返回更改后的结果到程序中。
*     表：是通过内表进行参数传递,处理方式与更改参数一样;
*异常：处理Function 中可能发生错误的情况,调用程序检查是否发生了错误,然后采取相应的措施.

  data t1 type table of eban.

  ex_p1 = im_p1 && im_p2 .




endfunction.
