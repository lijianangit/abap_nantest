*&---------------------------------------------------------------------*
*& Report z250507
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250507.

load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行PAI

start-of-selection."点击执行后的主程序代码。
  data(arg1) = 0.
  data(arg2) = 1.
  data(result_num) = 0.
  perform add_num
    using
      arg1
      arg2.


end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。

form add_num using arg1 type i
                   arg2 type i.

  data(result_num) = arg1 + arg2.

  if result_num < 1000.
    data(new_variable_1) = arg2.
    data(new_variable) = result_num.
    perform add_num using new_variable_1
                          new_variable.
  endif.

  write |{ result_num }|.
endform.
