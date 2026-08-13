FUNCTION-POOL zsdixml.                      "MESSAGE-ID ..

CLASS cl_abap_char_utilities DEFINITION LOAD.

TYPE-POOLS: sydes, ixml.

SET EXTENDED CHECK OFF.
CONSTANTS: b64tab(64)                TYPE c VALUE
   'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
           g_recordname              TYPE dcxmltypnm-fieldname VALUE 'record',
           g_segmentname             TYPE dcxmltypnm-fieldname VALUE 'segment',
           g_bapi_retname            TYPE swc_editel VALUE 'Return',
           g_xsd(3)                  TYPE c VALUE 'xsd',
           alias_tabname             TYPE dfies-tabname VALUE '=>',
           inner_type_text_prefix(6) TYPE c VALUE '%§##?%',
           max_d16d_value            TYPE string VALUE '9.999999999999999E+384',
           max_d34d_value            TYPE string VALUE '9.999999999999999999999999999999999E+6144'.
SET EXTENDED CHECK ON.

DATA: global_document TYPE REF TO if_ixml_document,
      global_size     TYPE i,
      global_title    TYPE sy-title,
      html            TYPE REF TO cl_gui_html_viewer,
      null            TYPE REF TO if_ixml_element.
DATA: g_encoding TYPE REF TO string.

FIELD-SYMBOLS <global_xml> TYPE dcxmllines.

DEFINE exit_at_err.
  IF rc <> 0.
     EXIT.
  ENDIF.
END-OF-DEFINITION.       " Exit_at_err

DEFINE set_schema_control.
  IF &1-xsdnsp IS INITIAL AND &1-thisnsp IS INITIAL
                          AND NOT &1-this_req IS INITIAL.
     &1-xsdnsp = g_xsd.
  ENDIF.
END-OF-DEFINITION.                " Set_schema_control


TYPES: elementname TYPE string,
       BEGIN OF elementname_nsp,
         elementname TYPE elementname,
         namespace   TYPE string,
         url         TYPE string,
       END OF elementname_nsp,
       BEGIN OF my_sydes_nameinfo,
         index TYPE sy-tabix,
         name  TYPE elementname,
       END OF my_sydes_nameinfo,
       my_sydes_nameinfos TYPE HASHED TABLE OF my_sydes_nameinfo
                          WITH UNIQUE KEY index,
       BEGIN OF my_sydes_desc,
         types TYPE sydes_typeinfos,
         names TYPE my_sydes_nameinfos,
       END OF my_sydes_desc,
       my_sydes_desc_tab TYPE STANDARD TABLE OF my_sydes_desc,
       worklist          TYPE HASHED TABLE OF dcxmltypnm
                WITH UNIQUE KEY tabname fieldname,
       BEGIN OF fupar,
         param       TYPE dcxmlfupar-param,
         stext       TYPE dcxmlfupar-stext,
         optional    TYPE dcxmlfupar-optional,
         deflt       TYPE dcxmlfupar-deflt,
         is_linetype TYPE ddbool_d,
         dfies       TYPE dfies,
       END OF fupar,
       parlist TYPE STANDARD TABLE OF fupar,
       BEGIN OF exception,
         param TYPE dcxmlfupar-param,
         stext TYPE dcxmlfupar-stext,
       END OF exception,
       exceptions TYPE STANDARD TABLE OF exception,
       BEGIN OF fposition,
         position TYPE dfies-position,
         line     TYPE REF TO data,
       END OF fposition,
       fpositions TYPE STANDARD TABLE OF fposition,
       BEGIN OF inner_type_translation,
         typename     LIKE dfies-lfieldname,
         typedescrref TYPE REF TO dcxmltyped,
         alias        LIKE dfies-tabname,
       END OF inner_type_translation,
       BEGIN OF text_alias,
         alias TYPE ddtext,
         text  TYPE string,
       END OF text_alias.

DATA: inner_type_aliases      TYPE HASHED TABLE OF inner_type_translation
                              WITH UNIQUE KEY typename typedescrref
                              WITH UNIQUE HASHED KEY alias_key
                                          COMPONENTS alias,
      inner_type_text_aliases TYPE HASHED TABLE OF text_alias WITH UNIQUE KEY alias.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
