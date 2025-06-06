class ZCL_Z250305_3_DPC_EXT definition
  public
  inheriting from ZCL_Z250305_3_DPC
  create public .

public section.
protected section.
    methods Z250305_TAB1SET_create_entity redefinition.
    methods Z250305_TAB1SET_delete_entity redefinition.
    methods Z250305_TAB1SET_update_entity redefinition.
    methods Z250305_TAB1SET_get_entity redefinition.
    methods Z250305_TAB1SET_get_entityset redefinition.
private section.
ENDCLASS.



CLASS ZCL_Z250305_3_DPC_EXT IMPLEMENTATION.

method Z250305_TAB1SET_get_entityset.

    select * from Z250305_TAB1
    into corresponding fields of
    table et_entityset.
  endmethod.

  method Z250305_TAB1SET_get_entity.
    data ls_key type /iwbep/s_mgw_name_value_pair.       " key-value的结构
    data lv_value type /iwbep/s_mgw_name_value_pair-value. " value

    read table it_key_tab into ls_key with key name = 'Uuid'. " 把表it_key_tab中key为id的行赋值给ks_key中
    lv_value = ls_key-value.

    if lv_value is not initial.
      select single * from Z250305_TAB1
        into corresponding fields of er_entity
        where uuid = lv_value.
    endif.
  endmethod.

  method Z250305_TAB1SET_create_entity.
    data:ls_requst_input_data type zcl_Z250305_3_mpc=>ts_Z250305_TAB1,
         ls_table             type zcl_Z250305_3_mpc=>ts_Z250305_TAB1.
    io_data_provider->read_entry_data( importing es_data = ls_requst_input_data ).
    insert Z250305_TAB1 from ls_requst_input_data .
    if sy-subrc eq 0 .
      er_entity = ls_requst_input_data .
    endif.
  endmethod.

  method Z250305_TAB1SET_delete_entity.
    data ls_key  type /iwbep/s_mgw_name_value_pair.
    data lv_id   type /iwbep/s_mgw_name_value_pair-value.
    data lv_flag type c length 1.

    read table it_key_tab into ls_key with key name = 'uuid'.
    lv_id = ls_key-value.
    if lv_id is initial.
      return.
    endif.
    delete from Z250305_TAB1 where uuid = lv_id.
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

  method Z250305_TAB1SET_update_entity.
    data ls_key               type /iwbep/s_mgw_name_value_pair.
    data lv_id                type /iwbep/s_mgw_name_value_pair-value.
    data ls_requst_input_data type zcl_Z250305_3_mpc=>ts_Z250305_TAB1.
    data tab1 type table of Z250305_TAB1.

    read table it_key_tab into ls_key with key name = 'uuid'.
    lv_id = ls_key-value.

    if lv_id is initial.
      return.
    endif.

    io_data_provider->read_entry_data( importing es_data = ls_requst_input_data ).

    modify Z250305_TAB1 from ls_requst_input_data.
    if sy-subrc = 0.
      er_entity = ls_requst_input_data.

    endif.
  endmethod.
ENDCLASS.
