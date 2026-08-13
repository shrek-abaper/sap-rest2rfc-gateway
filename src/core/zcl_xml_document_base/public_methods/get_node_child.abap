**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_NODE_CHILD .

   data: l_child_list type ref to if_ixml_node_list,
         l_index      type i.

   check not node is initial.

   l_child_list = node->get_children( ).

   check not l_child_list is initial.

*   l_index = index + 1. "--- to be compatible to release 4.6 ---
   l_index = index .
   child_node = l_child_list->get_item( index = l_index ).

*  --- index starts at 0 always! But sometimes a (unvisible) textnode
*      was insert before the child element. Within the method, the
*      textnode can't be skiped because the index has to be increased
*      and the second access return the same element !!! ---
*  --- following coding arroung the method get elements only
*
*    while l_index < l_node->num_children( ).
*       l_child = doc->get_node_child( node = l_node
*                                      index = l_index ).
*       if l_child is bound and
*         l_child->QUERY_INTERFACE( ixml_iid_element ) is not initial.
*         exit.
*       endif.
*       l_index = l_index + 1.
*    endwhile.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
