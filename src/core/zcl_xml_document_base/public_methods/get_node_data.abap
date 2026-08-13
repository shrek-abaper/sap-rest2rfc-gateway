**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_NODE_DATA .

   DATA: l_dom      TYPE REF TO  IF_IXML_ELEMENT,
         l_problems TYPE  DCXMLPRBL.

   retcode = c_failed.

   check not node is initial.

   l_dom ?= node->QUERY_INTERFACE( ixml_iid_element ).

   check not l_dom is initial.


   CALL FUNCTION 'SDIXML_DOM_TO_DATA'
     EXPORTING
       DATA_AS_DOM    = l_dom
     IMPORTING
       DATAOBJECT     = dataobject
       PROBLEMS       = l_problems
     EXCEPTIONS
       ILLEGAL_OBJECT = 1
       OTHERS         = 2.

   if sy-subrc = 0 and
      l_problems is initial.
      retcode = c_OK.
   endif.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
