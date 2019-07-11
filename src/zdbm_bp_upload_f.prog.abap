*&---------------------------------------------------------------------*
*& Include          ZDBM_BP_UPLOAD_ F
*&---------------------------------------------------------------------*

AT SELECTION-SCREEN ON VALUE-REQUEST FOR dataset.
  PERFORM filename_get.

**********************************************************************
**********************************************************************

END-OF-SELECTION.

  tfile = dataset.
  DATA : it_type   TYPE truxs_t_text_data.
*  BREAK msayed .
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    = ''
      i_line_header        = 'X'
      i_tab_raw_data       = it_type
      i_filename           = tfile
    TABLES
      i_tab_converted_data = records[]
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  BREAK msayed .

  IF sy-subrc <> 0 .
    WRITE:/1 'Error In Reading Excel Sheet ...!' COLOR 6.
    ULINE .
  ELSE .
    WRITE:/1 'Finished' COLOR 1.
    ULINE.

    BREAK msayed .
    LOOP AT records.
      index = index + 1 .

      "--- Assign Data From Excel to BAPI
      partnercategory = records-bpcategory .
      partnergroup    = records-grouping .
      roles-partnerrole = records-bprole.

      roles-valid_from = '00010101'.
      roles-valid_to = '99991231'.
      APPEND roles.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = records-title
        IMPORTING
          output = records-title.
      centraldata-title_key = records-title .
      centraldata-partnertype = records-bp_type .
      TRANSLATE centraldata-partnertype TO UPPER CASE.
      centraldataperson-LASTNAME  = records-name_last .
      centraldataperson-firstname  = records-name_first .
*      centraldataorganization-name1 = records-name_first .
*      centraldataorganization-name2 = records-name_last .
*      centraldataorganization-name2 = records-name_last .

