**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  method SET_DTD_RESTRICTION.
*   --- note 2132282 ---
    if max_expansion > 0 and ON is not initial .
       m_dtd_expansion = max_expansion.
    else.
       m_dtd_expansion = 0.
    endif.
  endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
