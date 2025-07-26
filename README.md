# Message Logger for ABAP Cloud (AML)

A logger class for the most use-cases in ABAP Cloud. Focus is the logging of messages and types with the posibility to save the log to the Application Logs.

## ABAP Cloud
Support of ABAP Cloud (ABAP Environment, Public Cloud and Private Cloud) with key capabilities:

- Mock- and testable
- Configuration via Settings
- Factory for Creation and/or Singleton
- Support for Application Job, 2nd DB Connection
- Support for RAP exceptions
- Context data **[Planned]**

## Configuration

You can configure the log during the creation. Here are the different settings explained. All settions and fields are optional.

| Field                 | Description                                                       |
|-----------------------|-------------------------------------------------------------------|
| object                | Application Log - Object                                          |
| subobject             | Application Log - Subobject                                       |
| external_id           | Application Log - External ID                                     |
| default_message_class | Default message class (add_message)                               |
| default_message_type  | Default message_type (add_message, text and exception); Default E |
| no_stacked_exceptions | Only the top exception is extracted                               |
| save_with_job         | Save the log with the Application Job                             |
| use_2nd_db_connection | Use the 2nd connection to save log (Works with rollback work)     |
| configuration         | Configuration object for archive settings                         |

You can create your own configuration, if you want to overwrite archive settings from ZCL_AML_DEFAULT_CONFIG.

## Methods

Methods to add messages to the object:

| Method                | Description                  |
|-----------------------|------------------------------|
| add_message           | T100 message                 |
| add_message_bapi      | BAPIRET2 structure           |
| add_message_bapis     | BAPIRET2 table               |
| add_message_exception | Any exception (also stacked) |
| add_message_system    | System variables (SY)        |
| add_message_text      | Generic text or string       |

Methods to get the collected messages:

| Method            | Description                                               |
|-------------------|-----------------------------------------------------------|
| get_messages      | Internal Format (UTC Timestamp, Type, SYMSG, BALI object) |
| get_messages_bapi | BAPIRET2 table                                            |
| get_messages_flat | String table                                              |
| get_messages_rap  | Exceptions with interface IF_ABAP_BEHV_MESSAGE            |

Methods that help to get more informations:

| Method                 | Description                              |
|------------------------|------------------------------------------|
| get_number_of_messages | Returns the number of collected messages |
| has_error              | Check the messages for Error (AEX)       |
| has_warning            | Check the messages for Warnings (WAEX)   |
| merge_logs             | Merge another log into this one          |
| save                   | Save messages to application log         |
| search_message         | Search for a message in the log          |

## Usage

Here you get some informations, how to use the log. You could also check the Unit Tests for message handling.

### Creation

The normal creation of a log object.

```ABAP
DATA(log) = zcl_aml_log_factory=>create( ).
```

When you want to set some settings in the class, manage them via the constructor.

```ABAP
DATA(log) = zcl_aml_log_factory=>create( VALUE #( default_message_class = 'Z_AML'
                                                  default_message_type  = 'I' ) ).
```                                                  

If you want to reuse the log or havn't saved it, you can use the Singleton principle. You can get the DEFAULT log or create different versions with the identification.

```ABAP
DATA(log) = zcl_aml_log_factory=>get_instance( ).
```

### Messages

Add messages via the different methods. Here to add a simple T100 message:

```ABAP
log->add_message( '001' ).
```

... or if you have catched an exception:

```ABAP
  CATCH cx_bali_runtime INTO DATA(bali_error).
    log->add_message_exception( bali_error ).
ENDTRY.
```

### Analysis

If you want to validate the erros, you could use the helper methods to check for errors.

```ABAP
IF log->has_error( ).
ENDIF
```

### Save

To save the log you simple need to call the save method. Ensure that the settings

```ABAP
log->save( ).
```

### Error

The framework catch possible exceptions and wrapps it in a NO_CHECK exception ZCX_AML_ERROR. For example if you want to save the log and an instance is not created, the exception could be raised.

## Tests

The framework is tested using unit tests, and currently all components are covered. If errors or enhancements are found, we would expand the tests.
