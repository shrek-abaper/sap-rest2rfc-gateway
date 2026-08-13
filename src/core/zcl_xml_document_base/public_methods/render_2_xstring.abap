**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method RENDER_2_XSTRING .

   data: l_stream type ref to if_ixml_ostream.

   retcode = c_no_ixml.
   clear stream.

   check not g_stream_factory is initial.

   l_Stream = g_stream_factory->create_ostream_xstring(
                     string = stream ).

   retcode = render( stream       = l_Stream
                     pretty_print = pretty_print ).

   if size is requested.
      size = l_stream->get_num_written_raw( ).
   endif.

   call method l_stream->close( ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
