**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

  METHOD write_log.

    CHECK general_con-logflg EQ abap_true.

    GET TIME.

    IF mode EQ record_mode-import.
      general_log = VALUE #( serino = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( )
                             ifcode = general_con-ifcode
                             sendtm = |{ sy-datum }{ sy-uzeit }|
                             datum  = sy-datum
                             ibtim  = sy-uzeit
                             uname  = sy-uname
                             msgin  = content ).
    ELSEIF mode EQ record_mode-export.

      general_log = VALUE #( BASE general_log
                             obtim  = sy-uzeit
                             msgot  = content
                             reqres = code
                             reqmsg = reason ).

*      TRY.
*          CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_c32
*            RECEIVING
*              uuid = general_log-serino.
*        CATCH cx_uuid_error .
*      ENDTRY.

    ENDIF.

    MODIFY ztif_general_log FROM general_log.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
