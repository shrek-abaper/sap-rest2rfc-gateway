FUNCTION ZSDIXML_DATA_TO_DOM.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(NAME) TYPE  STRING
*"     REFERENCE(DATAOBJECT)
*"     REFERENCE(CONTROL) TYPE  DCXMLSERCL OPTIONAL
*"  EXPORTING
*"     REFERENCE(DATA_AS_DOM) TYPE REF TO IF_IXML_ELEMENT
*"  CHANGING
*"     REFERENCE(DOCUMENT) TYPE REF TO IF_IXML_DOCUMENT OPTIONAL
*"     REFERENCE(TYPE_HANDLE) TYPE  SY-TABIX OPTIONAL
*"  EXCEPTIONS
*"      ILLEGAL_NAME
*"--------------------------------------------------------------------
DATA: elementname TYPE Elementname,
      rc TYPE SY-SUBRC,
      Typeinfos_loc TYPE My_SYDES_DESC_tab,
      optional TYPE DDBOOL_D.

STATICS Typeinfos TYPE My_SYDES_DESC_tab.

FIELD-SYMBOLS <Typeinfos> TYPE My_SYDES_DESC_tab.

IF NAME IS INITIAL.
   RAISE ILLEGAL_NAME.
ENDIF.
PERFORM Fieldname_to_elementname USING NAME CHANGING elementname rc.
IF rc <> 0.
   RAISE ILLEGAL_NAME.
ENDIF.
PERFORM Set_document CHANGING DOCUMENT.
PERFORM Create_element USING elementname CHANGING DATA_AS_DOM.
IF TYPE_HANDLE IS REQUESTED.
  ASSIGN Typeinfos TO <Typeinfos>.
ELSE.
  ASSIGN Typeinfos_loc TO <Typeinfos>.
ENDIF.
PERFORM Data_to_element USING dataobject control
                        CHANGING DATA_AS_DOM <Typeinfos> TYPE_HANDLE optional rc.
IF rc <> 0.
   RAISE ILLEGAL_NAME.
ENDIF.
ENDFUNCTION.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
