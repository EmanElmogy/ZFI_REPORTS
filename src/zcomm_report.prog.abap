*&---------------------------------------------------------------------*
*& Report ZCOMM_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCOMM_REPORT.

TABLES : VICNCN , ZCOMM_TRANS_RULS .


*
*TYPES : BEGIN OF STR ,
*          CONTRACT_NO   TYPE RECNNUMBER,
*          BUS_ENTITY TYPE SWENR,
*          CONTRACT_DATE TYPE RECNCNBEG,
*          AMOUNT        TYPE ZRECDUNITPRICE,
*          START_DATE    TYPE RECNBEG ,
*          RULE          TYPE ZRULE ,
*          EMPLOYEER     TYPE PERNR_D ,
*          EMP_PERS      TYPE ZRECDUNITPRICE ,
*          COMM          TYPE ZRECDUNITPRICE ,
*        END OF STR .


DATA : INST_TAB    TYPE  TABLE OF /CICRE/INSTALLMENTS_DETAILS WITH HEADER LINE,
       WA_INST     TYPE  /CICRE/INSTALLMENTS_DETAILS,
       IT_RULS     TYPE TABLE OF ZCOMM_TRANS_RULS,
       WA_RULS     TYPE ZCOMM_TRANS_RULS,
       SHARE       TYPE ZSHERE,
       COMM        TYPE ZCOMM,
       COMM_AMOUNT TYPE ZRECDUNITPRICE,
       IT_TERM     TYPE TABLE OF BAPI_RE_TERM_PY,
       VENDOR      TYPE LFA1-LIFNR.
*       WA_TERM TYPE BAPI_RE_TERM_PY .




DATA : IT_DATA      TYPE  TABLE OF ZCOMM_REPORT,
       WA_DATA      TYPE ZCOMM_REPORT,
       IT_VICNCN    TYPE TABLE OF VICNCN,
       WA_VICNCN    TYPE VICNCN,
       IT_CONT      TYPE TABLE OF ZCOMM_REPORT,
       WA_CONT      TYPE  ZCOMM_REPORT,
       DOC_NO       TYPE ZCOMM_MASTER-DOC_NO,
       IT_TEMP      LIKE IT_CONT,
       WA_TEMP      LIKE WA_CONT,
       IT_PARTNERS  TYPE TABLE OF  BAPI_RE_PARTNER,
       WA_PARTNERS  TYPE BAPI_RE_PARTNER,
       IT_SUMB      TYPE TABLE OF  BAPI_RE_RESUBM_RULE,
       WA_SUMB      TYPE BAPI_RE_RESUBM_RULE,
       IT_CONT2     LIKE IT_CONT,
       CONTRACT_HDR LIKE BAPI_RE_CONTRACT,
       WA_TERM      TYPE BAPI_RE_TERM_PY,
*       IT_TERM TYPE TABLE OF BAPI_RE_TERM_PY,
       IT_CONTRACT  TYPE TABLE OF /CICRE/CONTRACT_DATA,
       WA_CONTRACT  TYPE /CICRE/CONTRACT_DATA,
       DMBTR_S      TYPE BSID-DMBTR,
       DMBTR_H      TYPE BSID-DMBTR,
       CON_STR      TYPE STRING.



FIELD-SYMBOLS : <FS>      TYPE ZCOMM_REPORT,
                <FS_CONT> TYPE ZCOMM_REPORT.
SELECTION-SCREEN BEGIN OF BLOCK BLK1 .


SELECT-OPTIONS : S_DATE FOR VICNCN-RECNBEG ,
S_BUS   FOR VICNCN-BENOCN ,
S_EMP FOR ZCOMM_TRANS_RULS-EMPLOYER ,
S_BUKRS FOR VICNCN-BUKRS .

PARAMETERS : R1 AS CHECKBOX,
             R2 AS CHECKBOX.

SELECTION-SCREEN END OF   BLOCK BLK1.


