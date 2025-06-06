*&---------------------------------------------------------------------*
*& Report z_test_20250212
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_20250212.
select *        from scarr
       into table @data(carriers).

call transformation id source carriers = carriers
                       result xml data(xml).
data(l_belnr) = |{ '100000215' alpha = in }|.
cl_demo_output=>new(
  )->begin_section( `Some Text`
  )->write_text( |blah blah blah \n| &&
                 |blah blah blah|
  )->next_section( `Some Data`
  )->begin_section( `Elementary Object`
  )->write_data( carriers[ 1 ]-carrid
  )->next_section( `Internal Table`
  )->write_data( carriers
  )->end_section(
  )->next_section( `XML`
  )->write_xml( xml
  )->display( ).

select *
     from scarr
     into table @data(carriers2).
data(html) = cl_demo_output=>get( carriers2 ).
cl_abap_browser=>show_html( html_string = html ).
