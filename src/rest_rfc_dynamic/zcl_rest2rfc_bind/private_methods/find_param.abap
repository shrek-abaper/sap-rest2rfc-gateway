**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

  METHOD find_param.

    DATA(lv_key) = to_upper( iv_key ).

    READ TABLE it_params INTO rs_param WITH KEY name = lv_key.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    LOOP AT it_params INTO DATA(ls_param).
      IF replace( val = CONV string( ls_param-name ) sub = `_` with = `` occ = 0 ) = lv_key.
        rs_param = ls_param.
        RETURN.
      ENDIF.
    ENDLOOP.

    CLEAR rs_param.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
