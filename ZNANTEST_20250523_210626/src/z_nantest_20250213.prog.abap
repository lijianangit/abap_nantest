*&---------------------------------------------------------------------*
*& Report z_nantest_20250213
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_nantest_20250213.

parameters: text   type c length 20
                          lower case
                          default '     0000012345',
            length type i default 20,
            width  type i default 0.

class demo definition.
  public section.
    class-methods main.
  private section.
    class-methods output importing !title type csequence
                                   !text  type csequence.
endclass.

class demo implementation.
  method main.
    data textstring       type string.
    data resultstring_in  type string.
    data resultfield_in   type ref to data.
    data resultstring_out type string.
    data resultfield_out  type ref to data.
    field-symbols <resultfield_in>  type data.
    field-symbols <resultfield_out> type data.

    concatenate text `` into textstring respecting blanks.
    create data resultfield_in  type c length length.
    create data resultfield_out type c length length.
    assign resultfield_in->* to <resultfield_in>.
    assign resultfield_out->* to <resultfield_out>.
    if width = 0.
      resultstring_in = |{ textstring alpha = in }|.
      output( title = `String, IN`
              text  = resultstring_in ).
      <resultfield_in> = |{ textstring alpha = in }|.
      output( title = `Field,  IN`
              text  = <resultfield_in> ).
      resultstring_out = |{ textstring alpha = out }|.
      output( title = `String, OUT`
              text  = resultstring_out ).
      <resultfield_out> = |{ textstring alpha = out }|.
      output( title = `Field,  OUT`
              text  = <resultfield_out> ).
    else.
      resultstring_in = |{ textstring alpha = in width = width }|.
      output( title = `String, IN`
              text  = resultstring_in ).
      <resultfield_in> = |{ textstring alpha = in width = width }|.
      output( title = `Field,  IN`
              text  = <resultfield_in> ).
      resultstring_out = |{ textstring alpha = out width = width }|.
      output( title = `String, OUT`
              text  = resultstring_out ).
      <resultfield_out> = |{ textstring alpha = out width = width }|.
      output( title = `Field,  OUT`
              text  = <resultfield_out> ).
    endif.
  endmethod.
  method output.
    data fill type c length 40.
    write: /(12) title color col_heading no-gap,
            (3)  fill color col_positive no-gap,
                 text color col_normal   no-gap,
                 fill color col_positive no-gap,
            40   fill.
  endmethod.
endclass.

start-of-selection.
  demo=>main( ).

at selection-screen.
  if length < 1 or length > 20.
    message 'Length between 1 and 20 only' type 'E'.
  endif.
  if width < 0 or width > 20.
    message 'Width between 0 and 20 only' type 'E'.
  endif.
