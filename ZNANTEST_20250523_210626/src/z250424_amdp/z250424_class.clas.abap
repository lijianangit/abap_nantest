class z250424_class definition
  public
  final
  create public .

  public section.
    interfaces if_amdp_marker_hdb.

    methods increase_price
      importing value(clnt) type sy-mandt
                value(inc)  type sflight-price
      raising   cx_amdp_error.

    methods increase_price_client
      importing value(inc) type sflight-price
      raising   cx_amdp_error.

    methods increase_price_cds_client
      amdp options cds session client current
      importing value(inc) type sflight-price
      raising   cx_amdp_error.
endclass.



class z250424_class implementation.


  method increase_price by database procedure for hdb
                           language sqlscript
                           using sflight.
    update sflight set price = price + :inc
                   where mandt = :clnt;
  endmethod.


  method increase_price_cds_client by database procedure for hdb
                                   language sqlscript
                                   using sflight.
    update sflight set price = price + :inc
                   where mandt = SESSION_CONTEXT('CDS_CLIENT');
  endmethod.


  method increase_price_client by database procedure for hdb
                               language sqlscript
                               using sflight.
    update sflight set price = price + :inc
                   where mandt = SESSION_CONTEXT('CLIENT');
  endmethod.
endclass.
