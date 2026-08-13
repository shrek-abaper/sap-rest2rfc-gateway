**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD http_consumer.

    DATA:lo_http_client TYPE REF TO if_http_client,
         lv_len         TYPE i,
         lv_xbody       TYPE xstring.

    IF action NE space.
      SELECT SINGLE * INTO general_con FROM ztif_general_con WHERE ifcode EQ action.
      write_log( mode = record_mode-import content = body ).
    ENDIF.

    cl_http_client=>create_by_url( EXPORTING  url                = uri
                                   IMPORTING  client             = lo_http_client
                                   EXCEPTIONS argument_not_found = 1
                                              plugin_not_active  = 2
                                              internal_error     = 3
                                              OTHERS             = 4 ).
    IF sy-subrc NE 0.
      code   = 999.
      reason = COND #( WHEN sy-subrc EQ 1 THEN |Communication Parameters (Host or Service) Not Available|
                       WHEN sy-subrc EQ 2 THEN |HTTP/HTTPS Communication Not Available|
                       WHEN sy-subrc EQ 3 THEN |Internal Error (for example, name too long)|
                                          ELSE |Create HTTP/HTTPS client failed| ).
      IF action NE space.
        write_log( mode = record_mode-export content = body code = code reason = reason ).
      ENDIF.
      RETURN.
    ENDIF.
*    LOOP AT header_fields INTO DATA(ls_header_fields).
*      lo_http_client->request->set_header_field( name  = ls_header_fields-name value = ls_header_fields-value ).
*    ENDLOOP.
*    LOOP AT params_fields INTO DATA(ls_params_fields).
*      lo_http_client->request->set_form_field( name  = ls_params_fields-name value = ls_params_fields-value ).
*    ENDLOOP.

    "设定调用服务
    lo_http_client->request->set_method( method ).

    "Headers参数
    lo_http_client->request->set_header_fields( header_fields ).

    "Parameters 参数
    lo_http_client->request->set_form_fields( params_fields ).

*    IF NOT body IS INITIAL.
*      lv_len = strlen( body ).
*      lo_http_client->request->set_cdata(
*           data   = body
*           offset = 0
*           length = lv_len ).
*    ENDIF.

    lv_xbody = cl_abap_codepage=>convert_to( source      = body
                                             codepage    = content_type ).
    lv_len = xstrlen( lv_xbody ).
    lo_http_client->request->set_data( data   = lv_xbody
                                       offset = 0
                                       length = lv_len ).

    lo_http_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2 ).

    lo_http_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3 ).

    lo_http_client->response->get_status( IMPORTING code = code reason = reason ).

    REFRESH header_fields.CLEAR body.
    lo_http_client->response->if_http_entity~get_header_fields( CHANGING fields = header_fields ).

*    body = lo_http_client->response->get_cdata( ).
    lv_xbody = lo_http_client->response->get_data( ).
    body     = cl_abap_codepage=>convert_from( source      =  lv_xbody
                                               codepage    =  content_type ).
    IF action NE space.
      write_log( mode = record_mode-export content = body code = code reason = reason ).
    ENDIF.
  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
