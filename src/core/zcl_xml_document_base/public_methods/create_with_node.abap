**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method CREATE_WITH_NODE .

  data l_node type ref to if_ixml_node.

  retcode = create_empty_document( ).

  check retcode = c_ok.

  check not node is initial.

  l_node = node->clone( ).

  check not l_node is initial.

  retcode = m_document->append_child( new_child = l_node ).


endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
