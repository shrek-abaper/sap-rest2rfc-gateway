**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

  METHOD move_value.
*& 4. Scalar assignment with format checks, so that an invalid value
*&    never turns into a short dump inside the function module

    DATA(lv_val)  = is_node-value.
    DATA(lo_desc) = cl_abap_typedescr=>describe_by_data( cv_target ).

    CASE lo_desc->type_kind.

      WHEN 'D'.                                   " DATS
        lv_val = replace( val = lv_val sub = `-` with = `` occ = 0 ).
        IF lv_val IS NOT INITIAL
           AND ( strlen( lv_val ) <> 8 OR lv_val CN `0123456789` ).
          add_error( EXPORTING iv_path    = iv_path
                               iv_code    = |VALUE_INVALID|
                               iv_message = |A date must be YYYY-MM-DD or YYYYMMDD, |
                                         && |received { is_node-value }|
                     CHANGING  ct_error   = ct_error ).
          RETURN.
        ENDIF.

      WHEN 'T'.                                   " TIMS
        lv_val = replace( val = lv_val sub = `:` with = `` occ = 0 ).
        IF lv_val IS NOT INITIAL
           AND ( strlen( lv_val ) <> 6 OR lv_val CN `0123456789` ).
          add_error( EXPORTING iv_path    = iv_path
                               iv_code    = |VALUE_INVALID|
                               iv_message = |A time must be HH:MM:SS or HHMMSS, |
                                         && |received { is_node-value }|
                     CHANGING  ct_error   = ct_error ).
          RETURN.
        ENDIF.

      WHEN 'X' OR 'y'.                            " RAW / XSTRING
        add_error( EXPORTING iv_path    = iv_path
                             iv_code    = |NOT_SUPPORTED|
                             iv_message = |Binary fields require an explicit Base64 |
                                       && |policy in the registry, no implicit conversion|
                   CHANGING  ct_error   = ct_error ).
        RETURN.

      WHEN OTHERS.
        IF lo_desc->type_kind CA c_numeric_kinds.
          IF lv_val IS NOT INITIAL AND lv_val CN `0123456789+-., eE`.
            add_error( EXPORTING iv_path    = iv_path
                                 iv_code    = |VALUE_INVALID|
                                 iv_message = |Expected a number, received { is_node-value }|
                       CHANGING  ct_error   = ct_error ).
            RETURN.
          ENDIF.
        ELSE.
          " GENERATE degrades JSON booleans to text, map them back to
          " the ABAP convention
          IF lv_val = `true` OR lv_val = `TRUE`.
            lv_val = `X`.
          ELSEIF lv_val = `false` OR lv_val = `FALSE`.
            CLEAR lv_val.
          ENDIF.
        ENDIF.

    ENDCASE.

    TRY.
*       GENERATE hands numbers back as type F; an F turned to string
*       is scientific notation, which a packed target cannot parse.
*       Route exponent notation through F, then MOVE converts to the
*       real numeric type of the target.
        IF contains( val = lv_val regex = `[eE]` ).
          DATA(lv_num) = CONV f( lv_val ).
          cv_target = lv_num.
        ELSE.
          cv_target = lv_val.
        ENDIF.
      CATCH cx_root INTO DATA(lx_conv).
        add_error( EXPORTING iv_path    = iv_path
                             iv_code    = |VALUE_INVALID|
                             iv_message = lx_conv->get_text( )
                   CHANGING  ct_error   = ct_error ).
    ENDTRY.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
