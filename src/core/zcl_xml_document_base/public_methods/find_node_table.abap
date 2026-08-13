**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method FIND_NODE_TABLE .
  data: l_Root    type ref to if_ixml_element,
        l_cur     type ref to if_ixml_node,
        l_node    like line of t_nodes,
        l_item    type ref to IF_IXML_NODE.


  clear t_nodes[].
  retcode = C_NOT_FOUND.

  if root is initial.
    if not m_document is initial.
      l_root = m_DOCUMENT->get_root_element( ).
    endif.
  else.
    l_root ?= root->query_interface( ixml_iid_element ).
  endif.

  check not l_root is initial.

  if tabname is initial.
     l_cur ?= l_root.
  elseif tabname ca c_path_sep.
    l_cur = l_Root->find_from_path( path = tabname ).
  else.
    l_cur = l_Root->find_from_name( name = tabname ).
  endif.

 check not l_cur is initial.

 l_item = l_cur->get_first_child( ).
 while not l_item is initial.
    l_node-col  = 1.
    l_node-node = l_item->get_first_child( ).
    while not l_node-node is initial.
       append l_node to t_nodes.
       l_node-node = l_node-node->get_next( ).
       add 1 to l_node-col.
    endwhile.
    l_item = l_item->get_next( ) .
 endwhile.

 retcode = c_ok.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
