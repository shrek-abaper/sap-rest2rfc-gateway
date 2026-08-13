**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

METHOD IMPORT_FROM_FILE .

  DATA: lt_data    TYPE swxmlcont,
        l_filename TYPE string,
        l_size     TYPE i.
*
*  call function 'WS_UPLOAD'
*       EXPORTING
*            filename   = filename
*            filetype   = 'BIN'
*       IMPORTING
*            filelength = l_size
*       TABLES
*            data_tab   = lt_data
*       EXCEPTIONS
*            CONVERSION_ERROR        = 1
*            FILE_OPEN_ERROR         = c_not_found
*            FILE_READ_ERROR         = 3
*            INVALID_TYPE            = 4
*            NO_BATCH                = 5
*            INVALID_TABLE_WIDTH     = 6
*            GUI_REFUSE_FILETRANSFER = 7
*            CUSTOMER_ERROR          = 8
*            others                  = 99.
*

  l_filename = filename.
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = l_filename
      filetype                = 'BIN'
*     HAS_FIELD_SEPARATOR     = SPACE
*     HEADER_LENGTH           = 0
    IMPORTING
      filelength              = l_size
*     HEADER                  =
    CHANGING
      data_tab                = lt_data
    EXCEPTIONS
      file_open_error         = c_not_found
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 99.

  retcode = sy-subrc.

  IF retcode = 0.
    retcode = create_with_table( table = lt_data size = l_size ).
  ENDIF.

ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
