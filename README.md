# ABAP Message Logger for ABAP Cloud

A logger class for the most use-cases in ABAP Cloud. Focus is the logging of messages and types with the posibility to save the log to the Application Logs.

## ABAP Cloud
Support of ABAP Cloud (ABAP Environment, Public Cloud and Private Cloud) with key capabilities:

- Mock- and testable
- Configuration via Settings
- Factory for Creation and/or Singleton
- Support for Application Job, 2nd DB Connection
- Context (data)
- RAP Support

## Formats

Formats for messages

- T100 Message

Formats for output:

- Internal Format (UTC Timestamp, Type, SYMSG, BALI object)
- BAPIRET2
- 

## Usage

tbd

```ABAP
DATA(log) = zcl_aml_log_factory=>create( ).
```
