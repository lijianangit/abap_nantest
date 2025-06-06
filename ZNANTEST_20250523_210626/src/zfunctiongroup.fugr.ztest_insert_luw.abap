FUNCTION ZTEST_INSERT_LUW.
*"----------------------------------------------------------------------
*"*"更新函数模块：
*"
*"*"本地接口：
*"  IMPORTING
*"     VALUE(TAB1) TYPE  ZNAN_GT_ZTESTLUW02 OPTIONAL
*"----------------------------------------------------------------------
 " You can use the template 'functionModuleParameter' to add here the signature!
.

    modify ztestluw02 from table tab1.

*    data type1  type znan_gt_ztestluw02.


*commit work."跟新程序里面不允许写commit work



endfunction.
