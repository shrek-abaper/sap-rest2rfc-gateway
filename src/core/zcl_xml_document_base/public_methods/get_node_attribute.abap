**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_NODE_ATTRIBUTE .

  data:  l_element type ref to if_ixml_element.

  clear value.

  check not node is initial.
  check not name is initial.

  l_element ?= node->query_interface( ixml_iid_element ).

  if not l_element is initial.
     value = l_element->get_attribute( name = name ).
  endif.


endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
