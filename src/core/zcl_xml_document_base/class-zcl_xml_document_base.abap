**************************************************************************
*   Class attributes.                                                    *
**************************************************************************
Instantiation: Public
Message class:
State: Implemented
Final Indicator:
R/3 Release: 751

**************************************************************************
*   Public section of class.                                             *
**************************************************************************
class ZCL_XML_DOCUMENT_BASE definition
  public
  create public .

*"* public components of class ZCL_XML_DOCUMENT_BASE
*"* do not include other source files here!!
public section.
  type-pools IXML .

  constants C_NO_IXML type SYSUBRC value 99 ##NO_TEXT.
  constants C_OK type SYSUBRC value 0 ##NO_TEXT.
  constants C_NOT_FOUND type SYSUBRC value 2 ##NO_TEXT.
  constants C_FAILED type SYSUBRC value 9999 ##NO_TEXT.
  constants C_PATH_SEP type CHAR1 value '/' ##NO_TEXT.
  data M_DOCUMENT type ref to IF_IXML_DOCUMENT read-only .
  data M_CURR_NODE type ref to IF_IXML_NODE read-only .

  methods IS_INITIAL
    returning
      value(INITIAL) type XFLAG .
  methods SET_DATA
    importing
      NAME type STRING default 'DATA'
      ALIAS type STRING optional
      DATAOBJECT type ANY
      PARENT_NODE type ref to IF_IXML_NODE optional
      value(CONTROL) type DCXMLSERCL optional
    returning
      value(RETCODE) type SYSUBRC .
  methods GET_DATA
    importing
      NAME type STRING optional
    exporting
      RETCODE type SYSUBRC
    changing
      DATAOBJECT type ANY .
  methods INSERT_DOCUMENT_AS_CHILD
    importing
      NODE type ref to IF_IXML_NODE
      DOCUMENT type ref to CL_XML_DOCUMENT_BASE
      NO_COPY type XFLAG default SPACE
    returning
      value(RETCODE) type SYSUBRC .
  methods GET_NODE_PATH
    importing
      NODE type ref to IF_IXML_NODE optional
    returning
      value(PATH) type STRING .
  methods GET_NODE_CHILD
    importing
      NODE type ref to IF_IXML_NODE optional
      INDEX type I default 0
    returning
      value(CHILD_NODE) type ref to IF_IXML_NODE .
  methods GET_FIRST_NODE
    returning
      value(NODE) type ref to IF_IXML_NODE .
  methods GET_NODE_ATTRIBUTE
    importing
      NODE type ref to IF_IXML_NODE
      NAME type STRING
    returning
      value(VALUE) type STRING .
  methods GET_NODE_ATTR
    importing
      NODE type ref to IF_IXML_NODE
      INDEX type I default 0
    exporting
      NAME type STRING
      VALUE type STRING .
  methods GET_CHILD_DOCUMENT
    importing
      NODE type ref to IF_IXML_NODE
      EMBEDDED_ONLY type XFLAG default SPACE
      IN_DOCUMENT type ref to CL_XML_DOCUMENT_BASE optional
    returning
      value(OUT_DOCUMENT) type ref to CL_XML_DOCUMENT_BASE .
  methods GET_NODE_DATA
    importing
      NODE type ref to IF_IXML_NODE
    exporting
      value(DATAOBJECT) type ANY
      RETCODE type SYSUBRC .
  methods GET_NODE_VALUE
    importing
      NODE type ref to IF_IXML_NODE
    returning
      value(VALUE) type STRING .
  methods GET_NODE_NAME
    importing
      NODE type ref to IF_IXML_NODE optional
    returning
      value(VALUE) type STRING .
  methods GET_NODE_FROM_ID
    importing
      GID type I
    returning
      value(NODE) type ref to IF_IXML_NODE .
  methods FIND_NODE_TABLE
    importing
      TABNAME type STRING optional
      ROOT type ref to IF_IXML_NODE optional
    exporting
      T_NODES type SWXMLNODES
      RETCODE type SYSUBRC .
  methods FIND_NODE
    importing
      NAME type STRING
      ROOT type ref to IF_IXML_NODE optional
    returning
      value(NODE) type ref to IF_IXML_NODE .
  methods CREATE_COPY_FROM
    importing
      SOURCE type ref to CL_XML_DOCUMENT_BASE
    returning
      value(RETCODE) type SYSUBRC .
  methods CONSTRUCTOR
    importing
      DOCUMENT type ref to IF_IXML_DOCUMENT optional .
  methods RENDER_2_STRING
    importing
      PRETTY_PRINT type XFLAG default 'X'
    exporting
      value(RETCODE) type SYSUBRC
      STREAM type STRING
      SIZE type SYTABIX .
  methods RENDER_2_XSTRING
    importing
      PRETTY_PRINT type XFLAG default 'X'
    exporting
      value(RETCODE) type SYSUBRC
      STREAM type XSTRING
      SIZE type SYTABIX .
  methods RENDER_2_TABLE
    importing
      PRETTY_PRINT type XFLAG default 'X'
    exporting
      value(RETCODE) type SYSUBRC
      TABLE type STANDARD TABLE
      SIZE type SYTABIX .
  methods PARSE_STRING
    importing
      STREAM type STRING
    returning
      value(RETCODE) type SYSUBRC .
  methods PARSE_XSTRING
    importing
      STREAM type XSTRING
    returning
      value(RETCODE) type SYSUBRC .
  methods PARSE_TABLE
    importing
      TABLE type STANDARD TABLE
      value(SIZE) type SYTABIX default 0
    returning
      value(RETCODE) type SYSUBRC .
  methods CREATE_WITH_DATA
    importing
      NAME type STRING default 'DATA'
      DATAOBJECT type ANY
    returning
      value(RETCODE) type SYSUBRC .
  methods CREATE_WITH_TABLE
    importing
      TABLE type STANDARD TABLE
      value(SIZE) type SYTABIX default 0
    returning
      value(RETCODE) type SYSUBRC .
  methods EXPORT_TO_FILE
    importing
      FILENAME type LOCALFILE
    returning
      value(RETCODE) type SYSUBRC .
  methods IMPORT_FROM_FILE
    importing
      FILENAME type LOCALFILE
    returning
      value(RETCODE) type SYSUBRC .
  methods CREATE_WITH_NODE
    importing
      NODE type ref to IF_IXML_NODE
    returning
      value(RETCODE) type SYSUBRC .
  methods CREATE_EMPTY_DOCUMENT
    returning
      value(RETCODE) type SYSUBRC .
  methods CREATE_WITH_DOM
    importing
      DOCUMENT type ref to IF_IXML_DOCUMENT
    returning
      value(RETCODE) type SYSUBRC .
  methods FIND_ATTRIBUTE
    importing
      NODE_NAME type STRING
      ATTR_NAME type STRING
      ROOT type ref to IF_IXML_NODE optional
    returning
      value(VALUE) type STRING .
  methods SET_ATTRIBUTE
    importing
      NAME type STRING
      VALUE type STRING optional
      NODE type ref to IF_IXML_NODE optional
    returning
      value(RETCODE) type SYSUBRC .
  methods CREATE_SIMPLE_ELEMENT_PNAME
    importing
      NAME type STRING
      VALUE type STRING optional
      PARENT_NAME type STRING optional
    returning
      value(NEW_NAME) type STRING .
  methods CREATE_SIMPLE_ELEMENT
    importing
      NAME type STRING
      NAMESPACE type STRING optional
      VALUE type STRING optional
      PARENT type ref to IF_IXML_NODE optional
    returning
      value(NEW_NODE) type ref to IF_IXML_NODE .
  methods FIND_SIMPLE_ELEMENT
    importing
      NAME type STRING
      ROOT type ref to IF_IXML_NODE optional
    returning
      value(VALUE) type STRING .
  methods FREE .
  methods GET_NAMESPACE_DEF
    importing
      NODE type ref to IF_IXML_NODE optional
      ALIAS type STRING optional
    exporting
      URI type STRING .
  methods ADD_NAMESPACE_DEF
    importing
      NODE type ref to IF_IXML_NODE optional
      ALIAS type STRING
      URI type STRING
      LOCATION type STRING optional
      IS_TARGETNS type XFLAG default SPACE
    returning
      value(RETCODE) type SYSUBRC .
  methods SET_ENCODING
    importing
      CHARSET type STRING .
  methods GET_LAST_PARSE_ERROR
    returning
      value(RE_PARSE_ERROR) type ref to IF_IXML_PARSE_ERROR .
  methods SET_DTD_RESTRICTION
    importing
      ON type XFLAG
      MAX_EXPANSION type I .

