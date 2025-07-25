CLASS zcl_aml_log DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aml_log_factory.

  PUBLIC SECTION.
    INTERFACES zif_aml_log.

    METHODS constructor
      IMPORTING setting TYPE zif_aml_log=>default_setting.

  PRIVATE SECTION.
    "! Configuration for internal settings
    DATA setting            TYPE zif_aml_log=>default_setting.

    "! Internal messages
    DATA collected_messages TYPE zif_aml_log=>internal_messages.

    "! Format the message to flat message
    "! @parameter message | Message with all fields
    "! @parameter result  | Flat message
    METHODS format_message_to_string
      IMPORTING !message      TYPE symsg
      RETURNING VALUE(result) TYPE zif_aml_log=>flat_message.

    "! Extract the Exception and fills the message structure (without type)
    "! @parameter exception | Exception class
    "! @parameter result    | Message structure
    METHODS extract_message_from_exception
      IMPORTING !exception    TYPE REF TO cx_root
      RETURNING VALUE(result) TYPE symsg.

    "! Takes a text and fills a placeholder message
    "! @parameter text   | Text or String
    "! @parameter result | Message structure
    METHODS fill_text_to_message
      IMPORTING !text         TYPE clike
      RETURNING VALUE(result) TYPE symsg.
ENDCLASS.


CLASS zcl_aml_log IMPLEMENTATION.
  METHOD constructor.
    me->setting = setting.

    IF me->setting-configuration IS INITIAL.
      me->setting-configuration = NEW zcl_aml_default_config( ).
    ENDIF.

    IF me->setting-external_id IS INITIAL.
      me->setting-external_id = xco_cp=>uuid( )->as( xco_cp_uuid=>format->c36 )->value.
    ENDIF.
  ENDMETHOD.


  METHOD zif_aml_log~add_message.
    INSERT VALUE #( timestamp = utclong_current( )
                    type      = type
                    message   = VALUE symsg( msgty = type
                                             msgid = class
                                             msgno = number
                                             msgv1 = v1
                                             msgv2 = v2
                                             msgv3 = v3
                                             msgv4 = v4 )
                    item      = cl_bali_message_setter=>create( id         = class
                                                                severity   = type
                                                                number     = number
                                                                variable_1 = CONV #( v1 )
                                                                variable_2 = CONV #( v2 )
                                                                variable_3 = CONV #( v3 )
                                                                variable_4 = CONV #( v4 ) ) )
           INTO TABLE collected_messages.
  ENDMETHOD.


  METHOD zif_aml_log~add_message_bapi.
    LOOP AT messages INTO DATA(bapi_message).
      DATA(converted_message) = VALUE symsg( msgty = bapi_message-type
                                             msgid = bapi_message-id
                                             msgno = bapi_message-number
                                             msgv1 = bapi_message-message_v1
                                             msgv2 = bapi_message-message_v2
                                             msgv3 = bapi_message-message_v3
                                             msgv4 = bapi_message-message_v4 ).

      INSERT VALUE #( timestamp = utclong_current( )
                      type      = bapi_message-type
                      message   = converted_message
                      item      = cl_bali_message_setter=>create_from_bapiret2( bapi_message ) )
             INTO TABLE collected_messages.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_aml_log~add_message_exception.
    DATA(actual_exception) = exception.

    WHILE actual_exception IS BOUND.
      INSERT VALUE #( timestamp = utclong_current( )
                      type      = type
                      message   = extract_message_from_exception( actual_exception )
                      item      = cl_bali_exception_setter=>create( severity  = type
                                                                    exception = actual_exception ) )
             INTO TABLE collected_messages.

      actual_exception = actual_exception->previous.
    ENDWHILE.
  ENDMETHOD.


  METHOD zif_aml_log~add_message_system.
    DATA(system_message) = xco_cp=>sy->message( )->value.

    INSERT VALUE #( timestamp = utclong_current( )
                    type      = system_message-msgty
                    message   = system_message
                    item      = cl_bali_message_setter=>create_from_sy( ) )
           INTO TABLE collected_messages.
  ENDMETHOD.


  METHOD zif_aml_log~add_message_text.
    DATA(new_message) = fill_text_to_message( text ).
    new_message-msgty = type.

    INSERT VALUE #( timestamp = utclong_current( )
                    type      = type
                    message   = new_message
                    item      = cl_bali_free_text_setter=>create( severity = type
                                                                  text     = text ) )
           INTO TABLE collected_messages.
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
        DATA(log) = cl_bali_log=>create( ).
        LOOP AT collected_messages REFERENCE INTO DATA(message).
          log->add_item( message->item ).
        ENDLOOP.

        DATA(header) = cl_bali_header_setter=>create( object      = setting-object
                                                      subobject   = setting-subobject
                                                      external_id = setting-external_id
          )->set_expiry( expiry_date       = setting-configuration->get_expiry_date( )
                         keep_until_expiry = setting-configuration->get_keep_until_expiry( ) ).

        log->set_header( header ).

        DATA(database) = cl_bali_log_db=>get_instance( ).
        database->save_log( log                        = log
                            use_2nd_db_connection      = setting-use_2nd_db_connection
                            assign_to_current_appl_job = setting-save_with_job ).

        result = VALUE #( saved  = abap_true
                          handle = log->get_handle( ) ).

      CATCH cx_root INTO DATA(error).
        result = VALUE #( saved   = abap_false
                          message = error->get_text( ) ).
    ENDTRY.
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

    RETURN VALUE symsg( msgid = 'Z_AML'
                        msgno = '001'
                        msgv1 = message_text+0(50)
                        msgv2 = message_text+50(50)
                        msgv3 = message_text+100(50)
                        msgv4 = message_text+150(50) ).
  ENDMETHOD.
ENDCLASS.
