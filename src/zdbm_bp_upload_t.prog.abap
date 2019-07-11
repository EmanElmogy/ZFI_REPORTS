*&---------------------------------------------------------------------*
*& Include          ZDBM_BP_UPL OAD_T
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE TEXT-000.
PARAMETERS : dataset(132).
SELECTION-SCREEN END OF BLOCK b.


DATA :tfile        LIKE rlgrap-filename,
      partner_guid TYPE bu_partner_guid.
DATA: BEGIN OF records OCCURS 0,
        bpcategory   TYPE bapibus1006_head-partn_cat,      "---BP Cateogry
        grouping     TYPE bapibus1006_head-partn_grp,      "---Account Group
        bprole       TYPE bapibus1006_bproles-partnerrole, "---BP Rule
        bp_type      TYPE bapibus1006_head-PARTN_TYP,        "---BP type
        title        TYPE ad_title,                        "---BP Title
        name_first   TYPE bu_namep_f,                      "---Name1 Organization
        name_last    TYPE bu_namep_l,                      "---Name2 Organization
        other_name   TYPE bu_namepl2,                      "---Name3 Organization
        searchterm1	 TYPE	bu_sort1,                        "---Search Term1
        searchterm2	 TYPE	bu_sort2,                        "---Search Term2
        street       TYPE ad_street,                       "---Street
        house        TYPE ad_hsnm1,                        "---House
        city         TYPE ad_city1,                        "---City
        country      TYPE land1,                           "---Country Key
        region       TYPE REGIO,                           "---region
        langu        TYPE laiso,                           "---Language
        tel_number1  TYPE ad_tlnmbr,                       "---Telephone 1
        tel_number2  TYPE ad_tlnmbr,                       "---Telephone 2
        tel_number3  TYPE ad_tlnmbr,                       "---Telephone 3
        mob1         TYPE ad_tlnmbr,                       "---Mobile 1
        mob2         TYPE ad_tlnmbr,                       "---Mobile 2
        mob3         TYPE ad_tlnmbr,                       "---Mobile 3
        fax          TYPE ad_fxnmbr,                       "---Fax Number
        email        TYPE ad_smtpadr,                      "---Email
        legal_form   TYPE bu_legenty,                      "---BP: Legal form of organization
        extern_no	   TYPE	bu_bpext ,                       "---Business Partner Number in External System
        id_type      TYPE	bu_id_category ,                 "--- ID type
        id_number    TYPE	bu_id_number ,                   "--- ID Number
        id_type2     TYPE	bu_id_category ,                 "--- ID type 2
        id_number2   TYPE	bu_id_number ,                   "--- ID Number 2
        industry     TYPE bu_ind_sector,                   "--- Industry
        standred     TYPE char1        ,                   "--- Standred Industry Flag
        c_code_1     TYPE bukrs,                           "---Company Code
        account      TYPE akont,                           "---GL Account
        sort_key     TYPE dzuawa,                          "---Sort Key
        plannig_grp  TYPE fdgrv,                           "---Palnning Group
        fi_terms     TYPE dzterm,                          "---Payment Term
        double_check TYPE reprf,                           "---Double Check
        pay_method   TYPE dzwels,                          "---Payment Method
        witht_1      TYPE witht ,                          "---With Holding tax type 1
        wt_withcd_1  TYPE wt_withcd ,                      "---WHT Code1
        wt_subjct_1  TYPE wt_subjct ,                      "---WHT Subject Indicatior 1
        witht_2      TYPE witht ,                          "---With Holding tax type2
        wt_withcd_2  TYPE wt_withcd ,                      "---WHT Code2
        wt_subjct_2  TYPE wt_subjct ,                      "---WHT Subject Indicatior 2
        pur_org      TYPE ekorg ,                          "---Purchase Organization
        order_curr   TYPE bstwa ,                          "---Order Currency
        pur_term     TYPE dzterm,                          "---Purchase Payment Term
        CERT_ID      TYPE IDSAU_CR_ID,                     "---Certificate ID
        CERT_NO      type IDSAU_CR_NO,                     "---Certification Number
        VALID_FROM   type IDSAU_CR_VALID_FR,               "---Certification Valid From Date
        VALID_TO     type IDSAU_CR_VALID_TO,               "---Certification Valid to Date
        REG_CITY     type IDSAU_CR_REG_CITY,               "---Registration City
        MAIN_CERT    type IDSAU_CR_MAIN,                   "---Main Certificate
        CERT_ID2     TYPE IDSAU_CR_ID,                     "---Certificate ID2
        CERT_NO2     type IDSAU_CR_NO,                     "---Certification Number2
        VALID_FROM2  type IDSAU_CR_VALID_FR,               "---Certification Valid From Date2
        VALID_TO2    type IDSAU_CR_VALID_TO,               "---Certification Valid to Date2
        REG_CITy2    type IDSAU_CR_REG_CITY,               "---Registration City2
        MAIN_CERT2   type IDSAU_CR_MAIN,                   "---Main Certificate2
        SCHEMA       TYPE CHAR2 ,                          "---Schema
        GR_BASED     TYPE CHAR1,                           "---GR Based

      END OF records.
