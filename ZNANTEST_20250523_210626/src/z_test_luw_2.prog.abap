**&---------------------------------------------------------------------*
*& Report z_test_luw_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_luw_2.

data: gt_ztestluw01 type standard table of ztestluw01 with header line,
      gt_ztestluw02 type standard table of ztestluw02 with header line,
      gt_ztestluw03 type standard table of ztestluw03 with header line.

gt_ztestluw03-luwid = '00001'.
gt_ztestluw03-luwty = 'sap_luw'.
modify ztestluw03 from gt_ztestluw03 .

*commit work .

end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。
