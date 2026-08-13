**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method CREATE_COPY_FROM .

   data: l_node_s type ref to if_ixml_node,
         l_node_t type ref to if_ixml_node.

   retcode = c_no_ixml.

   check not g_ixml is initial.

   retcode = c_failed.

   check not source is initial.

   clear m_document.
*  --- copy sorce into target-DOM ---
   l_node_s = source->get_first_node( ) .
   if not l_node_s is initial.
       l_node_t = l_node_s->clone( ).
       if not l_node_t is initial.
          m_document = g_ixml->create_document( ).
          check not m_document is initial.
          retcode = m_document->append_child( new_child = l_node_t ).
       endif.
   endif.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
