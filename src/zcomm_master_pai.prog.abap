*&---------------------------------------------------------------------*
*&  Include  ZCOMM_MASTER_PAI
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'ITAB_TC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE ITAB_TC_MODIFY INPUT.
  MODIFY IT_RULES
    FROM WA_RULES
    INDEX ITAB_TC-CURRENT_LINE.

  IF SY-subrc <> 0 .

  APPEND WA_RULES to IT_RULES  .

  ENDIF.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'ITAB_TC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE ITAB_TC_MARK INPUT.
  DATA: g_ITAB_TC_wa2 like line of IT_RULES.
    if ITAB_TC-line_sel_mode = 1
    and WA_RULES-MARK = 'X'.
     loop at IT_RULES into g_ITAB_TC_wa2
       where MARK = 'X'.
       g_ITAB_TC_wa2-MARK = ''.
       modify IT_RULES
         from g_ITAB_TC_wa2
         transporting MARK.
     endloop.
  endif.
  MODIFY IT_RULES
    FROM WA_RULES
    INDEX ITAB_TC-CURRENT_LINE
    TRANSPORTING MARK.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ITAB_TC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE ITAB_TC_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'ITAB_TC'
                              'IT_RULES'
                              'MARK'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_RULE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_RULE INPUT.
*GET CURSOR LINE WA_INDEX .
*
*
*DATA : WA LIKE LINE OF IT_RULES .
*READ TABLE IT_RULES INTO WA INDEX WA_INDEX .
*
*LOOP AT IT_RULES INTO WA
*
*ENDLOOP.


IF IT_RULES IS NOT INITIAL .
  DATA : IT_RULE2 LIKE IT_RULES ,
         LINE TYPE I .

  IT_RULE2 = IT_RULES .
  SORT IT_RULE2 BY ZRULE .
  DELETE IT_RULE2 WHERE ZRULE = space.
  DELETE ADJACENT DUPLICATES FROM IT_RULE2 COMPARING ZRULE .

*  DESCRIBE TABLE  IT_RULE2 LINES LINE .
  IF SY-subrc = 0 .

    MESSAGE 'Rule is Twice Defined' TYPE 'E'.
*    LEAVE TO LIST-PROCESSING.



  ENDIF.

ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_DOC_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DOC_DATA INPUT.

CASE SY-UCOMM .
  WHEN 'CHCK'.

    PERFORM GET_RECORDS .
*	WHEN .
  WHEN OTHERS.
ENDCASE.
ENDMODULE.
