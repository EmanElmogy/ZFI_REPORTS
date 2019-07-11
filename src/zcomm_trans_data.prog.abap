*&---------------------------------------------------------------------*
*&  Include  ZCOMM_TRANS_DATA
*&---------------------------------------------------------------------*

*&SPWIZARD: DECLARATION OF TABLECONTROL 'ITAB_TC' ITSELF
CONTROLS: ITAB_TC TYPE TABLEVIEW USING SCREEN 0100.

*&SPWIZARD: LINES OF TABLECONTROL 'ITAB_TC'
DATA:     G_ITAB_TC_LINES  LIKE SY-LOOPC.

DATA:     OK_CODE LIKE SY-UCOMM.
