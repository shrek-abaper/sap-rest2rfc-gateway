**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_CHILD_DOCUMENT.

  data:  l_child type ref to if_ixml_node,
         l_type  type i,
         l_node  type ref to if_ixml_node.

  clear out_document.
  check not node is initial.

* --- default: given node is root of subtree ---
  if embedded_only is initial.
     l_node = node.
  else.
* --- special case: node has only one subtree as child ->
*     return only subtree <A> <B>xxx</B> </A> -> B is root ---
     check node->NUM_CHILDREN( ) = 1.
     l_child = node->GET_FIRST_CHILD( ).
     l_node = l_child.
  endif.

  check not l_node is initial.
  l_type = l_node->get_type( ).
  check l_type = if_ixml_node=>CO_NODE_ELEMENT or
        l_type = if_ixml_node=>CO_NODE_DOCUMENT.


* --- create returning object if don't exist !
  if in_document is initial.
     create object out_document. "don't forget to free it later !
  else.
     out_document = in_document.
  endif.

  if out_document->create_with_node( Node = l_node ) <> c_OK .
     clear out_document.
  endif.
*--- returns subtree or null ---

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
