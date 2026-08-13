**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD function_process.
*&---------------------------------------------------------------------*
*& Dynamic mode. Drop-in replacement for the previous FUNCTION_PROCESS.
*&
*& What disappeared compared with the previous version:
*&   - RFC_GET_FUNCTION_INTERFACE / _P                 -> done inside
*&     ZCL_REST2RFC_BIND=>GET_INTERFACE
*&   - READ TABLE ... PARAMETER = 'REQUEST' / 'RESPONSE'
*&   - LO_INREF / LO_OUTREF / <FS_REQUEST> / <FS_RESPONSE>
*&   - JSON_DESERIALIZE( ) and the IS INITIAL check
*&   - the hard coded two entry LT_PTAB
*&
*& Transaction ownership is driven by GENERAL_CON-COMMITMODE:
*&   ' ' / 'N'  read only. The gateway neither interprets RETURN nor
*&              commits. Behaviour of the previous version.
*&   'G'        the gateway owns the LUW. RETURN is checked, then
*&              BAPI_TRANSACTION_COMMIT or BAPI_TRANSACTION_ROLLBACK.
*&   'F'        the function module commits on its own. The gateway
*&              keeps its hands off.
*& An empty field behaves like 'N', so existing interfaces keep their
*& current behaviour after the field is added.
*&
*& Prerequisite: class ZCL_REST2RFC_BIND is active and ZTIF_GENERAL_CON
*& has the field COMMITMODE (CHAR1). Without that field, replace the
*& line marked (**) with: lv_commitmode = 'N'.
*& JSON is the changing parameter: request in, response out.
*&---------------------------------------------------------------------*
    TYPES: BEGIN OF lty_fault,
             error   TYPE string,
             details TYPE zcl_rest2rfc_bind=>tt_error,
           END OF lty_fault.

*   ABAP_FUNC_EXCPBIND / _TAB come from type group ABAP, exactly like
*   ABAP_FUNC_PARMBIND_TAB. They are not DDIC objects, so SE11 does not
*   find them. If the syntax check rejects them, replace the two DATA
*   lines marked (*) with:
*     TYPES: BEGIN OF lty_excpbind,
*              name  TYPE c LENGTH 30,
*              value TYPE i,
*            END OF lty_excpbind.
*     DATA lt_etab TYPE HASHED TABLE OF lty_excpbind WITH UNIQUE KEY name.
*     DATA ls_etab TYPE lty_excpbind.

    DATA: lt_ptab       TYPE abap_func_parmbind_tab,
          ls_bind       TYPE abap_func_parmbind,
          lt_etab       TYPE abap_func_excpbind_tab,   " (*)
          ls_etab       TYPE abap_func_excpbind,       " (*)
          lt_params     TYPE zcl_rest2rfc_bind=>tt_param,
          ls_param      TYPE zcl_rest2rfc_bind=>ty_param,
          lt_error      TYPE zcl_rest2rfc_bind=>tt_error,
          ls_error      TYPE zcl_rest2rfc_bind=>ty_error,
          lo_type       TYPE REF TO cl_abap_typedescr,
          ls_commit_ret TYPE bapiret2,
          lv_commitmode TYPE c LENGTH 1,
          lv_failed     TYPE abap_bool,
          lv_message    TYPE string,
          lv_subrc      TYPE sy-subrc,
          lv_part       TYPE string,
          lv_pair       TYPE string,
          lv_body       TYPE string,
          ls_fault      TYPE lty_fault.

    FIELD-SYMBOLS: <lv_value>  TYPE any,
                   <lt_return> TYPE ANY TABLE,
                   <ls_return> TYPE any,
                   <lv_type>   TYPE any,
                   <lv_text>   TYPE any.

    lv_commitmode = general_con-commitmode.          " (**)

*   ---------------------------------------------------------------
*   1. JSON -> PARAMETER-TABLE, validated against the real interface
*      of GENERAL_CON-TASKFM.
*   ---------------------------------------------------------------
    zcl_rest2rfc_bind=>json_to_parmbind(
      EXPORTING
        iv_funcname = general_con-taskfm
        iv_json     = json
      IMPORTING
        et_parmbind = lt_ptab
        et_params   = lt_params
        et_error    = lt_error ).

*   ---------------------------------------------------------------
*   2. Payload rejected. Answer before the function module is
*      reached, so nothing can stay half done in the system.
*   ---------------------------------------------------------------
    IF lt_error IS NOT INITIAL.
      READ TABLE lt_error INTO ls_error INDEX 1.
      IF ls_error-code EQ 'FUNC_NOT_FOUND'.
*       Wrong TASKFM in the registry, not a wrong request.
        http_status_response-code   = 404.
        http_status_response-reason = |Not Found:{ ls_error-message }|.
      ELSE.
        http_status_response-code   = 400.
        http_status_response-reason = |Bad Request:{ ls_error-message }|.
      ENDIF.
      http_status_response-detailed_info = |{ ls_error-code } { ls_error-path }|.

      ls_fault-error   = |BAD_REQUEST|.
      ls_fault-details = lt_error.
      json_serialize( EXPORTING data             = ls_fault
                                pretty_name      = pretty_mode-low_case
                                assoc_arrays     = /ui2/cl_json=>c_bool-true
                                assoc_arrays_opt = /ui2/cl_json=>c_bool-true
                                numc_as_string   = /ui2/cl_json=>c_bool-true
                      RECEIVING r_json           = json ).
      RETURN.
    ENDIF.