"--- Bapi's Variables
DATA : identification TYPE bapibus1006_identification .
DATA : centraldata             LIKE  bapibus1006_central,
       centraldataperson       LIKE  bapibus1006_central_person,
       centraldataorganization LIKE  bapibus1006_central_organ,
       centraldatagroup        LIKE  bapibus1006_central_group.
DATA: ls_main     TYPE vmds_ei_main,
      lt_vendors  TYPE vmds_ei_extern_t,
      ls_vendors  TYPE vmds_ei_extern,
      ls_head     TYPE vmds_ei_header,
      ls_instance TYPE vmds_instance.

DATA: ls_codata       TYPE vmds_ei_vmd_company,
      lt_company      TYPE vmds_ei_company_t,
      ls_company      TYPE vmds_ei_company,
      ls_wtax         TYPE vmds_ei_wtax_type_s,
      lt_wtax_type    TYPE vmds_ei_wtax_type_t,
      ls_wtax_type    TYPE vmds_ei_wtax_type,
      l_update_errors TYPE cvis_message,
      l_messages      TYPE cvis_message,
      lt_error        TYPE bapiret2_t,
      lw_error        TYPE bapiret2,
      l_it_bdcmsgcoll TYPE TABLE OF bdcmsgcoll,
      l_wa_bdcmsgcoll TYPE bdcmsgcoll,
      l_wa_messages   TYPE bapiret2,
      rec_account     TYPE akont.
DATA : is_purchasing           TYPE vmds_ei_purchasing .
"ADDRESS DATA
DATA : addressdata           LIKE bapibus1006_address,
       addressdata_x         LIKE bapibus1006_address_x,
       it_telefondata        TYPE TABLE OF bapiadtel,
       wa_telefondata        LIKE LINE OF it_telefondata,
       it_faxdata            TYPE TABLE OF bapiadfax,
       wa_faxdata            LIKE LINE OF it_faxdata,
       it_e_maildata         TYPE TABLE OF bapiadsmtp,
       wa_e_maildata         LIKE LINE OF it_e_maildata,
       partnercategory       TYPE  bapibus1006_head-partn_cat,
       businesspartnerextern TYPE  bapibus1006_head-bpartner,
       roles                 LIKE TABLE OF bapibusisb990_bproles  WITH HEADER LINE,
       businesspartner       TYPE  bapibus1006_head-bpartner.
DATA : return1  TYPE TABLE OF bapiret2               WITH HEADER LINE,
       return_t TYPE bapiret2_t,
       return_s TYPE bapiret2.
DATA : wa_return               LIKE LINE OF return1 .
DATA:  partnergroup            TYPE bapibus1006_head-partn_grp.

DATA : t_message               TYPE char200.
DATA : index                   TYPE char10 .
DATA :      IT_INVCRT TYPE TABLE OF  IDSAU_CR_DATA WITH HEADER LINE.
DATA :      IT_DEVCRT TYPE TABLE OF   IDSAU_CR_DATA WITH HEADER LINE .
