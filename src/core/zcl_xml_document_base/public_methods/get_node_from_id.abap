**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_NODE_FROM_ID .
  data: l_Root    type ref to if_ixml_element,
        l_retcode type sysubrc.

  check not m_document is initial.

  l_Root = m_DOCUMENT->get_root_element( ).

  node = l_Root->find_from_gid( gid = gid ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
