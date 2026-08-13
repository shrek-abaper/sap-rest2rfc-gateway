*&---------------------------------------------------------------------*
*&  Include  ZFMPARASAVEASJSON
*&---------------------------------------------------------------------*
DEFINE zfmparasavevariate.

  "&1 - 函数名
  DATA: BEGIN OF jsonstring OCCURS 0,
          sortcode  TYPE n,
          parameter TYPE rsfbpara-parameter,
          jsonstr   TYPE string,
        END OF jsonstring.

  DATA: params_tb TYPE TABLE OF rfc_fint_p,
        params_wa TYPE rfc_fint_p.

  DATA: location TYPE c.
  DATA: string   TYPE string.
  DATA: jsonstr  TYPE string.
  DATA: logflag  TYPE abap_bool.
  DATA: funcname TYPE tfdir-funcname.

  DATA: lo_cx_xslt_runtime_error TYPE REF TO cx_xslt_runtime_error.
  DATA: html TYPE string.

  FIELD-SYMBOLS: <dync> TYPE any .

  DATA st_general_log TYPE ztif_general_log.
  DATA st_general_con TYPE ztif_general_con.

  funcname     = &1 .

  CLEAR:st_general_log,st_general_con.
  REFRESH params_tb[].

  SELECT SINGLE * INTO st_general_con FROM ztif_general_con WHERE taskfm EQ funcname.
  IF sy-subrc EQ 0 AND st_general_con-logflg EQ 'X'.

    CALL FUNCTION 'RFC_GET_FUNCTION_INTERFACE_P'
      EXPORTING
        funcname      = funcname
*       LANGUAGE      = SY-LANGU
*       NONE_UNICODE_LENGTH        = ' '
      TABLES
        params_p      = params_tb
*       RESUMABLE_EXCEPTIONS       =
      EXCEPTIONS
        fu_not_found  = 1
        nametab_fault = 2
        OTHERS        = 3.

    IF sy-subrc NE 0.

    ENDIF.

   logflag = abap_true.
  ENDIF.

END-OF-DEFINITION.

DEFINE zfmparasaveasjson.

  "&1 - 标记执行位置：I:函数开头  E：函数结束
  location       = &1.

  IF NOT params_tb[] IS INITIAL.
    REFRESH jsonstring[].
    LOOP AT params_tb INTO params_wa.
      IF params_wa-paramclass EQ 'T'.
        CONCATENATE params_wa-parameter '[]' INTO string.
      ELSE.
        MOVE params_wa-parameter TO string.
      ENDIF.

      ASSIGN (string) TO <dync>.

      CHECK sy-subrc = 0 .
      CHECK NOT <dync> IS INITIAL.

      CLEAR jsonstring.
      CASE params_wa-paramclass.
        WHEN 'I'.
          jsonstring-sortcode = 1.
        WHEN 'C'.
          jsonstring-sortcode = 2.
        WHEN 'E'.
          jsonstring-sortcode = 3.
        WHEN 'T'.
          jsonstring-sortcode = 4.
        WHEN OTHERS.
          jsonstring-sortcode = 9.
      ENDCASE.

      jsonstring-parameter = params_wa-parameter.

      string = |{ params_wa-paramclass }:{ jsonstring-parameter }|.
      CALL METHOD /ui2/cl_json=>serialize
        EXPORTING
          data             = <dync>
          name             = string
          pretty_name      = /ui2/cl_json=>pretty_mode-low_case
          assoc_arrays     = /ui2/cl_json=>c_bool-true
        RECEIVING
          r_json           = jsonstring-jsonstr.
      APPEND jsonstring.
    ENDLOOP.

    SORT jsonstring BY sortcode.
    GET TIME.
    IF location EQ 'I'.
      st_general_log-ifcode = st_general_con-ifcode.
      IF st_general_log-serino IS INITIAL.
        TRY.
            CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = st_general_log-serino.
          CATCH cx_uuid_error .
        ENDTRY.
      ENDIF.
      st_general_log-sendtm = sy-datum && sy-uzeit.
      st_general_log-datum  = sy-datum.
      st_general_log-ibtim  = sy-uzeit.
      st_general_log-msgin = |\{|.
      LOOP AT jsonstring.
        string = jsonstring-jsonstr.
        AT LAST.
          st_general_log-msgin = |{ st_general_log-msgin }{ string }\}|.
          EXIT.
        ENDAT.

        st_general_log-msgin = |{ st_general_log-msgin }{ string },|.
      ENDLOOP.
    ELSEIF location EQ 'E'.
      IF NOT st_general_log IS INITIAL.
        st_general_log-obtim = sy-uzeit.
        st_general_log-uname = sy-uname.
        st_general_log-msgot = |\{|.
        LOOP AT jsonstring.
          string = jsonstring-jsonstr.
          AT LAST.
            st_general_log-msgot = |{ st_general_log-msgot }{ string }\}|.
            EXIT.
          ENDAT.
          st_general_log-msgot = |{ st_general_log-msgot }{ string },|.
        ENDLOOP.
      ENDIF.
    ENDIF.
    IF NOT st_general_log IS INITIAL.
      MODIFY ztif_general_log FROM st_general_log.
    ENDIF.
  ENDIF.

END-OF-DEFINITION.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 750
