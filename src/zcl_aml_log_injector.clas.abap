CLASS zcl_aml_log_injector DEFINITION
  PUBLIC ABSTRACT FINAL
  CREATE PUBLIC
  FOR TESTING.

  PUBLIC SECTION.
    CLASS-METHODS inject_log
      IMPORTING double TYPE REF TO zif_aml_log.
ENDCLASS.


CLASS zcl_aml_log_injector IMPLEMENTATION.
  METHOD inject_log.
    zcl_aml_log_factory=>double_log = double.
  ENDMETHOD.
ENDCLASS.
