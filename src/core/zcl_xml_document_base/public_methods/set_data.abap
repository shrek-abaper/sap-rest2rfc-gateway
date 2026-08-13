**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method SET_DATA .

  data: l_dom TYPE REF TO IF_IXML_ELEMENT.

  retcode = c_no_ixml.

  check not g_ixml is initial.

*-- create document
  if m_document is initial.
      m_document = g_ixml->create_document( ).
  endif.
  check not m_document is initial.

  retcode = c_failed.

*  check not dataobject is initial.

  CALL FUNCTION 'ZSDIXML_DATA_TO_DOM'
     EXPORTING
        NAME        = name
        DATAOBJECT  = dataobject
        CONTROL     = control
     IMPORTING
        DATA_AS_DOM = l_dom
     CHANGING
        DOCUMENT    = m_document
     EXCEPTIONS
        OTHERS      = 01.
  CHECK SY-SUBRC = 0.

  check not l_dom is initial.

  if alias is not initial.
     call method l_dom->SET_NAMESPACE_PREFIX( prefix = alias ).
  endif.

  if parent_node is initial.
     retcode = m_document->append_child( new_child = l_dom ).
  else.
     retcode = parent_node->append_child( new_child = l_dom ).
  endif.

  ms_changed-content = 'X'.

  m_curr_node ?= l_dom.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
