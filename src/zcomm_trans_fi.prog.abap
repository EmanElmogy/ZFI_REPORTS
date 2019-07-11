*&---------------------------------------------------------------------*
*&  Include  ZCOMM_TRANS_FI
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

FORM GET_CONTRACT_DATA .

  IF VICNCN-RECNNR IS NOT INITIAL .

    SELECT  * FROM ZCOMM_TRANS_RULS INTO CORRESPONDING FIELDS OF TABLE
      IT_RULES WHERE CONTRACT_NO = VICNCN-RECNNR  AND BUKRS = VICNCN-BUKRS   .
    IF SY-SUBRC = 0 .

      PERFORM GET_RECORDS USING 'O'. " OLD

    ELSE. " NEW

*      CLEAR : VICNCN .
      REFRESH  : IT_ITEMS , IT_RULES .

      PERFORM GET_RECORDS USING SPACE .





    ENDIF.

  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK     TYPE SY-UCOMM,
        L_OFFSET TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
    WHEN 'INSR'.                      "insert row
      PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                        P_TABLE_NAME.
      CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME.
      CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_INSERT_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_LINES_NAME       LIKE FELD-NAME.
  DATA L_SELLINE          LIKE SY-STEPL.
  DATA L_LASTLINE         TYPE I.
  DATA L_LINE             TYPE I.
  DATA L_TABLE_NAME       LIKE FELD-NAME.
  FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <LINES>              TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
  ASSIGN (L_LINES_NAME) TO <LINES>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE L_SELLINE.
  IF SY-SUBRC <> 0.                   " append line to table
    L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line                                               *
    IF L_SELLINE > <LINES>.
      <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
    ELSE.
      <TC>-TOP_LINE = 1.
    ENDIF.
  ELSE.                               " insert line into table
    L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
    L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
  <TC>-LINES = <TC>-LINES + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE L_LINE.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_DELETE_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME
                       P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    IF <MARK_FIELD> = 'X'.
      DELETE <TABLE> INDEX SYST-TABIX.
      IF SY-SUBRC = 0.
        <TC>-LINES = <TC>-LINES - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                      P_OK.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TC_NEW_TOP_LINE     TYPE I.
  DATA L_TC_NAME             LIKE FELD-NAME.
  DATA L_TC_LINES_NAME       LIKE FELD-NAME.
  DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <LINES>      TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
  ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*&SPWIZARD: is no line filled?                                         *
  IF <TC>-LINES = 0.
*&SPWIZARD: yes, ...                                                   *
    L_TC_NEW_TOP_LINE = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        ENTRY_ACT      = <TC>-TOP_LINE
        ENTRY_FROM     = 1
        ENTRY_TO       = <TC>-LINES
        LAST_PAGE_FULL = 'X'
        LOOPS          = <LINES>
        OK_CODE        = P_OK
        OVERLAPPING    = 'X'
      IMPORTING
        ENTRY_NEW      = L_TC_NEW_TOP_LINE
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD L_TC_FIELD_NAME
             AREA  L_TC_NAME.

  IF SYST-SUBRC = 0.
    IF L_TC_NAME = P_TC_NAME.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                               P_TABLE_NAME
                               P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                 P_TABLE_NAME
                                 P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE .


  ZCOMM_TRANS-CONTRACT_NO = VICNCN-RECNNR .
  ZCOMM_TRANS-BUKRS = VICNCN-BUKRS .
  ZCOMM_TRANS-CHANGE_DATE = SY-DATUM.
  ZCOMM_TRANS-CREATED_BY = SY-UNAME.

  MODIFY ZCOMM_TRANS .

  IF SY-SUBRC = 0 .

    DELETE FROM ZCOMM_TRANS_RULS WHERE CONTRACT_NO = VICNCN-RECNNR .

    LOOP AT IT_ITEMS INTO WA_ITEMS .

      MOVE-CORRESPONDING WA_ITEMS TO WA_RULES .

      WA_RULES-BUKRS = VICNCN-BUKRS .
      WA_RULES-CONTRACT_NO = VICNCN-RECNNR .

      APPEND WA_RULES TO IT_RULES .
    ENDLOOP.


    MODIFY ZCOMM_TRANS_RULS FROM TABLE IT_RULES .

    MESSAGE 'SAVED' TYPE 'I' .

    CLEAR : VICNCN , ZCOMM_TRANS , WA_RULES , WA_ITEMS , LVL_PRCNT , CONT_AMOUNT .

    REFRESH : IT_ITEMS , IT_RULES , IT_ITEMS2 , INST_TAB .

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_RECORDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_RECORDS USING FLAG .

  REFRESH IT_ITEMS .

  SELECT SINGLE  RECNBEG BUKRS  FROM VICNCN INTO (VICNCN-RECNBEG, VICNCN-BUKRS )  WHERE RECNNR = VICNCN-RECNNR  AND BUKRS = VICNCN-BUKRS .

  IF SY-SUBRC = 0 .

    REFRESH INST_TAB .
    CLEAR : CONT_AMOUNT .


    CALL FUNCTION 'BAPI_RE_CN_GET_DETAIL'
    EXPORTING
      COMPCODE                        = VICNCN-BUKRS
      CONTRACTNUMBER                  = VICNCN-RECNNR
   TABLES
      term_payment                    = IT_TERM
            .

   READ TABLE IT_TERM INTO WA_TERM INDEX 1 .
   IF SY-subrc = 0 .

     SHIFT VICNCN-RECNNR LEFT DELETING LEADING '0'.
     SELECT SUM( DMBTR ) FROM BSID INTO DMBTR_S
       WHERE BUKRS = VICNCN-BUKRS AND BLART = 'RL'  AND KUNNR = WA_TERM-PARTNER AND UMSKZ = 'D'
       AND ZUONR = VICNCN-RECNNR AND SHKZG = 'S' .
       IF SY-subrc <> 0 .


     SELECT SUM( DMBTR ) FROM BSAD INTO DMBTR_S
       WHERE BUKRS = VICNCN-BUKRS AND BLART = 'RL'  AND KUNNR = WA_TERM-PARTNER AND UMSKZ = 'D'
       AND ZUONR = VICNCN-RECNNR AND SHKZG = 'S' .

       ENDIF.


        SELECT SUM( DMBTR ) FROM BSID INTO DMBTR_H
       WHERE BUKRS = VICNCN-BUKRS AND BLART = 'RL'  AND KUNNR = WA_TERM-PARTNER AND UMSKZ = 'D'
       AND ZUONR = VICNCN-RECNNR AND SHKZG = 'H' .
       IF SY-subrc <> 0 .


     SELECT SUM( DMBTR ) FROM BSAD INTO DMBTR_H
       WHERE BUKRS = VICNCN-BUKRS AND BLART = 'RL'  AND KUNNR = WA_TERM-PARTNER AND UMSKZ = 'D'
       AND ZUONR = VICNCN-RECNNR AND SHKZG = 'H' .

       ENDIF.

       CONT_AMOUNT = ABS( DMBTR_S - DMBTR_H ) .

   ENDIF.


