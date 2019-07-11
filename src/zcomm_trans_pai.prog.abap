*&---------------------------------------------------------------------*
*&  Include  ZCOMM_TRANS_PAI
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'ITAB_TC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE ITAB_TC_MODIFY INPUT.

*  REFRESH IT_ITEMS .
*  CLEAR : WA_ITEMS .
  MODIFY IT_ITEMS
    FROM WA_ITEMS
    INDEX ITAB_TC-CURRENT_LINE.
   IF SY-SUBRC = 4 .

     APPEND WA_ITEMS TO IT_ITEMS .

   ENDIF.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'ITAB_TC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE ITAB_TC_MARK INPUT.
  DATA: g_ITAB_TC_wa2 like line of IT_ITEMS.
    if ITAB_TC-line_sel_mode = 1
    and WA_ITEMS-MARK = 'X'.
     loop at IT_ITEMS into g_ITAB_TC_wa2
       where MARK = 'X'.
       g_ITAB_TC_wa2-MARK = ''.
       modify IT_ITEMS
         from g_ITAB_TC_wa2
         transporting MARK.
     endloop.
  endif.
  MODIFY IT_ITEMS
    FROM WA_ITEMS
    INDEX ITAB_TC-CURRENT_LINE
    TRANSPORTING MARK.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ITAB_TC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE ITAB_TC_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'ITAB_TC'
                              'IT_ITEMS'
                              'MARK'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_LEVEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LEVEL INPUT.


  PERFORM CHECK_LEVEL_PRECENT .

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_RULE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_RULE INPUT.


*
* REFRESH IT_ITEMS2 .
*  IT_ITEMS2 = IT_ITEMS .
*  SORT IT_ITEMS2 BY ZRULE .
*  DELETE IT_ITEMS2 WHERE ZRULE = space.
*  DELETE ADJACENT DUPLICATES FROM IT_ITEMS2 COMPARING ZRULE .
*
**  DESCRIBE TABLE  IT_RULE2 LINES LINE .
*  IF SY-subrc = 0 .
*
*    MESSAGE 'Rule is Twice Defined' TYPE 'E'.
**    LEAVE TO LIST-PROCESSING.
*
*
*
*  ENDIF.

CLEAR /CICRE/ROLE .
SELECT SINGLE * FROM /CICRE/ROLE WHERE ROLE_ID = WA_ITEMS-ZRULE .
  IF SY-SUBRC <> 0 .

    MESSAGE `This Rule doesn't Defined in table /CICRE/ROLE` TYPE 'E' .

  else.
     SELECT SINGLE ROLE_T FROM /CICRE/ROLE INTO WA_ITEMS-RULE_DESC
            WHERE ROLE_ID = WA_ITEMS-ZRULE .
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_NAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_NAME INPUT.

     SELECT SINGLE SNAME FROM PA0001 INTO WA_ITEMS-NAME1
              WHERE PERNR = WA_ITEMS-EMPLOYER .
               IF SY-SUBRC <> 0 .
                 CLEAR WA_ITEMS-NAME1 .

               ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

   CASE SY-UCOMM.
    WHEN 'BACK' .
      LEAVE TO SCREEN 0 .
    WHEN 'EXIT'.
      LEAVE PROGRAM .
      ENDCASE.

ENDMODULE.
