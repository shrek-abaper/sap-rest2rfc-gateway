**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD xml_deserialize.

    DATA:retcode TYPE sysubrc,
         lv_xml  TYPE string,
         lo_xml  TYPE REF TO zcl_xml_document_base.

    lv_xml = xml.

    LOOP AT name_mappings INTO DATA(wa_name_mappings).
      REPLACE ALL OCCURRENCES OF wa_name_mappings-abap IN lv_xml WITH wa_name_mappings-json.
    ENDLOOP.

    CREATE OBJECT lo_xml.

    retcode = lo_xml->parse_string( stream = lv_xml ).
    IF retcode NE 0.
      RAISE xml_parse_error.
    ENDIF.

    lo_xml->get_data(
       EXPORTING
        name        = name
       IMPORTING
         retcode    = retcode
       CHANGING
         dataobject = dataobject
            ).
    IF retcode NE 0.
      RAISE xml_deserialize_error.
    ENDIF.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
