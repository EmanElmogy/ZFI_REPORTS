*----------------------------------------------------------------------*
***INCLUDE ZCOMM_MASTER_STATUS_100.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'MAIN'.
*  SET TITLEBAR 'xxx'.

  IF FLAG_NEW = 'X'.

    LOOP AT SCREEN.

      IF SCREEN-NAME = 'ZCOMM_MASTER-DOC_NO'.

         SCREEN-INPUT = 0 .

         MODIFY SCREEN .

      ENDIF.

    ENDLOOP.
  ELSEIF FOUND = 'X'.

     LOOP AT SCREEN.

      IF SCREEN-NAME <> 'ZCOMM_MASTER-VALID_TO' .

         SCREEN-INPUT = 0 .

         MODIFY SCREEN .

      ENDIF.

    ENDLOOP.



  ENDIF.
ENDMODULE.
