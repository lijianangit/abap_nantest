*&---------------------------------------------------------------------*
*& Report z_test_screen3
*&---------------------------------------------------------------------*
*&测试分组控制屏幕区块
*&---------------------------------------------------------------------*
report z_test_screen3.


" 物料与人员
parameters p_r1 radiobutton group grp1 default 'X' user-command f1.
parameters p_r2 radiobutton group grp1.

" 物料选择条件
selection-screen begin of block bk1 with frame title text-001.
  parameters p_werks type werks modif id m1.   " 工厂
  parameters p_matnr type matnr modif id m1.   " 物料
selection-screen end of block bk1.

" 人员选择条件
selection-screen begin of block bk2 with frame title text-002.
  parameters p_pernr type p_pernr modif id m2.  " 工号
selection-screen end of block bk2.

" Radio Button 指定了USER-COMMAND,单选按钮的值发生改变时触发事件
data tab1 type table of screen.

at selection-screen output.
  loop at screen .  " 遍历选择屏幕中的所有元素
    if p_r1 = 'X'. " 选中 P_R1 物料
      if screen-group1 = 'M2'. " 隐藏 MODIF ID = 'M2' 的屏幕元素
        screen-active = '0'.
      endif.
    else.  " 选中 P_R2 人员
      if screen-group1 = 'M1'."隐藏 MODIF ID = 'M1' 的屏幕元素
        screen-active = '0'.
      endif.
    endif.
    modify screen.  " 保存更改
    append screen to tab1.

  endloop.
*  cl_demo_output=>display( tab1 ).
