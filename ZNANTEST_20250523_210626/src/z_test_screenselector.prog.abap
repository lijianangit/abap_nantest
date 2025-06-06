*&---------------------------------------------------------------------*
*& Report z_test_screenselector
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_screenselector.

initialization.
  write / '1'.
  parameters int1 type i obligatory . "OBLIGATORY 标识必填
  parameters int2(524287) type i no-display . "NO-DISPLAY 标识不显示
  parameters c1 type c.
  parameters d1 type d.
  parameters p1 type p decimals 2. "固定小数位数的浮点类型
  parameters string1 type string visible length 250 . "定义显示的输入框大小
  parameters int8 type int8.
  parameters t1 type t.
  parameters b1 type abap_boolean as checkbox.
  parameters group1 type c  radiobutton group g1 user-command z_do_some_thing.
  parameters group2 radiobutton group g1.
  parameters nantest type string .
*combo
  parameters p type i as listbox visible length 10.
  data type1 type ztab1.
  select-options param1 for type1-age.
  select *
         from ztab1
         where age in @param1
         into @type1.
  endselect.


*    普通选择组件
  data spfli_wa type spfli.
  select-options s_carrid for spfli_wa-carrid.
  select *
         from spfli
         where carrid in @s_carrid
         into @spfli_wa.
  endselect.


  data: carrier    type spfli-carrid,
        connection type spfli-connid.

start-of-selection.
  select carrid, connid
         from spfli
         into (@carrier, @connection).
    write: / carrier hotspot, connection hotspot.
    hide:  carrier, connection.
  endselect.

at line-selection.
  set parameter id: 'CAR' field carrier,
                    'CON' field connection.
  call transaction 'DEMO_TRANSACTION'.




  parameters: carrid type spfli-carrid,
              connid type spfli-connid.



start-of-selection.

at selection-screen.
  write / '2'.

at selection-screen output.
  write / '7'.
  types: begin of type1,
           key(40)  type c,
           text(80) type c,
         end of type1.
  types: typeTabl type type1 occurs 0.
  data(l1) = value typeTabl( for i = 1 until i > 10 ( key = i text = |Value { i }| ) ).
  data(s_id) =  conv vrm_id( 'P' ).
  call function 'VRM_SET_VALUES'
    exporting
      id     = s_id
      values = l1.
  cl_demo_output=>display(
    reduce string( init s = ``
                   for  i = 1 until i > 10
                   next s = s && |{ i - 1 }| ) ).





*创建一个spfli-carrid的值的内表
  data carrid_range type range of spfli-carrid.
  carrid_range = value #(
    ( sign = 'I' option = 'BT' low = 'AA' high = 'LH') ).

  select *
         from spfli
         where carrid in @carrid_range
         into table @data(spfli_tab).

  cl_demo_output=>display(
    exporting
      data = 'xxxxx'
      name = 'yyyyyy'
  ).
  data time type t.
  time = sy-timlo.

  data(str1) = '23'.
  data(data23) = cond #(
       let t = str1 in
       when time < t then 'sdffff'
       when 1 < 5 and 5 > 10 then '23444'
       when t < 1111 then `High Noon`
       else 'xxxxx' ).

  data text type standard table of string .
  types text2 like text.

  types text type standard table of string  with empty key.

  data(arr23) = value text2( let it = `be` in
                ( |To { it } is to do|          )
                ( |To { it }, or not to { it }| )
                ( |To do is to { it }|          )
                ( |Do { it } do { it } do|      ) ).
  cl_demo_output=>display( arr23 ).


start-of-selection.
  write / '3'.

end-of-selection.
  write / '4'.

top-of-page.
  write / '5'.

end-of-page.
  write / '6'.
