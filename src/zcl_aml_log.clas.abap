CLASS zcl_aml_log DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aml_log_factory.

  PUBLIC SECTION.
    INTERFACES zif_aml_log.

    METHODS constructor
      IMPORTING setting TYPE zif_aml_log=>default_setting OPTIONAL.

  PRIVATE SECTION.
    TYPES generic_range TYPE RANGE OF string.

    "! Configuration for internal settings
    DATA setting            TYPE zif_aml_log=>default_setting.

    "! Internal messages
    DATA collected_messages TYPE zif_aml_log=>internal_messages.

    "! Logging object (for access use method get_log)
    DATA log_instance       TYPE REF TO if_bali_log.

    "! Format the message to flat message
    "! @parameter message | Message with all fields
    "! @parameter result  | Flat message
    METHODS format_message_to_string
      IMPORTING !message      TYPE zif_aml_log=>t100_message
      RETURNING VALUE(result) TYPE zif_aml_log=>flat_message.

    "! Extract the Exception and fills the message structure (without type)
    "! @parameter exception | Exception class
    "! @parameter result    | Message structure
    METHODS extract_message_from_exception
      IMPORTING !exception    TYPE REF TO cx_root
      RETURNING VALUE(result) TYPE zif_aml_log=>t100_message.

    "! Takes a text and fills a placeholder message
    "! @parameter text   | Text or String
    "! @parameter result | Message structure
    METHODS fill_text_to_message
      IMPORTING !text         TYPE clike
      RETURNING VALUE(result) TYPE zif_aml_log=>t100_message.

    "! Create the header for the log
    "! @parameter result          | Instance of log header
    "! @raising   cx_bali_runtime | Error creating the header
    METHODS create_log_header
      RETURNING VALUE(result) TYPE REF TO if_bali_header_setter
      RAISING   cx_bali_runtime.

    "! Get message class with default value
    "! @parameter class  | Message class input
    "! @parameter result | Assigned message class
    METHODS get_message_class
      IMPORTING !class        TYPE zif_aml_log=>t100_message-msgid
      RETURNING VALUE(result) TYPE zif_aml_log=>t100_message-msgid.

    "! Get message type with default value
    "! @parameter type   | Message type input
    "! @parameter result | Assigned message class
    METHODS get_message_type
      IMPORTING !type         TYPE zif_aml_log=>t100_message-msgty
      RETURNING VALUE(result) TYPE zif_aml_log=>t100_message-msgty.

    "! Returns the instance for the log and creates a new one, if it's empty
    "! @parameter result | Instance for log
    METHODS get_log
      RETURNING VALUE(result) TYPE REF TO if_bali_log.

    "! Collect the message as internal format
    "! @parameter message | T100 message to add
    "! @parameter item    | BALI item for save
    METHODS add_internal_message
      IMPORTING !message TYPE zif_aml_log=>t100_message
                item     TYPE REF TO if_bali_item_setter.

    "! Fill range result, if the value is not initial
    "! @parameter value  | Value for the message
    "! @parameter result | Range as filter
    METHODS fill_range
      IMPORTING !value        TYPE clike
      RETURNING VALUE(result) TYPE generic_range.
ENDCLASS.


