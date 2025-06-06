class ZNANTES_CO_Z_NANTEST_SERVICE_P definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods Z_TEST_RAP_1
    importing
      !INPUT type ZNANTES_Z_TEST_RAP_1
    exporting
      !OUTPUT type ZNANTES_Z_TEST_RAP_1RESPONSE
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZNANTES_CO_Z_NANTEST_SERVICE_P IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZNANTES_CO_Z_NANTEST_SERVICE_P'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method Z_TEST_RAP_1.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'Z_TEST_RAP_1'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
