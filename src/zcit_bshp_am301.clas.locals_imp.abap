*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type definitions

"═══════════════════════════════════════════════════════════════════
" HANDLER CLASS: lhc_Shipment
"═══════════════════════════════════════════════════════════════════
CLASS lhc_Shipment DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Shipment RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Shipment RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Shipment.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Shipment.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Shipment.

    METHODS read FOR READ
      IMPORTING keys FOR READ Shipment RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Shipment.

   METHODS mark_in_transit FOR MODIFY
  IMPORTING keys FOR ACTION Shipment~mark_in_transit.

METHODS mark_delivered FOR MODIFY
  IMPORTING keys FOR ACTION Shipment~mark_delivered.

METHODS cancel_shipment FOR MODIFY
  IMPORTING keys FOR ACTION Shipment~cancel_shipment.

    METHODS rba_TrackingLog FOR READ
      IMPORTING keys_rba FOR READ Shipment\_trackinglog
      FULL result_requested RESULT result LINK association_links.

    METHODS cba_TrackingLog FOR MODIFY
      IMPORTING entities_cba FOR CREATE Shipment\_trackinglog.

ENDCLASS.

CLASS lhc_Shipment IMPLEMENTATION.

  METHOD get_instance_authorizations. ENDMETHOD.
  METHOD get_global_authorizations.   ENDMETHOD.
  METHOD lock.                        ENDMETHOD.

  METHOD create.
    DATA ls_ship TYPE zcit_shpt_am301.
    LOOP AT entities INTO DATA(ls_ent).
      ls_ship = CORRESPONDING #( ls_ent MAPPING FROM ENTITY ).
      IF ls_ship-shipmentid IS NOT INITIAL.
        SELECT FROM zcit_shpt_am301 FIELDS shipmentid
          WHERE shipmentid = @ls_ship-shipmentid
          INTO TABLE @DATA(lt_check).
        IF sy-subrc NE 0.
          ls_ship-status      = 'PENDING'.
          ls_ship-progresspct = 0.
          DATA(lo_util) = zcit_util_am301=>get_instance( ).
          lo_util->set_ship_value(
            EXPORTING im_ship   = ls_ship
            IMPORTING ex_created = DATA(lv_ok) ).
          IF lv_ok = abap_true.
            APPEND VALUE #( %cid       = ls_ent-%cid
                            shipmentid = ls_ship-shipmentid )
              TO mapped-shipment.
          ENDIF.
        ELSE.
          APPEND VALUE #( %cid       = ls_ent-%cid
                          shipmentid = ls_ship-shipmentid )
            TO failed-shipment.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA ls_ship TYPE zcit_shpt_am301.
    LOOP AT entities INTO DATA(ls_ent).
      ls_ship = CORRESPONDING #( ls_ent MAPPING FROM ENTITY ).
      IF ls_ship-shipmentid IS NOT INITIAL.
        SELECT FROM zcit_shpt_am301 FIELDS shipmentid
          WHERE shipmentid = @ls_ship-shipmentid
          INTO TABLE @DATA(lt_check).
        IF sy-subrc EQ 0.
          DATA(lo_util) = zcit_util_am301=>get_instance( ).
          lo_util->set_ship_value(
            EXPORTING im_ship    = ls_ship
            IMPORTING ex_created = DATA(lv_ok) ).
          IF lv_ok = abap_true.
            APPEND VALUE #( shipmentid = ls_ship-shipmentid )
              TO mapped-shipment.
          ENDIF.
        ELSE.
          APPEND VALUE #( shipmentid = ls_ship-shipmentid )
            TO failed-shipment.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA(lo_util) = zcit_util_am301=>get_instance( ).
    LOOP AT keys INTO DATA(ls_key).
      lo_util->set_ship_del(
        im_key = VALUE #( shipmentid = ls_key-shipmentid ) ).
      lo_util->set_ship_del_flag( im_flag = abap_true ).
      APPEND VALUE #( shipmentid = ls_key-shipmentid )
        TO mapped-shipment.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zcit_shpt_am301 FIELDS *
        WHERE shipmentid = @ls_key-shipmentid
        INTO @DATA(ls_ship).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_ship ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

METHOD mark_in_transit.
  DATA(lo_util) = zcit_util_am301=>get_instance( ).
  LOOP AT keys INTO DATA(ls_key).
    SELECT SINGLE FROM zcit_shpt_am301
      FIELDS *
      WHERE shipmentid = @ls_key-shipmentid
      INTO @DATA(ls_ship).
    IF sy-subrc = 0.
      ls_ship-status      = 'IN_TRANSIT'.
      ls_ship-progresspct = 30.
      lo_util->set_ship_value(
        EXPORTING im_ship    = ls_ship
        IMPORTING ex_created = DATA(lv_ok) ).
    ENDIF.
  ENDLOOP.
ENDMETHOD.

METHOD mark_delivered.
  DATA(lo_util) = zcit_util_am301=>get_instance( ).
  LOOP AT keys INTO DATA(ls_key).
    SELECT SINGLE FROM zcit_shpt_am301
      FIELDS *
      WHERE shipmentid = @ls_key-shipmentid
      INTO @DATA(ls_ship).
    IF sy-subrc = 0.
      ls_ship-status      = 'DELIVERED'.
      ls_ship-progresspct = 100.
      ls_ship-delayflag   = abap_false.
      lo_util->set_ship_value(
        EXPORTING im_ship    = ls_ship
        IMPORTING ex_created = DATA(lv_ok) ).
    ENDIF.
  ENDLOOP.
ENDMETHOD.

METHOD cancel_shipment.
  DATA(lo_util) = zcit_util_am301=>get_instance( ).
  LOOP AT keys INTO DATA(ls_key).
    SELECT SINGLE FROM zcit_shpt_am301
      FIELDS *
      WHERE shipmentid = @ls_key-shipmentid
      INTO @DATA(ls_ship).
    IF sy-subrc = 0.
      ls_ship-status      = 'CANCELLED'.
      ls_ship-progresspct = 0.
      lo_util->set_ship_value(
        EXPORTING im_ship    = ls_ship
        IMPORTING ex_created = DATA(lv_ok) ).
    ENDIF.
  ENDLOOP.
ENDMETHOD.

  METHOD rba_TrackingLog.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT FROM zcit_tlgt_am301 FIELDS *
        WHERE shipmentid = @ls_key-shipmentid
        INTO TABLE @DATA(lt_logs).
      LOOP AT lt_logs INTO DATA(ls_log).
        APPEND CORRESPONDING #( ls_log ) TO result.
        APPEND VALUE #(
          source-shipmentid  = ls_key-shipmentid
          target-shipmentid  = ls_log-shipmentid
          target-logsequence = ls_log-logsequence )
          TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_TrackingLog.
    DATA ls_tlog TYPE zcit_tlgt_am301.
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        ls_tlog = CORRESPONDING #( ls_target MAPPING FROM ENTITY ).
        ls_tlog-shipmentid = ls_cba-shipmentid.
        IF ls_tlog-shipmentid IS NOT INITIAL
        AND ls_tlog-logsequence IS NOT INITIAL.
          SELECT FROM zcit_tlgt_am301 FIELDS logsequence
            WHERE shipmentid  = @ls_tlog-shipmentid
            AND   logsequence = @ls_tlog-logsequence
            INTO TABLE @DATA(lt_chk).
          IF sy-subrc NE 0.
            ls_tlog-logtimestamp = utclong_current( ).
            DATA(lo_util) = zcit_util_am301=>get_instance( ).
            lo_util->set_tlog_value(
              EXPORTING im_tlog    = ls_tlog
              IMPORTING ex_created = DATA(lv_ok) ).
            IF lv_ok = abap_true.
              APPEND VALUE #(
                %cid       = ls_target-%cid
                shipmentid = ls_tlog-shipmentid
                logsequence = ls_tlog-logsequence )
                TO mapped-trackinglog.
            ENDIF.
          ELSE.
            APPEND VALUE #(
              %cid        = ls_target-%cid
              shipmentid  = ls_tlog-shipmentid
              logsequence = ls_tlog-logsequence )
              TO failed-trackinglog.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


