**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD get_interface.
*& 1. Read the function interface metadata

    DATA lt_fint TYPE STANDARD TABLE OF rfc_fint_p WITH DEFAULT KEY.

    CLEAR: et_params, et_error.

    CALL FUNCTION 'RFC_GET_FUNCTION_INTERFACE_P'
      EXPORTING
        funcname      = iv_funcname
      TABLES
        params_p      = lt_fint
      EXCEPTIONS
        fu_not_found  = 1
        nametab_fault = 2
        OTHERS        = 3.
    IF sy-subrc <> 0.
      add_error( EXPORTING iv_path    = |/|
                           iv_code    = |FUNC_NOT_FOUND|
                           iv_message = |Function { iv_funcname } does not exist |
                                        && |or its interface cannot be read|
                 CHANGING  ct_error   = et_error ).
      RETURN.
    ENDIF.

    LOOP AT lt_fint INTO DATA(ls_fint).
      " FIELDNAME empty    -> TABNAME is the type name
      " FIELDNAME not empty -> TABNAME-FIELDNAME, e.g. BAPIEKKO-PO_NUMBER
      APPEND VALUE ty_param(
        name       = ls_fint-parameter
        paramclass = ls_fint-paramclass
        type_name  = COND string( WHEN ls_fint-fieldname IS INITIAL
                                  THEN ls_fint-tabname
                                  ELSE |{ ls_fint-tabname }-{ ls_fint-fieldname }| )
        is_table   = COND #( WHEN ls_fint-paramclass = 'T' THEN abap_true ELSE abap_false )
        optional   = COND #( WHEN ls_fint-optional IS NOT INITIAL THEN abap_true ELSE abap_false )
      ) TO et_params.
    ENDLOOP.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
