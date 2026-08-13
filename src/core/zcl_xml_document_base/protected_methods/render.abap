**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Protected
**************************************************************************

method RENDER .

    retcode = c_failed.
    check not m_document is initial.
    check not stream     is initial.

*-- render the DOM back into an output stream ---
    call method Stream->set_pretty_print(
                        pretty_print = pretty_print ).
*    call method m_document->render(
*                      ostream   = Stream
*                      recursive = 'X' ).


*  --- default RENDERER omits leading spaces 03.12.02 ---
   DATA: l_renderer       TYPE REF TO if_ixml_renderer.

   l_renderer = g_ixml->create_renderer( document = m_document
                                         ostream  = stream  ).
   l_renderer->set_normalizing( is_normalizing = space ).
   retcode = l_renderer->render( ).

*  retcode = c_ok.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
