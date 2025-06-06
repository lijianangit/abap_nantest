*&---------------------------------------------------------------------*
*& Report z_demo_hellow_world
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_demo_hellow_world.
load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。
selection-screen begin of screen 1100 .
  parameters inputStr(12) type c default 'Hello World!'.
  parameters check1 type c as checkbox.
  parameters p_p2 radiobutton group g1 user-command flag.
  parameters p_p3 radiobutton group g1.
selection-screen end of screen 1100.

class demo definition.
  public section.
    methods main.
endclass.
class demo implementation.
  method main.
* Selection Screen
    call selection-screen 1100 starting at 10 10.
    if sy-subrc <> 0.
      leave program.
    endif.

* Dynpro
    call screen 100.

* Message
    message inputStr type 'I'.

* List
    write inputStr.

  endmethod.
endclass.


at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行

start-of-selection."点击执行后的主程序代码。PAI
start-of-selection.
data Object1 type ref to demo.
create object Object1.
 object1->main( ).
START-OF-SELECTION.

end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。
