*&---------------------------------------------------------------------*
*& Report z_test_for_all_entries_in
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_for_all_entries_in.
data(out) = cl_demo_output=>new( ).

types: begin of type1,
         uuid type char32,

       end of type1.
data tab1 type table of type1.
tab1 = value #( ( uuid = '7446A0A1157D1EEF98C409E3BCCF5D7E' )
                ( uuid = '7446A0A1157D1EEF98C44655DC1C1E25' )
                ( uuid = '7446A0A1157D1EEF98C45B7EDF0F9E5E' ) ).
select * from znantest_student
  for all entries in @tab1
  where znantest_student~uuid = @tab1-uuid
  into table @data(tab2).
DATA itab TYPE RANGE OF i.

out->write_data( tab2 ).

select banpr,sum( preis ) as sum1 from eban into table @Data(tab3) group by banpr order by banpr descending.
out->write_data( tab3 ).

out->display( ).
