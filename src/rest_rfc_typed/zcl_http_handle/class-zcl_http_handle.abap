**************************************************************************
*   Class attributes.                                                    *
**************************************************************************
Instantiation: Public
Message class:
State: Implemented
Final Indicator: X
R/3 Release: 751

**************************************************************************
*   Public section of class.                                             *
**************************************************************************
class ZCL_HTTP_HANDLE definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .

  types XML type STRING .
  types LOG_RECORD_MODE type CHAR1 .
  types BOOL type CHAR1 .
  types JSON type STRING .
  types:
    BEGIN OF name_mapping,
        abap TYPE abap_compname,
        json TYPE string,
      END OF name_mapping .
  types:
    BEGIN OF uri_params,
        key   TYPE string,
        value TYPE string,
      END OF uri_params .
  types:
    name_mappings TYPE HASHED TABLE OF name_mapping WITH UNIQUE KEY abap .
  types:
    uri_paramt    TYPE TABLE OF uri_params .
  types PRETTY_NAME_MODE type CHAR1 .
  types:
    BEGIN OF http_status,
        code          TYPE i,
        reason        TYPE string,
        detailed_info TYPE string,
      END OF http_status .

  constants:     BEGIN OF pretty_mode,         none          TYPE char1  VALUE ``,         low_case      TYPE char1  VALUE `L`,         camel_case    TYPE char1  VALUE `X`,         extended      TYPE char1  VALUE `Y`,         user          TYPE char1  VALUE `U`,         user_low_case TYPE char1  VALUE `C`,       END OF  pretty_mode .
  constants:     BEGIN OF c_bool,         true  TYPE bool  VALUE `X`,         false TYPE bool  VALUE ``,       END OF  c_bool .
  class-data GENERAL_LOG type ZTIF_GENERAL_LOG .
  class-data GENERAL_CON type ZTIF_GENERAL_CON .
  class-data HTTP_STATUS_RESPONSE type HTTP_STATUS .
  constants:     BEGIN OF record_mode ,         import TYPE char1 VALUE 'I',         export TYPE char1 VALUE 'O',       END OF record_mode .

  class-methods WRITE_LOG
    importing
      MODE type LOG_RECORD_MODE
      CONTENT type STRING
      CODE type I optional
      REASON type STRING optional .
  class-methods JSON_DESERIALIZE
    importing
      JSON type JSON optional
      JSONX type XSTRING optional
      PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      ASSOC_ARRAYS type BOOL default C_BOOL-FALSE
      ASSOC_ARRAYS_OPT type BOOL default C_BOOL-FALSE
      NAME_MAPPINGS type NAME_MAPPINGS optional
    changing
      DATA type DATA .
  class-methods JSON_SERIALIZE
    importing
      DATA type DATA
      COMPRESS type BOOL default C_BOOL-FALSE
      NAME type STRING optional
      PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      TYPE_DESCR type ref to CL_ABAP_TYPEDESCR optional
      ASSOC_ARRAYS type BOOL default C_BOOL-FALSE
      TS_AS_ISO8601 type BOOL default C_BOOL-FALSE
      EXPAND_INCLUDES type BOOL default C_BOOL-TRUE
      ASSOC_ARRAYS_OPT type BOOL default C_BOOL-FALSE
      NUMC_AS_STRING type BOOL default C_BOOL-FALSE
      NAME_MAPPINGS type NAME_MAPPINGS optional
    returning
      value(R_JSON) type JSON .
  class-methods SPLIT_URI
    importing
      value(URI) type STRING
    exporting
      value(PATH) type STRING
      value(PARAMS) type URI_PARAMT .
  class-methods CHECK_URI
    importing
      METHOD type STRING
      PATH type STRING
      PARAMS type URI_PARAMT .
  class-methods FUNCTION_PROCESS
    changing
      JSON type STRING .
  class-methods HTTP_CONSUMER
    importing
      URI type STRING
      METHOD type STRING
      CONTENT_TYPE type STRING default 'UTF-8'
      ACTION type STRING optional
      PARAMS_FIELDS type TIHTTPNVP optional
    exporting
      CODE type I
      REASON type STRING
    changing
      HEADER_FIELDS type TIHTTPNVP optional
      BODY type STRING .
  class-methods GET_JSON_NODE
    importing
      NODE_SEQUENCE type STRING
    changing
      JSON type STRING
    exceptions
      NODE_NOT_FOUND .
  class-methods ENCODE_BASE64
    importing
      UNENCODED type STRING
    returning
      value(ENCODED) type STRING .
  class-methods DECODE_BASE64
    importing
      ENCODED type STRING
    returning
      value(DECODED) type STRING .
  class-methods XML_SERIALIZE
    importing
      NAME type STRING default 'DATA'
      DATAOBJECT type ANY
      PRETTY_PRINT type XFLAG default 'X'
      CODEPAGE type STRING default 'UTF-8'
      NAME_MAPPINGS type NAME_MAPPINGS optional
    returning
      value(XML) type XML
    exceptions
      XML_SERIALIZE_ERROR
      XML_PRETTY_ERROR .
  class-methods XML_DESERIALIZE
    importing
      XML type XML
      NAME type STRING optional
      NAME_MAPPINGS type NAME_MAPPINGS optional
    exporting
      value(DATAOBJECT) type ANY
    exceptions
      XML_PARSE_ERROR
      XML_DESERIALIZE_ERROR .

**************************************************************************
*   Private section of class.                                            *
**************************************************************************
  PRIVATE SECTION.

**************************************************************************
*   Protected section of class.                                          *
**************************************************************************
  PROTECTED SECTION.

**************************************************************************
*   Types section of class.                                              *
**************************************************************************
*"* dummy include to reduce generation dependencies between
*"* class ZCL_HTTP_HANDLE and it's users.
*"* touched if any type reference has been changed

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
