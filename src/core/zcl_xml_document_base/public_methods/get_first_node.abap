**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_FIRST_NODE .

  data:  l_root  type ref to if_ixml_node,
         l_dom_parent type ref to if_ixml_node.

  check not m_document is initial.

  l_root = m_document.

  node = l_root->get_first_child( ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
