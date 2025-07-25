CLASS ltc_internal_methods DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS flat_message_formatter         FOR TESTING RAISING cx_static_check.
    METHODS extract_exception_plain        FOR TESTING RAISING cx_static_check.
    METHODS extract_exception_rap          FOR TESTING RAISING cx_static_check.
    METHODS extract_exception_standard     FOR TESTING RAISING cx_static_check.
    METHODS extract_exception_no_interface FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS zcl_aml_log DEFINITION LOCAL FRIENDS ltc_internal_methods.

CLASS ltc_internal_methods IMPLEMENTATION.
  METHOD flat_message_formatter.
    DATA(cut) = NEW zcl_aml_log( VALUE #( ) ).

    DATA(result) = cut->format_message_to_string( VALUE #( msgid = 'Z_AML'
                                                           msgty = 'W'
                                                           msgno = '002'
                                                           msgv1 = 'placeholder' ) ).

    cl_abap_unit_assert=>assert_equals( exp = `W002(Z_AML) - Testing the message with placeholder`
                                        act = result ).
  ENDMETHOD.


  METHOD extract_exception_plain.
    DATA(cut) = NEW zcl_aml_log( VALUE #( ) ).

    DATA(result) = cut->extract_message_from_exception( NEW cx_sy_itab_line_not_found( ) ).

    cl_abap_unit_assert=>assert_equals( exp = VALUE symsg( msgid = 'Z_AML'
                                                           msgno = '001'
                                                           msgv1 = 'The specified row is not in the table.' )
                                        act = result ).
  ENDMETHOD.


  METHOD extract_exception_rap.
    DATA(cut) = NEW zcl_aml_log( VALUE #( ) ).
    DATA(exception) = CAST cx_root( zcx_aml_message=>new_message_from_symsg( VALUE #( msgid = 'Z_AML'
                                                                                      msgty = 'W'
                                                                                      msgno = '002'
                                                                                      msgv1 = 'placeholder' ) ) ).

    DATA(result) = cut->extract_message_from_exception( exception ).

    cl_abap_unit_assert=>assert_equals( exp = VALUE symsg( msgid = 'Z_AML'
                                                           msgno = '002'
                                                           msgv1 = 'placeholder' )
                                        act = result ).
  ENDMETHOD.


  METHOD extract_exception_standard.
    DATA(cut) = NEW zcl_aml_log( VALUE #( ) ).

    DATA(result) = cut->extract_message_from_exception( NEW cx_abap_api_state( ) ).

    cl_abap_unit_assert=>assert_equals( exp = VALUE symsg( msgid = 'SY'
                                                           msgno = '530' )
                                        act = result ).
  ENDMETHOD.


  METHOD extract_exception_no_interface.
    DATA(cut) = NEW zcl_aml_log( VALUE #( ) ).

    DATA(result) = cut->extract_message_from_exception( NEW cx_abap_datfm( ) ).

    cl_abap_unit_assert=>assert_equals( exp = VALUE symsg( msgid = 'Z_AML'
                                                           msgno = '001'
                                                           msgv1 = 'An exception was raised.' )
                                        act = result ).
  ENDMETHOD.
ENDCLASS.


CLASS ltc_external_methods DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zif_aml_log.

    METHODS setup.
    METHODS stacked_message FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_external_methods IMPLEMENTATION.
  METHOD setup.
    cut = zcl_aml_log_factory=>create( ).
  ENDMETHOD.


  METHOD stacked_message.
    DATA(last_exception) = NEW cx_sy_itab_line_not_found( ).
    DATA(middle_exception) = NEW cx_abap_api_state( previous = last_exception ).
    DATA(main_exception) = NEW cx_abap_datfm( previous = middle_exception ).

    cut->add_message_exception( main_exception ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = cut->get_number_of_messages( ) ).
  ENDMETHOD.
ENDCLASS.
