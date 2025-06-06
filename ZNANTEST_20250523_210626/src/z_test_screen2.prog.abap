*&---------------------------------------------------------------------*
*& Report z_test_screen2
*&---------------------------------------------------------------------*
*&
*ABAP的程序类型（type1 type m type f , type j type k type i）
*type1:可执行程序；
*type m 模块池程序
*可以在上面能建立独立的屏幕
*type f 函数程序
*type j and type k (接口程序)
*type i（继承程序）
*&---------------------------------------------------------------------*
report z_test_screen2.

load-of-program.
  write '1'.

top-of-page."在页首输出时触发。
  write '2'.

initialization."在程序开始执行时初始化数据时触发。
  write '3'.
*  屏幕1
  selection-screen begin of screen 1100 title xxxx as window.
    parameters inputStr(12) type c default 'Hello World!'.
    parameters check1 type c as checkbox.
    parameters p_p2 radiobutton group g1 user-command xx.
    parameters p_p3 radiobutton group g1.
  selection-screen end of screen 1100.
*  屏幕2
  selection-screen begin of screen 1200 title xxxxx2 as window.
    parameters input2(12) type c default 'Hello World!'.
    parameters check2 type c as checkbox.
    parameters group1 radiobutton group g2 user-command xx.
    parameters group2 radiobutton group g2 .
  selection-screen end of screen 1200.

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。
  write '4'.
*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行
  write sy-ucomm .
  message sy-ucomm type 'I'.
  write '5'.

start-of-selection."点击执行后的主程序代码。PAI
  write '6'.
  call screen 1100 ."普通选择屏幕

  call selection-screen 1200 starting at 10 10. "弹框

end-of-selection."选择数据结束时触发。
  write '7'.

end-of-page."在页尾输出时触发。
  write '8'.
