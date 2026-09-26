**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD json_to_parmbind.
*& 6. Main method

    DATA lt_nodes TYPE tt_node.
    DATA lt_bound TYPE HASHED TABLE OF abap_compname WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <lv_data> TYPE any.

    CLEAR: et_parmbind, et_params, et_error.

*   ---- 6.1 Interface metadata ------------------------------------
    get_interface( EXPORTING iv_funcname = iv_funcname
                   IMPORTING et_params   = et_params
                             et_error    = DATA(lt_err) ).
    APPEND LINES OF lt_err TO et_error.
    IF et_error IS NOT INITIAL.
      RETURN.
    ENDIF.

*   ---- 6.2 Parse the payload -------------------------------------
    parse_json( EXPORTING iv_json  = iv_json
                IMPORTING et_nodes = lt_nodes
                          et_error = lt_err ).
    APPEND LINES OF lt_err TO et_error.
    IF et_error IS NOT INITIAL.
      RETURN.
    ENDIF.

    READ TABLE lt_nodes INTO DATA(ls_root) WITH KEY parent = 0.
    IF sy-subrc <> 0.
      add_error( EXPORTING iv_path    = |/|
                           iv_code    = |JSON_PARSE_ERROR|
                           iv_message = |The payload cannot be parsed|
                 CHANGING  ct_error   = et_error ).
      RETURN.
    ENDIF.

    IF ls_root-kind = c_kind-array OR ls_root-kind = c_kind-value.
      add_error( EXPORTING iv_path    = |/|
                           iv_code    = |TYPE_MISMATCH|
                           iv_message = |The root node of the request must be a JSON object|
                 CHANGING  ct_error   = et_error ).
      RETURN.
    ENDIF.

*   ---- 6.3 Map every top level key to a parameter ----------------
    LOOP AT lt_nodes INTO DATA(ls_child) WHERE parent = ls_root-id.

      DATA(lv_path)  = |/{ ls_child-name }|.
      DATA(ls_param) = find_param( it_params = et_params
                                   iv_key    = ls_child-name ).

      IF ls_param-name IS INITIAL.
        add_error( EXPORTING iv_path    = lv_path
                             iv_code    = |UNKNOWN_PARAM|
                             iv_message = |Function { iv_funcname } has no parameter |
                                       && |{ ls_child-name }|
                   CHANGING  ct_error   = et_error ).
        CONTINUE.
      ENDIF.

      IF ls_param-paramclass = 'X'.
        add_error( EXPORTING iv_path    = lv_path
                             iv_code    = |UNKNOWN_PARAM|
                             iv_message = |{ ls_param-name } is an exception, not a parameter|
                   CHANGING  ct_error   = et_error ).
        CONTINUE.
      ENDIF.

      IF ls_param-paramclass = 'E'.
        add_error( EXPORTING iv_path    = lv_path
                             iv_code    = |OUTPUT_ONLY|
                             iv_message = |{ ls_param-name } is an output parameter of the |
                                       && |function and does not accept input|
                   CHANGING  ct_error   = et_error ).
        CONTINUE.
      ENDIF.

      IF line_exists( lt_bound[ table_line = ls_param-name ] ).
        add_error( EXPORTING iv_path    = lv_path
                             iv_code    = |DUPLICATE_PARAM|
                             iv_message = |Parameter { ls_param-name } occurs more than |
                                       && |once in the payload|
                   CHANGING  ct_error   = et_error ).
        CONTINUE.
      ENDIF.

      create_param_data( EXPORTING is_param = ls_param
                         IMPORTING er_data  = DATA(lr_data)
                                   ev_error = DATA(lv_cerr) ).
      IF lv_cerr IS NOT INITIAL.
        add_error( EXPORTING iv_path    = lv_path
                             iv_code    = |NOT_SUPPORTED|
                             iv_message = lv_cerr
                   CHANGING  ct_error   = et_error ).
        CONTINUE.
      ENDIF.

      ASSIGN lr_data->* TO <lv_data>.

      map_node( EXPORTING it_nodes  = lt_nodes
                          iv_node   = ls_child-id
                          iv_path   = lv_path
                CHANGING  cv_target = <lv_data>
                          ct_error  = et_error ).

      " Direction is inverted: an IMPORTING parameter of the function
      " is abap_func_exporting on the caller side
      INSERT VALUE abap_func_parmbind(
               name  = ls_param-name
               kind  = SWITCH #( ls_param-paramclass
                         WHEN 'I' THEN abap_func_exporting
                         WHEN 'C' THEN abap_func_changing
                         WHEN 'T' THEN abap_func_tables )
               value = lr_data ) INTO TABLE et_parmbind.

      INSERT ls_param-name INTO TABLE lt_bound.

    ENDLOOP.

*   ---- 6.4 Mandatory parameter check -----------------------------
    IF iv_strict_missing = abap_true.
      LOOP AT et_params INTO ls_param
           WHERE paramclass CA 'IC' AND optional = abap_false.
        IF NOT line_exists( lt_bound[ table_line = ls_param-name ] ).
          add_error( EXPORTING iv_path    = |/{ ls_param-name }|
                               iv_code    = |MISSING_PARAM|
                               iv_message = |Mandatory parameter { ls_param-name } is missing|
                     CHANGING  ct_error   = et_error ).
        ENDIF.
      ENDLOOP.
    ENDIF.

*   ---- 6.5 Bind the TABLES parameters that were not supplied,
*            a BAPI returns its output through them ----------------
    IF iv_bind_tables = abap_true.
      LOOP AT et_params INTO ls_param WHERE paramclass = 'T'.
        IF line_exists( lt_bound[ table_line = ls_param-name ] ).
          CONTINUE.
        ENDIF.
        create_param_data( EXPORTING is_param = ls_param
                           IMPORTING er_data  = lr_data
                                     ev_error = lv_cerr ).
        IF lv_cerr IS NOT INITIAL.
          CONTINUE.
        ENDIF.
        INSERT VALUE abap_func_parmbind( name  = ls_param-name
                                         kind  = abap_func_tables
                                         value = lr_data ) INTO TABLE et_parmbind.
        INSERT ls_param-name INTO TABLE lt_bound.
      ENDLOOP.
    ENDIF.

*   ---- 6.6 Bind the EXPORTING parameters that were not supplied,
*            so their values come back in the response -------------
    IF iv_bind_exports = abap_true.
      LOOP AT et_params INTO ls_param WHERE paramclass = 'E'.
        IF line_exists( lt_bound[ table_line = ls_param-name ] ).
          CONTINUE.
        ENDIF.
        create_param_data( EXPORTING is_param = ls_param
                           IMPORTING er_data  = lr_data
                                     ev_error = lv_cerr ).
        IF lv_cerr IS NOT INITIAL.
          CONTINUE.
        ENDIF.
        " Direction is inverted: an EXPORTING parameter of the function
        " is abap_func_importing on the caller side
        INSERT VALUE abap_func_parmbind( name  = ls_param-name
                                         kind  = abap_func_importing
                                         value = lr_data ) INTO TABLE et_parmbind.
        INSERT ls_param-name INTO TABLE lt_bound.
      ENDLOOP.
    ENDIF.

*   ---- 6.7 Never return a partially bound parameter table --------
    IF et_error IS NOT INITIAL.
      CLEAR et_parmbind.
    ENDIF.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
