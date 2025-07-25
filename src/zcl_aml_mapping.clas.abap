CLASS zcl_aml_mapping DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Map message type to BALI severity
    "! @parameter type   | Type for the message
    "! @parameter result | Severity of the message
    CLASS-METHODS map_type_to_severity
      IMPORTING !type         TYPE zif_aml_log=>bapi_message-type
      RETURNING VALUE(result) TYPE if_abap_behv_message=>t_severity.

    "! Map BALI severity to message type
    "! @parameter severity | Severity of the message
    "! @parameter result   | Type for the message
    CLASS-METHODS map_severity_to_type
      IMPORTING severity      TYPE if_abap_behv_message=>t_severity
      RETURNING VALUE(result) TYPE zif_aml_log=>bapi_message-type.
ENDCLASS.


CLASS zcl_aml_mapping IMPLEMENTATION.
  METHOD map_severity_to_type.
    RETURN SWITCH #( severity
                     WHEN if_abap_behv_message=>severity-error   THEN 'E'
                     WHEN if_abap_behv_message=>severity-warning THEN 'W'
                     WHEN if_abap_behv_message=>severity-success THEN 'S'
                     ELSE                                             'I' ).
  ENDMETHOD.


  METHOD map_type_to_severity.
    RETURN SWITCH #( type
                     WHEN 'A' THEN if_abap_behv_message=>severity-error
                     WHEN 'X' THEN if_abap_behv_message=>severity-error
                     WHEN 'E' THEN if_abap_behv_message=>severity-error
                     WHEN 'W' THEN if_abap_behv_message=>severity-warning
                     WHEN 'I' THEN if_abap_behv_message=>severity-information
                     WHEN 'S' THEN if_abap_behv_message=>severity-success
                     ELSE          if_abap_behv_message=>severity-none ).
  ENDMETHOD.
ENDCLASS.
