*&---------------------------------------------------------------------*
*& Report  ZFI_CHK_FORM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zfi_chk_multi_form_print.

TABLES zfi_cheques.

PARAMETERS : p_doc  TYPE vblnr OBLIGATORY,
             p_comp TYPE bukrs OBLIGATORY,
             p_year TYPE gjahr OBLIGATORY,
             p_line TYPE char1 AS CHECKBOX DEFAULT 'X'.

DATA: t_check_fields  TYPE TABLE OF zchk_fields,
      ls_check_fields LIKE LINE OF t_check_fields.

DATA: checks_table    TYPE zchk_form_table_tt,
      ls_checks_table LIKE LINE OF checks_table.

DATA: t_config  TYPE TABLE OF zchk_form_str,
      ls_config LIKE LINE OF  t_config.

DATA: sum_return TYPE spell.
DATA: fract_return TYPE spell.
DATA: wa_payr TYPE payr .
DATA: wa_bsik TYPE bsik .

DATA: x_cm TYPE p LENGTH 4 DECIMALS 3,
      x_in LIKE x_cm,
      y_in LIKE x_cm.

DATA : am1(13),
       am2(13),
       am3      TYPE numc2,
       in_words TYPE in_words.
DATA : temp_fract TYPE char50 .

DATA: wa_payee TYPE lfa1 .
DATA: wa_bsak TYPE bsak .

DATA: wa_bseg TYPE bseg.

DATA: fm_name         TYPE rs38l_fnam,
      form_name       TYPE fpname,
      fp_docparams    TYPE sfpdocparams,
      fp_outputparams TYPE sfpoutputparams.


SELECT SINGLE *
  FROM payr
  INTO wa_payr
  WHERE zbukr EQ p_comp
    AND gjahr EQ p_year
    AND vblnr EQ p_doc
   .
SELECT SINGLE *
  FROM bseg
  INTO wa_bseg
  WHERE bukrs EQ p_comp
    AND belnr EQ p_doc
    AND gjahr EQ p_year
    AND shkzg EQ 'H'
.
zfi_cheques-budat = sy-datum .
zfi_cheques-netwr = wa_payr-rwbtr .
zfi_cheques-curr = wa_payr-waers .
*zfi_cheques-zaldt = wa_payr-zaldt .
zfi_cheques-zaldt = wa_bseg-valut .
CONCATENATE wa_payr-znme1 wa_payr-znme2 INTO zfi_cheques-name1 SEPARATED BY space .

zfi_cheques-netwr = abs( zfi_cheques-netwr ) .
" Amount in words
am1 = zfi_cheques-netwr.
SHIFT am1 LEFT DELETING LEADING space.
SPLIT am1 AT '.' INTO am2 am3.
SHIFT am2 LEFT DELETING LEADING '0' .
*  shift am3 LEFT DELETING LEADING '0' .

CALL FUNCTION 'ZSPELL_AMOUNT'
  EXPORTING
    amount   = am2
*   fraction = am3
    currency = wa_payr-waers
  IMPORTING
    in_words = sum_return.

IF am3 > 0 .
  CALL FUNCTION 'ZSPELL_AMOUNT'
    EXPORTING
      amount   = am3
*     fraction = am3
      currency = wa_payr-waers
    IMPORTING
      in_words = fract_return.

*  temp_fract = fract_return .
  IF am3 > 10 .
    REPLACE ALL OCCURRENCES OF 'جنيه مصرى' IN fract_return-word WITH 'قرشا'.
  ELSE .
    REPLACE ALL OCCURRENCES OF 'جنيه مصرى' IN fract_return-word WITH 'قروش'.
  ENDIF.
*  zfi_cheques-aminlt = sum_return-word.
*  fract_return = temp_fract .
  CONCATENATE sum_return-word 'و' fract_return-word 'فقط لاغير' INTO zfi_cheques-aminlt  SEPARATED BY space .

ELSE .
*    zfi_cheques-aminlt = sum_return-word .
  CONCATENATE sum_return-word 'فقط لاغير' INTO zfi_cheques-aminlt  SEPARATED BY space .
ENDIF.

*  fp_outputparams-preview    = 'X'.
*  fp_outputparams-nodialog   = 'X'.
*  fp_outputparams-dest       = 'PDF'.

