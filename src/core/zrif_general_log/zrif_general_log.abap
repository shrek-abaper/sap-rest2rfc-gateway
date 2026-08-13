*&---------------------------------------------------------------------*
*&-----------------------------------------------------------------------------------------*
*& Report ZRIF_GENERAL_LOG                                                                 *
*&-----------------------------------------------------------------------------------------*
*&  Program name : ZRIF_GENERAL_LOG                                                        *
*&   Module name : ABAP                                                                    *
*&        Author :                                                                         *
*&  Create date  : 2020.02.19                                                              *
*&  Description  : 接口通用日志报表                                                        *
*&-----------------------------------------------------------------------------------------*
REPORT zrif_general_log.

*------------------------------------------------------------------------------------------*
*- Type Pools                                                                             -*
*------------------------------------------------------------------------------------------*
TYPE-POOLS:icon.

*------------------------------------------------------------------------------------------*
*- Tables                                                                                 -*
*------------------------------------------------------------------------------------------*
TABLES:ztif_general_con.

*------------------------------------------------------------------------------------------*
*- Types                                                                                  -*
*------------------------------------------------------------------------------------------*
TYPES:BEGIN OF typ_general_log.
        INCLUDE STRUCTURE ztif_general_con.
        TYPES:serino  TYPE ztif_general_log-serino,
        sendtm  TYPE ztif_general_log-sendtm,
        datum   TYPE ztif_general_log-datum,
        ibtim   TYPE ztif_general_log-ibtim,
        obtim   TYPE ztif_general_log-obtim,
        uname   TYPE ztif_general_log-uname,
        msgin   TYPE ztif_general_log-msgin,
        msgot   TYPE ztif_general_log-msgot,
        reqres  TYPE ztif_general_log-reqres,
        reqmsg  TYPE ztif_general_log-reqmsg,
        icon_ib TYPE char4,
        icon_ob TYPE char4,
      END OF typ_general_log.

*------------------------------------------------------------------------------------------*
*- Define Data                                                                            -*
*------------------------------------------------------------------------------------------*
DATA gt_general_log TYPE TABLE OF typ_general_log.
DATA gs_general_log TYPE typ_general_log.

DATA: w_fieldcat TYPE lvc_s_fcat,
      i_fieldcat TYPE lvc_t_fcat,
      w_layout   TYPE lvc_s_layo.

*------------------------------------------------------------------------------------------*
*- Selection Screen                                                                       -*
*------------------------------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME.
PARAMETERS p_ifcode TYPE ztif_general_con-ifcode OBLIGATORY.
SELECT-OPTIONS:s_datum  FOR sy-datum,
               s_ibtim  FOR sy-uzeit.
SELECTION-SCREEN END OF BLOCK b0.

*------------------------------------------------------------------------------------------*
*- Initialization                                                                         -*
*------------------------------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM frm_initial_listbox.

*------------------------------------------------------------------------------------------*
*- At Selection-screen on value-request                                                   -*
*------------------------------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ifcode.
  PERFORM frm_f4_ifcode USING 'P_IFCODE'.

*------------------------------------------------------------------------------------------*
*- At Selection-screen Output                                                             -*
*------------------------------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*------------------------------------------------------------------------------------------*
*- At Selection-screen                                                                    -*
*------------------------------------------------------------------------------------------*
AT SELECTION-SCREEN.


*------------------------------------------------------------------------------------------*
*- Start-of-selection                                                                     -*
*------------------------------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM frm_get_data.

*------------------------------------------------------------------------------------------*
*- End-of-selection                                                                       -*
*------------------------------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM frm_display_log.

