**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method INSERT_DOCUMENT_AS_CHILD .

    data : l_node type ref to if_ixml_node.

    retcode = c_failed.

    check not node is initial.
    check not document is initial.

    l_node = document->get_first_node( ).
*   --- (sometimes) makes a copy of source document ---
    if no_copy is initial and
       not l_node is initial.
         l_node = l_node->clone( ).
    endif.

    check not l_node is initial.
*   --- append document as child ---
    retcode = node->append_child( new_child = l_node ).

    ms_changed-content = 'X'.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
