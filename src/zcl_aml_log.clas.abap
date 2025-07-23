CLASS zcl_aml_log DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aml_log_factory.

  PUBLIC SECTION.
    INTERFACES zif_aml_log.

    METHODS constructor
      IMPORTING configuration TYPE REF TO zif_aml_config OPTIONAL.

  PRIVATE SECTION.
    "! Configuration for internal settings
    DATA configuration TYPE REF TO zif_aml_config.

ENDCLASS.


CLASS zcl_aml_log IMPLEMENTATION.
  METHOD constructor.
    IF configuration IS INITIAL.
      me->configuration = NEW zcl_aml_default_config( ).
    ELSE.
      me->configuration = configuration.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