START-OF-SELECTION .

  SELECT DISTINCT * FROM VICNCN  INTO  TABLE IT_VICNCN WHERE RECNBEG IN S_DATE AND BENOCN IN S_BUS AND BUKRS IN S_BUKRS

    AND EXISTS ( SELECT * FROM ZCOMM_TRANS_RULS WHERE BUKRS IN S_BUKRS AND   CONTRACT_NO = VICNCN~RECNNR AND EMPLOYER IN S_EMP  ).
  "  AND BUKRS <> '1000' .





  READ TABLE IT_TERM INTO WA_TERM INDEX 1 .

  LOOP AT IT_VICNCN INTO WA_VICNCN .


    WA_CONT-BUS_ENTITY  = WA_VICNCN-BENOCN .
    WA_CONT-CONTRACT_DATE = WA_VICNCN-RECNBEG .
    WA_CONT-CONTRACT_NO = WA_VICNCN-RECNNR .


    REFRESH IT_TERM .
    CLEAR WA_TERM .

    CALL FUNCTION 'BAPI_RE_CN_GET_DETAIL'
      EXPORTING
        COMPCODE       = WA_VICNCN-BUKRS
        CONTRACTNUMBER = WA_VICNCN-RECNNR
      TABLES
        TERM_PAYMENT   = IT_TERM.


    READ TABLE IT_TERM INTO WA_TERM INDEX 1 .
    IF SY-SUBRC = 0 .

      CON_STR = WA_VICNCN-RECNNR .

      SHIFT CON_STR LEFT DELETING LEADING '0' .

      SHIFT VICNCN-RECNNR LEFT DELETING LEADING '0'.
      SELECT SUM( DMBTR ) FROM BSID INTO DMBTR_S
        WHERE BUKRS = WA_VICNCN-BUKRS AND BLART = 'RL'  AND KUNNR = WA_TERM-PARTNER AND UMSKZ = 'D'
        AND ZUONR = CON_STR AND SHKZG = 'S' .
      IF SY-SUBRC <> 0 .


        SELECT SUM( DMBTR ) FROM BSAD INTO DMBTR_S
          WHERE BUKRS = WA_VICNCN-BUKRS AND BLART = 'RL'  AND KUNNR = WA_TERM-PARTNER AND UMSKZ = 'D'
          AND ZUONR = CON_STR  AND SHKZG = 'S' .

      ENDIF.


      SELECT SUM( DMBTR ) FROM BSID INTO DMBTR_H
     WHERE BUKRS = WA_VICNCN-BUKRS AND BLART = 'RL'  AND KUNNR = WA_TERM-PARTNER AND UMSKZ = 'D'
     AND ZUONR = CON_STR AND SHKZG = 'H' .
      IF SY-SUBRC <> 0 .


        SELECT SUM( DMBTR ) FROM BSAD INTO DMBTR_H
          WHERE BUKRS = WA_VICNCN-BUKRS AND BLART = 'RL'  AND KUNNR = WA_TERM-PARTNER AND UMSKZ = 'D'
          AND ZUONR = CON_STR AND SHKZG = 'H' .

      ENDIF.

    ENDIF.

    WA_CONT-FULL_AMOUNT = ABS( DMBTR_S - DMBTR_H ) .

*    CALL FUNCTION '/CICRE/INST_GET_LIST_CONTRACT'
*      EXPORTING
**       OFFER_NO    =
*        COMP_CODE   = WA_VICNCN-BUKRS
*        CONTRACT_NO = WA_VICNCN-RECNNR
*      TABLES
*        INST_TAB    = INST_TAB.
*
*    LOOP AT INST_TAB.
*
*      WA_CONT-FULL_AMOUNT = WA_CONT-FULL_AMOUNT + INST_TAB-COND_AMOUNT.
*
*    ENDLOOP.


    REFRESH IT_RULS .

    SELECT * FROM ZCOMM_TRANS_RULS INTO TABLE IT_RULS WHERE BUKRS = WA_VICNCN-BUKRS AND CONTRACT_NO = WA_VICNCN-RECNNR AND EMPLOYER IN S_EMP .


    LOOP AT IT_RULS INTO WA_RULS.

      WA_CONT-RULE = WA_RULS-ZRULE .
      WA_CONT-PERNR = WA_RULS-EMPLOYER .
      WA_CONT-BUKRS = WA_RULS-BUKRS .

      APPEND WA_CONT TO IT_CONT .

    ENDLOOP.

    CLEAR WA_CONT .
  ENDLOOP .


*  break ismail .

  REFRESH : IT_TERM .
  CLEAR WA_TERM .

  LOOP AT IT_CONT ASSIGNING <FS_CONT>.

    CLEAR : COMM_AMOUNT , COMM , DOC_NO , SHARE .

    SELECT SINGLE  ZSHARE COMMISSION FROM ZCOMM_TRANS_RULS  INTO (SHARE, COMM )  WHERE CONTRACT_NO  = <FS_CONT>-CONTRACT_NO AND ZRULE = <FS_CONT>-RULE
     AND EMPLOYER = <FS_CONT>-PERNR .

    <FS_CONT>-EMP_PER = <FS_CONT>-FULL_AMOUNT * ( SHARE / 100 ) .

    SELECT SINGLE DOC_NO FROM ZCOMM_MASTER INTO DOC_NO WHERE BUS_ENTITY = <FS_CONT>-BUS_ENTITY
      AND (  VALID_TO => <FS_CONT>-CONTRACT_DATE AND VALID_FROM <= <FS_CONT>-CONTRACT_DATE ) .

    SELECT SINGLE AMOUNT FROM ZCOMM_MAST_RULES INTO COMM_AMOUNT WHERE DOC_NO = DOC_NO AND ZRULE = <FS_CONT>-RULE .

    <FS_CONT>-COMMISSION = <FS_CONT>-EMP_PER * ( COMM_AMOUNT / 1000000 ) *  ( COMM / 100 ) .
