CLASS zcl_aml_log_factory DEFINITION
  PUBLIC ABSTRACT FINAL
  CREATE PUBLIC
  GLOBAL FRIENDS zcl_aml_log_injector.

  PUBLIC SECTION.
    "! Create application log object for usage
    "! @parameter configuration | Configuration for internal process
    "! @parameter result        | New Logging object
    CLASS-METHODS create_aml_log
      IMPORTING configuration TYPE REF TO zif_aml_config OPTIONAL
      RETURNING VALUE(result) TYPE REF TO zif_aml_log.

  PRIVATE SECTION.
    CLASS-DATA double_log TYPE REF TO zif_aml_log.
ENDCLASS.


CLASS zcl_aml_log_factory IMPLEMENTATION.
  METHOD create_aml_log.
    IF double_log IS BOUND.
      RETURN double_log.
    ELSE.
      RETURN NEW zcl_aml_log( configuration ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
