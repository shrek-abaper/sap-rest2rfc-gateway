**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

METHOD GET_NAMESPACE_DEF .

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
      uri = l_element->get_attribute(
                    name   = 'xmlns' ).    "#EC NOTEXT

    ELSE.
      uri = l_element->get_attribute(
                    name      = alias
                    namespace = 'xmlns' ).     "#EC NOTEXT
    ENDIF.
  ENDIF.

ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
