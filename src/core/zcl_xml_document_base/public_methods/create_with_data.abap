**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method CREATE_WITH_DATA .

  retcode = c_no_ixml.

  check not g_ixml is initial.
*-- create the XML tree for the input
  m_document = g_ixml->create_document( ).

  check not m_document is initial.

  retcode = set_data( name = name dataobject = dataobject ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
