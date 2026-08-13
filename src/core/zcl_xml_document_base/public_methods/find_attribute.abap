**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method FIND_ATTRIBUTE .
   data: l_node    type ref to if_ixml_node.

   clear value.

   l_node = find_node( name = node_name root = root ).

   if not l_node is initial.
      value = get_node_attribute( node = l_node name = attr_name ).
   endif.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
