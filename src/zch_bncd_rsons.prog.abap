*&---------------------------------------------------------------------*
*& Report ZCH_BNCD_RSONS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zch_bncd_rsons.

TABLES: bsed, zch_bncd_rsons.

TYPES: BEGIN OF ty_output.
    INCLUDE STRUCTURE zch_bncd_rsons.
TYPES: bncd_desc TYPE zbncd_rsons-bncd_desc.
TYPES: END OF ty_output.

DATA: t_reason  TYPE TABLE OF ty_output,
      ls_reason LIKE LINE OF t_reason.

DATA: alv_field_cat TYPE slis_t_fieldcat_alv,
      wa_field_cat  TYPE slis_fieldcat_alv,
      alv_layout    TYPE slis_layout_alv,
      t_sort        TYPE slis_t_sortinfo_alv,
      length        TYPE i.

* Selection Screen.
SELECTION-SCREEN BEGIN OF BLOCK blk.
SELECT-OPTIONS: bukrs    FOR bsed-bukrs OBLIGATORY,
                belnr    FOR bsed-belnr,
                boeno    FOR bsed-belnr,
                bank     FOR bsed-bank,
                b_reason FOR zch_bncd_rsons-bncd_rson MATCHCODE OBJECT zsh_bncd_rsons,
                b_date   FOR zch_bncd_rsons-bncd_date.
SELECTION-SCREEN END OF BLOCK blk.

LOOP AT boeno.
  SHIFT boeno-low  LEFT DELETING LEADING '0'.
  SHIFT boeno-high LEFT DELETING LEADING '0'.
  MODIFY boeno.
ENDLOOP.

* Selection
SELECT *
  FROM zch_bncd_rsons AS a
  INNER JOIN zbncd_rsons AS b ON a~bncd_rson = b~bncd_code
  INTO CORRESPONDING FIELDS OF TABLE t_reason
  WHERE bukrs IN bukrs
  AND belnr IN belnr
  AND boeno IN boeno
  AND bank IN bank
  AND bncd_rson IN b_reason
  AND bncd_date IN b_date.


PERFORM create_fieldcat CHANGING alv_field_cat.
PERFORM set_layout CHANGING alv_layout.
PERFORM alv_grid.


*&---------------------------------------------------------------------*
*& Include          ZCONTRACTOR_REPORT_DISPLAY
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          ZCONTRACTOR_REPORT_DISPLAY
*&---------------------------------------------------------------------*

FORM create_fieldcat CHANGING field_cat TYPE slis_t_fieldcat_alv.

  wa_field_cat-fieldname = 'BUKRS'.
  wa_field_cat-seltext_l = 'Company Code'.
  wa_field_cat-ddictxt   = 'M'.
  wa_field_cat-fix_column = 'X'.
  " wa_field_cat-key = 'X'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'GJAHR'.
  wa_field_cat-seltext_m = 'Fiscal Year'.
  wa_field_cat-ddictxt   = 'M'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'BELNR'.
  wa_field_cat-seltext_m = 'Document Number'.
  wa_field_cat-ddictxt   = 'M'.
  wa_field_cat-fix_column = 'X'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'BUZEI'.
  wa_field_cat-seltext_m = 'Line Item'.
  wa_field_cat-ddictxt   = 'M'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'BANK'.
  wa_field_cat-seltext_m = 'Bank Key'.
  wa_field_cat-ddictxt   = 'M'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'BOENO'.
  wa_field_cat-seltext_m = 'Check Number'.
  wa_field_cat-ddictxt   = 'M'.
  wa_field_cat-do_sum = 'X'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'ZFBDT'.
  wa_field_cat-seltext_m = 'Check Due Date'.
  wa_field_cat-ddictxt   = 'M'.
  wa_field_cat-do_sum = 'X'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'KUNNR'.
  wa_field_cat-seltext_m = 'Customer Code'.
  wa_field_cat-ddictxt   = 'M'.
  wa_field_cat-do_sum = 'X'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'BNCD_DATE'.
  wa_field_cat-seltext_m = 'Bounced Date'.
  wa_field_cat-ddictxt   = 'M'.
  wa_field_cat-do_sum = 'X'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'BNCD_RSON'.
  wa_field_cat-seltext_m = 'Bounced Reason Code'.
  wa_field_cat-ddictxt   = 'M'.
  wa_field_cat-do_sum = 'X'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.

  wa_field_cat-fieldname = 'BNCD_DESC'.
  wa_field_cat-seltext_m = 'Bounced Reason Desc.'.
  wa_field_cat-ddictxt   = 'M'.
  wa_field_cat-do_sum = 'X'.
  APPEND wa_field_cat TO field_cat.
  CLEAR wa_field_cat.


ENDFORM.

FORM set_layout CHANGING layout TYPE slis_layout_alv.

  layout-colwidth_optimize = 'X'.

ENDFORM.


FORM alv_grid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = 'Bounced Checks Reason'
      is_layout          = alv_layout
      it_fieldcat        = alv_field_cat
 "    i_save             = 'X'
 "    it_sort            = t_sort
    TABLES
      t_outtab           = t_reason
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.
