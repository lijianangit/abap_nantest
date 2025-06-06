*&---------------------------------------------------------------------*
*& Report z_memory
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_memory.
*测试 sap memory
data(p_matnr) = 'testSAP'.
SET PARAMETER ID 'MAT' FIELD p_matnr.


GET PARAMETER ID 'MAT' FIELD p_matnr.
SELECT * FROM ztab1 INTO TABLE @DATA(tab1).
data(line1) = tab1[ 1 ].
cl_demo_output=>DISPLAY( line1 ).


write / p_matnr.
skip.

*测试 abap memory
  data(id) = 'TEXTS'.
  data(text1) = `change1`.
  data(text2) = `change2`.
  export p1 = text1
         p2 = text2 to memory id 'xxxxxx'.
  import p1 to text2
         p2 to text1 from memory id 'xxxxxx'.
       write: / text1,text2.

* 调用其他程序
 SUBMIT  z_memory_2 AND RETURN.
 write / 'return'.
