INTERFACE zif_aml_config
  PUBLIC.


  METHODS add_message_system.

  METHODS merge_log
    IMPORTING log_object TYPE REF TO zif_aml_config.
ENDINTERFACE.