*    CALL FUNCTION '/CICRE/INST_GET_LIST_CONTRACT'
*      EXPORTING
**       OFFER_NO    =
*        COMP_CODE   = VICNCN-BUKRS
*        CONTRACT_NO = VICNCN-RECNNR
*      TABLES
*        INST_TAB    = INST_TAB.
*
*
*    LOOP AT INST_TAB.
*
*      CONT_AMOUNT  = CONT_AMOUNT + INST_TAB-COND_AMOUNT.
*
*    ENDLOOP.

    IF FLAG = 'O'.

      LOOP AT IT_RULES INTO WA_RULES.

        MOVE-CORRESPONDING WA_RULES TO WA_ITEMS .



        APPEND WA_ITEMS TO IT_ITEMS .

      ENDLOOP.

    ELSE.

      CALL FUNCTION 'BAPI_RE_CN_GET_DETAIL'
        EXPORTING
          COMPCODE                        = VICNCN-BUKRS
          CONTRACTNUMBER                  = VICNCN-RECNNR
       TABLES
        PARTNER                         =  IT_PARTNER  .

      LOOP AT IT_PARTNER INTO WA_PARTNER WHERE ROLE_TYPE = 'BUP003' .

        WA_ITEMS-EMPLOYER = WA_PARTNER-PARTNER .

        SELECT SINGLE * FROM /cicre/brch_user INTO WA_BRCH WHERE EMPLOYEE_ID = WA_PARTNER-PARTNER .
          IF SY-SUBRC = 0 .

            SELECT SINGLE * FROM /CICRE/ROL_USR INTO WA_ROLE WHERE USER_NAME = WA_BRCH-XCCRE_USER .
              IF SY-SUBRC = 0.

                WA_ITEMS-ZRULE = WA_ROLE-ROLE .

              ENDIF.
          ENDIF.


          SELECT SINGLE ROLE_T FROM /CICRE/ROLE INTO WA_ITEMS-RULE_DESC
            WHERE ROLE_ID = WA_ITEMS-ZRULE .
            IF SY-SUBRC <> 0 .

              CLEAR WA_ITEMS-RULE_DESC .

            ENDIF.

            SELECT SINGLE SNAME FROM PA0001 INTO WA_ITEMS-NAME1
              WHERE PERNR = WA_ITEMS-EMPLOYER .
               IF SY-SUBRC <> 0 .
                 CLEAR WA_ITEMS-NAME1 .

               ENDIF.

          APPEND WA_ITEMS to IT_ITEMS .

      ENDLOOP.


    ENDIF.

  ELSE.
    MESSAGE 'Please enter valid contract number' TYPE 'S' DISPLAY LIKE 'E' .
    EXIT.


  ENDIF.

  REFRESH IT_RULES.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_LEVEL_PRECENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_LEVEL_PRECENT .


  BREAK ISMAIL .


  CLEAR : LVL_PRCNT , WA_TEMP .

  LOOP AT IT_ITEMS  INTO WA_TEMP  WHERE ZLEVEL = WA_ITEMS-ZLEVEL .

    LVL_PRCNT = LVL_PRCNT + WA_TEMP-ZSHARE .

  ENDLOOP.

  IF LVL_PRCNT > 100 .

    MESSAGE 'Level Prcent Must be Equal or Less than 100' TYPE 'E'.

  ENDIF.

ENDFORM.
