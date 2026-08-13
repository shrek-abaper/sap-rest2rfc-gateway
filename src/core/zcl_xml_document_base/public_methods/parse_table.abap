**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method PARSE_TABLE .

  data: l_stream type ref to if_ixml_istream,
        l_lines  type sytabix.

  retcode = c_no_ixml.

  check not g_stream_factory is initial.

  if size = 0.
     describe TABLE table LINES l_lines.
     check l_lines > 0 .
     size = sy-tleng * l_lines.
  endif.

  l_stream = g_stream_factory->create_istream_itable(
             table = table[]
             size  = size ).

  retcode = parse( stream = l_stream ).

  call method l_stream->close( ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
