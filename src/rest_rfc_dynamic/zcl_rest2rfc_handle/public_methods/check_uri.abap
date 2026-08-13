**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD check_uri.

    IF method NE |POST|.
      http_status_response-code   = 405.
      http_status_response-reason = |Method Not Allowed|.
      RETURN.
    ENDIF.

    IF path NE |/SAP/BC/REST2RFC|.
      http_status_response-code   = 400.
      http_status_response-reason = |Bad Request:URI Path Error|.
      RETURN.
    ENDIF.

    IF NOT line_exists( params[ key = |RFC| ] ).
      http_status_response-code   = 400.
      http_status_response-reason = |Bad Request:Missing parameter 'rfc'|.
      RETURN.
    ENDIF.

    READ TABLE params INTO DATA(wa_params) WITH KEY key = |RFC|.

    SELECT SINGLE * INTO general_con
      FROM ztif_general_con
      WHERE taskfm EQ wa_params-value.
    IF sy-subrc NE 0.
      http_status_response-code   = 404.
      http_status_response-reason = |Not Found:RFC { wa_params-value } Non-allowed|.
      RETURN.
    ENDIF.

    IF general_con-actflg EQ space.
      http_status_response-code   = 404.
      http_status_response-reason = |Not Found:RFC { wa_params-value } not activated|.
      RETURN.
    ENDIF.
  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