**************************************************************************
*   Private section of class.                                            *
**************************************************************************
*" private components of class CL_XML_DOCUMENT
*" do not include other source files here!!
private section.


**************************************************************************
*   Protected section of class.                                          *
**************************************************************************
*"* protected components of class ZCL_XML_DOCUMENT_BASE
*"* do not include other source files here!!
protected section.

  class-data G_IXML type ref to IF_IXML .
  class-data G_STREAM_FACTORY type ref to IF_IXML_STREAM_FACTORY .
  data MS_CHANGED type SWXML_CHG .
  data M_PARSE_ERROR type ref to IF_IXML_PARSE_ERROR .
  data M_DTD_EXPANSION type I value 0 ##NO_TEXT.

  methods PARSE
    importing
      STREAM type ref to IF_IXML_ISTREAM
    returning
      value(RETCODE) type SYSUBRC .
  methods RENDER
    importing
      PRETTY_PRINT type XFLAG default 'X'
      STREAM type ref to IF_IXML_OSTREAM
    returning
      value(RETCODE) type SYSUBRC .

**************************************************************************
*   Types section of class.                                              *
**************************************************************************
*"* dummy include to reduce generation dependencies between
*"* class ZCL_XML_DOCUMENT_BASE and it's users.
*"* touched if any type reference has been changed

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