CLASS zcl_aml_log IMPLEMENTATION.
  METHOD constructor.
    me->setting = setting.

    IF me->setting-configuration IS INITIAL.
      me->setting-configuration = NEW zcl_aml_default_config( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_aml_log~add_message.
    DATA(new_message_class) = get_message_class( class ).
    DATA(new_message_type) = get_message_type( type ).

    add_internal_message( message = VALUE #( msgty = new_message_type
                                             msgid = new_message_class
                                             msgno = number
                                             msgv1 = v1
                                             msgv2 = v2
                                             msgv3 = v3
                                             msgv4 = v4 )
                          item    = cl_bali_message_setter=>create( id         = new_message_class
                                                                    severity   = new_message_type
                                                                    number     = number
                                                                    variable_1 = CONV #( v1 )
                                                                    variable_2 = CONV #( v2 )
                                                                    variable_3 = CONV #( v3 )
                                                                    variable_4 = CONV #( v4 ) ) ).
  ENDMETHOD.


  METHOD zif_aml_log~add_message_bapi.
    DATA messages TYPE zif_aml_log=>bapi_messages.

    INSERT message INTO TABLE messages.

    zif_aml_log~add_message_bapis( messages ).
  ENDMETHOD.


  METHOD zif_aml_log~add_message_bapis.
    LOOP AT messages INTO DATA(bapi_message).
      DATA(converted_message) = VALUE zif_aml_log=>t100_message( msgty = bapi_message-type
                                                                 msgid = bapi_message-id
                                                                 msgno = bapi_message-number
                                                                 msgv1 = bapi_message-message_v1
                                                                 msgv2 = bapi_message-message_v2
                                                                 msgv3 = bapi_message-message_v3
                                                                 msgv4 = bapi_message-message_v4 ).

      add_internal_message( message = converted_message
                            item    = cl_bali_message_setter=>create_from_bapiret2( bapi_message ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_aml_log~add_message_exception.
    DATA(actual_exception) = exception.
    DATA(new_message_type) = get_message_type( type ).

    WHILE actual_exception IS BOUND.
      DATA(message) = extract_message_from_exception( actual_exception ).
      message-msgty = new_message_type.

      add_internal_message( message = message
                            item    = cl_bali_exception_setter=>create( severity  = new_message_type
                                                                        exception = actual_exception ) ).

      IF setting-no_stacked_exception = abap_true.
        RETURN.
      ENDIF.

      actual_exception = actual_exception->previous.
    ENDWHILE.
  ENDMETHOD.


  METHOD zif_aml_log~add_message_system.
    add_internal_message( message = xco_cp=>sy->message( )->value
                          item    = cl_bali_message_setter=>create_from_sy( ) ).
  ENDMETHOD.


  METHOD zif_aml_log~add_message_text.
    DATA(new_message_type) = get_message_type( type ).
    DATA(new_message) = fill_text_to_message( text ).
    new_message-msgty = new_message_type.

    add_internal_message( message = new_message
                          item    = cl_bali_free_text_setter=>create( severity = new_message_type
                                                                      text     = CONV #( text ) ) ).
  ENDMETHOD.


  METHOD zif_aml_log~add_message_xco.
    add_internal_message( message = message->value
                          item    = cl_bali_message_setter=>create( id         = message->value-msgid
                                                                    severity   = message->value-msgty
                                                                    number     = message->value-msgno
                                                                    variable_1 = message->value-msgv1
                                                                    variable_2 = message->value-msgv2
                                                                    variable_3 = message->value-msgv3
                                                                    variable_4 = message->value-msgv4 ) ).
  ENDMETHOD.


  METHOD zif_aml_log~add_message_xcos.
    LOOP AT message_container->value INTO DATA(message).
      zif_aml_log~add_message_xco( message ).
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_aml_log~get_messages.
    RETURN collected_messages.
  ENDMETHOD.


  METHOD zif_aml_log~get_messages_bapi.
    RETURN VALUE #( FOR message IN collected_messages
                    ( type       = message-message-msgty
                      id         = message-message-msgid
                      number     = message-message-msgno
                      message_v1 = message-message-msgv1
                      message_v2 = message-message-msgv2
                      message_v3 = message-message-msgv3
                      message_v4 = message-message-msgv4 ) ).
  ENDMETHOD.


  METHOD zif_aml_log~get_messages_flat.
    RETURN VALUE #( FOR message IN collected_messages
                    ( format_message_to_string( message-message ) ) ).
  ENDMETHOD.


  METHOD zif_aml_log~get_messages_rap.
    RETURN VALUE #( FOR message IN collected_messages
                    ( zcx_aml_message=>new_message_from_symsg( message-message ) ) ).
  ENDMETHOD.


  METHOD zif_aml_log~get_messages_xco.
    RETURN xco_cp=>messages( VALUE #( FOR message IN collected_messages
                                      ( xco_cp=>message( message-message ) ) ) ).
  ENDMETHOD.


  METHOD zif_aml_log~has_error.
    LOOP AT collected_messages TRANSPORTING NO FIELDS WHERE type CA 'AEX'.
      RETURN abap_true.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_aml_log~has_warning.
    LOOP AT collected_messages TRANSPORTING NO FIELDS WHERE type CA 'AEXW'.
      RETURN abap_true.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_aml_log~merge_log.
    DATA(external_messages) = log_object->get_messages( ).
    INSERT LINES OF external_messages INTO TABLE collected_messages.
    SORT collected_messages BY timestamp ASCENDING.
  ENDMETHOD.


  METHOD zif_aml_log~save.
    TRY.
        DATA(log) = get_log( ).
        LOOP AT collected_messages REFERENCE INTO DATA(message).
          log->add_item( message->item ).
        ENDLOOP.

        DATA(header) = create_log_header( ).
        log->set_header( header ).

        DATA(database) = cl_bali_log_db=>get_instance( ).
        database->save_log( log                        = log
                            use_2nd_db_connection      = setting-use_2nd_db_connection
                            assign_to_current_appl_job = setting-save_with_job ).

        RETURN VALUE #( saved  = abap_true
                        handle = log->get_handle( ) ).

      CATCH cx_bali_not_possible INTO DATA(bali_error).
        IF bali_error->error_code = bali_error->object_not_allowed.
          RAISE EXCEPTION NEW zcx_aml_error( textid = zcx_aml_error=>error_release ).
        ELSE.
          RETURN VALUE #( saved     = abap_false
                          message   = bali_error->get_text( )
                          exception = bali_error ).
        ENDIF.

      CATCH cx_root INTO DATA(error).
        RETURN VALUE #( saved     = abap_false
                        message   = error->get_text( )
                        exception = error ).
    ENDTRY.
  ENDMETHOD.


  METHOD create_log_header.
    IF setting-external_id IS INITIAL.
      setting-external_id = xco_cp=>uuid( )->as( xco_cp_uuid=>format->c36 )->value.
    ENDIF.

    result = cl_bali_header_setter=>create( object      = setting-object
                                            subobject   = setting-subobject
                                            external_id = setting-external_id ).

    result->set_expiry( expiry_date       = setting-configuration->get_expiry_date( )
                        keep_until_expiry = setting-configuration->get_keep_until_expiry( ) ).
  ENDMETHOD.


  METHOD zif_aml_log~get_number_of_messages.
    RETURN lines( collected_messages ).
  ENDMETHOD.


  METHOD format_message_to_string.
    DATA(xco_message) = xco_cp=>message( message ).
    RETURN |{ message-msgty }{ message-msgno }({ message-msgid }) - { xco_message->get_text( ) }|.
  ENDMETHOD.


  METHOD extract_message_from_exception.
    CASE TYPE OF exception.
      WHEN TYPE if_t100_dyn_msg.
        DATA(t100_message) = CAST if_t100_dyn_msg( exception ).
        RETURN VALUE #( msgid = t100_message->if_t100_message~t100key-msgid
                        msgno = t100_message->if_t100_message~t100key-msgno
                        msgv1 = t100_message->msgv1
                        msgv2 = t100_message->msgv2
                        msgv3 = t100_message->msgv3
                        msgv4 = t100_message->msgv4 ).

      WHEN TYPE if_message.
        RETURN fill_text_to_message( exception->get_text( ) ).
    ENDCASE.
  ENDMETHOD.


  METHOD fill_text_to_message.
    DATA message_text TYPE zif_aml_log=>single_message.

    message_text = text.

    RETURN VALUE zif_aml_log=>t100_message( msgid = 'Z_AML'
                                            msgno = '001'
                                            msgv1 = message_text+0(50)
                                            msgv2 = message_text+50(50)
                                            msgv3 = message_text+100(50)
                                            msgv4 = message_text+150(50) ).
  ENDMETHOD.


  METHOD get_message_class.
    IF class IS NOT INITIAL.
      RETURN class.
    ELSE.
      RETURN setting-default_message_class.
    ENDIF.
  ENDMETHOD.


  METHOD get_message_type.
    IF type IS NOT INITIAL.
      RETURN type.
    ELSEIF setting-default_message_type IS NOT INITIAL.
      RETURN setting-default_message_type.
    ELSE.
      RETURN if_bali_constants=>c_severity_error.
    ENDIF.
  ENDMETHOD.


  METHOD get_log.
    IF log_instance IS INITIAL.
      TRY.
          log_instance = cl_bali_log=>create( ).
        CATCH cx_bali_runtime INTO DATA(bali_error).
          RAISE EXCEPTION NEW zcx_aml_error( textid   = zcx_aml_error=>error_in_creation
                                             previous = bali_error ).
      ENDTRY.
    ENDIF.

    RETURN log_instance.
  ENDMETHOD.


  METHOD zif_aml_log~get_log_handle.
    RETURN get_log( )->get_handle( ).
  ENDMETHOD.


  METHOD add_internal_message.
    INSERT VALUE #( timestamp = utclong_current( )
                    type      = message-msgty
                    message   = message
                    item      = item )
           INTO TABLE collected_messages.
  ENDMETHOD.


  METHOD zif_aml_log~search_message.
    LOOP AT collected_messages INTO DATA(found_message) WHERE     message-msgid IN fill_range( search-msgid )
                                                              AND message-msgno IN fill_range( search-msgno )
                                                              AND message-msgty IN fill_range( search-msgty )
                                                              AND message-msgv1 IN fill_range( search-msgv1 )
                                                              AND message-msgv2 IN fill_range( search-msgv2 )
                                                              AND message-msgv3 IN fill_range( search-msgv3 )
                                                              AND message-msgv4 IN fill_range( search-msgv4 ).
      RETURN VALUE #( found   = abap_true
                      message = found_message-message ).
    ENDLOOP.
  ENDMETHOD.


  METHOD fill_range.
    IF value IS INITIAL.
      RETURN.
    ENDIF.

    RETURN VALUE #( ( sign = 'I' option = 'EQ' low = value ) ).
  ENDMETHOD.
ENDCLASS.