*&---------------------------------------------------------------------*
*& Form FRM_INITIAL_LISTBOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_initial_listbox .
  DATA lt_list TYPE vrm_values.

  REFRESH lt_list.

  SELECT ifcode AS key
         ifname AS text
    INTO TABLE lt_list
    FROM ztif_general_con.

  SORT lt_list BY key.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_IFCODE'
      values = lt_list.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_data .

  REFRESH gt_general_log.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_general_log
    FROM ztif_general_log
    INNER JOIN ztif_general_con ON ztif_general_con~ifcode EQ ztif_general_log~ifcode
    WHERE ztif_general_log~ifcode EQ p_ifcode
      AND ztif_general_log~datum  IN s_datum
      AND ztif_general_log~ibtim  IN s_ibtim.

  LOOP AT gt_general_log ASSIGNING FIELD-SYMBOL(<log>).

    <log>-icon_ib = icon_display_text.
    <log>-icon_ob = icon_display_text.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_DISPLAY_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_display_log .
  DATA(lv_repid) = sy-repid.

  PERFORM frm_initial_fieldcat.
  PERFORM frm_initial_layout.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program      = lv_repid
*     i_callback_pf_status_set = 'PF_STATUS_SET'
      i_callback_user_command = 'USER_COMMAND'
      is_layout_lvc           = w_layout
      it_fieldcat_lvc         = i_fieldcat[]
