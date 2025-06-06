CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS CalculateTravelKey FOR DETERMINATION Travel~CalculateTravelKey
      IMPORTING keys FOR Travel.

    METHODS validateAgency FOR VALIDATION Travel~validateAgency
      IMPORTING keys FOR Travel.

    METHODS validateCustomer FOR VALIDATION Travel~validateCustomer
      IMPORTING keys FOR Travel.

    METHODS validateDates FOR VALIDATION Travel~validateDates
      IMPORTING keys FOR Travel.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD CalculateTravelKey.
  ENDMETHOD.

  METHOD validateAgency.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

  METHOD acceptTravel.
  ENDMETHOD.

  METHOD get_features.
  ENDMETHOD.

ENDCLASS.
