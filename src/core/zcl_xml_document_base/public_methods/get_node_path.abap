**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_NODE_PATH .

   data: l_type type i,
         l_name   type string,
         l_parent type ref to if_ixml_node.

   l_parent = node.
   while not l_parent is initial.
       l_type = l_parent->get_type( ).
       if l_type = if_ixml_node=>CO_NODE_ATTRIBUTE or
          l_type = if_ixml_node=>CO_NODE_ELEMENT.
        l_name = l_parent->get_name( ).
*        if path is initial.
*            path = l_name.
*        else.
            concatenate C_PATH_SEP l_name path into path.
*        endif.
      endif.
      l_parent = l_parent->get_parent( ).
   endwhile.


endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