*   ---------------------------------------------------------------
*   3. Call the function module.
*      EXCEPTION-TABLE is mandatory in dynamic mode: standard BAPIs
*      still use classic RAISE and the call would dump otherwise.
*      EXCEPTION-TABLE takes a table variable, not a constructor.
*      LV_SUBRC must be read in the statement directly after the
*      call, nothing may be inserted in between.
*   ---------------------------------------------------------------
    ls_etab-name  = 'OTHERS'.
    ls_etab-value = 9.
    INSERT ls_etab INTO TABLE lt_etab.

    TRY.
        CALL FUNCTION general_con-taskfm
          PARAMETER-TABLE lt_ptab
          EXCEPTION-TABLE lt_etab.
        lv_subrc = sy-subrc.
        IF lv_subrc NE 0.
          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  INTO lv_message.
          IF lv_message IS INITIAL.
            lv_message = |Classic exception raised, SY-SUBRC = { lv_subrc }|.
          ENDIF.
        ENDIF.
      CATCH cx_root INTO DATA(lo_cx_root).
        lv_message = lo_cx_root->if_message~get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
*     The function itself failed. Anything it may have registered in
*     the update task must go away before the response is sent.
      IF lv_commitmode EQ 'G'.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
      http_status_response-code   = 500.
      http_status_response-reason = |Internal Server Error:{ lv_message }|.
      RETURN.
    ENDIF.

*   ---------------------------------------------------------------
*   4. Transaction ownership. Only for COMMITMODE = 'G'.
*      Rule: whoever commits must judge RETURN first. In read only
*      mode the RETURN table is handed to the caller untouched.
*   ---------------------------------------------------------------
    IF lv_commitmode EQ 'G'.

*     Look for the RETURN parameter among the bound output parameters.
*     It can be a TABLES parameter (BAPIRET2 table) or a single
*     structure, so both shapes are handled.
      LOOP AT lt_params INTO ls_param.
        CHECK ls_param-paramclass CA 'ECT'.
        CHECK ls_param-name CS 'RETURN'.
        READ TABLE lt_ptab INTO ls_bind WITH KEY name = ls_param-name.
        IF sy-subrc NE 0 OR ls_bind-value IS NOT BOUND.
          CONTINUE.
        ENDIF.
        ASSIGN ls_bind-value->* TO <lv_value>.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.

        lo_type = cl_abap_typedescr=>describe_by_data( <lv_value> ).
        IF lo_type->kind EQ cl_abap_typedescr=>kind_table.
          ASSIGN <lv_value> TO <lt_return>.
          LOOP AT <lt_return> ASSIGNING <ls_return>.
            ASSIGN COMPONENT 'TYPE' OF STRUCTURE <ls_return> TO <lv_type>.
            IF sy-subrc EQ 0 AND <lv_type> CA 'EAX'.
              lv_failed = abap_true.
              ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <ls_return> TO <lv_text>.
              IF sy-subrc EQ 0 AND lv_message IS INITIAL.
                lv_message = <lv_text>.
              ENDIF.
              EXIT.
            ENDIF.
          ENDLOOP.
        ELSEIF lo_type->kind EQ cl_abap_typedescr=>kind_struct.
          ASSIGN COMPONENT 'TYPE' OF STRUCTURE <lv_value> TO <lv_type>.
          IF sy-subrc EQ 0 AND <lv_type> CA 'EAX'.
            lv_failed = abap_true.
            ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <lv_value> TO <lv_text>.
            IF sy-subrc EQ 0 AND lv_message IS INITIAL.
              lv_message = <lv_text>.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_failed EQ abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_failed EQ abap_true.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*       The payload was well formed, the business rules rejected it.
        http_status_response-code   = 422.
        http_status_response-reason = |Unprocessable Entity:{ lv_message }|.
      ELSE.
*       WAIT = 'X' so that the update task is finished before the
*       response leaves. Without it a client that reads back at once
*       may not see its own write.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = ls_commit_ret.
        IF ls_commit_ret-type CA 'EAX'.
          http_status_response-code   = 500.
          http_status_response-reason = |Internal Server Error:{ ls_commit_ret-message }|.
        ENDIF.
      ENDIF.

    ENDIF.

*   ---------------------------------------------------------------
*   5. Bound EXPORTING / CHANGING / TABLES parameters -> one JSON
*      object. This runs for 200, 422 and the commit 500 as well,
*      so the caller always receives the RETURN messages.
*   ---------------------------------------------------------------
    LOOP AT lt_params INTO ls_param.
      CHECK ls_param-paramclass CA 'ECT'.
      READ TABLE lt_ptab INTO ls_bind WITH KEY name = ls_param-name.
      IF sy-subrc NE 0 OR ls_bind-value IS NOT BOUND.
        CONTINUE.
      ENDIF.
      ASSIGN ls_bind-value->* TO <lv_value>.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

      json_serialize( EXPORTING data             = <lv_value>
                                pretty_name      = pretty_mode-low_case
                                assoc_arrays     = /ui2/cl_json=>c_bool-true
                                assoc_arrays_opt = /ui2/cl_json=>c_bool-true
                                numc_as_string   = /ui2/cl_json=>c_bool-true
                      RECEIVING r_json           = lv_part ).

      lv_pair = |"{ to_lower( ls_param-name ) }":{ lv_part }|.
      IF lv_body IS INITIAL.
        lv_body = lv_pair.
      ELSE.
        lv_body = |{ lv_body },{ lv_pair }|.
      ENDIF.
    ENDLOOP.

    json = |\{{ lv_body }\}|.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
