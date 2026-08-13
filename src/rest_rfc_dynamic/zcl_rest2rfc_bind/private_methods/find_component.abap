**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

  METHOD find_component.
*&    Field matching: exact first, then ignoring underscores so that
*&    camelCase clients still work.
*&    Caution: if a structure contains both POITEM and PO_ITEM, the
*&    first hit wins.

    DATA(lv_key) = to_upper( iv_key ).

    IF line_exists( io_struct->components[ name = lv_key ] ).
      rv_name = lv_key.
      RETURN.
    ENDIF.

    LOOP AT io_struct->components INTO DATA(ls_comp).
      IF replace( val = CONV string( ls_comp-name ) sub = `_` with = `` occ = 0 ) = lv_key.
        rv_name = ls_comp-name.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
