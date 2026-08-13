**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD if_http_extension~handle_request.

    DATA:lv_uri    TYPE string,
         lv_method TYPE string,
         lv_path   TYPE string,
         lt_params TYPE uri_paramt,
         lv_langu  TYPE string,
         lv_json   TYPE string.

    lv_method = server->request->get_header_field( '~request_method' ).
    lv_uri    = server->request->get_header_field( '~request_uri' ).
*    LV_LANGU  = server->request->get_header_field( '~request_' ).

    http_status_response-code   = 200.
    http_status_response-reason = |OK|.

    split_uri( EXPORTING uri    = lv_uri
               IMPORTING path   = lv_path
                         params = lt_params ).

    check_uri( EXPORTING method = lv_method
                         path   = lv_path
                         params = lt_params ).

    lv_json = server->request->if_http_entity~get_cdata( ).

    write_log( mode = record_mode-import content = lv_json ).

    IF http_status_response-code EQ 200.
      function_process( CHANGING json   = lv_json ).

      IF http_status_response-code EQ 200.
        server->response->set_content_type( 'application/json' ).
        server->response->set_cdata( data = lv_json ).
      ENDIF.
    ENDIF.

    server->response->set_status( code = http_status_response-code reason = http_status_response-reason ).

    write_log( mode = record_mode-export content = lv_json code = http_status_response-code reason = http_status_response-reason ).
  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
