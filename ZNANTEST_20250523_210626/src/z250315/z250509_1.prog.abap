*&---------------------------------------------------------------------*
*& Report z250509_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z250509_1.

data i type i value 100.
write / 'frm_ref===='.
perform frm_ref using i.
write / i. " 200

write / 'frm_val===='.
i = 100.
perform frm_val using i.
write / i. " 100

write / 'frm_ref2===='.

" 不能将下面的变量定义到frm_ref2过程中，如果这样，下面的dref指针在调用frm_ref2 后，指向的是Form中局部变量内存，为不安全发布，运行会抛异常，因为From结束后，它所拥有的所有变量内存空间会释放掉
data i_frm_ref2 type i value 400.
i = 100.
data dref type ref to i.
get reference of i into dref.
perform frm_ref2 using dref. " 传递的内容为地址，属于别名引用传递
write / i. " 4000


field-symbols <fs> type i.
assign dref->* to <fs>. " 由于frm_ref2过程中已修改了dref的指向，现指向了i_frm_ref2 变量的内存空间
write / <fs>. " 400

write / 'frm_val2===='.
i = 100.
data dref2 type ref to i.
get reference of i into dref2.
perform frm_val2 using dref2.
write / i. " 4000
assign dref2->* to <fs>.
write / <fs>. " 4000

form frm_ref  using  p_i type i ."C++中的引用参数传递：p_i为实参i的别名
  write: /  p_i."100
  p_i = 200."p_i为参数i的别名，所以可以直接修改实参
endform.

form frm_val  using   value(p_i)."传值：p_i为实参i的拷贝
  write: /  p_i."100
  p_i = 300."由于是传值，所以不会修改主调程序中的实参的值
endform.
form frm_ref2 using p_i type ref to i ."p_i为实参dref的别名，类似C++中的引用参数传递（传递的内容为地址，并且属于别名引用传递）
  field-symbols : <fs> type i .
  "现在<fs>就是实参所指向的内存内容的别名，代表实参所指向的实际内容
  assign p_i->* to <fs>.
  write: /  <fs>."100
  <fs> = 4000."直接修改实参所指向的实际内存


  data: dref type ref to i .
  get reference of i_frm_ref2 into dref.
  "由于USING为C++的引用参数，所以这里修改的直接是实参所存储的地址内容，这里的p_i为传进来的dref的别名，是同一个变量，所以实参的指向也发生了改变(这与Java中传递引用是不一样的，Java中传递引用时为地址的拷贝，即Java中永远也只有传值，但C/C++/ABAP中可以传递真正引用——别名）
  p_i = dref."此处会修改实参的指向
endform.

form frm_val2 using value(p_i) type ref to i ."p_i为实参dref2的拷贝，类似Java中的引用传递（虽然传递的内容为地址，但传递的方式属于地址拷贝——值传递）
  field-symbols : <fs> type i .
  "现在<fs>就是实参所指向的内存内容的别名，代表实参所指向的实际内容
  assign p_i->* to <fs>.
  write: /  <fs>."100
  <fs> = 4000."但这里还是可以直接修改实参所指向的实际内容


  data: dref type ref to i .
  get reference of i_frm_ref2 into dref.
  "这里与过程 frm_ref2 不一样，该过程 frm_val2 参数的传递方式与java中的引用传递是原理是一样的：传递的是地址拷贝，所以下面不会修改主调程序中实参dref2的指向，它所改变的只是拷贝过来的Form中局部形式参数的指向
  p_i = dref.
endform.
