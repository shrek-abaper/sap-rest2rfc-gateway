**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

METHOD ADD_NAMESPACE_DEF .

  DATA: l_element TYPE REF TO if_ixml_element.

  IF node IS INITIAL.
    IF NOT m_document IS INITIAL.
      l_element = m_document->get_root_element( ).
    ENDIF.
  ELSE.
    l_element ?= node->query_interface( ixml_iid_element ).
  ENDIF.


  IF l_element IS BOUND.
    IF alias IS INITIAL.
      retcode = l_element->set_attribute(
                    name   = 'xmlns'                        "#EC NOTEXT
                    value  = uri ).
    ELSE.
      retcode = l_element->set_attribute_ns(
                    name   = alias
                    prefix = 'xmlns'                        "#EC NOTEXT
*                 URI    = uri
                    value  = uri ).
    ENDIF.
  ENDIF.

ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
