class ZCL_AML_LOG_INJECTOR definition
  public
  abstract
  final
  create public
  for testing .

public section.

  class-methods INJECT_AML_LOG
    importing
      !DOUBLE type ref to ZIF_AML_LOG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AML_LOG_INJECTOR IMPLEMENTATION.


METHOD INJECT_AML_LOG.
ZCL_AML_LOG_FACTORY=>AML_LOG = double.
ENDMETHOD.
ENDCLASS.
