**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD split_uri.

    DATA:lv_params TYPE string,
         lv_key    TYPE string,
         lv_value  TYPE string,
         lt_params TYPE TABLE OF string.

    SPLIT to_upper( uri ) AT '?' INTO path lv_params.

    CHECK lv_params NE space.

    SPLIT lv_params AT '&' INTO TABLE lt_params.

    LOOP AT lt_params INTO DATA(ls_params).
      CLEAR:lv_key,lv_value.
      SPLIT ls_params AT '=' INTO lv_key lv_value.
      params[] = VALUE #( BASE params[] ( key = lv_key value = lv_value ) ).
    ENDLOOP.


  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
