**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method SET_ATTRIBUTE .
  data: l_Element type ref to if_ixml_element.

  retcode = c_failed.

  check not node is initial.

  l_element ?= node->query_interface( ixml_iid_element ).

  check not l_element is initial.

  retcode = l_element->SET_Attribute( name = name value = value ) .

  ms_changed-content = 'X'.
endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
