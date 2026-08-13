**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method GET_DATA .

   DATA: l_node     TYPE REF TO  IF_IXML_NODE.

   if name is initial.
      l_node = get_first_node( ).
   else.
      l_node = find_node( name = name ).
   endif.

   call method get_node_data
                 exporting node       = l_node
                 importing retcode    = retcode
                           dataobject = dataobject.

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
