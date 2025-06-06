*&---------------------------------------------------------------------*
*& Report z_test_screen
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_screen.
selection-screen comment /83(83) comm1 modif id mg1.



selection-screen comment /1(83) comm2.

parameters: r1 radiobutton group rad1,
            r2 radiobutton group rad1,
            r3 radiobutton group rad1.
selection-screen uline /83(1).

at selection-screen output.
  comm1 = 'Selection Screenxxxxxxxxxxxxxxx'.
  comm2 = 'Select one'.
  data tab1 type table of screen with empty key. "创建一个工作区
  loop at screen into data(screen_wa).
    append screen_wa to tab1.
    if screen_wa-group1 = 'mg1'.
      screen_wa-intensified = '1'.
      modify screen from screen_wa.
    endif.
  endloop.
  cl_demo_output=>display( tab1 ).

  at selection-screen."在屏幕选择执行的时候,点击执行PAI
    message sy-ucomm  type 'S'.
