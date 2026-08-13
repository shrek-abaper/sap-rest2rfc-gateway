**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_NODE_ATTR .

  data: l_attributes type ref to if_ixml_named_node_map,
        l_attribute  type ref to if_ixml_node.

  clear: name, value.

  check not node is initial.

  l_attributes = node->get_attributes( ).
  check not l_attributes is initial.

  l_attribute = l_attributes->get_item( index ).
  check not l_attribute is initial.

  name  = l_attribute->get_name( ).
  value = l_attribute->get_value( ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
