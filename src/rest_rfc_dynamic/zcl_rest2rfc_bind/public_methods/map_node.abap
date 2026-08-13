**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD map_node.
*& 3. Recursive mapping: tree node -> ABAP data object, with checks

    FIELD-SYMBOLS <lt_tab>  TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_line> TYPE any.
    DATA lv_idx TYPE i.

    READ TABLE it_nodes INTO DATA(ls_node) WITH KEY id = iv_node.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lo_desc) = cl_abap_typedescr=>describe_by_data( cv_target ).

    CASE lo_desc->kind.

*     ---- Elementary type -------------------------------------------
      WHEN cl_abap_typedescr=>kind_elem.

        IF ls_node-kind <> c_kind-value.
          add_error( EXPORTING iv_path    = iv_path
                               iv_code    = |TYPE_MISMATCH|
                               iv_message = |Expected an elementary value, |
                                         && |payload contains { describe_node( ls_node ) }|
                     CHANGING  ct_error   = ct_error ).
          RETURN.
        ENDIF.

        move_value( EXPORTING is_node   = ls_node
                              iv_path   = iv_path
                    CHANGING  cv_target = cv_target
                              ct_error  = ct_error ).

*     ---- Structure --------------------------------------------------
      WHEN cl_abap_typedescr=>kind_struct.

        IF ls_node-kind = c_kind-empty.
          RETURN.        " {} on a structure means: leave it initial
        ENDIF.
        IF ls_node-kind <> c_kind-object.
          add_error( EXPORTING iv_path    = iv_path
                               iv_code    = |TYPE_MISMATCH|
                               iv_message = |Expected a JSON object for structure |
                                         && |{ lo_desc->get_relative_name( ) }, |
                                         && |payload contains { describe_node( ls_node ) }|
                     CHANGING  ct_error   = ct_error ).
          RETURN.
        ENDIF.

        DATA(lo_struct) = CAST cl_abap_structdescr( lo_desc ).

        LOOP AT it_nodes INTO DATA(ls_child) WHERE parent = iv_node.

          DATA(lv_cpath) = |{ iv_path }/{ ls_child-name }|.
          DATA(lv_comp)  = find_component( io_struct = lo_struct
                                           iv_key    = ls_child-name ).
          IF lv_comp IS INITIAL.
            add_error( EXPORTING iv_path    = lv_cpath
                                 iv_code    = |UNKNOWN_FIELD|
                                 iv_message = |{ ls_child-name } is not a field of |
                                           && |structure { lo_struct->get_relative_name( ) }|
                       CHANGING  ct_error   = ct_error ).
            CONTINUE.
          ENDIF.

          ASSIGN COMPONENT lv_comp OF STRUCTURE cv_target TO FIELD-SYMBOL(<lv_comp>).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          map_node( EXPORTING it_nodes  = it_nodes
                              iv_node   = ls_child-id
                              iv_path   = lv_cpath
                    CHANGING  cv_target = <lv_comp>
                              ct_error  = ct_error ).
        ENDLOOP.

*     ---- Internal table --------------------------------------------
      WHEN cl_abap_typedescr=>kind_table.

        IF ls_node-kind = c_kind-empty.
          RETURN.        " [] on a table means: leave it empty
        ENDIF.
        IF ls_node-kind <> c_kind-array.
          add_error( EXPORTING iv_path    = iv_path
                               iv_code    = |TYPE_MISMATCH|
                               iv_message = |Expected a JSON array for a table parameter, |
                                         && |payload contains { describe_node( ls_node ) }|
                     CHANGING  ct_error   = ct_error ).
          RETURN.
        ENDIF.

        ASSIGN cv_target TO <lt_tab>.

        LOOP AT it_nodes INTO ls_child WHERE parent = iv_node.
          lv_idx = lv_idx + 1.

          IF ls_child-name IS NOT INITIAL.
            add_error( EXPORTING iv_path    = |{ iv_path }[{ lv_idx }]|
                                 iv_code    = |TYPE_MISMATCH|
                                 iv_message = |An array element must not carry the |
                                           && |member name { ls_child-name }|
                       CHANGING  ct_error   = ct_error ).
            CONTINUE.
          ENDIF.

          INSERT INITIAL LINE INTO TABLE <lt_tab> ASSIGNING <ls_line>.
          map_node( EXPORTING it_nodes  = it_nodes
                              iv_node   = ls_child-id
                              iv_path   = |{ iv_path }[{ lv_idx }]|
                    CHANGING  cv_target = <ls_line>
                              ct_error  = ct_error ).
        ENDLOOP.

*     ---- Anything else ---------------------------------------------
      WHEN OTHERS.
        add_error( EXPORTING iv_path    = iv_path
                             iv_code    = |NOT_SUPPORTED|
                             iv_message = |The target is neither a structure, a table |
                                       && |nor an elementary field, JSON cannot be mapped|
                   CHANGING  ct_error   = ct_error ).

    ENDCASE.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