"═══════════════════════════════════════════════════════════════════
" SAVER CLASS: lsc_ZCIT_SHPI_AM301
"═══════════════════════════════════════════════════════════════════
CLASS lsc_ZCIT_SHPI_AM301 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save              REDEFINITION.
    METHODS cleanup           REDEFINITION.
    METHODS cleanup_finalize  REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_SHPI_AM301 IMPLEMENTATION.

  METHOD finalize.          ENDMETHOD.
  METHOD check_before_save. ENDMETHOD.
  METHOD cleanup_finalize.  ENDMETHOD.

  METHOD save.
    DATA(lo_util) = zcit_util_am301=>get_instance( ).

    lo_util->get_ship_value( IMPORTING ex_ship = DATA(ls_ship) ).
    lo_util->get_tlog_value( IMPORTING ex_tlog = DATA(ls_tlog) ).
    lo_util->get_ship_del(   IMPORTING ex_keys = DATA(lt_ship_del) ).
    lo_util->get_tlog_del(   IMPORTING ex_keys = DATA(lt_tlog_del) ).
    lo_util->get_del_flags(  IMPORTING ex_ship_del = DATA(lv_ship_del) ).

    " 1. Save / Update Shipment Header
    IF ls_ship IS NOT INITIAL.
      MODIFY zcit_shpt_am301 FROM @ls_ship.
    ENDIF.

    " 2. Save / Update Tracking Log entry
    IF ls_tlog IS NOT INITIAL.
      MODIFY zcit_tlgt_am301 FROM @ls_tlog.
    ENDIF.

    " 3. Handle Deletions
    IF lv_ship_del = abap_true.
      LOOP AT lt_ship_del INTO DATA(ls_del_ship).
        DELETE FROM zcit_shpt_am301 WHERE shipmentid = @ls_del_ship-shipmentid.
        DELETE FROM zcit_tlgt_am301 WHERE shipmentid = @ls_del_ship-shipmentid.
      ENDLOOP.
    ELSE.
      LOOP AT lt_ship_del INTO DATA(ls_del_s).
        DELETE FROM zcit_shpt_am301 WHERE shipmentid = @ls_del_s-shipmentid.
      ENDLOOP.
      LOOP AT lt_tlog_del INTO DATA(ls_del_tlog).
        DELETE FROM zcit_tlgt_am301
          WHERE shipmentid  = @ls_del_tlog-shipmentid
          AND   logsequence = @ls_del_tlog-logsequence.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    zcit_util_am301=>get_instance( )->cleanup_buffer( ).
  ENDMETHOD.

ENDCLASS.
