**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

  METHOD create_param_data.
*& 5. Create the data object of a single parameter

    DATA lo_desc TYPE REF TO cl_abap_typedescr.

    CLEAR: er_data, ev_error.

    IF is_param-type_name IS INITIAL.
      ev_error = |Parameter { is_param-name } is not typed with a DDIC type, |
              && |dynamic mapping is not possible|.
      RETURN.
    ENDIF.

    cl_abap_typedescr=>describe_by_name(
      EXPORTING  p_name         = is_param-type_name
      RECEIVING  p_descr_ref    = lo_desc
      EXCEPTIONS type_not_found = 1 ).
    IF sy-subrc <> 0.
      ev_error = |Type { is_param-type_name } of parameter { is_param-name } does not exist|.
      RETURN.
    ENDIF.

    TRY.
        IF is_param-is_table = abap_true
           AND lo_desc->kind <> cl_abap_typedescr=>kind_table.
          " For TABLES parameters the metadata carries the line type,
          " so the table has to be built around it here
          CREATE DATA er_data TYPE TABLE OF (is_param-type_name).
        ELSE.
          CREATE DATA er_data TYPE (is_param-type_name).
        ENDIF.
      CATCH cx_root INTO DATA(lx_create).
        ev_error = |Cannot create the data object of parameter { is_param-name }: |
                && |{ lx_create->get_text( ) }|.
    ENDTRY.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
