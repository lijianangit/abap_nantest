*&---------------------------------------------------------------------*
*& Report z_test_bdc
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_bdc.

load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。
  selection-screen comment /1(83) str1.
  str1 = 'xxxxxxx'.
  parameters param1 type abap_bool as checkbox.
  parameters param2 type namem.
  parameters param3 type string.
  parameters param4 type string.
  parameters param5 type string.
  parameters: r1 radiobutton group rad1,
              r2 radiobutton group rad1,
              r3 radiobutton group rad1.

  select * from eban into table @data(tab1) where banfn = '0010009039'.



at selection-screen output."在屏幕选择数据输出时触发。PBO


at selection-screen.
  data tab1 type table of screen with empty key. "创建一个工作区
  loop at screen into data(screen_wa).
    append screen_wa to tab1.
    if screen_wa-group1 = 'mg1'.
      screen_wa-intensified = '1'.
      modify screen from screen_wa.
    endif.
  endloop.
  cl_demo_output=>display( tab1 ).

start-of-selection."点击执行后的主程序代码。



end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。
