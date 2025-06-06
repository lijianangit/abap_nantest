class zcl_z_nantest_rap_dpc_ext definition
  public
  inheriting from zcl_z_nantest_rap_dpc
  create public .

  public section.
  protected section.
    methods ztab1set_create_entity redefinition.
    methods ztab1set_delete_entity redefinition.
    methods ztab1set_update_entity redefinition.
    methods ztab1set_get_entity redefinition.
    methods ztab1set_get_entityset redefinition.
  private section.
endclass.



class zcl_z_nantest_rap_dpc_ext implementation.

  method ztab1set_get_entityset.

    select * from ztab1
    into corresponding fields of
    table et_entityset.
  endmethod.

  method ztab1set_get_entity.
    data ls_key type /iwbep/s_mgw_name_value_pair.       " key-value的结构
    data lv_value type /iwbep/s_mgw_name_value_pair-value. " value

    read table it_key_tab into ls_key with key name = 'Uuid'. " 把表it_key_tab中key为id的行赋值给ks_key中
    lv_value = ls_key-value.

    if lv_value is not initial.
      select single * from ztab1
        into corresponding fields of er_entity
        where uuid = lv_value.
    endif.
  endmethod.

  method ztab1set_create_entity.
    data:ls_requst_input_data type zcl_z_nantest_rap_mpc=>ts_ztab1,
         ls_table             type zcl_z_nantest_rap_mpc=>ts_ztab1.
    io_data_provider->read_entry_data( importing es_data = ls_requst_input_data ).
    insert ztab1 from ls_requst_input_data .
    if sy-subrc eq 0 .
      er_entity = ls_requst_input_data .
    endif.
  endmethod.

  method ztab1set_delete_entity.
    data ls_key  type /iwbep/s_mgw_name_value_pair.
    data lv_id   type /iwbep/s_mgw_name_value_pair-value.
    data lv_flag type c length 1.

    read table it_key_tab into ls_key with key name = 'uuid'.
    lv_id = ls_key-value.
    if lv_id is initial.
      return.
    endif.
    delete from ztab1 where uuid = lv_id.
    if sy-subrc <> 0.
      lv_flag = 'X'.
    endif.
    if lv_flag = 'X'.
      rollback work.
      message 'DELETE DATA FAILE' type 'E'.
    else.
      commit work.
    endif.
  endmethod.

  method ztab1set_update_entity.
    data ls_key               type /iwbep/s_mgw_name_value_pair.
    data lv_id                type /iwbep/s_mgw_name_value_pair-value.
    data ls_requst_input_data type zcl_z_nantest_rap_mpc=>ts_ztab1.
    data tab1 type table of ztab1.

    read table it_key_tab into ls_key with key name = 'uuid'.
    lv_id = ls_key-value.

    if lv_id is initial.
      return.
    endif.

    io_data_provider->read_entry_data( importing es_data = ls_requst_input_data ).

    modify ztab1 from ls_requst_input_data.
    if sy-subrc = 0.
      er_entity = ls_requst_input_data.

    endif.
  endmethod.

endclass.
