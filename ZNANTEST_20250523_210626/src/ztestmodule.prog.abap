*&---------------------------------------------------------------------*
*& Report ztestmodule
*&---------------------------------------------------------------------*
*& 模块化
*函数
*子例程
*宏
*类
*&---------------------------------------------------------------------*
report ztestmodule.

*Function
*Function模块是具有全局可见性的特殊程序。
*Function模块只能在Function Group中定义并使用。
*Function Group
*Function Group中可以包含一个以上的函数，是对某一类对象的操作。
*Function Group专门用作Function的主程序
data result1 type string value 'xxxxxxxxxxxxx'.
field-symbols <strRef> type string.
assign result1 to <strRef>.

data: lv_string type string,
      lr_string type ref to string.

lv_string = 'Hello, world!'.
create data lr_string type string.
lr_string->* = lv_string.


data result2 type string value  'jjjjjjjjjjjjjjjj'.
call function 'ZTESTFUNCTION'
  exporting
    im_p1         = <strRef>
    im_p2         = 'yyyyyyyyyy'
  importing
    ex_p1         = result2
  exceptions
    error_message = 1
    others        = 2.
case sy-subrc.
  when 1.
    write  / '1'.
  when 2.
    write / '2'.
endcase.
write / result2.
write / result1.

*宏
define add_numbers.
  data: result type i.
  result = &1 + &2.
  write: / 'Sum:', result.
end-of-definition.
add_numbers 5  3.

*form
*值传递引用传递
data int1 type i value 0.
data int2 type i value 0.
data int3 type i value 0.
data int4 type i value 0.
data globalInt type i value 0.
write:/ '初始值:',int1,int2,int3,int4,globalInt.
do 5 times .
  perform increment_number using  int1 int2 changing  int3 int4.
enddo.
write:/ int1,int2,int3,int4,globalInt.


form increment_number using
      p_value type i
      value(p_value2) type i
      changing value(result) type i
      result2 type i."值传递并且最后把值复制回去，在方法运行过程中是不变的
  p_value = p_value + 1.  " 修改子程序内的参数值
  p_value2 = p_value2 + 1.  " 修改子程序内的参数值
  result = result + 1.
  result2 = result2 + 1.
  globalInt = globalInt + 1.
  write: /  p_value,p_value2,result,result2,int1,int2,int3,int4,globalInt.
endform.




*Include Programe（包含程序）用于定义公用属性，让其他程序调用
*在ABAP/4中可以使用 Include 加载另一个程序, 通常用于共享数据项的定义
*将数据声明为公共部分
*为了使程序更透明，移植性更好
*在调用程序和子例程之间进行数据传递时，
*应尽量选择在内部和外部子例程中，明确指定所需的及可能更改的数据。








*接口


interface i1.
  data    a1 type string.
  methods m1.
  events  e1 exporting value(p1) type string.
endinterface.

interface i2 deferred."告诉程序，会用到一个叫做i2的接口，用于代码还没加载完的情况
interface i3.
  data i2 type ref to i2.
endinterface.

interface i2.
  methods m2.
endinterface.




class c1 definition.
  public section.
    interfaces i1.
    interfaces i3.
endclass.

class c1 implementation.
  method i1~m1.
    write / 'i1~m1'.
    raise event i1~e1 exporting p1 = i1~a1.


  endmethod.
endclass.
