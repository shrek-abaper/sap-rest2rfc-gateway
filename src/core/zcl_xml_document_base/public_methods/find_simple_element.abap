**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method FIND_SIMPLE_ELEMENT .
   data: l_Element type ref to if_ixml_element,
         l_node    type ref to if_ixml_node.

   clear value.

   l_node = find_node( name = name root = root ).

   if not l_node is initial.
        l_element ?= l_node->query_interface( ixml_iid_element ).
        if not l_element is initial.
             value = l_Node->get_value( ).
        endif.

   endif.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
