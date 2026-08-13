**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD json_serialize.

    CALL METHOD /ui2/cl_json=>serialize
      EXPORTING
        data             = data
        compress         = compress
        name             = name
        pretty_name      = pretty_name
        type_descr       = type_descr
        assoc_arrays     = assoc_arrays
        ts_as_iso8601    = ts_as_iso8601
        expand_includes  = expand_includes
        assoc_arrays_opt = assoc_arrays_opt
        numc_as_string   = numc_as_string
        name_mappings    = name_mappings
      RECEIVING
        r_json           = r_json.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