*    SELECT SINGLE VORNA FROM PA0002 INTO <FS_CONT>-NAME WHERE PERNR = <FS_CONT>-PERNR .
    VENDOR = <FS_CONT>-PERNR .

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = VENDOR
      IMPORTING
        OUTPUT = VENDOR.

    SELECT SINGLE NAME1 FROM LFA1 INTO <FS_CONT>-NAME WHERE LIFNR = VENDOR .
    SELECT SINGLE ROLE_T FROM /CICRE/ROLE INTO <FS_CONT>-ROLE_T WHERE ROLE_ID = <FS_CONT>-RULE.

    CALL FUNCTION 'BAPI_RE_CN_GET_DETAIL'
      EXPORTING
        COMPCODE       = <FS_CONT>-BUKRS
        CONTRACTNUMBER = <FS_CONT>-CONTRACT_NO
      IMPORTING
        CONTRACT       = CONTRACT_HDR
      TABLES
        PARTNER        = IT_PARTNERS
        RESUBM_RULE    = IT_SUMB
        TERM_PAYMENT   = IT_TERM.


    READ TABLE IT_TERM INTO WA_TERM INDEX 1 .
    IF SY-SUBRC = 0 .

      <FS_CONT>-CLIENT = WA_TERM-PARTNER .

      SELECT SINGLE NAME1 FROM KNA1 INTO <FS_CONT>-NAME_CUST WHERE KUNNR = WA_TERM-PARTNER .

    ENDIF.

    READ TABLE IT_PARTNERS INTO WA_PARTNERS WITH KEY ROLE_TYPE = 'TR0608'.
    IF SY-SUBRC = 0.

      <FS_CONT>-BRANCH_ID = WA_PARTNERS-PARTNER .

      SELECT SINGLE MC_NAME2 FROM BUT000 INTO <FS_CONT>-BRANCH_NAME WHERE PARTNER = WA_PARTNERS-PARTNER .

    ENDIF.



      READ TABLE IT_SUMB INTO WA_SUMB WITH KEY RESUBM_RULE = 'A01' RESUBM_REASON = '0312' .
      IF SY-SUBRC = 0 .

        <FS_CONT>-STATUS = 'X'.

      ELSE.
        <FS_CONT>-STATUS = SPACE .

      ENDIF.

*    READ TABLE IT_SUMB INTO WA_SUMB WITH KEY RESUBM_RULE = 'A26' .  "Commented by Maryam based on Dabbagh's request 18.10.2018
*    IF SY-SUBRC = 0 AND WA_SUMB-RESUBM_REASON = '0166' AND CONTRACT_HDR-NOTICE_ACTIVATION_DATE IS INITIAL .
*      " Resumbtion  Customer signed  & not termination

      CALL FUNCTION '/CICRE/CONTRACT_GET_ENTITYLIST'
        EXPORTING
          CONTRACT_ID    = <FS_CONT>-CONTRACT_NO
          COMPANY        = <FS_CONT>-BUKRS
        TABLES
          CONTRACTS_LIST = IT_CONTRACT.

      READ TABLE IT_CONTRACT INTO WA_CONTRACT WITH KEY IS_POSTED = 'X' .  " Posted

      IF SY-SUBRC = 0 .


        READ TABLE INST_TAB INTO WA_INST WITH KEY COND_TYPE = 'Z400' .

        IF SY-SUBRC = 0 .

          IF WA_INST-REM_AMOUNT = 0 .

            APPEND <FS_CONT> TO IT_CONT2 .

          ENDIF.


        ELSE.

          APPEND <FS_CONT> TO IT_CONT2.

        ENDIF.




      ENDIF.

*    ELSE.
*
*
*
*
*    ENDIF.


  ENDLOOP.

  IF R1 = 'X' AND R2 <> 'X'.

    DELETE IT_CONT2 WHERE STATUS = space .

  ELSEIF R1 = 'X' AND R2 = 'X' .

  ELSEIF R2 = 'X' AND R1 <> 'X' .

    DELETE IT_CONT2 WHERE STATUS = 'X'.


  ENDIF.

*    break ismail .


  SORT IT_CONT2 BY BUS_ENTITY PERNR RULE .

