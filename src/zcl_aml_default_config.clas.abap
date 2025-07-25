CLASS zcl_aml_default_config DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_aml_config.
ENDCLASS.


CLASS zcl_aml_default_config IMPLEMENTATION.
  METHOD zif_aml_config~get_expiry_date.
    RETURN cl_abap_context_info=>get_system_date( ) + 14.
  ENDMETHOD.


  METHOD zif_aml_config~get_keep_until_expiry.
    RETURN abap_false.
  ENDMETHOD.
ENDCLASS.
