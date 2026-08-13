**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Protected
**************************************************************************

method PARSE .

  data: l_parser type ref to if_ixml_parser,
        l_errno  type i.
*        l_error  type ref to if_ixml_parse_error.

  retcode = c_no_ixml.

  check not g_ixml is initial.
*-- create the XML tree for the input
  m_document = g_ixml->create_document( ).

  check not m_document is initial.
  check not stream is initial.

* --- note 2132282 ---
  if m_dtd_expansion > 0.
    stream->set_dtd_restriction( level = if_ixml_istream=>DTD_RESTRICTED ).
    stream->set_max_expansion( m_dtd_expansion ).
  endif.
* ---

  l_parser = g_ixml->create_parser( stream_factory = g_stream_factory
                                    istream        = Stream
                                    document       = m_Document ).

* --- default PARSER omits leading spaces 03.12.02 ---
  l_parser->set_normalizing( IS_NORMALIZING = space ).

  retcode = l_parser->parse( ).

  if retcode ne 0.
      l_errno  = l_parser->num_errors( ).
      if retcode >= l_errno.
          retcode = l_errno.
      endif.
*      if retcode <> 0.
         m_parse_error = l_parser->get_error( index = 0 ).
*         if not l_error is initial. "--- note 1728404 ---

*  g_error_line        = error->get_line( ).
*  g_error_column      = error->get_column( ).
*  str                 = error->get_severity_text( ).
*  g_error_severity    = str.
*  g_error_description = error->get_reason( ).
*         endif.
*      endif.
  endif.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
