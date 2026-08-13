**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method CREATE_SIMPLE_ELEMENT_PNAME .
  data: l_Element type ref to if_ixml_element,
        l_parent  type ref to if_ixml_node.

* --- get parent node (empty = root ) ---
  if not m_document is initial and
     not parent_name is initial.
       l_parent = find_node( Name = Parent_name ).
  endif.
* --- create element ---
  l_parent = create_simple_element( Name   = Name
                                    value  = value
                                    Parent = l_parent ).
* --- get path ---
  new_name = GET_NODE_PATH( node = l_parent ).

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
