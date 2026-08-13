**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

method EXPORT_TO_FILE .

  data: lt_data    type standard table of char255, "swxmlcont,
        l_size     type i,
        l_filename type string.

  call method render_2_table
      importing table   = lt_data
                size    = l_size
                retcode = retcode.

  check retcode = c_OK.

*  CALL FUNCTION 'WS_DOWNLOAD'
*    EXPORTING
*       BIN_FILESIZE                  = l_size
*       FILENAME                      = filename
*       FILETYPE                      = 'BIN'
**   IMPORTING
**      FILELENGTH                    =
*    TABLES
*       DATA_TAB                      = lt_data
*    EXCEPTIONS
*       FILE_OPEN_ERROR               = 1
*       FILE_WRITE_ERROR              = 2
*       INVALID_FILESIZE              = 3
*       INVALID_TYPE                  = 4
*       OTHERS                        = 10.

  l_filename = filename.
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      BIN_FILESIZE            = l_size
      filename                = l_filename
      FILETYPE                = 'BIN'
*     APPEND                  = SPACE
*     WRITE_FIELD_SEPARATOR   = SPACE
*     HEADER                  = '00'
*   IMPORTING
*     FILELENGTH              =
    CHANGING
      DATA_TAB                = lt_data
    EXCEPTIONS
      GUI_REFUSE_FILETRANSFER = 1
      FILE_WRITE_ERROR        = 2
      FILESIZE_NOT_ALLOWED    = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      others                  = 10.

  retcode = SY-SUBRC .

endmethod.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
