*&---------------------------------------------------------------------*
*& Report ZCOMM_TRANS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCOMM_TRANS.

TABLES : ZCOMM_TRANS , VICNCN ,/CICRE/ROLE .
DATA : CONT_AMOUNT TYPE BSID-DMBTR ,
        IT_ITEMS TYPE TABLE OF  ZCOMM_TRANS_STR ,
       WA_ITEMS TYPE ZCOMM_TRANS_STR ,
       INST_TAB type  table of /CICRE/INSTALLMENTS_DETAILS with header line,
       IT_RULES TYPE TABLE OF ZCOMM_TRANS_RULS ,
       WA_RULES TYPE ZCOMM_TRANS_RULS,
       WA_TEMP LIKE WA_ITEMS ,
       LVL_PRCNT TYPE I ,
       IT_ITEMS2 LIKE IT_ITEMS ,
       LINE TYPE I ,
       IT_PARTNER TYPE TABLE OF  BAPI_RE_PARTNER ,
       WA_PARTNER TYPE BAPI_RE_PARTNER ,
       WA_BRCH TYPE /CICRE/BRCH_USER ,
       WA_ROLE TYPE /CICRE/ROL_USR ,
      WA_TERM tYPE BAPI_RE_TERM_PY ,
       IT_TERM TYPE TABLE OF BAPI_RE_TERM_PY,
       DMBTR_S TYPE BSID-DMBTR ,
       DMBTR_H TYPE BSID-DMBTR .


CALL SCREEN 100.

INCLUDE zcomm_trans_status_100.

INCLUDE zcomm_trans_user_command_100.

*&SPWizard: Data incl. inserted by SP Wizard. DO NOT CHANGE THIS LINE!
INCLUDE ZCOMM_TRANS_DATA .
*&SPWizard: Include inserted by SP Wizard. DO NOT CHANGE THIS LINE!
INCLUDE ZCOMM_TRANS_PBO .
INCLUDE ZCOMM_TRANS_PAI .
INCLUDE ZCOMM_TRANS_FI .
