*&---------------------------------------------------------------------*
*& Report z_test_luw
*&---------------------------------------------------------------------*
*&
*理解luw必须明白到底从哪里开始为一个db luw,一般的报表程序中，写了多次数据库操作，都是一个db luw;只要没遇到显式和隐式回滚和提交。
*所有的显式提交和隐式提交，显式回滚和隐式回滚，都是一个db luw的结束和新的luw开始的标志。调用事务会开新的sap luw.
*
*
*显式提交 commit work  commit work and waite.

*显式回滚 rollback work.

*隐式提交
*对话屏幕结束时（跳转另一屏幕），一个dialog结束；
*call transaction <tcode> or SUBMIT <program> statement；
*；同步或异步方式远程调用RFC时
*；发送dialog消息时（type: E,S,I）
*
*隐式回滚 出错
*故，只要遇到以上任意情况，就是一个db luw ,然而sap luw就是使用跟新方法，把多个luw的数据操作合并到一起。
*
*使用了跟新模块call function xx in update task.的方法，只有在显式提交的时候执行。在更新模块中不允许有commit work
*
*显式操作优先级高于隐式操作，覆盖隐式操作

*&---------------------------------------------------------------------*
report z_test_luw.

load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行PAI

start-of-selection. " 点击执行后的主程序代码。
  type-pools znan. " 引入类型池，这里是全局使用的类型
  types znan_gt_ztestluw02 type ztestluw02 occurs 1.
  data gt_ztestluw01 type standard table of ztestluw01 with header line with default key.
  data gt_ztestluw02 type znan_gt_ztestluw02.
  data gt_ztestluw03 type standard table of ztestluw03 with header line with default key.

  " 删除工作区对应的数据库数据
  delete from ztestluw01.
  delete from ztestluw02.
  delete from ztestluw03.
  commit work.

    break-point.
  gt_ztestluw01-luwid = '00001'.
  gt_ztestluw01-luwty = 'sap_luw'.
  modify ztestluw01 from gt_ztestluw01.

*  gt_ztestluw02-luwid = '00001'.
*  gt_ztestluw02-luwty = 'sap_luw'.
*  append gt_ztestluw02.
*  clear gt_ztestluw02.
*  gt_ztestluw02-luwid = '00002'.
*  gt_ztestluw02-luwty = 'sap_luw'.
*  append gt_ztestluw02.
  gt_ztestluw02 = value #( ( luwid = '00001' luwty = 'sap_luw' )
                           ( luwid = '00002' luwty = 'xxxxxxxxx' ) ).
  modify ztestluw02 from table gt_ztestluw02.
  gt_ztestluw02[ 1 ]-luwty = 'YYYYYY'.
  call function 'ZTEST_INSERT_LUW' in update task"只有在显式调用commit work才执行
    exporting
      tab1 = gt_ztestluw02[].

  submit z_test_luw_2 and return."调用其他程序，会触发隐式提交

  commit work."其他非主
   "rollback work."隐式提交，和显式回滚,显式回滚优先级高
