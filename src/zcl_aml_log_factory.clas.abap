CLASS zcl_aml_log_factory DEFINITION
  PUBLIC ABSTRACT FINAL
  CREATE PUBLIC
  GLOBAL FRIENDS zcl_aml_log_injector.

  PUBLIC SECTION.
    TYPES identification TYPE c LENGTH 50.

    CONSTANTS standard_identification TYPE identification VALUE 'DEFAULT'.

    "! Create application log object for usage
    "! @parameter setting | Configuration for internal process
    "! @parameter result  | New Logging object
    CLASS-METHODS create
      IMPORTING setting       TYPE zif_aml_log=>default_setting OPTIONAL
      RETURNING VALUE(result) TYPE REF TO zif_aml_log.

    "! Return an instance for the given identification. If there is no one, a new one is created
    "! @parameter identification | Log identification
    "! @parameter setting        | Configuration for internal process
    "! @parameter result         | New logging object if not found, else returned instance
    CLASS-METHODS get_instance
      IMPORTING !identification TYPE identification               DEFAULT standard_identification
                setting         TYPE zif_aml_log=>default_setting OPTIONAL
      RETURNING VALUE(result)   TYPE REF TO zif_aml_log.

  PRIVATE SECTION.
    TYPES: BEGIN OF log_buffer,
             ident        TYPE identification,
             log_instance TYPE REF TO zif_aml_log,
           END OF log_buffer.
    TYPES log_buffers TYPE SORTED TABLE OF log_buffer WITH UNIQUE KEY ident.

    "! Test Double for Unit Tests
    CLASS-DATA double_log TYPE REF TO zif_aml_log.

    "! Buffer for central access and defined logs
    CLASS-DATA buffer     TYPE log_buffers.
ENDCLASS.


CLASS zcl_aml_log_factory IMPLEMENTATION.
  METHOD create.
    IF double_log IS BOUND.
      RETURN double_log.
    ELSE.
      RETURN NEW zcl_aml_log( setting ).
    ENDIF.
  ENDMETHOD.


  METHOD get_instance.
    TRY.
        RETURN buffer[ ident = identification ]-log_instance.

      CATCH cx_sy_itab_line_not_found.
        result = zcl_aml_log_factory=>create( setting ).

        INSERT VALUE #( ident        = identification
                        log_instance = result ) INTO TABLE buffer.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
