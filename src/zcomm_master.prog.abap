*&---------------------------------------------------------------------*
*& Report ZCOMM_MASTER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCOMM_MASTER.

TABLES : ZCOMM_MASTER .

DATA : IT_RULES  TYPE TABLE OF ZCOMM_MAST_RULES_S ,
       WA_RULES TYPE  ZCOMM_MAST_RULES_S ,
       IT_DATA TYPE TABLE OF ZCOMM_MAST_RULES,
       WA_DATA TYPE ZCOMM_MAST_RULES ,
        DOC type num ,
       FLAG_NEW,
       FOuND.

CALL SCREEN 100 .

INCLUDE zcomm_master_status_100.

INCLUDE zcomm_master_user_command_100.

*&SPWizard: Data incl. inserted by SP Wizard. DO NOT CHANGE THIS LINE!
INCLUDE ZCOMM_MASTER_DATA .
*&SPWizard: Include inserted by SP Wizard. DO NOT CHANGE THIS LINE!
INCLUDE ZCOMM_MASTER_PBO .
INCLUDE ZCOMM_MASTER_PAI .
INCLUDE ZCOMM_MASTER_FI .
