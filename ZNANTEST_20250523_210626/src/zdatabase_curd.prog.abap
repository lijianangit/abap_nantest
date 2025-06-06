*&---------------------------------------------------------------------*
*& Report zdatabase_curd
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zdatabase_curd.

select * from ztab1 into table @data(tab1).
data arr1 type table of string with empty key.
data arr2 type table of string with empty key.
data arr3 type table of string with empty key.
data arr4 like table of arr1.

" 创建id数组

perform create_random using arr1.
perform create_random using arr2.
perform create_random using arr3.
cl_demo_output=>display( arr1 ).
cl_demo_output=>display( arr2 ).
cl_demo_output=>display( arr3 ).
perform test_curd.
perform add_tab1_data using arr1.
perform add_tab2_data using arr2
                            arr1
                            arr3.
perform add_tab3_data using arr3
                            arr2.

form add_tab1_data using arr1 like arr1.
  data ls_record type ztab1.

  " 生成3位随机数
  do 10 times.
    clear ls_record.
    " 填充记录
    ls_record-uuid       = arr1[ sy-index ].
    ls_record-desc1      = '55'.
    ls_record-desc2      = '11111111'.
    ls_record-createdate = sy-datum.
    ls_record-creater    = sy-uname.
    ls_record-age        = 18.
    insert into ztab1 values ls_record.
  enddo.
endform.

form add_tab2_data using
                tab2Ids like arr2
                tab1Ids like arr1
                tab3Ids like arr3.
  data: ls_record type ztab2.
  do 10 times.
    clear   ls_record.
    ls_record = value #( uuid = tab2Ids[ sy-index ]
                         desc1 = '111111'
                         desc2 = '11111111'
                         createdate = sy-datum
                         creater = sy-uname
                         age = 18
                         tab13d = tab3Ids[ sy-index ]
                         tab1id = tab1Ids[ sy-index ] ).
    insert into ztab2 values ls_record.
  enddo.
endform.

form add_tab3_data using tab3Ids like arr3 tab2Ids like arr2.
  data: ls_record type ztab3.
  do 10 times.
    clear   ls_record.
    ls_record = value #( uuid = tab3Ids[ sy-index ]
                         ztab2id = tab2Ids[ sy-index ]
                        ).
    insert into ztab3 values ls_record.
  enddo.
endform.

form test_CURD .
*删除数据库数
  delete from demo_update.

  modify demo_update from @(
    value #(  id = 'X' col1 = 10 col2 = 20 col3 = 30 col4 = 40 ) ).

  modify demo_update from table @(
    value #( ( id = 'X' col1 =  1 col2 =  2 col3 =  3 col4 =  4 )
             ( id = 'Y' col1 = 11 col2 = 12 col3 = 13 col4 = 14 )
             ( id = 'Z' col1 = 21 col2 = 22 col3 = 23 col4 = 24 ) ) ).
endform.

form create_random changing result like arr1.
  do 10 times.
    data: cl_random type ref to cl_random_number,
          m         type i.
    create object cl_random.

    call method cl_random->if_random_number~init .
    call method cl_random->if_random_number~get_random_int
      exporting
        i_limit  = 9999999
      receiving
        r_random = m.
    append m to result.
  enddo.
endform.
