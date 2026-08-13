**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD xml_serialize.

    DATA:retcode    TYPE sysubrc,
         lo_xml     TYPE REF TO zcl_xml_document_base,
         lv_xstring TYPE xstring.

    CREATE OBJECT lo_xml.

    retcode = lo_xml->create_with_data(
             name       = name
             dataobject = dataobject
             ).
    IF retcode NE 0.
      RAISE xml_serialize_error.
    ENDIF.

    lo_xml->render_2_xstring(
      EXPORTING
        pretty_print = pretty_print
      IMPORTING
        retcode      = retcode
        stream       = lv_xstring
*    size         = size
           ).
    IF retcode NE 0.
      RAISE xml_pretty_error.
    ENDIF.

    xml        = cl_abap_codepage=>convert_from( source = lv_xstring ).
    lv_xstring = cl_abap_codepage=>convert_to( source = xml  codepage = codepage ).
    xml        = cl_abap_codepage=>convert_from( source = lv_xstring codepage =  codepage ).

    LOOP AT name_mappings INTO DATA(wa_name_mappings).
      REPLACE ALL OCCURRENCES OF wa_name_mappings-abap IN xml WITH wa_name_mappings-json.
    ENDLOOP.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
