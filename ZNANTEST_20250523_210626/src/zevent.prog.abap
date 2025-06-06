*&---------------------------------------------------------------------*
*& Report zevent
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zevent."

load-of-program.
  write / 'LOAD-OF-PROGRAM'.

top-of-page."在页首输出时触发。
  write / '8'.

initialization."在程序开始执行时初始化数据时触发。
  do 5 times.
    write  sy-index.
    write  sy-subrc.
  enddo.
  parameters a type string.

  parameters check1 type c as checkbox.
  write / 'initialization'.
  message 'initialization' type 'W'.

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。
  write / 'at selection-screen output'.
  message 'at selection-screen output!' type 'I'  .

  data(sy1) =  sy-index.
*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行
  write / '3'.
  message 'at selection-screen.!' type 'I'  .
*  message 'Success!' type 'A'  .
*  message 'Success!' type 'S'  .
*  message 'Success!' type 'W'  .
*  message 'Success!' type 'E'  .

start-of-selection."点击执行后的主程序代码。PAI
  write / '1'.

end-of-selection."选择数据结束时触发。
  write / '2'.

end-of-page."在页尾输出时触发。
  write / '9'.





*数据库操作事件."
*AT NEW / ENDAT：在处理新记录时触发。

**事务提交前后事件."
*AT USER-COMMAND."在用户执行命令时触发。
*AT SELECTION-SCREEN."在屏幕选择时触发。
