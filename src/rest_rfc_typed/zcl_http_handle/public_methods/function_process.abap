**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD function_process.

    DATA:lt_func_params TYPE TABLE OF rfc_fint_p,
         lw_func_params TYPE rfc_fint_p,
         lv_dataname    TYPE string.

    DATA: lo_inref  TYPE REF TO data,
          lo_outref TYPE REF TO data.
    FIELD-SYMBOLS: <fs_request>  TYPE any,
                   <fs_response> TYPE any.

    CALL FUNCTION 'RFC_GET_FUNCTION_INTERFACE_P'
      EXPORTING
        funcname      = general_con-taskfm
*       LANGUAGE      = SY-LANGU
*       NONE_UNICODE_LENGTH        = ' '
      TABLES
        params_p      = lt_func_params
*       RESUMABLE_EXCEPTIONS       =
      EXCEPTIONS
        fu_not_found  = 1
        nametab_fault = 2
        OTHERS        = 3.

    IF sy-subrc EQ 0.
      READ TABLE lt_func_params INTO lw_func_params WITH KEY parameter = 'REQUEST'.
      IF sy-subrc EQ 0.
        lv_dataname = lw_func_params-tabname.
        CREATE DATA lo_inref TYPE (lv_dataname).
        ASSIGN lo_inref->* TO <fs_request>.
      ELSE.
        http_status_response-code = 400.
        http_status_response-reason = |Bad Request:Failed to get function import paramters|.
        RETURN.
      ENDIF.

      READ TABLE lt_func_params INTO lw_func_params WITH KEY parameter = 'RESPONSE'.
      IF sy-subrc EQ 0.
        lv_dataname = lw_func_params-tabname.
        CREATE DATA lo_inref TYPE (lv_dataname).
        ASSIGN lo_inref->* TO <fs_response>.
      ELSE.
        http_status_response-code = 400.
        http_status_response-reason = |Bad Request:Failed to get function export paramters|.
        RETURN.
      ENDIF.

        json_deserialize( EXPORTING json = json
                          CHANGING  data = <fs_request> ).

      IF <fs_request> IS INITIAL.
        http_status_response-code   = 400.
        http_status_response-reason = |Bad Request:Failed to deserialize JSON string|.
      ELSE.

        DATA(lt_ptab) = VALUE abap_func_parmbind_tab( ( name = |REQUEST|   kind = abap_func_exporting value = REF #( <fs_request> ) )
                                                      ( name = |RESPONSE|  kind = abap_func_importing value = REF #( <fs_response> ) )
                                                     ).

        TRY .
            CALL FUNCTION general_con-taskfm PARAMETER-TABLE lt_ptab.
          CATCH cx_root INTO DATA(lo_cx_root).
            DATA(lv_message) = lo_cx_root->if_message~get_text( ).
        ENDTRY.
        IF lv_message IS INITIAL.
            json_serialize( EXPORTING data             = <fs_response>
                                      pretty_name      = pretty_mode-low_case
                                      assoc_arrays     = /ui2/cl_json=>c_bool-true
                                      assoc_arrays_opt = /ui2/cl_json=>c_bool-true
                                      numc_as_string   = /ui2/cl_json=>c_bool-true
                            RECEIVING r_json           = json ).
        ELSE.
          http_status_response-code = 400.
          http_status_response-reason = |Bad Request:{ lv_message }|.
        ENDIF.
      ENDIF.
    ELSE.
      http_status_response-code = 400.
      http_status_response-reason = |Bad Request:Failed to get function paramters|.
    ENDIF.
  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
