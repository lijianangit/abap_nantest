*&---------------------------------------------------------------------*
*& Report z_test_other
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_other.

initialization.

at selection-screen.

start-of-selection.
  data carrid_range type range of spfli-carrid.
*sign：表示是否包含或排除该行的条件结果。有效值为 “I”（包含）和 “E”（排除）。
*option：选择条件的操作符，例如 “EQ”、“NE”、“GE”、“GT”、“LE”、“LT”、“CP”、“NP” 等。
*low：比较值或下限。
*high：上限。
  carrid_range = value #(
    ( sign = 'I' option = 'EQ' low = 'AA' high = 'LH') ).
  select *
         from spfli
         where carrid in @carrid_range
  into table @data(spfli_tab).
  cl_demo_output=>display( spfli_tab ).





  types t_date_tab type table of string with empty key.
  data(date_tab) = value t_date_tab(
    ( |xxxxxxxxxx| )
    ( | xxxxxx2 | )
    ( | xxxxxxxxxxx3| ) ).

  cl_demo_output=>display( date_tab ).
  cl_demo_output=>display( date_tab[ 1 ] ).

  cl_demo_output=>display( 'xxxxxxxxx' ).



end-of-selection.

top-of-page.

end-of-page.
