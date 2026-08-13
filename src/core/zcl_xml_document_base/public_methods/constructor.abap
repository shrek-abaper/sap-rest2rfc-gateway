**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method CONSTRUCTOR .


* --- create global interfaces ----
  if g_ixml is initial.
    g_ixml = cl_ixml=>create( ).
    if not g_ixml is initial.
       g_stream_factory = g_ixml->create_stream_factory( ).
    endif.
  endif.

  m_document = document.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
