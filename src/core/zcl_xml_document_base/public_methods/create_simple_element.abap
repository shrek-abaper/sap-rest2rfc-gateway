**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method CREATE_SIMPLE_ELEMENT .
  data: l_Element type ref to if_ixml_element,
        l_parent  type ref to if_ixml_node.

  if m_document is initial.
     if not g_ixml is initial.
        m_Document = g_ixml->create_document( ).
     endif.
  endif.
  check not m_document is initial.

  if parent is initial.
     l_parent = m_document.
  else.
     l_parent = parent.
  endif.

  l_element = m_Document->create_simple_element_ns(
                           Name   = Name
                           prefix = namespace
                           value  = value
                           Parent = l_parent ).
  new_node = l_element.

  ms_changed-content = 'X'.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
