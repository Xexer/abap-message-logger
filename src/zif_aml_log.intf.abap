INTERFACE zif_aml_log
  PUBLIC.

  TYPES:
    BEGIN OF default_setting,
      object                TYPE cl_bali_header_setter=>ty_object,
      subobject             TYPE cl_bali_header_setter=>ty_subobject,
      external_id           TYPE cl_bali_header_setter=>ty_external_id,
      default_message_class TYPE symsgid,
      default_message_type  TYPE symsgty,
      no_stacked_exception  TYPE abap_boolean,
      save_with_job         TYPE abap_boolean,
      use_2nd_db_connection TYPE abap_boolean,
      configuration         TYPE REF TO zif_aml_config,
    END OF default_setting.

  TYPES:
    single_message TYPE c LENGTH 220,
    t100_message   TYPE symsg.

  TYPES:
    BEGIN OF internal_message,
      timestamp TYPE utclong,
      type      TYPE symsgty,
      message   TYPE t100_message,
      item      TYPE REF TO if_bali_item_setter,
    END OF internal_message,
    internal_messages TYPE STANDARD TABLE OF internal_message WITH EMPTY KEY.

  TYPES:
    bapi_message  TYPE bapiret2,
    bapi_messages TYPE STANDARD TABLE OF bapi_message WITH DEFAULT KEY,

    flat_message  TYPE string,
    flat_messages TYPE STANDARD TABLE OF flat_message WITH EMPTY KEY,

    rap_messages  TYPE STANDARD TABLE OF REF TO if_abap_behv_message WITH EMPTY KEY.

  TYPES:
    BEGIN OF save_result,
      saved     TYPE abap_boolean,
      handle    TYPE if_bali_log=>ty_handle,
      message   TYPE single_message,
      exception TYPE REF TO cx_root,
    END OF save_result.

  TYPES:
    BEGIN OF search_result,
      found   TYPE abap_boolean,
      message TYPE t100_message,
    END OF search_result.

  " Dummy-Text for system messages (as reference)
  DATA message_text TYPE string.

  "! Check if the messages has warnings or higher
  "! @parameter result | X = Warning or Higher, '' = No warning
  METHODS has_warning
    RETURNING VALUE(result) TYPE abap_boolean.

  "! Check if the messages has errors
  "! @parameter result | X = Errors, '' = No error
  METHODS has_error
    RETURNING VALUE(result) TYPE abap_boolean.

  "! Merge the given log into the actual log
  "! @parameter log_object | Source log object
  METHODS merge_log
    IMPORTING log_object TYPE REF TO zif_aml_log.

  "! Save the messages to the application log. Settings could be adjusted via settings in constructor
  "! @parameter result | Result of the operation
  METHODS save
    RETURNING VALUE(result) TYPE save_result.

  "! Add default T100 message
  "! @parameter class  | Message class
  "! @parameter type   | Type for the message
  "! @parameter number | Number of the message
  "! @parameter v1     | Placeholder 1
  "! @parameter v2     | Placeholder 2
  "! @parameter v3     | Placeholder 3
  "! @parameter v4     | Placeholder 4
  METHODS add_message
    IMPORTING !class  TYPE bapi_message-id   OPTIONAL
              !type   TYPE bapi_message-type OPTIONAL
              !number TYPE bapi_message-number
              v1      TYPE any               OPTIONAL
              v2      TYPE any               OPTIONAL
              v3      TYPE any               OPTIONAL
              v4      TYPE any               OPTIONAL.

  "! Add simple text as message
  "! @parameter type | Type for the message
  "! @parameter text | Text (Maximum 200 signs)
  METHODS add_message_text
    IMPORTING !type TYPE bapi_message-type OPTIONAL
              !text TYPE clike.

  "! Add a message from the system fields
  METHODS add_message_system.

  "! Add message from exception
  "! @parameter type      | Type for the message
  "! @parameter exception | Exception
  METHODS add_message_exception
    IMPORTING !type      TYPE bapi_message-type OPTIONAL
              !exception TYPE REF TO cx_root.

  "! Add message from BAPIRET2 structure
  "! @parameter message | Message in BAPIRET2 format
  METHODS add_message_bapi
    IMPORTING !message TYPE bapi_message.

  "! Add message from BAPIRET2 table
  "! @parameter messages | Messages in BAPIRET2 format
  METHODS add_message_bapis
    IMPORTING !messages TYPE bapi_messages.

  "! Add message from XCO class
  "! @parameter message | Messages as XCO reference
  METHODS add_message_xco
    IMPORTING !message TYPE REF TO if_xco_message.

  "! Add message from XCO message container
  "! @parameter message_container | XCO message container
  METHODS add_message_xcos
    IMPORTING message_container TYPE REF TO if_xco_messages.

  "! Get all messages in internal format
  "! @parameter result | Messages in internal format
  METHODS get_messages
    RETURNING VALUE(result) TYPE internal_messages.

  "! Get all messages in flat format
  "! @parameter result | Messages as string table
  METHODS get_messages_flat
    RETURNING VALUE(result) TYPE flat_messages.

  "! Get all messages in BAPIRET2 format
  "! @parameter result | Messages as BAPI table
  METHODS get_messages_bapi
    RETURNING VALUE(result) TYPE bapi_messages.

  "! Get all messages in RAP format (Exceptions)
  "! @parameter result | Messages as Exception
  METHODS get_messages_rap
    RETURNING VALUE(result) TYPE rap_messages.

  "! Get all messages in XCO message container
  "! @parameter result | Messages as XCO container
  METHODS get_messages_xco
    RETURNING VALUE(result) TYPE REF TO if_xco_messages.

  "! Return the number of messages in log
  "! @parameter result | Number of messages
  METHODS get_number_of_messages
    RETURNING VALUE(result) TYPE i.

  "! Returns the log handle for further processing
  "! @parameter result | Log handle
  METHODS get_log_handle
    RETURNING VALUE(result) TYPE if_bali_log=>ty_handle.

  "! Search for a specific message in the log
  "! @parameter search | Message for search
  "! @parameter result | Result structure
  METHODS search_message
    IMPORTING !search       TYPE t100_message
    RETURNING VALUE(result) TYPE search_result.
ENDINTERFACE.
