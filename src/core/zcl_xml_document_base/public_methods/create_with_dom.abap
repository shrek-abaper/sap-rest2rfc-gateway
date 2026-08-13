**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method CREATE_WITH_DOM .

   retcode = c_failed.

   check not document is initial.

   m_document = document.

   retcode = c_OK.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
