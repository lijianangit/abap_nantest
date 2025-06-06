class lhc_Travel definition inheriting
from cl_abap_behavior_handler.
  private section.

    types tt_trave_update
     type table for update znantest_rap1_cds.
    methods get_features for features
      importing keys request requested_features
      for Travel result result.

endclass.

class lhc_Travel implementation.

  method get_features.
  endmethod.

endclass.
