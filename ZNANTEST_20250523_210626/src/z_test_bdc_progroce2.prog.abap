report Z_TEST_BDC_PROGROCE2
       no standard page heading line-size 255.

* Include bdcrecx1_s:
* The call transaction using is called WITH AUTHORITY-CHECK!
* If you have own auth.-checks you can use include bdcrecx1 instead.
include bdcrecx1_s.

start-of-selection.

perform open_group.

perform bdc_dynpro      using 'Z_TEST_BDC' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EGET'.
perform bdc_field       using 'BDC_CURSOR'
                              'PARAM2'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '05/13'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_dynpro      using 'Z_TEST_BDC' '1000'.
perform bdc_field       using 'BDC_CURSOR'
                              'PARAM2'.
perform bdc_field       using 'BDC_OKCODE'
                              '=CRET'.
perform bdc_field       using 'PARAM1'
                              'X'.
perform bdc_field       using 'PARAM2'
                              '1111111'.
perform bdc_field       using 'PARAM3'
                              '22222222'.
perform bdc_field       using 'PARAM4'
                              '3333333333333'.
perform bdc_field       using 'PARAM5'
                              '4444444444444'.
perform bdc_field       using 'R3'
                              'X'.
perform bdc_transaction using 'ZTESTBDC'.

perform close_group.
