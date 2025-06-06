*&---------------------------------------------------------------------*
*& Report znantest1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report znantest1.

initialization.

at selection-screen.

start-of-selection  .
  do 10 times.
    write / sy-index.
  enddo.
  select  * from vbak into
  table @data(tab1).
  write / |VBAK 条目数量为：{ lines( tab1 )  }|.
  perform test_form.



  data(id) = 'TEXTS'.
  data(text1) = `Ike`.
  data(text2) = `Tina`.
  export p1 = text1
         p2 = text2 to memory id id.
  import p1 = text2
         p2 = text1 from memory id id.

  write / 'ABAP'.







at line-selection.
  write / 'TEST'.

end-of-selection.

top-of-page.

end-of-page.

form test_form.
  data(num) = 1 * 5 * 5 * 5 .
  data str type string value 'xxxxxxxx'.
  write / str.
endform.
