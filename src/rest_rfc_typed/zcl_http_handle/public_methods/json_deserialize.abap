**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD json_deserialize.

    CALL METHOD /ui2/cl_json=>deserialize
      EXPORTING
        json             = json
        jsonx            = jsonx
        pretty_name      = pretty_name
        assoc_arrays     = assoc_arrays
        assoc_arrays_opt = assoc_arrays_opt
        name_mappings    = name_mappings
      CHANGING
        data             = data.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
