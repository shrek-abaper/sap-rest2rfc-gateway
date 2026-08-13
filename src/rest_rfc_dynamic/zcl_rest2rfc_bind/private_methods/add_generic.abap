**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

  METHOD add_generic.
*&    Recursively expand the generic object into tree nodes

    DATA ls_node TYPE ty_node.
    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    DATA(lo_desc) = cl_abap_typedescr=>describe_by_data( cv_any ).

*   ---- Data reference: dereference one level and retry ------------
    IF lo_desc->kind = cl_abap_typedescr=>kind_ref.
      ASSIGN cv_any->* TO FIELD-SYMBOL(<lv_inner>).
      IF sy-subrc <> 0.
        " Unbound reference = {} or [], kind not detectable
        gv_seq = gv_seq + 1.
        APPEND VALUE ty_node( id     = gv_seq
                              parent = iv_parent
                              name   = iv_name
                              kind   = c_kind-empty ) TO ct_nodes.
        RETURN.
      ENDIF.
      add_generic( EXPORTING iv_parent = iv_parent
                             iv_name   = iv_name
                   CHANGING  cv_any    = <lv_inner>
                             ct_nodes  = ct_nodes ).
      RETURN.
    ENDIF.

    gv_seq = gv_seq + 1.
    ls_node-id     = gv_seq.
    ls_node-parent = iv_parent.
    ls_node-name   = iv_name.

    CASE lo_desc->kind.

*     ---- JSON object -----------------------------------------------
      WHEN cl_abap_typedescr=>kind_struct.
        ls_node-kind = c_kind-object.
        APPEND ls_node TO ct_nodes.
        DATA(lv_parent) = ls_node-id.

        DATA(lo_struct) = CAST cl_abap_structdescr( lo_desc ).
        LOOP AT lo_struct->components INTO DATA(ls_comp).
          ASSIGN COMPONENT ls_comp-name OF STRUCTURE cv_any TO FIELD-SYMBOL(<lv_comp>).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          add_generic( EXPORTING iv_parent = lv_parent
                                 iv_name   = CONV string( ls_comp-name )
                       CHANGING  cv_any    = <lv_comp>
                                 ct_nodes  = ct_nodes ).
        ENDLOOP.

*     ---- JSON array ------------------------------------------------
      WHEN cl_abap_typedescr=>kind_table.
        ls_node-kind = c_kind-array.
        APPEND ls_node TO ct_nodes.
        lv_parent = ls_node-id.

        ASSIGN cv_any TO <lt_tab>.
        LOOP AT <lt_tab> ASSIGNING FIELD-SYMBOL(<ls_row>).
          add_generic( EXPORTING iv_parent = lv_parent
                                 iv_name   = ||
                       CHANGING  cv_any    = <ls_row>
                                 ct_nodes  = ct_nodes ).
        ENDLOOP.

*     ---- JSON scalar (always a string after GENERATE) --------------
      WHEN cl_abap_typedescr=>kind_elem.
        ls_node-kind  = c_kind-value.
        ls_node-value = cv_any.
        APPEND ls_node TO ct_nodes.

      WHEN OTHERS.
        ls_node-kind = c_kind-empty.
        APPEND ls_node TO ct_nodes.

    ENDCASE.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
