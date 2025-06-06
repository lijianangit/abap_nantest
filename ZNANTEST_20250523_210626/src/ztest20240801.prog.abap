*&---------------------------------------------------------------------*
*& Report ztest20240801
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ztest20240801.
load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行PAI

start-of-selection."点击执行后的主程序代码。
select * from eban into  table  @data(tab1).
sort tab1 descending.
read table tab1 into data(tab2) with key adacn = '123' binary search.
end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。
