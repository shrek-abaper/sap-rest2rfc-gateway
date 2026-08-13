**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method SET_ENCODING .

  data : l_encode  TYPE REF TO IF_IXML_ENCODING.

  check m_document is bound.

  l_encode = m_document->get_encoding( ).
  if l_encode is initial.
     l_encode = g_ixml->create_encoding(
                             BYTE_ORDER    = 0
                             character_set = charset ).
  else.
     call method l_encode->set_character_set( CHARSET = charset ).
  endif.
  call method m_document->set_encoding( l_encode ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
