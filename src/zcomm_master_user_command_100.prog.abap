*----------------------------------------------------------------------*
***INCLUDE ZCOMM_MASTER_USER_COMMAND_100.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.


  CASE SY-UCOMM.
    WHEN  'SAVE'.

      PERFORM SAVE_DATA.
      WHEN  'BACK' .
      LEAVE TO SCREEN 0 .
      WHEN  'EXIT' .
      LEAVE PROGRAM .
    WHEN 'NEW'.
      FLAG_NEW = 'X'.

      CLEAR : ZCOMM_MASTER,   FOUND .
      REFRESH IT_RULES .

      PERFORM GET_DOC_ID.

    WHEN 'CLEAR' .

          CLEAR : ZCOMM_MASTER,  FLAG_NEW , FOUND , WA_RULES .
          REFRESH IT_RULES .




      WHEN OTHERS.
  ENDCASE.

ENDMODULE.
