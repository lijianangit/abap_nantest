*&---------------------------------------------------------------------*
*& Report z_test_pbo_pai
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_test_pbo_pai.

*initialization.
*
*  parameters a type c as checkbox.
*
*at selection-screen output."PBO
*
*
*at selection-screen."PAI
*
*start-of-selection.
*
*end-of-selection.
*
*top-of-page.
*
*end-of-page.
*
*REPORT demo_at_selection_screen.

* Global data

tables sscrfields.

data: spfli_tab type table of spfli,
      spfli_wa  like line of spfli_tab.

* Selection screens

parameters p_carrid type spfli-carrid.

selection-screen begin of screen 500.
  select-options s_conn for spfli_wa-connid.
selection-screen end of screen 500.

* Handling selection screen events

at selection-screen on p_carrid.
  if p_carrid is initial.
    message 'Please enter a value' type 'E'.
  endif.
  authority-check object 'S_CARRID'
                  id 'CARRID' field p_carrid
                  id 'ACTVT'  field '03'.
  if sy-subrc = 4.
    message 'No authorization for carrier' type 'E'.
  elseif sy-subrc <> 0.
    message 'Error in authority check' type 'A'.
  else.
    if sscrfields-ucomm = 'ONLI'.
      call selection-screen '0500'.
    endif.
  endif.

at selection-screen.
  if sy-dynnr = '0500'.
    if s_conn is initial.
      message 'Please enter values' type 'W'.
    else.
      select *
             from spfli
             where carrid = @p_carrid and
                   connid in @s_conn
             into table @spfli_tab.
      if sy-subrc <> 0.
        message 'No flights found' type 'E'.
      endif.
    endif.
  endif.

* Main program

start-of-selection.
