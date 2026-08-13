**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD parse_json.
*& 2. Parsing: /UI2/CL_JSON=>GENERATE -> flat syntax tree
*&    In the generic object returned by GENERATE the structure
*&    components are themselves REF TO DATA, so the walk has to
*&    dereference level by level.

    DATA lr_data TYPE REF TO data.
    FIELD-SYMBOLS <lv_root> TYPE any.

    CLEAR: et_nodes, et_error.
    gv_seq = 0.

    IF iv_json IS INITIAL.
      add_error( EXPORTING iv_path    = |/|
                           iv_code    = |JSON_PARSE_ERROR|
                           iv_message = |Request body is empty|
                 CHANGING  ct_error   = et_error ).
      RETURN.
    ENDIF.

    TRY.
        lr_data = /ui2/cl_json=>generate( json = iv_json ).
      CATCH cx_root INTO DATA(lx_gen).
        add_error( EXPORTING iv_path    = |/|
                             iv_code    = |JSON_PARSE_ERROR|
                             iv_message = lx_gen->get_text( )
                   CHANGING  ct_error   = et_error ).
        RETURN.
    ENDTRY.

    IF lr_data IS NOT BOUND.
      " The payload is {} or it is syntactically broken. GENERATE
      " returns an unbound reference for both cases, so they cannot be
      " told apart. Treat it as an empty object; the mandatory
      " parameter check below will then report what is missing.
      APPEND VALUE ty_node( id = 1 parent = 0 kind = c_kind-empty ) TO et_nodes.
      RETURN.
    ENDIF.

    ASSIGN lr_data->* TO <lv_root>.
    add_generic( EXPORTING iv_parent = 0
                           iv_name   = ||
                 CHANGING  cv_any    = <lv_root>
                           ct_nodes  = et_nodes ).

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