*CASE wa_payr-hbkid.
*  WHEN 'AUDI' OR 'AUD11' OR 'AUD12' OR 'AUD13' OR 'AUD20' OR 'AUD21' OR 'AUD22' OR 'AUD23' OR 'AUD24' OR 'AUD03' OR 'AUD02' .     "AUDI BANK
*    form_name = 'ZLAUDI_BANK'.
*  WHEN 'ALX01' OR 'ALX02' OR 'ALX03' OR 'ALX11'.    "ALEX Bank
*    form_name = 'ZLALEX_BANK'.
*  WHEN 'EGB01' OR 'EGB02' .
*    form_name = 'ZLEG_BANK' .
*  WHEN 'QNB' OR 'QNB20' OR 'QNB21' OR 'QNB22' OR 'QNB23'  .
*    form_name = 'ZLQNB_BANK'.
*  WHEN 'EAL01' .
*    form_name = 'ZLEALB_BANK'.
*  WHEN 'UNI01' OR 'UNIB'.
*    form_name = 'ZLUNIB_BANK'.
*  WHEN 'BMISR' OR 'BMSR1'.
*    form_name = 'ZLBMISR_BANK' .
*  WHEN 'BCAIR' OR 'BCA01' .
*    form_name = 'ZLCAIRO_BANK'.
*  WHEN 'BEDBE' OR 'BEBE1'.
*    form_name = 'ZLEBE_BANK'.
*  ENDCASE.

* Read Field Dimenstions from Database.
SELECT *
  FROM zchk_fields
  INTO CORRESPONDING FIELDS OF TABLE t_check_fields.

DO 3 TIMES.
* Prepare Dimensions table
  LOOP AT t_check_fields INTO ls_check_fields.

    ls_check_fields-dim_x = ls_check_fields-dim_x - '0.2'.
    MOVE-CORRESPONDING ls_check_fields TO ls_config.
    " ls_config-dim_x = ls_config-dim_x && 'IN'.
    "  ls_config-dim_y = ls_config-dim_y && 'IN'.
    IF ls_check_fields-field_name = 'CUST_NAME'.
      x_in = ( ls_config-dim_x - 10 ) *  '0.393701'.
    ELSEIF ls_check_fields-field_name = 'AMOUNT_TXT'.
      x_in = ( ls_config-dim_x - 10 ) *  '0.393701'.
    ELSE.
      x_in = ( ls_config-dim_x ) *  '0.393701'.
    ENDIF.
    y_in = ls_config-dim_y *  '0.393701'.
    ls_config-dim_x = x_in && 'IN'.
    ls_config-dim_y = y_in && 'IN'.

    CASE ls_check_fields-field_name.
      WHEN 'CUST_NAME'.
        ls_config-field_value = 'مريم أسامة أحمد حسين محمد'. "zfi_cheques-name1. 'ABC'
        ls_config-index = 1.
        "  x_cm = '6'."( '27.94' * '6')  / '16.9'.
      WHEN 'POST_DATE'.
        ls_config-field_value = '01.01.2018'. "zfi_cheques-budat. '01.01.2018'
        ls_config-index = 2.
        "   x_cm = '12.5'. "( '27.94' * '12.5')  / '16.9'.
*      x_in = ls_config-dim_x *  '0.393701'.
*      ls_config-dim_x = x_in && 'IN'.
      WHEN 'AMOUNT'.
        ls_config-field_value = '20,000'. "zfi_cheques-budat. '01.01.2018'
        ls_config-index = 3.
        "     x_cm = '13.5'. "( '27.94' * '13.5')  / '16.9'.
*      x_in = ls_config-dim_x *  '0.393701'.
*      ls_config-dim_x = x_in && 'IN'.
      WHEN 'AMOUNT_TXT'.
        ls_config-field_value = 'عشرون ألف جنيه مصري فقط لا غير'. "zfi_cheques-budat. '01.01.2018'
        ls_config-index = 4.
        "   x_cm = '5'. "( '27.94' * '5')  / '16.9'.
*      x_in = ls_config-dim_x *  '0.393701'.
*      ls_config-dim_x = x_in && 'IN'.
    ENDCASE.

    APPEND ls_config TO t_config.
    CLEAR:  ls_config, x_cm, x_in.
  ENDLOOP.

  SORT t_config BY index.
  ls_checks_table-t_config = t_config.
  ls_checks_table-with_line = p_line.
  APPEND ls_checks_table TO checks_table.
  CLEAR: t_config[], t_config, ls_checks_table.

ENDDO.

form_name = 'ZDYNAMIC_MULTI_CHECKS_PRINT_F'.

CALL FUNCTION 'FP_JOB_OPEN'
  CHANGING
    ie_outputparams = fp_outputparams
  EXCEPTIONS
    cancel          = 1
    usage_error     = 2
    system_error    = 3
    internal_error  = 4
    OTHERS          = 5.

CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
  EXPORTING
    i_name     = form_name
  IMPORTING
    e_funcname = fm_name.

  CALL FUNCTION fm_name
    EXPORTING
      /1bcdwb/docparams = fp_docparams
      t_checks          = checks_table
    EXCEPTIONS
      usage_error       = 1
      system_error      = 2
      internal_error    = 3.

CALL FUNCTION 'FP_JOB_CLOSE'
*    IMPORTING
*     E_RESULT        =
  EXCEPTIONS
    usage_error    = 1
    system_error   = 2
    internal_error = 3
    OTHERS         = 4.
