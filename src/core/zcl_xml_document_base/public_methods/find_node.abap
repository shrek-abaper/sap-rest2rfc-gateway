**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method FIND_NODE .
  data: l_Root    type ref to if_ixml_element,
        l_retcode type sysubrc.

  if root is initial.
    if not m_document is initial.
      l_root = m_DOCUMENT->get_root_element( ).
    endif.
  else.
    l_root ?= root->query_interface( ixml_iid_element ).
  endif.

  check not l_root is initial.

  if name ca c_path_sep.
    node = l_Root->find_from_path( path = name ).
  else.
    if l_Root->get_name( ) = name .
       node = l_Root.
    else.
       node = l_Root->find_from_name( name = name ).
    endif.
  endif.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
