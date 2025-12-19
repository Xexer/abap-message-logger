"! The factory creates new instances for logs, you can find two methods for this purpose:
"! <ul>
"!  <li><strong>CREATE</strong> - Creates a single log object via settings.</li>
"!  <li><strong>GET_INSTANCE</strong> - Creates an instance and saves it to the identification. When you request
"! the same ID you will get the object from the buffer</li>
"! </ul>
"! <br/>
"! Here you get some informations for the settings for a log object:
"! <ul>
"!  <li><strong>object, subobject</strong> - Identification for the BAL Log and only needed if you want to save the log.</li>
"!  <li><strong>external_id</strong> - External ID for saving and finding the object</li>
"!  <li><strong>default_message_class</strong> - Default message class, when you add a message (ADD_MESSAGE).</li>
"!  <li><strong>default_message_type</strong> - Default type for saving a message (ADD_MESSAGE, ADD_MESSAGE_EXCEPTION, ADD_MESSAGE_TEXT)</li>
"!  <li><strong>no_stacked_exception</strong> - When X you onnly add the top message from the exception, previous is ignored.</li>
"!  <li><strong>save_with_job</strong> - The log is attached to the Application Job and is visible in the Fiori App.</li>
"!  <li><strong>use_2nd_db_connection</strong> - You use a second DB connection to save the log, so no COMMIT in actual session.</li>
"!  <li><strong>emergency_logging</strong> - Logs messages directly, no save needed. Performance is really bad in this mode</li>
"!  <li><strong>configuration</strong> - Object from type ZIF_AML_CONFIG for archiving options.</li>
"! </ul>
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
