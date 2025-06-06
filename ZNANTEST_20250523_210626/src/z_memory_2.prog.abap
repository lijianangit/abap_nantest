*&---------------------------------------------------------------------*
*& Report z_memory_2
*&---------------------------------------------------------------------*
*&  由于没错在eclipse打开都是一个新的External Session客户端连接只能用sapmemory来进行数据通信，在gui里面，只有在同一窗口
* 就会是用同一用户session故abap memory会取到值，而eclipse里面取不到值，如果是程序1调用程序2就可以取到值
*&---------------------------------------------------------------------*
report z_memory_2.

load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。
  data(text1) = `initial`.
  data(text2) = `initial`.
  get parameter id 'MAT' field data(p_matnr).
  write / p_matnr.
  import p1 to text2
         p2 to text1 from memory id 'xxxxxx'.
  write: / text1,text2.
  message | { text1 } && { text2 }| type 'I'.
  selection-screen begin of screen 1100 title xxxx as window.
    parameters inputStr(12) type c default 'xxxxxxxxxxxxxxxxx'.
    parameters check1 type c as checkbox.
    parameters str1 type string memory id xxxxxx-p1.
    parameters str3 type string default 'xxxxxx' .
    parameters str2 type string default p_matnr.
    parameters p_p2 radiobutton group g1 user-command flag.
    parameters p_p3 radiobutton group g1.
  selection-screen end of screen 1100.


at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行

start-of-selection."点击执行后的主程序代码。PAI
  call screen 1100 starting at 5 5.

end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。
