*&---------------------------------------------------------------------*
*& Include z_250325_include_2
*&---------------------------------------------------------------------*

tables  t001l.
data: gs_out type z250318.
data: gt_out type table of z250318.

*&------------------------------------------------------------------&*
*&  选择屏幕输入
*&------------------------------------------------------------------&*
selection-screen begin of block blk_001 with frame title text-001.
  select-options:
    so_werks for t001l-werks.
selection-screen end of block blk_001.

selection-screen begin of block blk_002 with frame title text-002.
  parameters:
    pa_main radiobutton group rad default 'X',
    pa_view radiobutton group rad.

selection-screen end of block blk_002.
