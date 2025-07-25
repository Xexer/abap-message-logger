CLASS zcx_aml_message DEFINITION
  PUBLIC
  INHERITING FROM cx_no_check FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_abap_behv_message.

    ALIASES msgty FOR if_t100_dyn_msg~msgty.
    ALIASES msgv1 FOR if_t100_dyn_msg~msgv1.
    ALIASES msgv2 FOR if_t100_dyn_msg~msgv2.
    ALIASES msgv3 FOR if_t100_dyn_msg~msgv3.
    ALIASES msgv4 FOR if_t100_dyn_msg~msgv4.

    METHODS constructor
      IMPORTING textid    LIKE if_t100_message=>t100key OPTIONAL
                !previous LIKE previous                 OPTIONAL
                msgty     TYPE symsgty                  OPTIONAL
                msgv1     TYPE simple                   OPTIONAL
                msgv2     TYPE simple                   OPTIONAL
                msgv3     TYPE simple                   OPTIONAL
                msgv4     TYPE simple                   OPTIONAL.

    "! Generates a new message for behavior within RAP
    "! @parameter class    | Message class
    "! @parameter number   | Message number
    "! @parameter severity | Severity
    "! @parameter v1       | Placeholder 1
    "! @parameter v2       | Placeholder 2
    "! @parameter v3       | Placeholder 3
    "! @parameter v4       | Placeholder 4
    "! @parameter result   | Instance for message
    CLASS-METHODS new_message
      IMPORTING !class        TYPE symsgid
                !number       TYPE symsgno
                severity      TYPE if_abap_behv_message=>t_severity
                v1            TYPE simple OPTIONAL
                v2            TYPE simple OPTIONAL
                v3            TYPE simple OPTIONAL
                v4            TYPE simple OPTIONAL
      RETURNING VALUE(result) TYPE REF TO if_abap_behv_message.

    "! Generates a new message from SYMSG
    "! @parameter message | Message in Format
    "! @parameter result  | Instance for message
    CLASS-METHODS new_message_from_symsg
      IMPORTING !message      TYPE symsg
      RETURNING VALUE(result) TYPE REF TO if_abap_behv_message.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcx_aml_message IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    me->msgty = msgty.
    me->msgv1 = msgv1.
    me->msgv2 = msgv2.
    me->msgv3 = msgv3.
    me->msgv4 = msgv4.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.


  METHOD new_message.
    result = NEW zcx_aml_message(
        textid = VALUE #( msgid = class
                          msgno = number
                          attr1 = COND #( WHEN v1 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV1' )
                          attr2 = COND #( WHEN v2 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV2' )
                          attr3 = COND #( WHEN v3 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV3' )
                          attr4 = COND #( WHEN v4 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV4' ) )
        msgty  = zcl_aml_mapping=>map_severity_to_type( severity )
        msgv1  = |{ v1 }|
        msgv2  = |{ v2 }|
        msgv3  = |{ v3 }|
        msgv4  = |{ v4 }| ).

    result->m_severity = severity.
  ENDMETHOD.


  METHOD new_message_from_symsg.
    RETURN new_message( class    = message-msgid
                        number   = message-msgno
                        severity = zcl_aml_mapping=>map_type_to_severity( message-msgty )
                        v1       = message-msgv1
                        v2       = message-msgv2
                        v3       = message-msgv3
                        v4       = message-msgv4 ).
  ENDMETHOD.
ENDCLASS.