*    IT_TEMP = IT_CONT .
*
*    DELETE ADJACENT DUPLICATES FROM IT_TEMP COMPARING BUS_ENTITY EMPLOYEER RULE .
*
*
*    LOOP AT IT_TEMP INTO WA_TEMP.
*
*      LOOP AT IT_CONT INTO WA_CONT WHERE BUS_ENTITY = WA_TEMP-BUS_ENTITY  AND EMPLOYEER = WA_TEMP-EMPLOYEER AND RULE = WA_TEMP-RULE.
*
*        WA_DATA-FULL_AMOUNT = WA_DATA-FULL_AMOUNT + WA_CONT-AMOUNT .
*        WA_DATA-EMP_PER  = WA_DATA-EMP_PER + WA_CONT-EMP_PERS .
*        WA_DATA-COMMISSION = WA_DATA-COMMISSION + WA_CONT-COMM .
*
*      ENDLOOP.
*
*      WA_DATA-RULE = WA_TEMP-RULE .
*      WA_DATA-BUS_ENTITY = WA_TEMP-bus_entity .
*      WA_DATA-PERNR = WA_TEMP-EMPLOYEER .
*      SELECT SINGLE VORNA FROM PA0002 INTO WA_DATA-NAME WHERE PERNR = WA_DATA-PERNR .
*      SELECT SINGLE ROLE_T FROM /cicre/ROLE INTO WA_DATA-ROLE_T WHERE ROLE_ID = WA_DATA-RULE.
*
*     APPEND WA_DATA to IT_DATA .
*
*     CLEAR : WA_DATA .
*
*    ENDLOOP.



  DATA : IT_FC TYPE SLIS_T_FIELDCAT_ALV,
         WA_FC LIKE LINE OF IT_FC.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-CPROG
      I_STRUCTURE_NAME       = 'ZCOMM_REPORT'
      I_CLIENT_NEVER_DISPLAY = 'X'
      I_INCLNAME             = SY-CPROG
    CHANGING
      CT_FIELDCAT            = IT_FC
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1.

  LOOP AT IT_FC INTO WA_FC.

    IF WA_FC-FIELDNAME = 'FULL_AMOUNT' .

      WA_FC-DDICTXT = 'M'.
      WA_FC-SELTEXT_L = 'Full Contract Amount'.
      WA_FC-SELTEXT_M = 'Full Contract Amount'.
      WA_FC-SELTEXT_S = 'Full Contract Amount'.

    ELSEIF WA_FC-FIELDNAME = 'EMP_PER'.


      WA_FC-DDICTXT  = 'L'.
      WA_FC-SELTEXT_L = 'EMP Percentage Amount'.
      WA_FC-SELTEXT_M = 'EMP Percentage Amount'.

    ELSEIF WA_FC-FIELDNAME = 'COMMISSION'.


      WA_FC-DDICTXT   = 'M'.
      WA_FC-SELTEXT_L = 'Commission Amount'.
      WA_FC-SELTEXT_M = 'Commission Amount'.


    ELSEIF WA_FC-FIELDNAME = 'BUS_ENTITY'.

      WA_FC-DDICTXT = 'M'.
      WA_FC-OUTPUTLEN = 12.

    ELSEIF WA_FC-FIELDNAME = 'PERNR'.

      WA_FC-DDICTXT   = 'M'.
      WA_FC-SELTEXT_L = 'Employee'.
      WA_FC-SELTEXT_M = 'Employee'.

    ELSEIF WA_FC-FIELDNAME = 'ROLE_T'.

      WA_FC-DDICTXT = 'M'.
      WA_FC-SELTEXT_M = 'Rule Desc'.

    ELSEIF WA_FC-FIELDNAME = 'BRANCH_ID'.
      WA_FC-DDICTXT = 'M'.
      WA_FC-SELTEXT_M = 'Branch ID'.

    ELSEIF WA_FC-FIELDNAME = 'BRANCH_NAME'.
      WA_FC-DDICTXT = 'M'.
      WA_FC-SELTEXT_M = 'Branch Name'.

    ELSEIF WA_FC-FIELDNAME = 'CLIENT' .
      WA_FC-DDICTXT = 'M' .
      WA_FC-SELTEXT_M = 'Client' .
    ELSEIF WA_FC-FIELDNAME = 'NAME_CUST'.
      WA_FC-DDICTXT = 'M' .
      WA_FC-SELTEXT_M = 'Client Name' .

    ELSEIF WA_FC-FIELDNAME = 'STATUS'.
      WA_FC-DDICTXT = 'M'.
      WA_FC-SELTEXT_M = 'Confirmed' .


    ENDIF.
    MODIFY IT_FC FROM WA_FC.
  ENDLOOP.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-CPROG
*     is_layout          = ls_layo
      I_SAVE = 'A'
      IT_FIELDCAT        = IT_FC
*     i_callback_pf_status_set = 'SET_PF_STATUS'
*     i_suppress_empty_data    = 'X'
    TABLES
      T_OUTTAB           = IT_CONT2
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
