**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD GET_JSON_NODE.

    DATA: lt_node TYPE TABLE OF string,
          lr_data TYPE REF TO data.

    FIELD-SYMBOLS: <data>  TYPE data,
                   <field> TYPE any.

    SPLIT to_upper( node_sequence ) AT '-' INTO TABLE lt_node.

    lr_data = /ui2/cl_json=>generate( json = json ).
    IF lr_data IS BOUND.
      LOOP AT lt_node INTO DATA(ls_node).
        ASSIGN lr_data->* TO <data>.
        ASSIGN COMPONENT ls_node OF STRUCTURE <data> TO <field>.
        IF sy-subrc EQ 0 AND <field> IS ASSIGNED.
          lr_data = <field>.
        ELSE.
          RAISE node_not_found.
        ENDIF.

        AT LAST.
          json = json_serialize( data = <field> ).
        ENDAT.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
