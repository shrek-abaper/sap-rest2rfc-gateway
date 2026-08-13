**************************************************************************
*   Class attributes.                                                    *
**************************************************************************
Instantiation: Public
Message class:
State: Implemented
Final Indicator: X
R/3 Release: 756

**************************************************************************
*   Public section of class.                                             *
**************************************************************************
CLASS zcl_rest2rfc_bind DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*& CLASS ZCL_REST2RFC_BIND   (parser layer = /UI2/CL_JSON)
*& Version: 2026-08-13 | parser = /UI2/CL_JSON | file zcl_rest2rfc_bind.abap
*& Purpose: read the interface metadata of an RFC / BAPI by function
*&          name, convert a JSON payload into the ABAP input parameter
*&          objects one parameter at a time, and validate the shape of
*&          the payload against the shape of the interface.
*& Layers (only layer 1 depends on the JSON library):
*&   1. PARSE_JSON        JSON      -> flat syntax tree TT_NODE
*&                                     via /UI2/CL_JSON=>GENERATE
*&   2. MAP_NODE          syntax tree -> ABAP data object + validation
*&   3. JSON_TO_PARMBIND  top level keys -> parameters -> PARAMETER-TABLE
*&   Layers 2 and 3 are parser agnostic. To move to CL_SXML or AJSON
*&   later, rewrite PARSE_JSON only.
*& Known trade offs of the /UI2/CL_JSON=>GENERATE route (accepted):
*&   a) An empty object {} and an empty array [] both become an unbound
*&      reference and cannot be told apart.
*&      -> Both are reported as KIND = 'E' (empty). Accepted for a
*&         structure and for a table target, nothing is assigned.
*&      -> Consequence: "PO_ITEMS": {} does NOT raise TYPE_MISMATCH.
*&   b) All scalars degrade to strings, so the original num / bool /
*&      null distinction is lost.
*&   c) JSON keys are upper cased, so the original spelling is not kept
*&      in the reported error paths.
*&   d) Duplicate JSON keys are merged silently, DUPLICATE_FIELD can no
*&      longer be raised.
*&   The core checks (UNKNOWN_PARAM / UNKNOWN_FIELD / TYPE_MISMATCH /
*&   MISSING_PARAM / VALUE_INVALID) are not affected.
*& Verify before productive use: the field names of RFC_FINT_P on this
*& release (SE11) must match the ones used in GET_INTERFACE.


    TYPES:
      BEGIN OF ty_error,
        path    TYPE string,
        code    TYPE string,
        message TYPE string,
      END OF ty_error .
    TYPES:
      tt_error TYPE STANDARD TABLE OF ty_error WITH DEFAULT KEY .

    TYPES:
      BEGIN OF ty_param,
        name       TYPE abap_compname,
        paramclass TYPE char1,          " I / E / C / T / X
        type_name  TYPE string,
        is_table   TYPE abap_bool,
        optional   TYPE abap_bool,
      END OF ty_param .
    TYPES:
      tt_param TYPE STANDARD TABLE OF ty_param WITH DEFAULT KEY .

*   Flat syntax tree
    TYPES:
      BEGIN OF ty_node,
        id     TYPE i,
        parent TYPE i,
        name   TYPE string,             " member name, upper case;
                                        " empty for array elements
        kind   TYPE char1,              " O=object A=array V=value E=empty
        value  TYPE string,
      END OF ty_node .
    TYPES:
      tt_node TYPE STANDARD TABLE OF ty_node WITH DEFAULT KEY .

    CONSTANTS:
      BEGIN OF c_kind,
        object TYPE char1 VALUE 'O',
        array  TYPE char1 VALUE 'A',
        value  TYPE char1 VALUE 'V',
        empty  TYPE char1 VALUE 'E',    " {} or [], kind not detectable
      END OF c_kind .

*   =================================================================
*   Main entry: JSON -> function input parameters
*   =================================================================
    CLASS-METHODS json_to_parmbind
      IMPORTING
        iv_funcname       TYPE rs38l_fnam
        iv_json           TYPE string
        iv_strict_missing TYPE abap_bool DEFAULT abap_true
        iv_bind_tables    TYPE abap_bool DEFAULT abap_true
      EXPORTING
        et_parmbind       TYPE abap_func_parmbind_tab
        et_params         TYPE tt_param
        et_error          TYPE tt_error .

    CLASS-METHODS get_interface
      IMPORTING iv_funcname TYPE rs38l_fnam
      EXPORTING et_params   TYPE tt_param
                et_error    TYPE tt_error .

*   Parser layer: /UI2/CL_JSON=>GENERATE plus an RTTI walk
    CLASS-METHODS parse_json
      IMPORTING iv_json  TYPE string
      EXPORTING et_nodes TYPE tt_node
                et_error TYPE tt_error .

*   Mapping layer: recursive validation and assignment
    CLASS-METHODS map_node
      IMPORTING it_nodes  TYPE tt_node
                iv_node   TYPE i
                iv_path   TYPE string
      CHANGING  cv_target TYPE any
                ct_error  TYPE tt_error .


**************************************************************************
*   Private section of class.                                            *
**************************************************************************
  PRIVATE SECTION.

    " Numeric type kinds: I b s P 8 F a e N
    CONSTANTS c_numeric_kinds TYPE string VALUE 'IbsP8FaeN' .

    CLASS-DATA gv_seq TYPE i .          " node counter used by PARSE_JSON

    CLASS-METHODS add_generic
      IMPORTING iv_parent TYPE i
                iv_name   TYPE string
      CHANGING  cv_any    TYPE any
                ct_nodes  TYPE tt_node .
    CLASS-METHODS create_param_data       IMPORTING !is_param TYPE ty_param       EXPORTING !er_data  TYPE REF TO data                 !ev_error TYPE string .
    CLASS-METHODS move_value
      IMPORTING is_node   TYPE ty_node
                iv_path   TYPE string
      CHANGING  cv_target TYPE any
                ct_error  TYPE tt_error .
    CLASS-METHODS find_component
      IMPORTING io_struct     TYPE REF TO cl_abap_structdescr
                iv_key        TYPE string
      RETURNING VALUE(rv_name) TYPE abap_compname .
    CLASS-METHODS find_param
      IMPORTING it_params      TYPE tt_param
                iv_key         TYPE string
      RETURNING VALUE(rs_param) TYPE ty_param .
    CLASS-METHODS add_error
      IMPORTING iv_path    TYPE string
                iv_code    TYPE string
                iv_message TYPE string
      CHANGING  ct_error   TYPE tt_error .
    CLASS-METHODS describe_node
      IMPORTING is_node       TYPE ty_node
      RETURNING VALUE(rv_text) TYPE string .


**************************************************************************
*   Protected section of class.                                          *
**************************************************************************


**************************************************************************
*   Types section of class.                                              *
**************************************************************************
*"* dummy include to reduce generation dependencies between
*"* class ZCL_REST2RFC_BIND and it's users.
*"* touched if any type reference has been changed

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
