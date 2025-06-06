*&---------------------------------------------------------------------*
*& Report z250422
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250422.

load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。
  data lt_datatab type table of z250318.

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行PAI

start-of-selection."点击执行后的主程序代码。
    call screen '1000'.
end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。


form display_alv_by_custom using lt_datatab type standard table  .

  data gr_container type ref to cl_gui_custom_container.
  data: gr_table type ref to cl_salv_table.
  data: gr_functions type ref to cl_salv_functions_list.


  " 判断是否已分配了一个有效引用
  if gr_container is not bound.
    "创建容器
    create object gr_container
      exporting
        container_name = 'CONTAINER1'. "屏幕上用户自定义控件名
    "创建ALV
    cl_salv_table=>factory(
      exporting
        r_container    = gr_container
        container_name = 'CONTAINER1'
      importing
        r_salv_table   = gr_table
      changing
        t_table        = lt_datatab[] ).
    "设置工具栏
    gr_functions = gr_table->get_functions( ).
    gr_functions->set_all( abap_true ). "Activate All Generic ALV Functions，将激活所有的ALV内置通用按钮
    "显示
    gr_table->display( ).
  endif.
endform.

*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_1000 output.
 set pf-status 'S_001'.
 set titlebar 'xxx'.
 perform display_alv_by_custom
   using
     lt_datatab
   .
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_1000 input.
  data(ok_code) = sy-ucomm.
    message |{ ok_code  }| type 'I'.
 CASE ok_code.
    when `LOGIN`.
  endcase.
endmodule.