*      centraldataorganization-name3 = records-other_name .
      centraldata-searchterm1 = records-searchterm1 .
      centraldata-searchterm2 = records-searchterm2 .
      addressdata-street       = records-street.
      addressdata-house_no     = records-house.
      addressdata-city         = records-city.
      addressdata-country      = records-country.
      addressdata-region       = records-region.
      addressdata-langu       = records-langu.

      "---Telephone
      IF records-tel_number1 IS NOT INITIAL .
        wa_telefondata-telephone = records-tel_number1 .
        wa_telefondata-r_3_user   = '1'.
        APPEND wa_telefondata TO it_telefondata.
      ENDIF.
      IF records-tel_number2 IS NOT INITIAL.
        wa_telefondata-telephone = records-tel_number2 .
        wa_telefondata-r_3_user   = '1'.
        APPEND wa_telefondata TO it_telefondata.
      ENDIF.
      IF records-tel_number3 IS NOT INITIAL .
        wa_telefondata-telephone = records-tel_number3 .
        wa_telefondata-r_3_user   = '1'.
        APPEND wa_telefondata TO it_telefondata.
      ENDIF.

      "---Mobile
      IF records-mob1 IS NOT INITIAL.
        wa_telefondata-telephone = records-mob1 .
        wa_telefondata-r_3_user   = '3'.
        APPEND wa_telefondata TO it_telefondata.
      ENDIF.
      IF  records-mob2 IS NOT INITIAL .
        wa_telefondata-telephone = records-mob2 .
        wa_telefondata-r_3_user   = '3'.
        APPEND wa_telefondata TO it_telefondata.
      ENDIF.
      IF records-mob3 IS NOT INITIAL  .
        wa_telefondata-telephone = records-mob3 .
        wa_telefondata-r_3_user   = '3'.
        APPEND wa_telefondata TO it_telefondata.
      ENDIF.

      "---Fax
      IF records-fax IS  NOT INITIAL .
        wa_faxdata-fax        = records-fax.
        APPEND wa_faxdata TO  it_faxdata .
      ENDIF.

      "---Email
      IF records-email IS NOT INITIAL .
        wa_e_maildata-e_mail = records-email.
        APPEND wa_e_maildata TO it_e_maildata .
      ENDIF.

      centraldataorganization-legalform = records-legal_form .
      centraldata-partnerexternal = records-extern_no .
      SHIFT index LEFT DELETING LEADING ' ' .
      CALL FUNCTION 'BAPI_BUPA_FS_CREATE_FROM_DATA2'
        EXPORTING
          businesspartnerextern   = businesspartnerextern
          partnercategory         = partnercategory
          partnergroup            = partnergroup
          centraldata             = centraldata
          centraldataperson       = centraldataperson
          centraldataorganization = centraldataorganization
          centraldatagroup        = centraldatagroup
          addressdata             = addressdata
          accept_error            = 'X'
        IMPORTING
          businesspartner         = businesspartner
        TABLES
          roles                   = roles
          telefondata             = it_telefondata
          faxdata                 = it_faxdata
          e_maildata              = it_e_maildata
          return                  = return1.
      READ TABLE return1 WITH KEY type = 'E' .
      IF sy-subrc <> 0 .
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        CLEAR : return1[] , return1 .
        IF records-id_type IS NOT INITIAL AND records-id_number IS NOT INITIAL.
          CALL FUNCTION 'BAPI_IDENTIFICATION_ADD'
            EXPORTING
              businesspartner        = businesspartner
              identificationcategory = records-id_type
              identificationnumber   = records-id_number
              identification         = identification
            TABLES
              return                 = return1.
          READ TABLE return1 WITH KEY type = 'E' .
          IF sy-subrc <> 0 .
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ELSE .
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF .
        ENDIF.
        IF records-id_type2 IS NOT INITIAL AND records-id_number2 IS NOT INITIAL.
          CALL FUNCTION 'BAPI_IDENTIFICATION_ADD'
            EXPORTING
              businesspartner        = businesspartner
              identificationcategory = records-id_type2
              identificationnumber   = records-id_number2
              identification         = identification
            TABLES
              return                 = return1.
          READ TABLE return1 WITH KEY type = 'E' .
          IF sy-subrc <> 0 .
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ELSE .
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF .
        ENDIF .
        CLEAR : return1[] , return1 .

        CALL FUNCTION 'BAPI_INDUSTRYSECTOR_ADD'
          EXPORTING
            businesspartner         = businesspartner
            industrysectorkeysystem = 'Z001'
            industrysector          = records-industry
            defaultindustry         = records-standred
          TABLES
            return                  = return1.
        READ TABLE return1 WITH KEY type = 'E' .
        IF sy-subrc <> 0 .
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ELSE .
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF .
        IF records-cert_id IS NOT INITIAL AND records-cert_no IS NOT INITIAL AND records-valid_from IS NOT INITIAL
         AND records-valid_to IS NOT INITIAL  AND records-reg_city IS NOT INITIAL.
          TRANSLATE records-cert_id TO UPPER CASE .
          it_invcrt-lifnr = businesspartner .
          it_invcrt-bukrs = records-c_code_1 .
          it_invcrt-cert_id = records-cert_id .
          it_invcrt-cert_no = records-cert_no .
          it_invcrt-valid_from = records-valid_from.
          it_invcrt-valid_to = records-valid_to.
          it_invcrt-reg_city = records-reg_city.
          it_invcrt-main_cert = records-main_cert.
          APPEND it_invcrt.
        ENDIF.
        IF records-cert_id2 IS NOT INITIAL AND records-cert_no2 IS NOT INITIAL AND records-valid_from2 IS NOT INITIAL
          AND records-valid_to2 IS NOT INITIAL  AND records-reg_city2 IS NOT INITIAL.
          TRANSLATE records-cert_id2 TO UPPER CASE .
          it_invcrt-lifnr   = businesspartner .
          it_invcrt-bukrs   = records-c_code_1 .
          it_invcrt-cert_id = records-cert_id2 .
          it_invcrt-cert_no = records-cert_no2 .
          it_invcrt-valid_from = records-valid_from2.
          it_invcrt-valid_to = records-valid_to2.
          it_invcrt-reg_city = records-reg_city2.
          it_invcrt-main_cert = records-main_cert2.
          APPEND it_invcrt.
        ENDIF.
        IF it_invcrt[] IS NOT INITIAL.
          CALL FUNCTION 'IDSAU_CR_SAVE'
            TABLES
              it_invcrt = it_invcrt
              it_devcrt = it_devcrt.
        ENDIF.


        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = records-account
          IMPORTING
            output = records-account.

        IF records-witht_1 IS NOT INITIAL .
          ls_wtax_type-data_key-witht = records-witht_1  . "  give WHT type
          ls_wtax_type-data-wt_withcd =  records-wt_withcd_1 .  "  give WHT code
          ls_wtax_type-task = 'I'.
          ls_wtax_type-data-wt_subjct = records-wt_subjct_1.
          ls_wtax_type-datax-wt_subjct = records-wt_subjct_1.
          ls_wtax_type-datax-qsrec     = 'X'.
          ls_wtax_type-datax-wt_withcd = 'X'.
          APPEND ls_wtax_type TO lt_wtax_type.
          CLEAR: ls_wtax_type.
        ENDIF.


        IF records-witht_2 IS NOT INITIAL .
          ls_wtax_type-task = 'I'.
          ls_wtax_type-data-wt_subjct = records-wt_subjct_2.
          ls_wtax_type-datax-wt_subjct = records-wt_subjct_2.
          ls_wtax_type-data_key-witht = records-witht_2  . "  give WHT type
          ls_wtax_type-data-wt_withcd =  records-wt_withcd_2 .  "  give WHT code
          ls_wtax_type-datax-qsrec     = 'X'.
          ls_wtax_type-datax-wt_withcd = 'X'.
          APPEND ls_wtax_type TO lt_wtax_type.
          CLEAR: ls_wtax_type.
        ENDIF .
        ls_wtax-wtax_type = lt_wtax_type.
        IF records-c_code_1 IS NOT INITIAL .
          ls_company-data_key-bukrs    = records-c_code_1.
          ls_company-data-akont        = records-account.
          ls_company-data-zuawa        = records-sort_key.
          ls_company-data-fdgrv        = records-plannig_grp .
          ls_company-data-zterm        = records-fi_terms .
          ls_company-data-reprf        = records-double_check .
          ls_company-data-zwels        = records-pay_method .
          ls_company-wtax_type         = ls_wtax.
          ls_company-task              = 'I' .
          APPEND ls_company TO lt_company.
          CLEAR: ls_company.
        ENDIF.

        is_purchasing-task = 'I'.
        is_purchasing-data_key-ekorg = records-pur_org.
        is_purchasing-data-waers = records-order_curr.
        is_purchasing-datax-waers = 'X'.
        is_purchasing-data-zterm = records-pur_term.
        is_purchasing-datax-zterm = 'X'.
        is_purchasing-data-webre = records-gr_based.
        is_purchasing-datax-webre = 'X'.
        is_purchasing-data-kalsk = records-schema.
        is_purchasing-datax-kalsk = 'X'.
