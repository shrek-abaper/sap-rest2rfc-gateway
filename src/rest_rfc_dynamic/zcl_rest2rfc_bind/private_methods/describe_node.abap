**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

  METHOD describe_node.
    rv_text = SWITCH #( is_node-kind
                WHEN c_kind-object THEN |a JSON object|
                WHEN c_kind-array  THEN |a JSON array|
                WHEN c_kind-empty  THEN |an empty value (\{\} or [])|
                ELSE                    |a JSON scalar| ).
  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
