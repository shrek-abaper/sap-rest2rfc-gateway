**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method PARSE_STRING .

  data: l_stream type ref to if_ixml_istream.

  retcode = c_no_ixml.

  check not g_stream_factory is initial.

  l_stream = g_stream_factory->create_istream_string(
             string = stream ).

  retcode = parse( stream = l_stream ).

  call method l_stream->close( ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