*     I_DEFAULT               = 'X'
      i_save                  = 'A'    "保存布局
    TABLES
      t_outtab                = gt_general_log[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_INITIAL_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_initial_layout .
  w_layout-zebra       = 'X'.  "设置每行的背景颜色交错 显示。
  w_layout-cwidth_opt  = 'X'.  "ALV输出时候自动优化宽 度
  w_layout-sel_mode    = 'D'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_INITIAL_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_initial_fieldcat .
  DATA l_pos TYPE numc4.

  CLEAR l_pos.

  CLEAR i_fieldcat[].

  DEFINE inital_fieldcat.
    CLEAR w_fieldcat.
    w_fieldcat-col_pos = l_pos + 1.
    w_fieldcat-fieldname = &1.
    w_fieldcat-coltext   = &2.
    w_fieldcat-ref_table = &3.
    w_fieldcat-ref_field = &4.
    w_fieldcat-no_out    = &5.
    w_fieldcat-icon       = &6.
    w_fieldcat-key        = &7.
    w_fieldcat-hotspot    = &8.
    APPEND w_fieldcat TO i_fieldcat.
    l_pos = w_fieldcat-col_pos.
  END-OF-DEFINITION.

  inital_fieldcat 'IFCODE' '接口编码' 'ZTIF_GENERAL_CON' 'IFCODE' '' '' 'X' ''.
  inital_fieldcat 'IFNAME' '接口名称' '' '' '' '' 'X' ''.
  inital_fieldcat 'TASKFM' '函数模块' 'ZTIF_GENERAL_CON' 'ZTASKFM' '' '' 'X' ''.
  inital_fieldcat 'IFTYPE' '接口类型' 'ZTIF_GENERAL_CON' 'IFTYPE' '' '' 'X' ''.
*  inital_fieldcat 'INBSYS' '入站系统' 'ZTIF_GENERAL_CON' 'ZINBSYS' '' '' 'X' ''.
*  inital_fieldcat 'OUTSYS' '出站系统' 'ZTIF_GENERAL_CON' 'ZINBSYS' '' '' 'X' ''.

  inital_fieldcat 'SERINO' '流水号' '' '' '' '' '' ''.
  inital_fieldcat 'DATUM' '日期' 'SYST' 'DATUM' '' '' '' ''.
  inital_fieldcat 'IBTIM' '入站时间' 'SYST' 'UZEIT' '' '' '' ''.
  inital_fieldcat 'OBTIM' '出站时间' 'SYST' 'UZEIT' '' '' '' ''.
  inital_fieldcat 'ICON_IB' '入站报文' '' '' '' 'X' '' 'X'.
  inital_fieldcat 'ICON_OB' '出站报文' '' '' '' 'X' '' 'X'.
  inital_fieldcat 'UNAME' '用户名' '' '' '' '' '' ''.
  inital_fieldcat 'REQRES' '调用结果' '' '' '' '' '' ''.
  inital_fieldcat 'REQMSG' '调用消息' '' '' '' '' '' ''.
  inital_fieldcat 'MSGIN' '入站报文' '' '' '' '' '' ''.
  inital_fieldcat 'MSGOT' '出站报文' '' '' '' '' '' ''.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       User command
*----------------------------------------------------------------------*
FORM user_command USING  r_ucomm LIKE sy-ucomm
                     rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'.
      IF rs_selfield-fieldname(4) EQ |ICON|.
        PERFORM frm_show_message USING rs_selfield.
      ENDIF.
      IF rs_selfield-fieldname(3) EQ |MSG|.
        PERFORM frm_down_log USING rs_selfield.
      ENDIF.
  ENDCASE.

ENDFORM. "F_USER_COMMAND
*&---------------------------------------------------------------------*
*& Form FRM_SHOW_MESSAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM frm_show_message  USING rs_selfield TYPE slis_selfield.

  CHECK rs_selfield-fieldname(4) EQ 'ICON'.

  DATA: lv_string TYPE string,
        lv_error  TYPE string.

  CLEAR:lv_string,lv_error.

  READ TABLE gt_general_log INTO gs_general_log INDEX rs_selfield-tabindex.

  IF sy-subrc EQ 0.
    IF rs_selfield-fieldname EQ 'ICON_IB'.
      lv_string = gs_general_log-msgin.
    ELSEIF rs_selfield-fieldname EQ 'ICON_OB'.
      lv_string = gs_general_log-msgot.
    ENDIF.

*    cl_demo_output=>display_json( lv_string ).

    IF gs_general_log-msgfom EQ |J|.
      TRY.
          CALL TRANSFORMATION sjson2html SOURCE XML lv_string
                                         RESULT XML DATA(html).
        CATCH cx_xslt_runtime_error INTO DATA(lo_cx_xslt_runtime_error).
          lv_error = |{ lo_cx_xslt_runtime_error->get_text( ) }|.
      ENDTRY.

      IF lv_error IS INITIAL.
        cl_abap_browser=>show_html( html_string =
             cl_abap_codepage=>convert_from( html ) ).
      ELSE.
        cl_demo_text=>display_string( lv_string ).
      ENDIF.
    ELSEIF gs_general_log-msgfom EQ |X|.
      cl_abap_browser=>show_xml( xml_string = lv_string ).
    ELSE.
      cl_demo_text=>display_string( lv_string ).
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DOWN_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM frm_down_log  USING    rs_selfield TYPE slis_selfield.
  DATA:lv_filename TYPE string,
       lv_str1     TYPE string,
       lv_str2     TYPE string,
       lv_name     TYPE string.

  DATA xmltab TYPE string OCCURS 0.

*--->>>获取下载路径
  lv_name = COND #( WHEN rs_selfield-fieldname EQ |MSGIN| THEN |请求报文.txt|
                    WHEN rs_selfield-fieldname EQ |MSGOT| THEN |应答报文.txt| ).
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_file_name    = lv_name
    CHANGING
      filename             = lv_str1
      path                 = lv_str2
      fullpath             = lv_filename
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  CHECK lv_filename NE space.

  READ TABLE gt_general_log INTO gs_general_log INDEX rs_selfield-tabindex.
  xmltab[] = COND #( WHEN rs_selfield-fieldname EQ |MSGIN| THEN VALUE #( ( gs_general_log-msgin ) )
                     WHEN rs_selfield-fieldname EQ |MSGOT| THEN VALUE #( ( gs_general_log-msgot ) ) ).

*--将内表数据导出到 TXT
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      confirm_overwrite = 'X'      "如果文件存在 弹出是否覆盖文件的对话框
*     write_field_separator = 'X'      "加入字段分隔符 TAB
      filename          = lv_filename "文件名 必须为 STRING 类型
    TABLES
      data_tab          = xmltab  "内表
    EXCEPTIONS
      file_write_error  = 1
      file_not_found    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
         DISPLAY LIKE 'I'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_F4_IFCODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM frm_f4_ifcode  USING uv_fieldname.

  SELECT * INTO TABLE @DATA(lt_ztif_general_con)
    FROM ztif_general_con.

  SORT lt_ztif_general_con BY ifcode.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'IFCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = uv_fieldname
      value_org       = 'S'
    TABLES
      value_tab       = lt_ztif_general_con
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.


*Selection texts
*----------------------------------------------------------
* P_IFCODE         接口编码
* S_DATUM         日期
* S_IBTIM         入站时间

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 756
