INTERFACE zif_aml_config
  PUBLIC.

  "! Get expiry date for the log, when it is saved
  "! @parameter result | Date for expiry
  METHODS get_expiry_date
    RETURNING VALUE(result) TYPE if_bali_header_setter=>ty_expiry_date.

  "! Get "Keep unitl expiry" falg, if set you can not delete the log before the date
  "! @parameter result | '' = Can be deleted before date, X = Can delete before
  METHODS get_keep_until_expiry
    RETURNING VALUE(result) TYPE if_bali_header_setter=>ty_keep_until_expiry.
ENDINTERFACE.
