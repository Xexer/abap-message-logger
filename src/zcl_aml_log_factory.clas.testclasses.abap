CLASS ltc_generation DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS create_log                FOR TESTING RAISING cx_static_check.
    METHODS create_standard_singleton FOR TESTING RAISING cx_static_check.
    METHODS create_specific_singleton FOR TESTING RAISING cx_static_check.
    METHODS create_with_double        FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_generation IMPLEMENTATION.
  METHOD create_log.
    DATA(cut) = zcl_aml_log_factory=>create( ).

    cl_abap_unit_assert=>assert_not_initial( cut ).
  ENDMETHOD.


  METHOD create_standard_singleton.
    DATA(cut) = zcl_aml_log_factory=>get_instance( ).
    DATA(result) = zcl_aml_log_factory=>get_instance( ).

    cl_abap_unit_assert=>assert_not_initial( cut ).
    cl_abap_unit_assert=>assert_equals( exp = result
                                        act = cut ).
  ENDMETHOD.


  METHOD create_specific_singleton.
    DATA(cut) = zcl_aml_log_factory=>get_instance( identification = 'SPEC' ).
    DATA(result) = zcl_aml_log_factory=>get_instance( identification = 'SPEC' ).

    cl_abap_unit_assert=>assert_not_initial( cut ).
    cl_abap_unit_assert=>assert_equals( exp = result
                                        act = cut ).
  ENDMETHOD.


  METHOD create_with_double.
    DATA(double) = zcl_aml_log_factory=>create( ).
    double->add_message_text( 'TEST_VALUE' ).
    zcl_aml_log_injector=>inject_log( double ).

    DATA(cut) = zcl_aml_log_factory=>create( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = cut->get_number_of_messages( ) ).
  ENDMETHOD.
ENDCLASS.
