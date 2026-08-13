**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_NODE_VALUE .

  data:  l_child type ref to if_ixml_node,
         l_text  type ref to if_ixml_text,
         l_type  type i.

  clear value.

  l_child = node.

  while not l_child is initial.
* --- node has type TEXT ---
     if l_child->get_type( ) = if_ixml_node=>co_node_text.
*       --- but is it really a text ? ---
        l_text ?= l_child->query_interface( ixml_iid_text ).
        if not l_text is initial and
           l_text->ws_only( ) is initial.
               value = l_child->get_value( ).
               exit.
        endif.
     endif.
* --- sometimes value of node is the childnode ---
     if l_child = node.
        l_child = l_child->GET_FIRST_CHILD( ).
     else.
        exit.
     endif.
  endwhile.

* --- check : node is a element ---
*  if not node->query_interface( ixml_iid_element ) is initial.
*      value = Node->get_value( ).
*  endif.
*--- returns  text of all child elements ---

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