*       is_purchasing-data-VERKF = records-Sales_PER.
*       is_purchasing-datax-VERKF = 'X'.
*       is_purchasing-data-TELF1 = records-Sales_TELE.
*       is_purchasing-datax-TELF1 = 'X'.
        ls_instance-lifnr = businesspartner .  "  give vendor code
        ls_codata-company            = lt_company.
        ls_head-object_instance      = ls_instance.
        ls_head-object_task          = 'U'.
        ls_vendors-header            = ls_head.
        ls_vendors-company_data      = ls_codata.
        APPEND is_purchasing TO ls_vendors-purchasing_data-purchasing .
        APPEND ls_vendors TO lt_vendors.
        CLEAR: ls_instance,ls_head,ls_codata.


        ls_main-vendors = lt_vendors.
        WAIT UP TO 1 SECONDS .
        vmd_ei_api=>initialize( ).
        SET UPDATE TASK LOCAL.
        vmd_ei_api=>maintain_bapi(
        EXPORTING
          iv_test_run    = ''
          is_master_data = ls_main
        IMPORTING
          es_message_correct  =  l_messages
          es_message_defective = l_update_errors  ).
        IF l_update_errors-is_error IS INITIAL.

          COMMIT WORK.

        ELSE .

          REFRESH return_t .
          CLEAR return_t .
          return_t = l_update_errors-messages.

          LOOP AT return_t INTO return_s WHERE type = 'E'.

            wa_return-type = return_s-type .
            wa_return-message = return_s-message .
            APPEND wa_return TO return1 .
            CLEAR wa_return .
          ENDLOOP.

        ENDIF.
        IF  l_update_errors-is_error IS NOT INITIAL.
          CONCATENATE 'Line'index'- Business Partner'  '=>' businesspartner 'Created,But There is an error for create company data Or Purchase Data..!'  INTO t_message SEPARATED BY space.
          WRITE:/1 t_message COLOR 3 .
        ELSE .
          CONCATENATE 'Line'index'- Business Partner'  '=>' businesspartner 'Created Successfully ...' INTO t_message SEPARATED BY space.
          WRITE:/1 t_message COLOR 5 .
        ENDIF.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        CONCATENATE 'Error In Line' index ',Please Check Data in Excel Sheet.....' INTO t_message SEPARATED BY space.
        WRITE:/1 t_message COLOR 6 .
      ENDIF.
      CLEAR : businesspartner ,  businesspartnerextern , partnercategory , partnergroup , centraldata , centraldataperson , centraldataorganization , centraldatagroup , addressdata ,
              roles[] , roles , it_telefondata[] , wa_telefondata , it_faxdata , wa_faxdata , it_e_maildata , wa_e_maildata , return1[] , ls_main-vendors,
              is_purchasing , ls_vendors-purchasing_data-purchasing  , lt_company , ls_company , ls_wtax_type , lt_wtax_type , lt_vendors.
    ENDLOOP .
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM filename_get .
  DATA: filerc         TYPE i,
        filename_tab   TYPE filetable,
        filename       TYPE file_table,
        fileaction     TYPE i,
        window_title   TYPE string,
        my_file_filter TYPE string.

  window_title = TEXT-005.

  CLASS cl_gui_frontend_services DEFINITION LOAD.
*  concatenate cl_gui_frontend_services=>filetype_all
*              into my_file_filter.
  my_file_filter = 'All files(*.*)|*.*'(084).
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = window_title
      file_filter             = my_file_filter
    CHANGING
      file_table              = filename_tab
      rc                      = filerc
      user_action             = fileaction
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4.


  IF fileaction EQ cl_gui_frontend_services=>action_ok.
    CHECK NOT filename_tab IS INITIAL.
    READ TABLE filename_tab INTO filename INDEX 1.
    MOVE filename-filename TO dataset.
  ENDIF.
ENDFORM.
