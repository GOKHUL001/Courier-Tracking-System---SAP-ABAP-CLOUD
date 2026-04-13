CLASS zcit_util_am301 DEFINITION
  PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_ship_key,
        shipmentid TYPE zcit_shid_am301,
      END OF ty_ship_key,
      BEGIN OF ty_tlog_key,
        shipmentid  TYPE zcit_shid_am301,
        logsequence TYPE int4,
      END OF ty_tlog_key.
    TYPES:
      tt_ship_key TYPE STANDARD TABLE OF ty_ship_key,
      tt_tlog_key TYPE STANDARD TABLE OF ty_tlog_key.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcit_util_am301.

    METHODS:
      set_ship_value  IMPORTING im_ship TYPE zcit_shpt_am301
                      EXPORTING ex_created TYPE abap_boolean,
      get_ship_value  EXPORTING ex_ship TYPE zcit_shpt_am301,
      set_tlog_value  IMPORTING im_tlog TYPE zcit_tlgt_am301
                      EXPORTING ex_created TYPE abap_boolean,
      get_tlog_value  EXPORTING ex_tlog TYPE zcit_tlgt_am301,
      set_ship_del    IMPORTING im_key TYPE ty_ship_key,
      set_tlog_del    IMPORTING im_key TYPE ty_tlog_key,
      get_ship_del    EXPORTING ex_keys TYPE tt_ship_key,
      get_tlog_del    EXPORTING ex_keys TYPE tt_tlog_key,
      set_ship_del_flag IMPORTING im_flag TYPE abap_boolean,
      get_del_flags   EXPORTING ex_ship_del TYPE abap_boolean,
      cleanup_buffer.

  PRIVATE SECTION.
    CLASS-DATA: gs_ship   TYPE zcit_shpt_am301,
                gs_tlog   TYPE zcit_tlgt_am301,
                gt_ship_del TYPE tt_ship_key,
                gt_tlog_del TYPE tt_tlog_key,
                gv_ship_del TYPE abap_boolean.
    CLASS-DATA mo_instance TYPE REF TO zcit_util_am301.
ENDCLASS.

CLASS zcit_util_am301 IMPLEMENTATION.
  METHOD get_instance.
    IF mo_instance IS INITIAL.
      CREATE OBJECT mo_instance.
    ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.

  METHOD set_ship_value.
    IF im_ship-shipmentid IS NOT INITIAL.
      gs_ship = im_ship.  ex_created = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_ship_value.  ex_ship = gs_ship.  ENDMETHOD.

  METHOD set_tlog_value.
    IF im_tlog IS NOT INITIAL.
      gs_tlog = im_tlog.  ex_created = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_tlog_value.  ex_tlog = gs_tlog.  ENDMETHOD.

  METHOD set_ship_del.  APPEND im_key TO gt_ship_del.  ENDMETHOD.
  METHOD set_tlog_del.  APPEND im_key TO gt_tlog_del.  ENDMETHOD.
  METHOD get_ship_del.  ex_keys = gt_ship_del.  ENDMETHOD.
  METHOD get_tlog_del.  ex_keys = gt_tlog_del.  ENDMETHOD.

  METHOD set_ship_del_flag.  gv_ship_del = im_flag.  ENDMETHOD.
  METHOD get_del_flags.      ex_ship_del = gv_ship_del.  ENDMETHOD.

  METHOD cleanup_buffer.
    CLEAR: gs_ship, gs_tlog, gt_ship_del, gt_tlog_del, gv_ship_del.
  ENDMETHOD.
ENDCLASS.
